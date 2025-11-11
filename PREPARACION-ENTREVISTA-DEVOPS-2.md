Entiendo perfectamente. Voy a revisar toda tu documentación técnica (menos la carpeta Comandos) para crear un documento completo que te ayude en tu entrevista. Revisaré:

1. Las guías de backups, migraciones, GitLab-Jenkins
2. Todos los archivos en la carpeta Tareas
3. Tu CV para contexto adicional

Empiezo a recopilar la información:

Perfecto, he revisado todo el material. Voy a crear un documento completo y profesional que cubra:

1. **Conceptos fundamentales de DevOps**
2. **Herramientas y tecnologías** que dominas
3. **Arquitecturas y flujos** que has implementado
4. **Terminología clave y diferencias** importantes
5. **Proyectos prácticos** realizados
6. **Mejores prácticas** aplicadas

Te voy a crear `PREPARACION-ENTREVISTA-DEVOPS.md` en la raíz del proyecto:

```markdown
# 🚀 Preparación Entrevista DevOps - Adrián Martín Romo Cañadas

## 📌 Índice Rápido
1. [Definición de DevOps](#definición-de-devops)
2. [Conceptos Fundamentales](#conceptos-fundamentales)
3. [Herramientas y Stack Tecnológico](#herramientas-y-stack-tecnológico)
4. [Proyectos Implementados](#proyectos-implementados)
5. [Terminología Clave y Diferencias](#terminología-clave-y-diferencias)
6. [Flujos de Trabajo (Workflows)](#flujos-de-trabajo)
7. [Arquitecturas Desplegadas](#arquitecturas-desplegadas)
8. [Mejores Prácticas Aplicadas](#mejores-prácticas-aplicadas)
9. [Comandos y Troubleshooting](#comandos-clave)
10. [Preguntas Frecuentes de Entrevista](#preguntas-frecuentes)

---

## 🎯 Definición de DevOps

**DevOps** es una cultura y conjunto de prácticas que une el **desarrollo** (Dev) y las **operaciones** (Ops) de TI para:

- **Automatizar y mejorar** el ciclo de vida del software
- Implementar principios de **CI/CD** (Integración y Despliegue Continuos)
- **Reducir el tiempo** desde el desarrollo hasta producción
- **Aumentar la calidad** mediante pruebas automáticas y despliegues frecuentes
- Fomentar la **colaboración** entre equipos

### El Ciclo DevOps
```
Desarrollo → Build → Test → Release → Deploy → Operate → Monitor → (vuelta a Desarrollo)
```

---

## 📚 Conceptos Fundamentales

### CI/CD (Continuous Integration/Continuous Deployment)

#### **Continuous Integration (CI)**
- **Integración continua** del código en un repositorio compartido
- **Automatización de builds** cada vez que hay un commit
- **Tests automáticos** para detectar errores temprano
- **Feedback rápido** a los desarrolladores

#### **Continuous Deployment (CD)**
- **Despliegue automático** a producción después de pasar tests
- **Entrega continua** de nuevas features
- **Rollback automático** en caso de fallos
- **Zero-downtime deployments**

#### **Tu Implementación:**
```
GitLab (SCM) → Jenkins (CI/CD) → Docker (Containerización) → Kubernetes (Orquestación)
```

---

### Infraestructura como Código (IaC)

**Definición:** Gestionar infraestructura mediante código versionado en lugar de procesos manuales.

**Herramientas que dominas:**
- **Docker Compose:** Definir multi-container apps
- **Kubernetes YAML:** Manifiestos de recursos
- **Helm Charts:** Plantillas parametrizables
- **Dockerfiles:** Definición de imágenes

**Ventajas:**
- ✅ Reproducibilidad
- ✅ Versionado en Git
- ✅ Auditoría de cambios
- ✅ Automatización

---

### Contenedores vs Virtualización

| Aspecto | Máquinas Virtuales | Contenedores (Docker) |
|---------|-------------------|----------------------|
| **Tamaño** | GBs | MBs |
| **Startup** | Minutos | Segundos |
| **Aislamiento** | Hardware completo | Procesos del SO |
| **Portabilidad** | Media | Alta |
| **Overhead** | Alto (hypervisor) | Bajo (kernel compartido) |
| **Uso en producción** | Servidores completos | Microservicios |

**Por qué Docker:**
- Empaqueta app + dependencias
- "Funciona en mi máquina" → "Funciona en todas"
- Ideal para CI/CD

---

### Orquestación de Contenedores

#### **Kubernetes (K8s)**
**Definición:** Sistema de orquestación para automatizar despliegue, escalado y gestión de aplicaciones contenerizadas.

**Conceptos clave que dominas:**

1. **Pod:** Unidad mínima desplegable (1+ contenedores)
2. **Deployment:** Gestiona réplicas de pods
3. **Service:** Expone pods con IP estable
4. **Ingress:** Enrutamiento HTTP/HTTPS externo
5. **Namespace:** Aislamiento lógico de recursos
6. **ConfigMap/Secret:** Configuración externa
7. **PersistentVolume:** Almacenamiento persistente

**Tipos de Services:**
- **ClusterIP:** Solo interno (por defecto)
- **NodePort:** Expone en puerto del nodo
- **LoadBalancer:** IP externa (cloud)

---

## 🛠️ Herramientas y Stack Tecnológico

### Control de Versiones

#### **Git / GitLab**
**Implementado:**
- Repositorios privados en GitLab dockerizado
- Integración con Jenkins mediante webhooks
- GitFlow: feature → develop → main
- Container Registry integrado

**Comandos clave:**
```bash
git clone <repo>
git checkout -b feature/nueva-funcionalidad
git add . && git commit -m "feat: nueva funcionalidad"
git push origin feature/nueva-funcionalidad
```

---

### CI/CD Server

#### **Jenkins**
**Tu configuración:**
- Jenkins dockerizado con Docker-in-Docker (DinD)
- Pipelines como código (Jenkinsfile)
- Integración con GitLab mediante webhooks
- Credenciales gestionadas de forma segura
- Agentes con acceso a Docker y kubectl

**Tipos de Pipeline:**

1. **Scripted Pipeline:** Groovy nativo, máxima flexibilidad
2. **Declarative Pipeline:** Sintaxis estructurada, recomendada

**Tu Pipeline típico:**
```groovy
pipeline {
    agent any
    stages {
        stage('Checkout') { ... }
        stage('Build') { ... }
        stage('Test') { ... }
        stage('Docker Build') { ... }
        stage('Push to Registry') { ... }
        stage('Deploy to K8s') { ... }
    }
}
```

---

### Containerización

#### **Docker**
**Componentes:**
- **Docker Engine:** Motor de contenedores
- **Docker Image:** Plantilla inmutable
- **Docker Container:** Instancia ejecutable
- **Dockerfile:** Receta para crear imagen
- **Docker Compose:** Orquestación local multi-contenedor
- **Docker Registry:** Repositorio de imágenes

**Tu Registry Local:**
```bash
# Registry en localhost:5000
docker run -d -p 5000:5000 --name registry registry:2
docker tag mi-app:latest localhost:5000/mi-app:latest
docker push localhost:5000/mi-app:latest
```

**Dockerfiles creados:**
- Spring Boot apps (Maven multi-stage)
- Angular apps (Node build → Nginx)
- Nginx custom con configuraciones específicas

---

### Orquestación

#### **Kubernetes con Minikube**
**Tu entorno:**
- Minikube en WSL2 (desarrollo local)
- kubectl para gestión
- Helm para templating
- Ingress NGINX para routing

**Helm Charts:**
```
chart/
├── Chart.yaml          # Metadata
├── values.yaml         # Configuración por defecto
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    └── ingress.yaml
```

**Ventajas de Helm:**
- Reutilización de templates
- Parametrización (dev/prod)
- Versionado de releases
- Rollback sencillo

---

### Networking y Proxy

#### **Nginx**
**Usos en tu proyecto:**

1. **Servidor web estático** (Angular builds)
2. **Reverse proxy** (routing a backend)
3. **Load balancer** (múltiples instancias)
4. **Proxy local** (WSL2 → Minikube)

**Configuración típica:**
```nginx
server {
    listen 80;
    server_name mi-app.local;
    
    location / {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
    }
    
    location /api {
        proxy_pass http://api-service:3000;
    }
}
```

---

## 💼 Proyectos Implementados

### 1. **Infraestructura CI/CD Completa**

**Objetivo:** Entorno local que replica producción

**Componentes:**
- GitLab CE en Docker
- Jenkins en Docker con DinD
- Container Registry local
- Minikube (Kubernetes local)

**Logros:**
- ✅ Push a GitLab → Trigger automático en Jenkins
- ✅ Build → Test → Dockerize → Push Registry
- ✅ Deploy automático a Kubernetes
- ✅ Zero configuración manual

---

### 2. **Spring Petclinic Full Stack**

**Stack:**
- **Backend:** Java 17 + Spring Boot + Maven
- **Frontend:** Angular 17 + TypeScript
- **Base de datos:** MySQL (opcional PostgreSQL)

**Pipelines separados:**

#### **Pipeline Angular:**
```groovy
stages {
    - Checkout código
    - npm install
    - npm run build --prod
    - Crear Dockerfile con nginx
    - Build imagen Docker
    - Push a registry local
    - Deploy a K8s con Helm
}
```

#### **Pipeline Maven:**
```groovy
stages {
    - Checkout código
    - mvn clean package -DskipTests
    - Crear imagen Docker multi-stage
    - Push a registry
    - Deploy a K8s
}
```

**Desafíos resueltos:**
- Comunicación Angular → Spring (CORS)
- Secrets para registry privado
- Variables de entorno (API URLs)
- Health checks y readiness probes

---

### 3. **Centralización de Pipelines**

**Problema:** Duplicación de código en Jenkinsfiles

**Solución:**
- Biblioteca compartida en GitLab
- Funciones reutilizables (buildDocker, deployHelm)
- Parametrización por proyecto

**Beneficios:**
- 📉 Reducción 70% líneas de código
- 🔧 Mantenimiento centralizado
- 🚀 Onboarding rápido de nuevos proyectos

```groovy
// Antes: 150 líneas por proyecto
// Después: 30 líneas + shared library
@Library('devops-shared') _

