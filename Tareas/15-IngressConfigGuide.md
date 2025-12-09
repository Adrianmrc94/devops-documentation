# Guía Completa: Configurar Ingress en Kubernetes con Minikube y WSL2

## 📋 Contexto
Esta guía documenta cómo configurar un Ingress en Kubernetes usando Minikube en WSL2, con una URL personalizada accesible desde Windows sin necesidad de especificar puerto.

## 🎯 Objetivo Final
Acceder a tu aplicación Angular mediante una URL personalizada (ej: `http://mi-app.local`) sin puerto, desde el navegador de Windows.

---

## 📚 Conceptos Clave

### ¿Qué es un Ingress?
- **Ingress**: Recurso de Kubernetes que gestiona el acceso externo a servicios HTTP/HTTPS
- **Ingress Controller**: Implementación real que hace funcionar el Ingress (ej: NGINX)
- **Service**: Punto de entrada interno a los pods
- **Pod**: Contenedor donde corre tu aplicación

### Flujo de tráfico
```
Navegador → Nginx (puerto 80) → kubectl port-forward (8081) → Ingress Controller → Service → Pod
```

---

## 🛠️ Prerequisitos

- WSL2 con Ubuntu
- Minikube instalado y corriendo
- kubectl configurado
- Helm instalado
- Tu aplicación desplegada en Kubernetes

---

## 📝 Paso a Paso

### 1. Instalar el Ingress Controller en Minikube

```bash
# Habilitar el addon de ingress
minikube addons enable ingress

# Verificar instalación (espera ~60 segundos)
kubectl get pods -n ingress-nginx

# Deberías ver:
# ingress-nginx-controller-xxxxx   1/1     Running
```

### 2. Configurar el Helm Chart

#### 2.1. Editar `helm/values.yaml`

```yaml
replicaCount: 1

image:
  repository: host.docker.internal:5000/petclinic-angular
  tag: latest
  pullPolicy: Always

service:
  name: spring-petclinic-angular-service  # Nombre de tu servicio existente
  type: ClusterIP
  port: 80

# CONFIGURACIÓN INGRESS
ingressEnable: true
namespace: default
host: "mi-dominio.local"  # ← Cambia esto a tu dominio deseado

ingressClass: "nginx"
ingressTLS: false

rules:
  - http:
      paths:
        - path: /
          pathType: Prefix
          port: 80

env:
  - name: ENVIRONMENT
    value: development
  - name: API_URL
    value: http://backend-service:8080
```

#### 2.2. Crear template de Ingress `chart/templates/ingress.yaml`

```yaml
{{- if .Values.ingressEnable }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Release.Name }}-ingress
  namespace: {{ .Values.namespace | default "default" }}
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: {{ .Values.ingressClass | default "nginx" | quote }}
  rules:
    - host: {{ .Values.host | quote }}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: {{ .Values.service.name }}
                port:
                  number: {{ .Values.service.port }}
{{- end }}
```

#### 2.3. Desplegar con Helm

```bash
helm upgrade --install spring-petclinic-angular ./chart -f helm/values.yaml

# Verificar que el Ingress se creó
kubectl get ingress
```

### 3. Problema: WSL2 no puede alcanzar la red de Minikube

**El error común:**
- `ping 192.168.49.2` → 100% packet loss
- `minikube tunnel` → Problemas de permisos con puerto 80

**Solución:** Usar nginx como proxy local + kubectl port-forward

### 4. Configurar Nginx como Proxy Local

#### 4.1. Instalar nginx en WSL

```bash
sudo apt update
sudo apt install nginx
```

#### 4.2. Crear configuración del proxy

```bash
sudo tee /etc/nginx/sites-available/angular-proxy <<EOF
server {
    listen 80;
    server_name mi-dominio.local;  # ← Cambiar al dominio deseado
    
    location / {
        proxy_pass http://127.0.0.1:8081;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF
```

#### 4.3. Activar configuración

```bash
# Desactivar sitio por defecto
sudo rm /etc/nginx/sites-enabled/default

# Activar configuración del proxy
sudo ln -sf /etc/nginx/sites-available/angular-proxy /etc/nginx/sites-enabled/

# Verificar configuración
sudo nginx -t

# Recargar nginx
sudo systemctl reload nginx

# Verificar estado
sudo systemctl status nginx
```

### 5. Configurar el archivo hosts de Windows

