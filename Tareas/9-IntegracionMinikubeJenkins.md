# ☸️ Guía Completa: Integración de Minikube con Jenkins

## 📋 **Índice**
1. [Introducción](#introducción)
2. [Conceptos Clave](#conceptos-clave)
3. [Dos Métodos de Autenticación](#dos-métodos-de-autenticación)
4. [Prerrequisitos](#prerrequisitos)
5. [Instalación de Minikube](#instalación-de-minikube)
6. [Configuración de Kubernetes para Jenkins](#configuración-de-kubernetes-para-jenkins)
7. [Instalación de kubectl en Jenkins](#instalación-de-kubectl-en-jenkins)
8. [Verificación de la Integración](#verificación-de-la-integración)
9. [Pipelines de Prueba](#pipelines-de-prueba)
10. [Método Alternativo: Token Directo](#método-alternativo-token-directo)
11. [Troubleshooting](#troubleshooting)

---

## 🎯 **Introducción**

### **Objetivo**
Integrar **Minikube** (Kubernetes local) con **Jenkins** para permitir que las pipelines de CI/CD puedan desplegar aplicaciones containerizadas en un cluster de Kubernetes local.

### **¿Qué vamos a lograr?**
```
Jenkins Pipeline → Build Image → Push Registry → Deploy en Kubernetes (Minikube)
```

### **Arquitectura Final**
```
Windows Host
└── WSL
    └── Docker Desktop
        ├── 🔴 Jenkins (puerto 8080)
        │   └── kubectl instalado
        │   └── Conectado a Minikube
        ├── 🟢 GitLab (puerto 8929)
        ├── 🐳 Registry (puerto 5000)
        └── ☸️ Minikube (Kubernetes)
            └── namespace: jenkins
                └── Pods desplegados por Jenkins
```

---

## 📚 **Conceptos Clave**

### **¿Qué es Minikube?**
- **Kubernetes local** que corre en tu máquina
- Simula un **cluster completo** de Kubernetes
- Perfecto para **desarrollo y testing**
- Más ligero que un cluster real

### **¿Qué es Kubernetes (K8s)?**
- **Orquestador de contenedores** (gestiona Docker containers)
- Maneja **despliegues, escalado, recuperación automática**
- Automatiza **rollouts y rollbacks**
- Gestiona **networking, storage y balanceo de carga**

### **¿Qué es kubectl?**
- **Herramienta de línea de comandos** para interactuar con Kubernetes
- Permite crear, modificar y eliminar recursos (pods, deployments, services, etc.)
- Se comunica con el **API Server** de Kubernetes

### **¿Qué es un Namespace?**
- **Espacio de nombres** que agrupa recursos en Kubernetes
- Permite **aislar** aplicaciones y equipos
- En nuestro caso: namespace `jenkins` para recursos desplegados por Jenkins

### **¿Qué es un Service Account?**
- **Identidad** para aplicaciones que corren en Kubernetes
- Permite **autenticación y autorización**
- En nuestro caso: cuenta `jenkins` con permisos de administrador

### **¿Qué es kubeconfig?**
- **Archivo de configuración** que contiene:
  - URL del cluster de Kubernetes
  - Certificados de autenticación
  - Contexto actual (namespace, usuario)
- Ubicación por defecto: `~/.kube/config`

---

## 🔐 **Dos Métodos de Autenticación**

### **⚠️ Importante: En esta guía usamos Método 2 (kubeconfig)**

Existen **dos formas principales** de que Jenkins se autentique con Kubernetes. Ambas son válidas y funcionan correctamente.

### **📊 Comparación de Métodos**

| Aspecto | Método 1: Token Directo | Método 2: Kubeconfig (usado aquí) |
|---------|------------------------|-----------------------------------|
| **Complejidad** | Media-Alta | Baja |
| **Configuración** | Kubernetes Cloud Plugin | kubectl + archivo config |
| **Autenticación** | Token explícito en Jenkins Credentials | Certificados/token en kubeconfig |
| **Uso típico** | Pods dinámicos para cada build | kubectl desde shell scripts |
| **Flexibilidad** | Limitada a Kubernetes plugin | Total (cualquier comando kubectl) |
| **Recomendado para** | Equipos grandes, infraestructura compleja | Desarrollo local, simplicidad |

---

### **🔑 Método 1: Token Directo (Kubernetes Cloud Plugin)**

**¿Cómo funciona?**
```
1. Generas token con: kubectl create token jenkins -n jenkins
2. Guardas token en Jenkins Credentials
3. Configuras Kubernetes Cloud en Jenkins
4. Jenkins usa el token para crear pods dinámicos
```

**Pipeline ejemplo:**
```groovy
pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'  // Usa configuración de Kubernetes Cloud
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:alpine
            command: ['cat']
            tty: true
      '''
    }
  }
  stages {
    stage('Build') {
      steps {
        container('maven') {
          sh 'mvn --version'
        }
      }
    }
  }
}
```

**Ventajas:**
- ✅ Jenkins **crea y destruye pods automáticamente** por cada build
- ✅ Aislamiento total entre builds
- ✅ Escalabilidad (múltiples builds paralelos)
- ✅ Método "oficial" de Kubernetes plugin

**Desventajas:**
- ❌ Configuración más compleja
- ❌ Requiere configurar Kubernetes Cloud en Jenkins
- ❌ Problemas de conectividad más complejos de resolver
- ❌ Menos flexible para scripts personalizados

---

### **📄 Método 2: Kubeconfig + kubectl (USADO EN ESTA GUÍA)**

**¿Cómo funciona?**
```
1. Exportas kubeconfig de Minikube
2. Copias kubeconfig al contenedor Jenkins
3. Instalas kubectl en Jenkins
4. Jenkins ejecuta comandos kubectl directamente
```

**Pipeline ejemplo:**
```groovy
pipeline {
  agent any  // Corre en Jenkins normal (no pods dinámicos)
  
  environment {
    KUBECONFIG = '/var/jenkins_home/kubeconfig'
  }
  
  stages {
    stage('Deploy') {
      steps {
        sh '''
          kubectl apply -f deployment.yaml
          kubectl get pods -n jenkins
        '''
      }
    }
  }
}
```

**Ventajas:**
- ✅ **Configuración muy simple** (solo copiar archivo + instalar kubectl)
- ✅ **Flexibilidad total** (cualquier comando kubectl)
- ✅ Debugging más fácil
- ✅ Perfecto para desarrollo local
- ✅ No requiere plugins adicionales

**Desventajas:**
- ❌ No crea pods dinámicos (todos los builds usan mismo agente Jenkins)
- ❌ Menor aislamiento entre builds
- ❌ Menos escalable para equipos grandes

---

### **🤔 ¿Por qué usamos Método 2 en esta guía?**

**Razones principales:**

1. **Simplicidad:** 
   - Solo 3 pasos: copiar archivo, instalar kubectl, conectar redes
   - No requiere configurar Kubernetes Cloud

2. **Debugging más fácil:**
   - Puedes ejecutar `docker exec jenkins kubectl get pods` directamente
   - Logs más claros

3. **Flexibilidad:**
   - Puedes ejecutar **cualquier** comando kubectl
   - No estás limitado al formato YAML del plugin

4. **Ideal para aprendizaje:**
   - Entiendes exactamente cómo funciona kubectl
   - Puedes ver y modificar el kubeconfig

---

### **🔍 ¿Dónde está el "token" en Método 2?**

**Respuesta:** El kubeconfig **contiene credenciales** (certificados o token), pero de forma **indirecta**.

**Verificar qué usa tu kubeconfig:**

```bash
# Ver tipo de autenticación
kubectl config view --minify

# Buscar sección 'users'
grep -A10 "users:" ~/.kube/config
```

**Posibilidad 1: Certificados de cliente (más común con Minikube)**
```yaml
users:
- name: minikube
  user:
    client-certificate: /home/user/.minikube/profiles/minikube/client.crt
    client-key: /home/user/.minikube/profiles/minikube/client.key
```

**Posibilidad 2: Token embebido**
```yaml
users:
- name: minikube
  user:
    token: eyJhbGciOiJSUzI1NiIsImtpZCI6IjZuYnJ3...
```

En ambos casos, **kubectl lee estas credenciales automáticamente** del kubeconfig y las usa para autenticarse.

---

### **📝 Resumen: ¿Cuál elegir?**

**Usa Método 1 (Token Directo) si:**
- 🏢 Equipo grande con múltiples desarrolladores
- 🚀 Necesitas builds paralelos con aislamiento total
- 🔒 Infraestructura de producción
- 📦 Quieres pods efímeros por cada build

**Usa Método 2 (Kubeconfig) si:**
- 💻 Desarrollo local o testing
- 🎓 Estás aprendiendo Kubernetes
- 🔧 Necesitas flexibilidad total con kubectl
- ⚡ Quieres configuración rápida y simple

---

### **🎯 Nota para el Futuro**

Al final de esta guía, en la sección [Método Alternativo: Token Directo](#método-alternativo-token-directo), encontrarás los pasos completos para implementar el Método 1 si decides cambiar en el futuro.

---

## ✅ **Prerrequisitos**

### **Verificar que tienes:**

```bash
# 1. Docker Desktop funcionando
docker ps

# Debes ver: Jenkins, GitLab, Registry corriendo

# 2. Al menos 4GB RAM disponibles
free -h

# 3. Red devops-net activa
docker network ls | grep devops-net

# 4. Versión de Docker
docker version
```

**Requisitos mínimos:**
- ✅ Docker Desktop instalado
- ✅ WSL configurado
- ✅ Jenkins, GitLab y Registry funcionando
- ✅ 4GB+ RAM libre
- ✅ Conexión a internet

---

## 🚀 **Fase 1: Instalación de Minikube**

### **Paso 1.1: Descargar e instalar Minikube**

```bash
# Descargar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Instalar
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Verificar instalación
minikube version
```

**Salida esperada:**
```
minikube version: v1.37.0
commit: 65318f4cfff9c12cc87ec9eb8f4cdd57b25047f3
```

### **Paso 1.2: Iniciar Minikube con configuración para Registry**

```bash
# Iniciar Minikube con Docker como driver e insecure registries
minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=4096 \
  --insecure-registry="registry:5000" \
  --insecure-registry="localhost:5000" \
  --insecure-registry="host.minikube.internal:5000"
```

**¿Qué hacen estos parámetros?**
- `--driver=docker` → Usa Docker Desktop como base (no VirtualBox/KVM)
- `--cpus=2` → Asigna 2 CPUs al cluster
- `--memory=4096` → Asigna 4GB de RAM
- `--insecure-registry` → Permite usar registry sin HTTPS (para desarrollo local)

**Proceso de instalación (2-4 minutos):**
```
😄  minikube v1.37.0 on Ubuntu
✨  Using the docker driver
👍  Starting control plane node minikube
🚜  Pulling base image ...
🔥  Creating docker container (CPUs=2, Memory=4096MB) ...
🐳  Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster
```

### **Paso 1.3: Verificar instalación**

```bash
# Estado del cluster
minikube status

# Información del cluster
kubectl cluster-info

# Ver nodos
kubectl get nodes

# Ver pods del sistema
kubectl get pods -A
```

**Salidas esperadas:**

```bash
# minikube status
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured

# kubectl get nodes
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   5m    v1.34.0

# kubectl get pods -A
NAMESPACE     NAME                               READY   STATUS    RESTARTS   AGE
kube-system   coredns-xxxxx                      1/1     Running   0          5m
kube-system   etcd-minikube                      1/1     Running   0          5m
kube-system   kube-apiserver-minikube            1/1     Running   0          5m
kube-system   kube-controller-manager-minikube   1/1     Running   0          5m
kube-system   kube-proxy-xxxxx                   1/1     Running   0          5m
kube-system   kube-scheduler-minikube            1/1     Running   0          5m
kube-system   storage-provisioner                1/1     Running   0          5m
```

### **Paso 1.4: Conectar Minikube a la red devops-net**

```bash
# Conectar Minikube a la red compartida
docker network connect devops-net minikube

# Verificar conexión
docker inspect minikube | grep -A10 "Networks"

# Probar conectividad con registry desde Minikube
minikube ssh
curl http://registry:5000/v2/_catalog
exit
```

**Salida esperada del curl:**
```json
{"repositories":["hello-world"]}
```

---

## ⚙️ **Fase 2: Configuración de Kubernetes para Jenkins**

### **Paso 2.1: Crear namespace dedicado para Jenkins**

```bash
# Crear namespace
kubectl create namespace jenkins

# Verificar
kubectl get namespaces
```

**¿Por qué un namespace específico?**
- ✅ **Aislamiento:** Recursos de Jenkins separados de otros
- ✅ **Organización:** Fácil identificar qué recursos pertenecen a Jenkins
- ✅ **Permisos:** Asignar permisos específicos al namespace
- ✅ **Limpieza:** Eliminar todo con `kubectl delete namespace jenkins`

### **Paso 2.2: Crear Service Account para Jenkins**

```bash
# Crear service account
kubectl create serviceaccount jenkins -n jenkins

# Verificar
kubectl get serviceaccounts -n jenkins
```

**¿Qué es un Service Account?**
- Identidad para aplicaciones (no usuarios humanos)
- Jenkins usará esta cuenta para autenticarse con Kubernetes
- Necesario para que Jenkins pueda crear/modificar recursos

### **Paso 2.3: Generar token de autenticación**

```bash
# Crear token con duración de 1 año (8760 horas)
kubectl create token jenkins -n jenkins --duration=8760h
```

**⚠️ IMPORTANTE:** 
- **Copia y guarda el token** que aparece
- Este token permite a Jenkins autenticarse con Kubernetes
- Tiene validez de 1 año

**Ejemplo de token:**
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IjZuYn...
```

### **Paso 2.4: Asignar permisos de administrador**

```bash
# Crear rolebinding con permisos de admin
kubectl create rolebinding jenkins-admin-binding \
  --clusterrole=admin \
  --serviceaccount=jenkins:jenkins \
  --namespace=jenkins

# Verificar
kubectl get rolebindings -n jenkins
```

**¿Qué hace este comando?**
- Asigna el rol `admin` al service account `jenkins`
- Solo en el namespace `jenkins`
- Permite a Jenkins crear, modificar y eliminar recursos

---

## 🔧 **Fase 3: Instalación de kubectl en Jenkins**

### **¿Por qué instalar kubectl en Jenkins?**

Jenkins necesita `kubectl` para:
- ✅ Comunicarse con el API Server de Kubernetes
- ✅ Crear y gestionar recursos (pods, deployments, services)
- ✅ Verificar estado de despliegues
- ✅ Obtener logs de aplicaciones

### **Paso 3.1: Exportar configuración de Kubernetes**

```bash
# Exportar kubeconfig a archivo temporal
kubectl config view --flatten > /tmp/kubeconfig

# Verificar que se creó
ls -la /tmp/kubeconfig
```

**¿Qué contiene kubeconfig?**
- URL del API Server de Kubernetes
- Certificados de autenticación
- Contexto actual (cluster, namespace, usuario)

### **Paso 3.2: Copiar kubeconfig al contenedor Jenkins**

```bash
# Copiar archivo al contenedor
docker cp /tmp/kubeconfig jenkins:/var/jenkins_home/kubeconfig

# Verificar que se copió
docker exec jenkins ls -la /var/jenkins_home/kubeconfig
```

**Salida esperada:**
```
-rw-r--r-- 1 jenkins jenkins 5963 Oct 1 12:19 /var/jenkins_home/kubeconfig
```

### **Paso 3.3: Ajustar permisos del archivo**

```bash
# Cambiar owner a usuario jenkins
docker exec -u root jenkins chown jenkins:jenkins /var/jenkins_home/kubeconfig
```

**¿Por qué cambiar permisos?**
- El archivo fue copiado como `root`
- Jenkins corre como usuario `jenkins`
- Sin permisos correctos, Jenkins no puede leerlo

### **Paso 3.4: Descargar kubectl**

```bash
# Descargar kubectl dentro del contenedor Jenkins
docker exec -u root jenkins curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
```

**¿Por qué versión v1.31.0?**
- Compatible con Kubernetes v1.34.0 de Minikube
- Versión estable y probada

### **Paso 3.5: Instalar kubectl**

```bash
# Instalar kubectl en /usr/local/bin
docker exec -u root jenkins install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**¿Qué hace este comando?**
- Mueve kubectl a `/usr/local/bin` (PATH global)
- Establece permisos de ejecución (`755`)
- Hace que kubectl esté disponible para todos los usuarios

### **Paso 3.6: Limpiar archivo temporal**

```bash
# Eliminar archivo de descarga
docker exec -u root jenkins rm kubectl
```

### **Paso 3.7: Actualizar kubeconfig con IP correcta**

**PROBLEMA:** Por defecto, kubeconfig usa `127.0.0.1` (localhost), pero Jenkins y Minikube están en contenedores diferentes.

**SOLUCIÓN:** Usar la IP real de Minikube en la red Docker.

```bash
# 1. Obtener IP de Minikube
minikube ip
# Ejemplo: 192.168.49.2

# 2. Actualizar configuración
kubectl config set-cluster minikube \
  --server=https://192.168.49.2:8443 \
  --insecure-skip-tls-verify=true

# 3. Regenerar kubeconfig
kubectl config view --flatten > /tmp/kubeconfig

# 4. Copiar nuevamente a Jenkins
docker cp /tmp/kubeconfig jenkins:/var/jenkins_home/kubeconfig
```

**¿Por qué `--insecure-skip-tls-verify=true`?**
- Minikube usa certificados autofirmados
- Para desarrollo local es seguro omitir verificación TLS
- En producción, usarías certificados válidos

### **Paso 3.8: Conectar Jenkins a la red de Minikube**

```bash
# Conectar Jenkins a la red de Minikube
docker network connect minikube jenkins
```

**¿Por qué este paso?**
- Jenkins y Minikube estaban en redes diferentes
- Sin conexión de red, Jenkins no puede alcanzar la IP `192.168.49.2`
- Ahora comparten red y pueden comunicarse

### **Paso 3.9: Verificar conexión**

```bash
# Probar que Jenkins puede ver el cluster
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
```

**Salida esperada:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   71m   v1.34.0
```

✅ **Si ves esto, ¡la integración funciona!**

```bash
# Verificar namespaces
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get namespaces
```

**Salida esperada:**
```
NAME              STATUS   AGE
default           Active   74m
jenkins           Active   27m
kube-node-lease   Active   74m
kube-public       Active   74m
kube-system       Active   74m
```

---

## ✅ **Fase 4: Verificación con Pipelines**

### **Pipeline 1: Verificar Conexión**

**Crear job en Jenkins:**

1. Jenkins → **New Item**
2. Name: `kubernetes-test`
3. Type: **Pipeline**
4. OK

**Pipeline Script:**

```groovy
pipeline {
  agent any
  
  environment {
    KUBECONFIG = '/var/jenkins_home/kubeconfig'
  }
  
  stages {
    stage('Test Kubernetes Connection') {
      steps {
        sh '''
          echo "🔍 Testing Kubernetes connection..."
          kubectl get nodes
          kubectl get namespaces
          kubectl get pods -n jenkins
        '''
      }
    }
  }
}
```

**¿Qué hace esta pipeline?**
- `KUBECONFIG` → Especifica ubicación del archivo de configuración
- `kubectl get nodes` → Verifica conexión al cluster
- `kubectl get namespaces` → Lista todos los namespaces
- `kubectl get pods -n jenkins` → Busca pods en namespace jenkins

**Resultado esperado:**
```
Started by user Adrián Martín Romo Cañadas
...
🔍 Testing Kubernetes connection...
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   74m   v1.34.0
...
Finished: SUCCESS
```

### **Pipeline 2: Desplegar Aplicación**

**Crear job en Jenkins:**

1. Jenkins → **New Item**
2. Name: `deploy-to-kubernetes`
3. Type: **Pipeline**
4. OK

**Pipeline Script:**

```groovy
pipeline {
  agent any
  
  environment {
    KUBECONFIG = '/var/jenkins_home/kubeconfig'
  }
  
  stages {
    stage('Deploy Nginx to Kubernetes') {
      steps {
        sh '''
          echo "🚀 Deploying Nginx to Kubernetes..."
          
          # Crear Pod usando kubectl apply con YAML inline
          kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: nginx-test
  namespace: jenkins
  labels:
    app: nginx
spec:
  containers:
  - name: nginx
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

          echo "⏳ Waiting for pod to be ready..."
          kubectl wait --for=condition=Ready pod/nginx-test -n jenkins --timeout=60s
          
          echo "✅ Pod deployed successfully!"
          kubectl get pods -n jenkins
        '''
      }
    }
  }
}
```

**¿Qué hace esta pipeline?**

1. **`kubectl apply -f -`** → Crea recursos desde YAML inline
2. **`<<EOF ... EOF`** → Sintaxis de "here document" para YAML multilínea
3. **`kubectl wait`** → Espera hasta que el pod esté listo
4. **`kubectl get pods`** → Muestra el estado final

**Explicación del YAML:**

```yaml
apiVersion: v1              # Versión de la API de Kubernetes
kind: Pod                   # Tipo de recurso (Pod)
metadata:
  name: nginx-test          # Nombre del pod
  namespace: jenkins        # Namespace donde se crea
  labels:
    app: nginx              # Etiqueta para identificar el pod
spec:
  containers:
  - name: nginx             # Nombre del contenedor
    image: nginx:alpine     # Imagen Docker a usar
    ports:
    - containerPort: 80     # Puerto que expone el contenedor
```

**Resultado esperado:**
```
🚀 Deploying Nginx to Kubernetes...
pod/nginx-test created
⏳ Waiting for pod to be ready...
pod/nginx-test condition met
✅ Pod deployed successfully!
NAME         READY   STATUS    RESTARTS   AGE
nginx-test   1/1     Running   0          5s
Finished: SUCCESS
```

**Verificar desde línea de comandos:**

```bash
# Ver pods en namespace jenkins
kubectl get pods -n jenkins

# Ver detalles del pod
kubectl describe pod nginx-test -n jenkins

# Ver logs del nginx
kubectl logs nginx-test -n jenkins

# Eliminar el pod (limpieza)
kubectl delete pod nginx-test -n jenkins
```

---

## 🎯 **Verificación Final de la Integración**

### **Checklist completo:**

```bash
# 1. Minikube funcionando
minikube status
# Debe mostrar: host: Running, kubelet: Running, apiserver: Running

# 2. Namespace jenkins existe
kubectl get namespace jenkins
# Debe mostrar: jenkins   Active   XXm

# 3. Service account jenkins existe
kubectl get serviceaccount jenkins -n jenkins
# Debe mostrar: jenkins   0         XXm

# 4. Jenkins puede ejecutar kubectl
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
# Debe mostrar: minikube   Ready   control-plane

# 5. Pipelines pueden desplegar recursos
# Ejecutar pipeline deploy-to-kubernetes
# Debe terminar con: Finished: SUCCESS
```

---

## 🏆 **Arquitectura Final Lograda**

```
WINDOWS HOST
└── WSL
    └── DOCKER DESKTOP
        ├── 🔴 Jenkins Container (puerto 8080)
        │   ├── kubectl instalado ✅
        │   ├── kubeconfig configurado ✅
        │   ├── Conectado a red minikube ✅
        │   └── Conectado a red devops-net ✅
        │
        ├── 🟢 GitLab Container (puerto 8929) ✅
        │
        ├── 🐳 Registry Container (puerto 5000) ✅
        │
        └── ☸️ Minikube Container
            ├── Kubernetes v1.34.0 ✅
            ├── Conectado a red devops-net ✅
            ├── Acceso a registry:5000 ✅
            └── Namespace: jenkins
                ├── Service Account: jenkins ✅
                ├── RoleBinding: jenkins-admin-binding ✅
                └── Pods desplegados por Jenkins ✅
```

### **Flujo de Despliegue Completo:**

```
1. Developer → Push código a GitLab
2. GitLab → Webhook a Jenkins
3. Jenkins → Build aplicación
4. Jenkins → Build imagen Docker
5. Jenkins → Push imagen a Registry (localhost:5000)
6. Jenkins → kubectl apply deployment en Minikube
7. Minikube → Pull imagen desde Registry
8. Minikube → Despliega pods
9. Aplicación corriendo en Kubernetes ✅
```

---

## � **Método Alternativo: Token Directo (Kubernetes Cloud Plugin)**

### **📋 Introducción**

Esta sección muestra cómo implementar el **Método 1** (Token Directo) como alternativa al método de kubeconfig usado en esta guía.

**⚠️ Nota:** Esta configuración es **opcional** y más compleja. Solo úsala si necesitas pods dinámicos por cada build.

---

### **🎯 ¿Cuándo usar este método?**

- ✅ Equipo grande con múltiples pipelines paralelas
- ✅ Necesitas aislamiento total entre builds
- ✅ Quieres que Jenkins cree pods temporales automáticamente
- ✅ Infraestructura más cercana a producción

---

### **📝 Paso a Paso: Configuración con Token**

#### **Paso 1: Ya tienes el token (del Paso 2.3 de esta guía)**

```bash
# El token que generaste antes:
kubectl create token jenkins -n jenkins --duration=8760h
```

**Ejemplo de token:**
```
eyJhbGciOiJSUzI1NiIsImtpZCI6IjZuYnJ3VjkxNjBUWkRjVWhfa1ZtdFg0a21hTGFhMXl1djhRa29IMnd3d00ifQ...
```

⚠️ **Guarda este token**, lo necesitarás en el siguiente paso.

---

#### **Paso 2: Guardar token en Jenkins Credentials**

**En Jenkins (navegador):**

1. **Manage Jenkins** → **Credentials**
2. **System** → **Global credentials (unrestricted)**
3. **Add Credentials**
4. Configurar:
   - **Kind:** `Secret text`
   - **Scope:** `Global (Jenkins, nodes, items, all child items, etc)`
   - **Secret:** `{PEGA EL TOKEN AQUÍ}`
   - **ID:** `kubernetes-jenkins-token`
   - **Description:** `Minikube Jenkins Service Account Token (8760h expiration)`
5. **Create**

**Verificación:**
- Deberías ver la credencial listada con ID `kubernetes-jenkins-token`

---

#### **Paso 3: Instalar Kubernetes Plugin (si no lo hiciste)**

1. **Manage Jenkins** → **Plugins**
2. **Available plugins**
3. Buscar e instalar:
   - ☑️ **Kubernetes**
   - ☑️ **Kubernetes CLI**
4. **Install without restart**
5. ✅ **Restart Jenkins when installation is complete**

---

#### **Paso 4: Configurar Kubernetes Cloud**

**En Jenkins:**

1. **Manage Jenkins** → **Clouds**
2. **New cloud**
3. **Name:** `kubernetes`
4. **Type:** Seleccionar `Kubernetes`
5. **Kubernetes Cloud details:**

```
Name: kubernetes
Kubernetes URL: https://192.168.49.2:8443
Kubernetes server certificate key: [DEJAR VACÍO]
☑️ Disable https certificate check: MARCAR
Kubernetes Namespace: jenkins
Credentials: kubernetes-jenkins-token (el que creaste)
WebSocket: ☐ DESMARCAR
Direct Connection: ☑️ MARCAR
Jenkins URL: http://jenkins:8080
Jenkins tunnel: [DEJAR VACÍO]
```

6. **Test Connection** 

**Si funciona, verás:**
```
✅ Connected to Kubernetes v1.34.0
```

**Si no funciona:**
- Verifica que Jenkins esté en red `minikube`: `docker network connect minikube jenkins`
- Verifica la IP de Minikube: `minikube ip`
- Prueba con: `https://{IP_MINIKUBE}:8443`

7. **Save**

---

#### **Paso 5: Configurar Pod Template (Opcional)**

En la misma página de **Kubernetes Cloud**:

1. **Pod Templates** → **Add Pod Template**
2. **Pod Template details:**

```
Name: jenkins-agent
Namespace: jenkins
Labels: jenkins-agent
Usage: Use this node as much as possible

Containers:
  Name: jnlp
  Docker image: jenkins/inbound-agent:latest
  Working directory: /home/jenkins/agent
  Command to run: [DEJAR VACÍO]
  Arguments to pass: ${computer.jnlpmac} ${computer.name}
```

3. **Save**

---

### **🧪 Pipeline de Prueba con Método Token**

**Crear nuevo job:**

1. **New Item** → Name: `kubernetes-cloud-test` → **Pipeline** → OK
2. **Pipeline script:**

```groovy
pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'
      yaml '''
        apiVersion: v1
        kind: Pod
        metadata:
          labels:
            jenkins: agent
        spec:
          containers:
          - name: maven
            image: maven:3.9.9-eclipse-temurin-17
            command:
            - cat
            tty: true
          - name: node
            image: node:18-alpine
            command:
            - cat
            tty: true
      '''
    }
  }
  
  stages {
    stage('Test Maven Container') {
      steps {
        container('maven') {
          sh '''
            echo "🔍 Testing Maven container..."
            mvn --version
            java --version
          '''
        }
      }
    }
    
    stage('Test Node Container') {
      steps {
        container('node') {
          sh '''
            echo "🔍 Testing Node container..."
            node --version
            npm --version
          '''
        }
      }
    }
    
    stage('Verify Pod') {
      steps {
        container('maven') {
          sh '''
            echo "📋 Pod information:"
            echo "Hostname: $(hostname)"
            echo "Namespace: ${KUBERNETES_NAMESPACE:-jenkins}"
          '''
        }
      }
    }
  }
}
```

3. **Save** → **Build Now**

---

### **✅ ¿Qué debería pasar?**

1. Jenkins **crea un Pod temporal** en namespace `jenkins`
2. El Pod tiene **2 contenedores**: `maven` y `node`
3. Se ejecutan las etapas en los contenedores correspondientes
4. Al terminar, el Pod se **destruye automáticamente**

**Console Output esperado:**
```
...
Agent default-xxxxx is provisioned from template default
...
🔍 Testing Maven container...
Apache Maven 3.9.9
Java version: 17.x.x
...
🔍 Testing Node container...
v18.x.x
10.x.x
...
Finished: SUCCESS
```

---

### **📊 Verificar pods dinámicos**

```bash
# Mientras el build corre, ver pods
kubectl get pods -n jenkins -w

# Deberías ver:
NAME              READY   STATUS    RESTARTS   AGE
default-xxxxx     2/2     Running   0          10s

# Después del build, el pod desaparece
```

---

### **🔄 Pipeline Completa con Deploy**

```groovy
@Library('jenkinspipelines') _

pipeline {
  agent {
    kubernetes {
      cloud 'kubernetes'
      yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: maven
            image: maven:3.9.9-eclipse-temurin-17
            command: ['cat']
            tty: true
          - name: docker
            image: docker:latest
            command: ['cat']
            tty: true
            volumeMounts:
            - name: docker-sock
              mountPath: /var/run/docker.sock
          - name: kubectl
            image: bitnami/kubectl:latest
            command: ['cat']
            tty: true
          volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
      '''
    }
  }
  
  environment {
    REGISTRY = 'registry:5000'
    IMAGE_NAME = 'myapp'
    IMAGE_TAG = "${BUILD_NUMBER}"
  }
  
  stages {
    stage('Build with Maven') {
      steps {
        container('maven') {
          sh 'mvn clean package -DskipTests'
        }
      }
    }
    
    stage('Build Docker Image') {
      steps {
        container('docker') {
          sh """
            docker build -t ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} .
            docker push ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
          """
        }
      }
    }
    
    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          sh """
            kubectl set image deployment/myapp \
              myapp=${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG} \
              -n jenkins
          """
        }
      }
    }
  }
}
```

---

### **🆚 Comparación: Método Token vs Kubeconfig**

| Característica | Token (Cloud Plugin) | Kubeconfig (esta guía) |
|----------------|---------------------|------------------------|
| **Configuración inicial** | Compleja (5 pasos) | Simple (3 pasos) |
| **Pods dinámicos** | ✅ Sí (por cada build) | ❌ No (usa agente Jenkins) |
| **Aislamiento** | ✅ Total (pod nuevo) | ⚠️ Parcial (mismo agente) |
| **Múltiples contenedores** | ✅ Fácil (YAML) | ⚠️ Limitado |
| **Flexibilidad kubectl** | ⚠️ Limitada | ✅ Total |
| **Debugging** | ❌ Más complejo | ✅ Más simple |
| **Escalabilidad** | ✅ Excelente | ⚠️ Limitada |
| **Uso de recursos** | ✅ Eficiente | ⚠️ Menos eficiente |

---

### **💡 Recomendación Final**

**Empieza con Método Kubeconfig (esta guía) porque:**
- ✅ Aprendes los fundamentos
- ✅ Configuración rápida
- ✅ Debugging más fácil
- ✅ Suficiente para desarrollo local

**Migra a Método Token cuando:**
- 🏢 Tengas equipo grande
- 🚀 Necesites builds paralelos
- 🔒 Vayas a producción
- 📈 Escales tu infraestructura

---

## �🛠️ **Troubleshooting**

### **Problema 1: Jenkins no puede conectarse a Minikube**

**Síntoma:**
```
Error: dial tcp 192.168.49.2:8443: i/o timeout
```

**Causa:** Jenkins y Minikube no están en la misma red.

**Solución:**
```bash
# Conectar Jenkins a la red de Minikube
docker network connect minikube jenkins

# Verificar
docker inspect jenkins | grep -A5 "Networks"
```

### **Problema 2: kubectl no encuentra kubeconfig**

**Síntoma:**
```
Error: The connection to the server localhost:8080 was refused
```

**Causa:** Variable `KUBECONFIG` no está configurada.

**Solución:**
En la pipeline, siempre especifica:
```groovy
environment {
  KUBECONFIG = '/var/jenkins_home/kubeconfig'
}
```

O usa el flag directamente:
```bash
kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
```

### **Problema 3: Permission denied al acceder a kubeconfig**

**Síntoma:**
```
Error: open /var/jenkins_home/kubeconfig: permission denied
```

**Causa:** El archivo no tiene permisos correctos.

**Solución:**
```bash
docker exec -u root jenkins chown jenkins:jenkins /var/jenkins_home/kubeconfig
docker exec -u root jenkins chmod 644 /var/jenkins_home/kubeconfig
```

### **Problema 4: Minikube no puede descargar imágenes del registry**

**Síntoma:**
```
Error: Failed to pull image "registry:5000/myapp:latest": rpc error: code = Unknown desc = Error response from daemon: Get https://registry:5000/v2/: http: server gave HTTP response to HTTPS client
```

**Causa:** Registry no está configurado como insecure en Minikube.

**Solución:**
```bash
# Reiniciar Minikube con insecure-registry
minikube stop
minikube start \
  --driver=docker \
  --cpus=2 \
  --memory=4096 \
  --insecure-registry="registry:5000"

# Reconectar a devops-net
docker network connect devops-net minikube
```

### **Problema 5: Pods quedan en estado Pending**

**Síntoma:**
```
NAME       READY   STATUS    RESTARTS   AGE
my-pod     0/1     Pending   0          2m
```

**Diagnóstico:**
```bash
# Ver detalles del pod
kubectl describe pod my-pod -n jenkins

# Ver eventos del namespace
kubectl get events -n jenkins --sort-by='.lastTimestamp'
```

**Causas comunes:**
- Recursos insuficientes (CPU/memoria)
- Imagen no disponible
- PersistentVolumeClaim sin resolver

**Solución:** Revisar logs y eventos para identificar causa específica.

### **Problema 6: "x509: certificate signed by unknown authority"**

**Síntoma:**
```
Error: x509: certificate signed by unknown authority
```

**Causa:** Certificados autofirmados de Minikube.

**Solución:**
```bash
# Actualizar kubeconfig con skip-tls-verify
kubectl config set-cluster minikube \
  --server=https://192.168.49.2:8443 \
  --insecure-skip-tls-verify=true

# Regenerar y copiar a Jenkins
kubectl config view --flatten > /tmp/kubeconfig
docker cp /tmp/kubeconfig jenkins:/var/jenkins_home/kubeconfig
```

---

### **Problemas Específicos del Método Token (Kubernetes Cloud)**

#### **Problema 7: "Error testing connection" en Kubernetes Cloud**

**Síntoma:**
```
Error testing connection https://192.168.49.2:8443: java.io.IOException
```

**Causas posibles:**

1. **Jenkins no está en red de Minikube:**
```bash
docker network connect minikube jenkins
```

2. **IP incorrecta:**
```bash
# Ver IP real de Minikube
minikube ip

# Actualizar en Kubernetes Cloud config
```

3. **Certificados no válidos:**
- ☑️ Marcar "Disable https certificate check" en configuración

4. **Token expirado:**
```bash
# Generar nuevo token
kubectl create token jenkins -n jenkins --duration=8760h

# Actualizar en Jenkins Credentials
```

#### **Problema 8: "Pod nunca arranca" en builds**

**Síntoma:**
```
Still waiting to schedule task
All nodes of label 'jenkins-agent' are offline
```

**Diagnóstico:**
```bash
# Ver eventos en namespace jenkins
kubectl get events -n jenkins --sort-by='.lastTimestamp'

# Ver pods problemáticos
kubectl get pods -n jenkins
kubectl describe pod <pod-name> -n jenkins
```

**Causas comunes:**

1. **Recursos insuficientes:**
```bash
# Ver recursos de Minikube
kubectl top nodes
kubectl describe node minikube
```

**Solución:** Aumentar recursos de Minikube
```bash
minikube stop
minikube start --cpus=4 --memory=8192
```

2. **Imagen no disponible:**
```yaml
# En pipeline, especificar imagePullPolicy
containers:
- name: maven
  image: maven:alpine
  imagePullPolicy: IfNotPresent  # o Always
```

3. **Service Account sin permisos:**
```bash
# Verificar permisos
kubectl get rolebindings -n jenkins
kubectl describe rolebinding jenkins-admin-binding -n jenkins
```

#### **Problema 9: "Container no responde" en pipeline con múltiples containers**

**Síntoma:**
```
Process apparently never started in /home/jenkins/agent/workspace/...
```

**Causa:** Contenedor sin comando `cat` y `tty: true`

**Solución correcta:**
```yaml
containers:
- name: maven
  image: maven:alpine
  command:
  - cat        # ⚠️ IMPORTANTE
  tty: true    # ⚠️ IMPORTANTE
```

**Explicación:**
- `command: [cat]` → Mantiene el contenedor vivo
- `tty: true` → Permite interacción con el contenedor

#### **Problema 10: "Failed to connect to bus" en pods de Jenkins**

**Síntoma:**
```
Failed to connect to bus: No such file or directory
```

**Causa:** Problemas con systemd en contenedor Jenkins agent

**Solución:**
```yaml
# Usar imagen específica de Jenkins agent
containers:
- name: jnlp
  image: jenkins/inbound-agent:latest-jdk17
  args:
  - '$(JENKINS_SECRET)'
  - '$(JENKINS_NAME)'
```

---

## 🎓 **Conceptos Avanzados**

### **Diferencia entre Pod, Deployment y Service**

| Recurso | Propósito | Ejemplo de Uso |
|---------|-----------|----------------|
| **Pod** | Unidad mínima de ejecución | Contenedor individual o grupo de contenedores relacionados |
| **Deployment** | Gestiona réplicas de pods | Aplicación con múltiples instancias, rollouts automáticos |
| **Service** | Expone pods con IP estable | Balanceador de carga interno, acceso desde fuera del cluster |

**Ejemplo de Deployment:**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: jenkins
spec:
  replicas: 3  # 3 instancias del pod
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
```

**Ejemplo de Service:**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: jenkins
spec:
  selector:
    app: nginx
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

### **Labels y Selectors**

**Labels:** Etiquetas clave-valor para organizar recursos

```yaml
metadata:
  labels:
    app: nginx
    environment: production
    team: devops
```

**Selectors:** Filtros para seleccionar recursos por labels

```bash
# Ver pods con label específico
kubectl get pods -l app=nginx -n jenkins

# Eliminar todos los pods con un label
kubectl delete pods -l app=nginx -n jenkins
```

---

## ✅ **Checklist Final**

```
✅ Minikube instalado y corriendo
✅ Namespace jenkins creado
✅ Service account jenkins con permisos admin
✅ kubectl instalado en Jenkins
✅ kubeconfig configurado correctamente
✅ Jenkins conectado a red de Minikube
✅ Pipeline de prueba ejecutada exitosamente
✅ Despliegue de aplicación en Kubernetes exitoso
✅ Registry accesible desde Minikube
```

---

**Documentación creada:** Octubre 2025  
**Última actualización:** Octubre 2025  
**Versión:** 1.0