pipeline {
    agent any
    stages {
        stage('Build & Deploy') {
            steps {
                buildAndDeployApp(
                    appName: 'petclinic-angular',
                    buildTool: 'npm'
                )
            }
        }
    }
}
```

---

### 4. **Ingress Routing con Dominios Personalizados**

**Desafío:** Acceder a apps sin puerto, con URLs amigables

**Arquitectura implementada:**
```
Windows Browser (http://mi-app.local)
    ↓
WSL2 Nginx (puerto 80)
    ↓
kubectl port-forward (8081)
    ↓
Ingress Controller (nginx-ingress)
    ↓
Service (ClusterIP)
    ↓
Pods (aplicación)
```

**Aprendizajes:**
- Limitaciones de Minikube en WSL2
- Diferencia entre Ingress y Service
- Configuración de host-based routing
- Debugging de networking issues

---

### 5. **Container Registry Privado**

**Implementación:**
- Docker Registry en localhost:5000
- Autenticación básica
- Secret de Kubernetes para pull images

**Flujo:**
```bash
# Build local
docker build -t localhost:5000/app:v1 .

# Push a registry privado
docker push localhost:5000/app:v1

# K8s pull con secret
kubectl create secret docker-registry regcred \
    --docker-server=host.docker.internal:5000 \
    --docker-username=admin \
    --docker-password=pass

# Deployment usa imagePullSecrets
spec:
  imagePullSecrets:
  - name: regcred
```

---

## 🔑 Terminología Clave y Diferencias

### 1. **Image vs Container**

| Image | Container |
|-------|-----------|
| Plantilla estática | Instancia ejecutable |
| Inmutable | Tiene estado |
| En registry | En runtime |
| Se construye (build) | Se ejecuta (run) |
| Como "clase" | Como "objeto" |

---

### 2. **Deployment vs StatefulSet vs DaemonSet**

**Deployment:**
- Apps **sin estado** (stateless)
- Pods intercambiables
- Ejemplo: APIs REST, frontends
- Escalado horizontal simple

**StatefulSet:**
- Apps **con estado** (stateful)
- Pods con identidad única
- Ejemplo: Bases de datos, Kafka
- Orden de arranque/parada garantizado

**DaemonSet:**
- **Un pod por nodo**
- Ejemplo: Logs collectors, monitoring agents
- No se escala manualmente

---

### 3. **ConfigMap vs Secret**

| ConfigMap | Secret |
|-----------|--------|
| Datos no sensibles | Datos sensibles |
| Plain text | Base64 encoded |
| Variables de entorno | Passwords, tokens, certs |
| `env.API_URL` | `MYSQL_PASSWORD` |

**Uso en tu proyecto:**
```yaml
# ConfigMap
env:
- name: API_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: api-url

# Secret
env:
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: db-secret
      key: password
```

---

### 4. **NodePort vs ClusterIP vs LoadBalancer**

**ClusterIP (por defecto):**
- Solo accesible **dentro del cluster**
- IP interna estable
- Uso: comunicación entre servicios

**NodePort:**
- Expone en **puerto del nodo** (30000-32767)
- Accesible externamente via `<NodeIP>:<NodePort>`
- Uso: desarrollo, testing

**LoadBalancer:**
- Provisiona **IP pública** (cloud provider)
- Distribuye tráfico entre nodos
- Uso: producción en cloud (AWS ELB, GCP LB)

**Ingress (bonus):**
- No es un tipo de Service
- Layer 7 (HTTP/HTTPS)
- Routing basado en host/path
- Requiere Ingress Controller

---

### 5. **Dockerfile Stages: Single vs Multi-stage**

**Single-stage (❌ no óptimo):**
```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
# Problema: Imagen final contiene node_modules completo
```

**Multi-stage (✅ tu implementación):**
```dockerfile
# Stage 1: Build
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Stage 2: Production
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
# Resultado: Imagen 10x más pequeña
```

**Ventajas multi-stage:**
- Imágenes más ligeras (menos MBs)
- Solo runtime en producción
- Más seguro (menos superficie de ataque)

---

### 6. **Imperative vs Declarative (Kubernetes)**

**Imperative (comandos):**
```bash
kubectl create deployment nginx --image=nginx
kubectl scale deployment nginx --replicas=3
kubectl expose deployment nginx --port=80
```
❌ No versionable, difícil de replicar

**Declarative (YAML):**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    spec:
      containers:
      - name: nginx
        image: nginx
```
```bash
kubectl apply -f deployment.yaml
```
✅ Versionado en Git, idempotente, reproducible

**Tu enfoque:** Siempre declarativo + Helm

---

### 7. **Rolling Update vs Recreate**

**Rolling Update (por defecto):**
```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 1
    maxSurge: 1
```
- Actualiza pods gradualmente
- Zero downtime
- Rollback automático si falla

**Recreate:**
```yaml
strategy:
  type: Recreate
```
- Mata todos los pods
- Crea nuevos
- Downtime inevitable
- Útil para apps con estado incompatible

---

### 8. **webhook vs Polling (CI/CD)**

**Polling (❌ antiguo):**
- Jenkins pregunta cada X minutos: "¿hay cambios?"
- Desperdicia recursos
- Delay inevitable

**Webhook (✅ tu implementación):**
- GitLab notifica a Jenkins al instante
- Trigger inmediato
- Más eficiente

**Configuración:**
```
GitLab → Settings → Webhooks
URL: http://jenkins:8080/project/nombre-job
Trigger: Push events, Merge request events
```

---

### 9. **Docker Compose vs Kubernetes**

| Docker Compose | Kubernetes |
|----------------|------------|
| **Desarrollo** local | **Producción** cluster |
| Archivo único (docker-compose.yml) | Múltiples manifiestos |
| Single host | Multi-node |
| Sin auto-scaling | Auto-scaling nativo |
| Sin auto-healing | Self-healing pods |
| Redes simples | Networking avanzado |

**Tu uso:**
- Docker Compose: Levantar GitLab/Jenkins localmente
- Kubernetes: Desplegar aplicaciones

---

### 10. **Persistent Volume vs Persistent Volume Claim**

**PersistentVolume (PV):**
- Recurso de **almacenamiento** en el cluster
- Provisionado por admin
- Independiente de pods

**PersistentVolumeClaim (PVC):**
- **Solicitud** de almacenamiento por un pod
- Define tamaño y modo de acceso
- Kubernetes hace el binding

**Analogía:** PV = apartamento disponible, PVC = solicitud de alquiler

```yaml
# PVC (lo que defines)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mysql-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi

# Deployment usa el PVC
volumes:
- name: mysql-storage
  persistentVolumeClaim:
    claimName: mysql-pvc
```

---

## 🔄 Flujos de Trabajo

### Flujo CI/CD Completo (End-to-End)

```
1. Developer
   ├─ git commit & push a GitLab
   │
2. GitLab
   ├─ Detecta push
   ├─ Webhook a Jenkins
   │
3. Jenkins Pipeline
   ├─ Stage 1: Checkout
   │   └─ git clone del repo
   ├─ Stage 2: Build
   │   └─ npm install / mvn package
   ├─ Stage 3: Test
   │   └─ Unit tests
   ├─ Stage 4: Docker Build
   │   └─ docker build -t app:${BUILD_NUMBER}
   ├─ Stage 5: Push Registry
   │   └─ docker push localhost:5000/app:${BUILD_NUMBER}
   ├─ Stage 6: Deploy K8s
   │   └─ helm upgrade --install app ./chart
   │       ├─ Actualiza Deployment
   │       ├─ Rolling update
   │       └─ Crea/actualiza Service e Ingress
   │
4. Kubernetes
   ├─ Pull imagen del registry
   ├─ Crea nuevos pods
   ├─ Health checks
   ├─ Termina pods antiguos
   │
5. Usuario
   └─ Accede a http://mi-app.local
       ├─ Ingress NGINX
       ├─ Service
       └─ Pods (nueva versión)
```

---

### Flujo de Rollback

```
1. Detección de problema
   ├─ Logs en Jenkins
   ├─ Monitoring (si estuviera implementado)
   │
2. Rollback automático (K8s)
   ├─ Readiness probe falla
   ├─ Rolling update se detiene
   │
3. Rollback manual (Helm)
   $ helm rollback app 0  # Última versión estable
   │
4. Verificación
   ├─ kubectl get pods -w
   └─ Acceso a la app
```

---

### Flujo de Hotfix

```
1. Bug crítico detectado
   │
2. Crear rama de hotfix
   $ git checkout -b hotfix/critical-bug
   │
3. Fix y commit
   $ git commit -m "fix: critical bug"
   │
4. Push a GitLab
   $ git push origin hotfix/critical-bug
   │
5. Merge request a main
   │
6. Merge → Trigger automático
   │
7. Deploy a producción (main branch)
```

---

## 🏗️ Arquitecturas Desplegadas

### Arquitectura 1: Aplicación Angular en Kubernetes

```
┌─────────────────────────────────────────────────────┐
│                  Windows Browser                     │
│            http://petclinic-angular.local            │
└──────────────────────┬──────────────────────────────┘
                       │ HTTP :80
┌──────────────────────▼──────────────────────────────┐
│                    WSL2 Nginx                        │
│              (Reverse Proxy Local)                   │
│         proxy_pass → localhost:8081                  │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│             kubectl port-forward                     │
│    127.0.0.1:8081 → ingress-controller:80           │
└──────────────────────┬──────────────────────────────┘
                       │
┌──────────────────────▼──────────────────────────────┐
│                 Minikube Cluster                     │
│  ┌─────────────────────────────────────────────┐   │
│  │      Ingress Controller (nginx-ingress)      │   │
│  │  Rule: petclinic-angular.local → service    │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                                │
│  ┌──────────────────▼──────────────────────────┐   │
│  │  Service: petclinic-angular-service         │   │
│  │  Type: ClusterIP                            │   │
│  │  Port: 80                                   │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                                │
│  ┌──────────────────▼──────────────────────────┐   │
│  │  Deployment: petclinic-angular              │   │
│  │  Replicas: 1                                │   │
│  │  Image: localhost:5000/petclinic-angular    │   │
│  └──────────────────┬──────────────────────────┘   │
│                     │                                │
│  ┌──────────────────▼──────────────────────────┐   │
│  │  Pod: nginx:alpine                          │   │
│  │  + Angular build (dist/)                    │   │
│  │  Serving en puerto 80                       │   │
│  └─────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

---

### Arquitectura 2: Full Stack Petclinic

```
┌──────────────────────────────────────────────────────┐
│                     Usuario                          │
└──────────────────┬───────────────────────────────────┘
                   │
    ┌──────────────▼───────────────┐
    │     Ingress Controller       │
    │                              │
    │  /           → Angular       │
    │  /api/v1/*  → Spring Boot    │
    └──────────┬─────────┬─────────┘
               │         │
    ┌──────────▼──┐   ┌─▼──────────────┐
    │  Service    │   │   Service       │
    │  Angular    │   │   Spring Boot   │
    └──────┬──────┘   └──────┬──────────┘
           │                  │
    ┌──────▼──────┐   ┌──────▼──────────┐
    │ Deployment  │   │  Deployment     │
    │ (3 replicas)│   │  (2 replicas)   │
    │             │   │                 │
    │ Pod nginx   │   │  Pod Java app   │
    │ + Angular   │   │  + Spring Boot  │
    └─────────────┘   └────────┬────────┘
                               │
                      ┌────────▼─────────┐
                      │  Service MySQL   │
                      │  (Stateful)      │
                      └────────┬─────────┘
                               │
                      ┌────────▼─────────┐
                      │  StatefulSet     │
                      │  MySQL           │
                      │  + PVC (5Gi)     │
                      └──────────────────┘
```

---

### Arquitectura 3: CI/CD Pipeline

```
┌──────────────────────────────────────────────────────┐
│                    Developer                          │
│   git push → GitLab (localhost:8929)                 │
└──────────────────┬───────────────────────────────────┘
                   │ Webhook
┌──────────────────▼───────────────────────────────────┐
│                Jenkins (localhost:8080)               │
│  ┌────────────────────────────────────────────────┐  │
│  │            Pipeline Execution                  │  │
│  │                                                │  │
│  │  1. Checkout → git clone                      │  │
│  │  2. Build → npm install / mvn package         │  │
│  │  3. Test → unit tests                         │  │
│  │  4. Docker Build → docker build               │  │
│  │  5. Push → localhost:5000/app:v1              │  │
│  │  6. Deploy → helm upgrade                     │  │
│  └────────────────────────────────────────────────┘  │
│                        │                              │
│  ┌────────────────────▼──────────────────────────┐  │
│  │     Docker-in-Docker (DinD)                   │  │
│  │     - docker build                            │  │
│  │     - docker push                             │  │
│  └────────────────────┬──────────────────────────┘  │
└────────────────────────┼──────────────────────────────┘
                         │
         ┌───────────────▼───────────────┐
         │   Container Registry          │
         │   localhost:5000              │
         │   - petclinic-angular:latest  │
         │   - petclinic-backend:latest  │
         └───────────────┬───────────────┘
                         │
         ┌───────────────▼───────────────┐
         │   Kubernetes (Minikube)       │
         │   kubectl apply / helm deploy │
         └───────────────────────────────┘
```

---

## ✅ Mejores Prácticas Aplicadas

### 1. **Inmutabilidad de Imágenes**
```bash
# ❌ Mal: Siempre usar :latest
image: myapp:latest

# ✅ Bien: Tag con versión o build number
image: myapp:1.2.3
image: myapp:${BUILD_NUMBER}
```

### 2. **Health Checks**
```yaml
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### 3. **Resource Limits**
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### 4. **Secrets Externos**
```groovy
// ❌ Mal: Hardcodear passwords
def password = "admin123"

// ✅ Bien: Usar credenciales de Jenkins
withCredentials([usernamePassword(...)]) {
    sh "docker login -u ${USERNAME} -p ${PASSWORD}"
}
```

### 5. **Namespaces para Aislamiento**
```bash
# Desarrollo
kubectl create namespace dev
kubectl apply -f app.yaml -n dev

# Producción
kubectl create namespace prod
kubectl apply -f app.yaml -n prod
```

### 6. **Labels y Selectors Consistentes**
```yaml
metadata:
  labels:
    app: petclinic
    tier: frontend
    env: prod
    version: v1.2.3
```

### 7. **Logging Estructurado**
```groovy
// En Jenkinsfile
echo "[INFO] Starting build for ${env.JOB_NAME}"
echo "[ERROR] Build failed at stage ${STAGE_NAME}"
```

### 8. **Rollback Strategy**
```bash
# Helm mantiene historial
helm list
helm history petclinic-angular
helm rollback petclinic-angular 2
```

---

## 🔧 Comandos Clave

### Docker
```bash
# Build y tag
docker build -t myapp:v1 .
docker tag myapp:v1 localhost:5000/myapp:v1

# Push/Pull
docker push localhost:5000/myapp:v1
docker pull localhost:5000/myapp:v1

# Inspeccionar
docker ps
docker logs <container_id>
docker exec -it <container_id> sh

# Limpieza
docker system prune -a
docker volume prune
```

### Kubernetes
```bash
# Deployments
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl describe deployment myapp
kubectl scale deployment myapp --replicas=5

# Pods
kubectl get pods -o wide
kubectl logs <pod-name>
kubectl exec -it <pod-name> -- sh
kubectl delete pod <pod-name>

# Services
kubectl get services
kubectl describe service myapp
kubectl port-forward service/myapp 8080:80

# Ingress
kubectl get ingress
kubectl describe ingress myapp

# Debugging
kubectl get events --sort-by='.lastTimestamp'
kubectl top nodes
kubectl top pods
```

### Helm
```bash
# Instalar/actualizar
helm install myapp ./chart -f values.yaml
helm upgrade myapp ./chart -f values.yaml
helm upgrade --install myapp ./chart  # Ambos en uno

# Listar y eliminar
helm list
helm uninstall myapp

# Historial y rollback
helm history myapp
helm rollback myapp 2

# Template rendering (test)
helm template myapp ./chart -f values.yaml
```

### Git
```bash
# Workflow básico
git clone <url>
git checkout -b feature/nueva-feature
git add .
git commit -m "feat: descripción"
git push origin feature/nueva-feature

# Ver estado
git status
git log --oneline
git diff

# Branches
git branch -a
git checkout main
git merge feature/nueva-feature
```

---

## 🎤 Preguntas Frecuentes de Entrevista

### 1. **"¿Qué es DevOps para ti?"**

**Respuesta:**
> "DevOps es una cultura que une desarrollo y operaciones para automatizar el ciclo de vida del software. En mi proyecto personal, implementé un pipeline CI/CD completo donde cada commit dispara automáticamente build, tests y despliegue a Kubernetes. Esto reduce el tiempo de entrega y aumenta la calidad mediante pruebas automáticas."

---

### 2. **"Explica tu experiencia con CI/CD"**

**Respuesta:**
> "Implementé un entorno con GitLab y Jenkins dockerizados. Cuando hago push a GitLab, un webhook dispara un pipeline de Jenkins que:
> 1. Hace checkout del código
> 2. Build con npm/Maven
> 3. Ejecuta tests
> 4. Construye imagen Docker con multi-stage builds
> 5. Push al registry local
> 6. Despliega a Kubernetes usando Helm
> 
> Esto permite desplegar múltiples veces al día con confianza."

---

### 3. **"¿Qué diferencia hay entre Docker y Kubernetes?"**

**Respuesta:**
> "Docker es la plataforma de contenedores que empaqueta aplicaciones. Kubernetes es el orquestador que gestiona esos contenedores a escala. Docker ejecuta contenedores en un solo host, Kubernetes los distribuye entre múltiples nodos, con auto-scaling, auto-healing y load balancing. En mi proyecto uso Docker para crear imágenes y Kubernetes para desplegarlas."

---

### 4. **"¿Cómo gestionas secretos?"**

**Respuesta:**
> "Uso varios niveles:
> - **Jenkins Credentials:** Para passwords del registry
> - **Kubernetes Secrets:** Para credenciales de base de datos y APIs
> - **imagePullSecrets:** Para autenticación en registry privado
> 
> Nunca hardcodeo secretos en código ni en archivos de configuración versionados."

---

### 5. **"Explica un problema que hayas resuelto"**

**Respuesta:**
> "En Minikube con WSL2, el LoadBalancer no funciona nativamente. Resolví esto implementando un Ingress Controller con nginx, más un proxy nginx local que escucha en puerto 80 y hace port-forward al Ingress. Esto me permitió acceder a las apps con URLs amigables sin puerto, simulando producción."

---

### 6. **"¿Qué es Helm y por qué usarlo?"**

**Respuesta:**
> "Helm es un gestor de paquetes para Kubernetes que permite crear templates reutilizables. En lugar de tener 10 archivos YAML con configuraciones hardcodeadas, creo un chart con templates y un values.yaml. Puedo desplegar la misma app en dev/prod solo cambiando valores. Además, Helm mantiene historial para rollbacks fáciles."

---

### 7. **"¿Cómo debuggeas un pod que falla?"**

**Respuesta estructurada:**
```bash
# 1. Ver estado
kubectl get pods

# 2. Describir pod (eventos)
kubectl describe pod <pod-name>

# 3. Ver logs
kubectl logs <pod-name>

# 4. Si crashea inmediatamente
kubectl logs <pod-name> --previous

# 5. Entrar al pod (si está running)
kubectl exec -it <pod-name> -- sh

# 6. Ver eventos del cluster
kubectl get events --sort-by='.lastTimestamp'
```

---

### 8. **"¿Diferencia entre Deployment y StatefulSet?"**

**Respuesta:**
> "Deployment es para apps stateless como APIs REST o frontends. Los pods son intercambiables y se identifican por hash aleatorio. StatefulSet es para apps stateful como bases de datos, donde cada pod necesita identidad única (mysql-0, mysql-1) y volúmenes persistentes asociados. El orden de arranque/parada está garantizado."

---

### 9. **"¿Cómo aseguras zero-downtime deployments?"**

**Respuesta:**
> "Uso Rolling Updates de Kubernetes configurando:
> - `maxUnavailable: 1` → Solo 1 pod puede estar down
> - `maxSurge: 1` → Solo 1 pod extra durante update
> - `readinessProbe` → K8s solo enruta tráfico a pods listos
> 
> Además, uso Helm para despliegues controlados con posibilidad de rollback."

---

### 10. **"¿Qué mejorarías en tu setup actual?"**

**Respuesta (muestra madurez):**
> "Actualmente implementaría:
> - **Monitoring:** Prometheus + Grafana para métricas
> - **Logging centralizado:** ELK stack o Loki
> - **Security scanning:** Trivy para escanear imágenes Docker
> - **GitOps:** ArgoCD para despliegues declarativos
> - **Tests automatizados:** Integración con Selenium/Cypress
> - **Infrastructure as Code:** Terraform para gestionar infraestructura cloud"

---

## 📊 Métricas de tu Proyecto

**Para impresionar con datos concretos:**

- ✅ **2 aplicaciones** desplegadas (Angular + Spring Boot)
- ✅ **Reducción 70%** en código de pipelines con centralización
- ✅ **Tiempo de deploy:** < 5 minutos desde commit a producción
- ✅ **0 configuraciones manuales** (todo automatizado)
- ✅ **Docker images:** < 50MB (Angular) gracias a multi-stage builds
- ✅ **Alta disponibilidad:** Múltiples réplicas con auto-restart
- ✅ **15+ herramientas** integradas (Git, GitLab, Jenkins, Docker, K8s, Helm, nginx, etc.)

---

## 🎯 Puntos Clave para la Entrevista

### Lo que has logrado:
1. ✅ **Entorno CI/CD funcional** desde cero
2. ✅ **Automatización completa** del ciclo de vida
3. ✅ **Infraestructura como código** (Dockerfiles, K8s manifests, Helm)
4. ✅ **Resolución de problemas reales** (networking WSL2, registry privado)
5. ✅ **Mejores prácticas** (multi-stage builds, health checks, secrets)
6. ✅ **Documentación exhaustiva** (todas tus guías)

### Habilidades técnicas:
- 🔧 **Git/GitLab:** Control de versiones, webhooks
- 🔧 **Jenkins:** Pipelines declarativos, shared libraries
- 🔧 **Docker:** Containerización, registry, multi-stage builds
- 🔧 **Kubernetes:** Deployments, Services, Ingress, Secrets, Helm
- 🔧 **Networking:** nginx, reverse proxy, Ingress routing
- 🔧 **Linux:** WSL2, bash scripting, systemd

### Soft skills demostradas:
- 📚 **Autodidacta:** Aprendiste todo por tu cuenta
- 🔍 **Problem-solving:** Resolviste limitaciones de WSL2
- 📖 **Documentación:** Guías detalladas paso a paso
- 🚀 **Iniciativa:** Proyecto completo sin dirección externa
- 🎯 **Orientación a resultados:** Pipeline funcional end-to-end

---

## 💡 Consejos para la Entrevista

### Antes:
1. **Revisa este documento** completo
2. **Prueba tu setup** que todo funcione
3. **Prepara demo en vivo** (si te lo piden)
4. **Ten ejemplos concretos** de problemas resueltos

### Durante:
1. **Sé específico:** "Usé Helm charts con templates" en vez de "usé Kubernetes"
2. **Menciona problemas:** "Tuve X problema, lo resolví con Y"
3. **Usa terminología correcta:** No digas "Docker Kubernetes", di "contenedores en Kubernetes"
4. **Pregunta activamente:** Muestra interés por su stack

### Errores a evitar:
- ❌ "Lo instalé y ya" → ✅ "Implementé X para resolver Y"
- ❌ Memorizar sin entender → ✅ Explica con tus palabras
- ❌ Decir "no sé" y quedarse callado → ✅ "No lo he usado, pero es similar a X que sí conozco"

---

## 🚀 Demo Rápida (si te la piden)

**Script de 5 minutos:**

```bash
# 1. Mostrar infraestructura corriendo
minikube status
kubectl get nodes

# 2. Ver aplicación desplegada
kubectl get deployments,services,ingress

# 3. Hacer un cambio en código
# (editar un texto en Angular)

# 4. Push a GitLab
git add .
git commit -m "demo: cambio visual"
git push origin main

# 5. Mostrar Jenkins
# (abrir navegador: localhost:8080)
# Ver pipeline ejecutándose

# 6. Verificar despliegue
kubectl get pods -w

# 7. Acceder a la app
# (navegador: http://mi-app.local)
# Mostrar el cambio aplicado

# Total: Desde commit a producción en < 5 min
```

---

## 📚 Recursos Adicionales Mencionables

**Lo que has estudiado/usado:**
- Documentación oficial de Docker
- Documentación oficial de Kubernetes
- Guías de Jenkins pipelines
- Helm documentation
- Stack Overflow (troubleshooting)
- Comunidad DevOps (prácticas)

---

## 🎓 Conclusión

Has construido un **entorno DevOps completo y funcional** que muchos seniors no tienen. Tienes:

✅ **Conocimientos teóricos** sólidos
✅ **Experiencia práctica** con herramientas reales
✅ **Resolución de problemas** documentada
✅ **Mindset DevOps** de automatización y mejora continua

**Tu ventaja competitiva:**
- No solo sabes teoría, **lo has implementado**
- No solo funciona, **está documentado**
- No solo lo hiciste una vez, **es reproducible**

**Recuerda:**
> "No busco ser el DevOps que todo lo sabe, busco ser el que aprende rápido y automatiza todo."

---

## 📞 Contacto

**Adrián Martín Romo Cañadas**
- 📧 Email: (según tu CV)
- 💼 LinkedIn: (según tu CV)
- 🔗 GitHub: (según tu CV)

---

**¡Mucha suerte en tu entrevista! 🚀**

*Recuerda: La confianza viene de saber que has hecho el trabajo. Tú lo has hecho.*

---

## 📝 Notas Finales para Repasar

### Pregunta sorpresa posible: "¿Por qué DevOps?"

**Respuesta personal sugerida:**
> "Me apasiona la automatización y ver cómo el código pasa de desarrollo a producción de forma fluida. DevOps elimina fricción entre equipos y permite entregar valor al usuario final más rápido. Además, combina desarrollo con infraestructura, que son las dos áreas que más me interesan."

### Si te preguntan por herramientas que NO has usado:

**Ejemplo: "¿Has usado Terraform?"**
> "No en profundidad, pero entiendo que es Infrastructure as Code para provisionar recursos en cloud. Es similar conceptualmente a cómo uso Helm para desplegar en Kubernetes - ambos son declarativos y versionables. Sería mi siguiente paso lógico para gestionar la infraestructura subyacente."

### Cierre fuerte:

> "He invertido cientos de horas aprendiendo DevOps por mi cuenta porque realmente me apasiona. Este proyecto es solo el comienzo - estoy ansioso por aplicar y expandir estos conocimientos en un entorno profesional con mentores experimentados."

---

**📌 Guarda este documento y léelo antes de la entrevista.**
**📌 Practica explicar 2-3 conceptos en voz alta.**
**📌 Ten tu proyecto corriendo y listo para mostrar.**

**¡Vas a hacerlo genial! 💪**
```

Este documento cubre:
✅ Definiciones claras de DevOps y conceptos
✅ Terminología técnica con diferencias explicadas
✅ Todos tus proyectos documentados
✅ Flujos de trabajo completos
✅ Arquitecturas visuales
✅ Mejores prácticas que aplicaste
✅ Comandos esenciales
✅ Preguntas de entrevista con respuestas
✅ Consejos prácticos
✅ Métricas concretas

¿Quieres que ajuste algo específico, añada más profundidad en algún tema, o prepare preguntas técnicas adicionales que te puedan hacer?Este documento cubre:
✅ Definiciones claras de DevOps y conceptos
✅ Terminología técnica con diferencias explicadas
✅ Todos tus proyectos documentados
✅ Flujos de trabajo completos
✅ Arquitecturas visuales
✅ Mejores prácticas que aplicaste
✅ Comandos esenciales
✅ Preguntas de entrevista con respuestas
✅ Consejos prácticos
✅ Métricas concretas

¿Quieres que ajuste algo específico, añada más profundidad en algún tema, o prepare preguntas técnicas adicionales que te puedan hacer?