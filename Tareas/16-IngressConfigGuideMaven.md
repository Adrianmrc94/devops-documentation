# Guía Completa: Configurar Ingress para Maven (Spring Boot) en Kubernetes

## 📋 Contexto
Esta guía documenta cómo configurar un Ingress para la API REST de Spring Boot (Maven) usando Minikube en WSL2, con acceso desde Windows sin especificar puerto.

## 🎯 Objetivo Final
Acceder a tu API Spring Boot mediante `http://prueba.local.maven/petclinic/api/owners` sin puerto, desde el navegador de Windows.

**Nota:** La aplicación Spring Boot requiere el prefijo `/petclinic` en todas las URLs.

---

## 📚 Conceptos Clave

### Aplicación Maven (Spring Boot)
- **Puerto interno:** 9966
- **Servicio K8s:** `petclinic-maven-service`
- **Deployment:** `petclinic-maven`
- **Imagen:** `host.docker.internal:5000/petclinic-maven:latest`

### Flujo de tráfico
```
Navegador → Nginx (puerto 80) → kubectl port-forward (8082) → Ingress Controller → Service (9966) → Pod
```

---

## 🛠️ Prerequisitos

- Ingress Controller ya instalado (compartido con Angular)
- Aplicación Maven desplegada en Kubernetes
- Nginx ya instalado en WSL
- Puerto 8082 libre para port-forward

---

## 📝 Paso a Paso

### 1. Crear Ingress para Maven

#### 1.1. Crear archivo `k8s-ingress-maven.yaml`

**Ubicación:** `~/tmp-forks/spring-petclinic-rest/k8s-ingress-maven.yaml`

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: petclinic-maven-ingress
  namespace: default
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  ingressClassName: nginx
  rules:
    - host: prueba.local.maven
      http:
        paths:
          - path: /petclinic
            pathType: Prefix
            backend:
              service:
                name: petclinic-maven-service
                port:
                  number: 9966
```

#### 1.2. Aplicar Ingress

```bash
cd ~/tmp-forks/spring-petclinic-rest
kubectl apply -f k8s-ingress-maven.yaml