**Importante:** El `/etc/hosts` de WSL NO afecta a Windows. Debes editar el de Windows.

#### 5.1. Abrir hosts de Windows

1. Abrir Notepad como **Administrador**
2. Archivo → Abrir → `C:\Windows\System32\drivers\etc\hosts`
3. Agregar línea:

```
127.0.0.1    mi-dominio.local
```

4. Guardar

### 6. Iniciar el Port-Forward

```bash
# En una terminal de WSL (mantener abierta)
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80

# Deberías ver:
# Forwarding from 127.0.0.1:8081 -> 80
# Forwarding from [::1]:8081 -> 80
```

### 7. ¡Probar!

Abre Chrome en Windows y ve a:
```
http://mi-dominio.local
```

**Sin puerto** 🎉

---

## 🔧 Cambiar el Dominio

Para usar un dominio diferente:

1. **Editar `helm/values.yaml`:**
   ```yaml
   host: "nuevo-dominio.local"
   ```

2. **Aplicar cambios:**
   ```bash
   helm upgrade spring-petclinic-angular ./chart -f helm/values.yaml
   ```

3. **Actualizar configuración de nginx:**
   ```bash
   sudo tee /etc/nginx/sites-available/angular-proxy <<EOF
   server {
       listen 80;
       server_name nuevo-dominio.local;
       
       location / {
           proxy_pass http://127.0.0.1:8081;
           proxy_set_header Host \$host;
           proxy_set_header X-Real-IP \$remote_addr;
       }
   }
   EOF
   
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Actualizar hosts de Windows:**
   ```
   127.0.0.1    nuevo-dominio.local
   ```

5. **Reiniciar port-forward:**
   ```bash
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80
   ```

---

## 🐛 Troubleshooting

### El navegador muestra "nginx default page"

**Causa:** Nginx está mostrando su página por defecto

**Solución:**
```bash
sudo rm /etc/nginx/sites-enabled/default
sudo systemctl reload nginx
```

### Error: "Unable to listen on port 80: permission denied"

**Causa:** El puerto 80 requiere permisos de root

**Solución:** Por eso usamos nginx (que corre con sudo) + port-forward en puerto 8081

### El dominio no resuelve en Windows

**Causa:** El archivo hosts de Windows no está configurado correctamente

**Solución:** 
- Verifica que el archivo `C:\Windows\System32\drivers\etc\hosts` contiene:
  ```
  127.0.0.1    tu-dominio.local
  ```
- Abre Chrome en modo incógnito para evitar caché DNS

### El port-forward se detiene

**Causa:** La terminal se cierra o pierdes conexión

**Solución:** Mantén la terminal abierta o usa `screen`/`tmux`:
```bash
# Instalar tmux
sudo apt install tmux

# Crear sesión
tmux new -s portforward

# Ejecutar port-forward
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80

# Desconectar (Ctrl+B, luego D)
# Reconectar: tmux attach -t portforward
```

### Verificar que todo está corriendo

```bash
# 1. Pods de la aplicación
kubectl get pods

# 2. Servicio
kubectl get services

# 3. Ingress
kubectl get ingress

# 4. Ingress Controller
kubectl get pods -n ingress-nginx

# 5. Nginx local
sudo systemctl status nginx

# 6. Puerto 8081 escuchando
sudo netstat -tulpn | grep 8081
```

---

## 📊 Arquitectura Final

```
┌─────────────────────────────────────────────────────────────┐
│                        Windows                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Chrome: http://mi-dominio.local                      │  │
│  │  (hosts: 127.0.0.1 → mi-dominio.local)               │  │
│  └──────────────────┬───────────────────────────────────┘  │
│                     │ HTTP :80                              │
└─────────────────────┼───────────────────────────────────────┘
                      │
┌─────────────────────┼───────────────────────────────────────┐
│                    WSL2                                      │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  Nginx (puerto 80)                                  │    │
│  │  server_name: mi-dominio.local                      │    │
│  │  proxy_pass: http://127.0.0.1:8081                 │    │
│  └─────────────────┬──────────────────────────────────┘    │
│                    │                                         │
│  ┌─────────────────▼──────────────────────────────────┐    │
│  │  kubectl port-forward                               │    │
│  │  127.0.0.1:8081 → Ingress Controller:80            │    │
│  └─────────────────┬──────────────────────────────────┘    │
└────────────────────┼──────────────────────────────────────┘
                     │
┌────────────────────┼──────────────────────────────────────┐
│                 Minikube                                    │
│  ┌──────────────────▼─────────────────────────────────┐   │
│  │  Ingress Controller (nginx-ingress)                 │   │
│  │  Regla: mi-dominio.local → service:80              │   │
│  └──────────────────┬─────────────────────────────────┘   │
│                     │                                       │
│  ┌──────────────────▼─────────────────────────────────┐   │
│  │  Service: spring-petclinic-angular-service          │   │
│  │  ClusterIP:80 → Pod:80                             │   │
│  └──────────────────┬─────────────────────────────────┘   │
│                     │                                       │
│  ┌──────────────────▼─────────────────────────────────┐   │
│  │  Pod: Angular App                                   │   │
│  │  Container: nginx:stable con app Angular           │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 Para Entrevistas

**Puntos clave para mencionar:**

1. **Ingress vs Service:**
   - Service: Exposición interna dentro del cluster
   - Ingress: Exposición externa con routing basado en dominio/path

2. **Ingress Controller:**
   - Necesitas tanto el recurso Ingress como el Controller
   - NGINX es el más común

3. **Diferencias entre entornos:**
   - **Producción (Cloud):** LoadBalancer funciona automáticamente
   - **Local (Minikube):** Necesitas soluciones alternativas (tunnel, port-forward, proxy)

4. **Networking en WSL2:**
   - WSL2 usa una red virtual separada de Windows
   - Por eso necesitamos proxy/port-forward para comunicación

5. **Helm Charts:**
   - Separan configuración (values.yaml) de templates
   - Facilitan despliegues reproducibles

---

## 🚀 Automatización

### 📋 Scripts Necesarios

#### 1. Script de Inicialización Diaria (Ya existe)

**Ubicación:** `~/scripts/setup-registry-k8s-fixed-v4.sh`  
**Cuándo ejecutar:** Cada vez que inicias Docker Desktop/WSL  
**Tiempo:** ~2-3 minutos  

```bash
cd ~/scripts
./setup-registry-k8s-fixed-v4.sh
```

---

#### 2. Script para Angular con Ingress (NUEVO)

**Crear archivo:** `~/scripts/start-angular-ingress.sh`

```bash
#!/bin/bash

# ============================================
# Script para iniciar Angular con Ingress
# Ejecutar DESPUÉS de setup-registry-k8s
# ============================================

set -e

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_status() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

echo ""
echo "🚀 Iniciando Aplicación Angular con Ingress"
echo "=============================================="
echo ""

# 1. Verificar Minikube
print_status "Verificando Minikube..."
if ! minikube status | grep -q "Running"; then
    print_error "Minikube no está corriendo"
    echo "   Ejecuta primero: cd ~/scripts && ./setup-registry-k8s-fixed-v4.sh"
    exit 1
fi
print_success "Minikube está corriendo"

# 2. Verificar Ingress Controller
print_status "Verificando Ingress Controller..."
if ! kubectl get pods -n ingress-nginx | grep -q "ingress-nginx-controller.*Running"; then
    print_warning "Habilitando addon de ingress..."
    minikube addons enable ingress
    print_status "Esperando 60 segundos para que inicie..."
    sleep 60
fi
print_success "Ingress Controller está corriendo"

# 3. Iniciar nginx local
print_status "Verificando nginx local..."
if ! systemctl is-active --quiet nginx; then
    print_status "Iniciando nginx..."
    sudo systemctl start nginx
fi
print_success "Nginx está activo"

# 4. Verificar configuración de nginx
if [ ! -f /etc/nginx/sites-enabled/angular-proxy ]; then
    print_error "Configuración de nginx no encontrada"
    echo "   Crea el archivo: /etc/nginx/sites-available/angular-proxy"
    exit 1
fi

# 5. Matar port-forward previo si existe
print_status "Limpiando port-forward anteriores..."
pkill -f "kubectl port-forward.*8081:80" 2>/dev/null || true
sleep 2

# 6. Iniciar port-forward en background
print_status "Iniciando port-forward..."
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8081:80 > /tmp/port-forward.log 2>&1 &
PF_PID=$!
echo $PF_PID > /tmp/port-forward.pid
sleep 3

# 7. Verificar que el port-forward está corriendo
if ! ps -p $PF_PID > /dev/null; then
    print_error "Port-forward falló al iniciar"
    cat /tmp/port-forward.log
    exit 1
fi
print_success "Port-forward iniciado (PID: $PF_PID)"

# 8. Verificar puerto 8081
if ! netstat -tuln | grep -q ":8081"; then
    print_error "Puerto 8081 no está escuchando"
    exit 1
fi
print_success "Puerto 8081 escuchando"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Sistema listo para acceder a la aplicación"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 URL de acceso:"
echo "   http://prueba.local.angular"
echo ""
echo "🔍 Verificar ingress:"
echo "   kubectl get ingress"
echo ""
echo "📊 Ver logs del port-forward:"
echo "   tail -f /tmp/port-forward.log"
echo ""
echo "🛑 Para detener el port-forward:"
echo "   kill $PF_PID"
echo "   # O ejecuta: pkill -f 'kubectl port-forward.*8081:80'"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

**Crear y dar permisos:**
```bash
nano ~/scripts/start-angular-ingress.sh
# Pegar el contenido anterior
chmod +x ~/scripts/start-angular-ingress.sh
```

**Ejecutar:**
```bash
~/scripts/start-angular-ingress.sh
```

---

#### 3. Script para Detener (NUEVO)

**Crear archivo:** `~/scripts/stop-angular-ingress.sh`

```bash
#!/bin/bash