# Verificar
kubectl get ingress
```

**Deberías ver:**
```
NAME                      CLASS   HOSTS                  ADDRESS        PORTS   AGE
petclinic-maven-ingress   nginx   prueba.local.maven     192.168.49.2   80      5s
```

---

### 2. Configurar Nginx como Proxy Local

#### 2.1. Crear configuración del proxy para Maven

```bash
sudo tee /etc/nginx/sites-available/maven-proxy <<EOF
server {
    listen 80;
    server_name prueba.local.maven;
    
    location / {
        proxy_pass http://127.0.0.1:8082;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF
```

#### 2.2. Activar configuración

```bash
# Activar configuración del proxy Maven
sudo ln -sf /etc/nginx/sites-available/maven-proxy /etc/nginx/sites-enabled/

# Verificar que ambas configuraciones están activas
ls -la /etc/nginx/sites-enabled/

# Deberías ver:
# angular-proxy -> /etc/nginx/sites-available/angular-proxy
# maven-proxy -> /etc/nginx/sites-available/maven-proxy

# Verificar sintaxis
sudo nginx -t

# Recargar nginx
sudo systemctl reload nginx
```

---

### 3. Configurar archivo hosts de Windows

**Editar:** `C:\Windows\System32\drivers\etc\hosts` (como Administrador)

**Agregar línea:**
```
127.0.0.1    prueba.local.maven
```

**Archivo completo debería verse así:**
```
127.0.0.1    prueba.local.angular
127.0.0.1    prueba.local.maven
```

---

### 4. Iniciar Port-Forward para Maven

```bash
# En una terminal de WSL (mantener abierta)
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8082:80

# Deberías ver:
# Forwarding from 127.0.0.1:8082 -> 80
# Forwarding from [::1]:8082 -> 80
```

**Importante:** Necesitas mantener 2 terminales con port-forward:
- Terminal 1: `kubectl port-forward ... 8081:80` (para Angular)
- Terminal 2: `kubectl port-forward ... 8082:80` (para Maven)

---

### 5. ¡Probar!

Abre Chrome en Windows y ve a:
```
http://prueba.local.maven/petclinic/api/owners
```

Deberías ver un JSON con los owners. Ejemplo:
```json
[{"firstName":"Test","lastName":"Owner","address":"123 Test St","city":"TestCity","telephone":"1234567890","id":1,"pets":[]}]
```

**Otros endpoints para probar:**
- `http://prueba.local.maven/petclinic/api/vets`
- `http://prueba.local.maven/petclinic/api/pettypes`
- `http://prueba.local.maven/petclinic/actuator/health`

---

## 🚀 Automatización con Scripts

### Script para Iniciar Maven Ingress

**Crear:** `~/scripts/daily/4-start-maven.sh`

```bash
#!/bin/bash

# ============================================
# Script para iniciar Maven API con Ingress
# Ejecutar DESPUÉS de 1-setup-devops.sh
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
echo "🚀 Iniciando API Maven con Ingress"
echo "===================================="
echo ""

# 1. Verificar Minikube
print_status "Verificando Minikube..."
if ! minikube status | grep -q "Running"; then
    print_error "Minikube no está corriendo"
    echo "   Ejecuta primero: cd ~/scripts/daily && ./1-setup-devops.sh"
    exit 1
fi
print_success "Minikube está corriendo"

# 2. Verificar Ingress Controller
print_status "Verificando Ingress Controller..."
if ! kubectl get pods -n ingress-nginx | grep -q "ingress-nginx-controller.*Running"; then
    print_error "Ingress Controller no está corriendo"
    echo "   El script 2-start-angular.sh debería haberlo iniciado"
    exit 1
fi
print_success "Ingress Controller está corriendo"

# 3. Verificar que la app Maven está desplegada
print_status "Verificando deployment de Maven..."
if ! kubectl get deployment petclinic-maven &>/dev/null; then
    print_warning "Deployment no encontrado, aplicando YAML..."
    kubectl apply -f ~/tmp-forks/spring-petclinic-rest/k8s-deployment-maven.yaml
    sleep 10
fi
print_success "Deployment de Maven existe"

# 4. Verificar que el Ingress existe
print_status "Verificando Ingress para Maven..."
if ! kubectl get ingress petclinic-maven-ingress &>/dev/null; then
    print_warning "Ingress no encontrado, aplicando..."
    kubectl apply -f ~/tmp-forks/spring-petclinic-rest/k8s-ingress-maven.yaml
    sleep 5
fi
print_success "Ingress de Maven configurado"

# 5. Verificar nginx local
print_status "Verificando configuración de nginx..."
if [ ! -f /etc/nginx/sites-enabled/maven-proxy ]; then
    print_error "Configuración de nginx no encontrada"
    echo "   Crea el archivo: /etc/nginx/sites-available/maven-proxy"
    exit 1
fi
print_success "Nginx configurado para Maven"

# 6. Matar port-forward previo si existe
print_status "Limpiando port-forward anteriores en 8082..."
pkill -f "kubectl port-forward.*8082:80" 2>/dev/null || true
sleep 2

# 7. Iniciar port-forward en background
print_status "Iniciando port-forward en puerto 8082..."
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8082:80 > /tmp/port-forward-maven.log 2>&1 &
PF_PID=$!
echo $PF_PID > /tmp/port-forward-maven.pid
sleep 3

# 8. Verificar que el port-forward está corriendo
if ! ps -p $PF_PID > /dev/null; then
    print_error "Port-forward falló al iniciar"
    cat /tmp/port-forward-maven.log
    exit 1
fi
print_success "Port-forward iniciado (PID: $PF_PID)"

# 9. Verificar puerto 8082
if ! netstat -tuln | grep -q ":8082"; then
    print_error "Puerto 8082 no está escuchando"
    exit 1
fi
print_success "Puerto 8082 escuchando"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ API Maven lista para acceder"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 URL de acceso:"
echo "   http://prueba.local.maven"
echo ""
echo "🔬 Endpoints de prueba:"
echo "   http://prueba.local.maven/petclinic/api/owners"
echo "   http://prueba.local.maven/petclinic/api/vets"
echo "   http://prueba.local.maven/petclinic/swagger-ui.html"
echo ""
echo "🔍 Verificar recursos:"
echo "   kubectl get pods | grep maven"
echo "   kubectl get ingress petclinic-maven-ingress"
echo ""
echo "📊 Ver logs:"
echo "   kubectl logs -f deployment/petclinic-maven"
echo "   tail -f /tmp/port-forward-maven.log"
echo ""
echo "🛑 Para detener:"
echo "   kill $PF_PID"
echo "   # O: cd ~/scripts/daily && ./5-stop-maven.sh"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
```

---

### Script para Detener Maven Ingress

**Crear:** `~/scripts/daily/5-stop-maven.sh`

```bash
#!/bin/bash

echo "🛑 Deteniendo port-forward de Maven..."

if [ -f /tmp/port-forward-maven.pid ]; then
    PID=$(cat /tmp/port-forward-maven.pid)
    if ps -p $PID > /dev/null; then
        kill $PID
        echo "✓ Port-forward detenido (PID: $PID)"
    else
        echo "⚠ Proceso ya no existe"
    fi
    rm /tmp/port-forward-maven.pid
else
    echo "⚠ Archivo PID no encontrado, intentando detener todos en puerto 8082..."
    pkill -f "kubectl port-forward.*8082:80"
fi

echo "✓ Listo"
```

---

### Crear scripts y dar permisos

```bash
# Crear script de inicio
nano ~/scripts/daily/4-start-maven.sh
# Pegar contenido del script de arriba

# Crear script de detención
nano ~/scripts/daily/5-stop-maven.sh
# Pegar contenido del script de arriba

# Dar permisos
chmod +x ~/scripts/daily/4-start-maven.sh
chmod +x ~/scripts/daily/5-stop-maven.sh
```

---

## 📝 Orden de Ejecución Completo (Angular + Maven)

**Cada día al iniciar Docker:**

```bash
# 1. Setup del entorno DevOps
cd ~/scripts/daily
./1-setup-devops.sh

# 2. Iniciar Ingress para Angular
./2-start-angular.sh

# 3. Iniciar Ingress para Maven
./4-start-maven.sh

# Ahora tienes acceso a:
# - http://prueba.local.angular (Frontend)
# - http://prueba.local.maven (Backend API)
```

**Al terminar el día:**

```bash
cd ~/scripts/daily
./3-stop-angular.sh
./5-stop-maven.sh
./stop-all.sh  # Opcional: detiene Minikube
```

---

## 🐛 Troubleshooting

### Error: "Connection refused" al acceder a la API

**Causa:** El pod de Maven puede no estar listo aún

**Solución:**
```bash
# Verificar estado del pod
kubectl get pods | grep maven

# Si está en CrashLoopBackOff o Error, ver logs
kubectl logs deployment/petclinic-maven

# Verificar que el servicio responde internamente
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
# Dentro del pod:
wget -O- http://petclinic-maven-service:9966/petclinic/
```

### Puerto 8082 ya está en uso

**Causa:** Otro proceso está usando el puerto

**Solución:**
```bash
# Ver qué está usando el puerto
sudo netstat -tulpn | grep 8082

# Matar proceso si es necesario
sudo kill <PID>

# O cambiar el puerto en el script (usar 8083, 8084, etc.)
```

### Nginx no resuelve el dominio Maven

**Causa:** Configuración no está activada o tiene errores

**Solución:**
```bash
# Verificar sintaxis
sudo nginx -t

# Ver configuraciones activas
ls -la /etc/nginx/sites-enabled/

# Recargar nginx
sudo systemctl reload nginx

# Ver logs de nginx
sudo tail -f /var/log/nginx/error.log
```

### Verificar que todo está corriendo

```bash
# 1. Pods de Maven
kubectl get pods | grep maven

# 2. Servicio de Maven
kubectl get services | grep maven

# 3. Ingress de Maven
kubectl get ingress petclinic-maven-ingress

# 4. Port-forward activo
ps aux | grep "kubectl port-forward.*8082"

# 5. Puerto escuchando
sudo netstat -tulpn | grep 8082

# 6. Nginx configurado
sudo nginx -t
ls -la /etc/nginx/sites-enabled/ | grep maven
```

---

## 📊 Arquitectura Final (Angular + Maven)

```
┌─────────────────────────────────────────────────────────────┐
│                        Windows                               │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Chrome:                                              │  │
│  │  - http://prueba.local.angular  (Frontend)           │  │
│  │  - http://prueba.local.maven    (Backend API)        │  │
│  │  (hosts: 127.0.0.1 → ambos dominios)                │  │
│  └──────────┬───────────────────────┬───────────────────┘  │
│             │ HTTP :80              │ HTTP :80              │
└─────────────┼───────────────────────┼───────────────────────┘
              │                       │
┌─────────────┼───────────────────────┼───────────────────────┐
│           WSL2                      │                        │
│  ┌────────▼────────────┐   ┌───────▼─────────────┐        │
│  │ Nginx (puerto 80)   │   │ Nginx (puerto 80)    │        │
│  │ prueba.local.angular│   │ prueba.local.maven   │        │
│  │ → 127.0.0.1:8081   │   │ → 127.0.0.1:8082    │        │
│  └────────┬────────────┘   └───────┬─────────────┘        │
│           │                        │                        │
│  ┌────────▼────────────┐   ┌───────▼─────────────┐        │
│  │ port-forward 8081   │   │ port-forward 8082    │        │
│  │ → Ingress:80       │   │ → Ingress:80        │        │
│  └────────┬────────────┘   └───────┬─────────────┘        │
└───────────┼────────────────────────┼───────────────────────┘
            │                        │
┌───────────┼────────────────────────┼───────────────────────┐
│        Minikube                    │                        │
│  ┌─────▼──────────────────┐ ┌─────▼────────────────┐      │
│  │ Ingress Controller      │ │ Ingress Controller    │      │
│  │ Rule: *.angular → svc  │ │ Rule: *.maven → svc  │      │
│  └─────┬──────────────────┘ └─────┬────────────────┘      │
│        │                          │                        │
│  ┌─────▼──────────────────┐ ┌─────▼────────────────┐      │
│  │ Service: angular:80    │ │ Service: maven:9966  │      │
│  └─────┬──────────────────┘ └─────┬────────────────┘      │
│        │                          │                        │
│  ┌─────▼──────────────────┐ ┌─────▼────────────────┐      │
│  │ Pod: Angular (nginx)   │ │ Pod: Spring Boot     │      │
│  └────────────────────────┘ └──────────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## 💡 Para Entrevistas

**Puntos clave adicionales para Maven:**

1. **Multi-aplicación con Ingress:**
   - Un solo Ingress Controller
   - Múltiples reglas basadas en Host
   - Routing eficiente sin duplicar recursos

2. **Puertos diferentes:**
   - Frontend: puerto 80 (estándar HTTP)
   - Backend: puerto 9966 (custom)
   - Ingress normaliza todo a puerto 80 externamente

3. **Port-forwarding múltiple:**
   - 8081 para Angular
   - 8082 para Maven
   - Ambos apuntan al mismo Ingress Controller (puerto 80)
   - El routing se hace por `Host` header

4. **Configuración Nginx:**
   - Múltiples server blocks
   - Mismo puerto (80) escuchando
   - Diferenciación por `server_name`

---

## 📖 Resumen de Comandos Útiles para Maven

```bash
# Ver estado de Maven
kubectl get pods | grep maven
kubectl logs -f deployment/petclinic-maven

# Ver Ingress de Maven
kubectl get ingress petclinic-maven-ingress
kubectl describe ingress petclinic-maven-ingress

# Ver servicio de Maven
kubectl get service petclinic-maven-service

# Probar endpoint internamente (desde dentro del cluster)
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://petclinic-maven-service:9966/petclinic/api/owners

# Ver configuración de Nginx
cat /etc/nginx/sites-available/maven-proxy
sudo nginx -t

# Reiniciar deployment si es necesario
kubectl rollout restart deployment/petclinic-maven

# Ver todas las configuraciones de Ingress
kubectl get ingress
```

---

## ✅ Checklist Final

Antes de considerar que funciona correctamente:

- [ ] Ingress Controller corriendo (compartido con Angular)
- [ ] Deployment `petclinic-maven` corriendo
- [ ] Service `petclinic-maven-service` creado
- [ ] Ingress `petclinic-maven-ingress` configurado
- [ ] Nginx proxy para Maven configurado en `/etc/nginx/sites-available/maven-proxy`
- [ ] Hosts de Windows tiene `prueba.local.maven`
- [ ] Port-forward corriendo en puerto 8082
- [ ] API accesible desde `http://prueba.local.maven`
- [ ] Endpoints de API responden correctamente

---

## 🎓 Conclusión

Ahora tienes **dos aplicaciones** (Angular + Spring Boot) accesibles mediante Ingress:

- ✅ **Frontend:** `http://prueba.local.angular`
- ✅ **Backend API:** `http://prueba.local.maven`

Esto demuestra una arquitectura **full-stack en Kubernetes** con Ingress routing, ideal para mencionar en entrevistas DevOps.

**Ventajas de esta configuración:**
- Un solo Ingress Controller para múltiples apps
- Routing basado en dominio (Host-based)
- Escalable: puedes agregar más aplicaciones fácilmente
- Simula entorno de producción con microservicios

---

¡Éxito con tu proyecto DevOps! 🚀