echo "🛑 Deteniendo port-forward..."

if [ -f /tmp/port-forward.pid ]; then
    PID=$(cat /tmp/port-forward.pid)
    if ps -p $PID > /dev/null; then
        kill $PID
        echo "✓ Port-forward detenido (PID: $PID)"
    else
        echo "⚠ Proceso ya no existe"
    fi
    rm /tmp/port-forward.pid
else
    echo "⚠ Archivo PID no encontrado, intentando detener todos..."
    pkill -f "kubectl port-forward.*8081:80"
fi

echo "✓ Listo"
```

**Dar permisos:**
```bash
chmod +x ~/scripts/stop-angular-ingress.sh
```

---

### 📝 Orden de Ejecución

**Cada día al iniciar Docker:**

```bash
# 1. Levantar entorno completo (Minikube, redes, secrets)
cd ~/scripts
./setup-registry-k8s-fixed-v4.sh

# 2. Desplegar aplicación con Helm (si no está desplegada)
cd ~/tmp-forks/spring-petclinic-angular
helm upgrade --install spring-petclinic-angular ./chart -f helm/values.yaml

# 3. Iniciar servicios para acceso con Ingress
~/scripts/start-angular-ingress.sh

# 4. Abrir navegador en Windows
# http://prueba.local.angular
```

**Para detener al final del día:**

```bash
~/scripts/stop-angular-ingress.sh
```

---

## 📖 Resumen de Comandos Útiles

```bash
# Ver estado del Ingress
kubectl get ingress
kubectl describe ingress spring-petclinic-angular-ingress

# Ver logs del Ingress Controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Ver estado de nginx local
sudo systemctl status nginx
sudo nginx -t  # Verificar configuración

# Recargar nginx después de cambios
sudo systemctl reload nginx

# Ver qué está usando un puerto
sudo netstat -tulpn | grep :80

# Ver pods y servicios
kubectl get pods,services

# Actualizar Helm chart
helm upgrade spring-petclinic-angular ./chart -f helm/values.yaml

# Ver releases de Helm
helm list
```

---

## ✅ Checklist Final

Antes de considerar que funciona correctamente:

- [ ] Ingress Controller corriendo en Minikube
- [ ] Ingress creado y apuntando al servicio correcto
- [ ] Nginx instalado y configurado en WSL
- [ ] Sitio por defecto de nginx desactivado
- [ ] Hosts de Windows configurado con el dominio
- [ ] Port-forward corriendo en puerto 8081
- [ ] Aplicación accesible desde Chrome sin puerto

---

## 🎓 Conclusión

Esta configuración es específica para **desarrollo local** con Minikube en WSL2. En producción con Kubernetes en la nube (EKS, GKE, AKS), el Ingress funcionará directamente con un LoadBalancer externo, sin necesidad de nginx local ni port-forward.

**Lo importante:** Has aprendido cómo funciona Ingress, cómo debuggear problemas de networking, y cómo crear una solución práctica para desarrollo local.

---

¡Éxito con tus entrevistas de DevOps! 🚀
