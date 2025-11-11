# 🚀 Preparación para Entrevista DevOps - Adrián Martín Romo Cañadas

**Fecha:** Noviembre 2025  
**Nivel:** Junior DevOps Engineer  
**Objetivo:** Demostrar conocimientos prácticos y teóricos en DevOps, CI/CD y contenedores

---

## 📌 Índice Completo

### Sección 1: Fundamentos
1. [Definición de DevOps](#-definición-de-devops)
2. [Mi Proyecto DevOps - Resumen Ejecutivo](#-mi-proyecto-devops---resumen-ejecutivo)
3. [Flujo CI/CD Completo Implementado](#-flujo-cicd-completo-implementado)

### Sección 2: Conocimientos Técnicos
4. [Conceptos DevOps Fundamentales](#-conceptos-devops-fundamentales)
   - 4.1 [CI/CD](#1-cicd-continuous-integration--continuous-delivery)
   - 4.2 [Contenedores y Docker](#2-contenedores-y-docker)
   - 4.3 [Kubernetes](#3-orquestación-de-contenedores---kubernetes)
   - 4.4 [Jenkins](#4-jenkins---cicd-automation)
   - 4.5 [Git y GitLab](#5-git-y-control-de-versiones)
   - 4.6 [Helm](#6-helm---package-manager-para-kubernetes)
   - 4.7 [Ingress](#7-ingress---acceso-externo-a-kubernetes)
5. [Herramientas y Tecnologías Dominadas](#%EF%B8%8F-herramientas-y-tecnologías-dominadas)

### Sección 3: Experiencia Práctica
6. [Problemas Resueltos y Soluciones Implementadas](#-problemas-resueltos-y-soluciones-implementadas)
7. [Diferencias de Terminología Clave](#-diferencias-de-terminología-clave)
8. [Comandos Críticos por Herramienta](#-comandos-críticos-por-herramienta)
9. [Logros Técnicos Medibles](#-logros-técnicos-medibles)

### Sección 4: Visión y Preparación
10. [Próximos Pasos y Mejoras Planificadas](#-próximos-pasos-y-mejoras-planificadas)
11. [Respuestas a Preguntas Frecuentes de Entrevista](#-respuestas-a-preguntas-frecuentes-de-entrevista)
12. [Mejores Prácticas Aplicadas](#-mejores-prácticas-aplicadas)
13. [Referencias y Recursos Utilizados](#-referencias-y-recursos-utilizados)
14. [Conclusión](#-conclusión)

### Sección 5: IMPRESCINDIBLE
15. [⚡ MEGA RESUMEN - IMPRESCINDIBLES PARA LA ENTREVISTA](#-mega-resumen---imprescindibles-para-la-entrevista)

---

## 🎯 Definición de DevOps

**DevOps** es una cultura y conjunto de prácticas que integra el desarrollo de software (Development) con las operaciones de IT (Operations). Los profesionales DevOps son responsables de **automatizar y mejorar el ciclo de vida completo del software**, desde el desarrollo hasta el despliegue en producción, aplicando principios de **Integración Continua (CI)** y **Despliegue Continuo (CD)**.

**Objetivo principal:** Reducir el tiempo entre escribir código y ponerlo en producción de forma confiable y repetible.

---

## 🎯 Mi Proyecto DevOps - Resumen Ejecutivo

He construido un **entorno DevOps completo y funcional** desde cero, incluyendo:

### Arquitectura Implementada

```
┌─────────────────────────────────────────────────────────────────┐
│                        Host (Windows/WSL)                       │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   GitLab     │  │   Jenkins    │  │   Registry   │        │
│  │   :8929      │◄─┤   :8080      │─►│   :5000      │        │
│  │  (SCM)       │  │   (CI/CD)    │  │  (Images)    │        │
│  └──────────────┘  └───────┬──────┘  └──────────────┘        │
│                            │                                    │
│                    devops-net (172.18.0.0/16)                  │
│                            │                                    │
│  ┌─────────────────────────▼──────────────────────────────┐   │
│  │              Minikube (Kubernetes)                       │   │
│  │         192.168.49.2 (cluster IP)                        │   │
│  │                                                           │   │
│  │  Namespace: jenkins                                      │   │
│  │  - Secret: registry-secret (docker-registry)             │   │
│  │  - ServiceAccount: jenkins (admin)                       │   │
│  │  - Deployments: Frontend (Angular) + Backend (Maven)    │   │
│  └──────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Componentes Implementados

| Componente | Tecnología | Puerto | Función |
|------------|-----------|--------|---------|
| **SCM** | GitLab CE | 8929 | Control de versiones, repositorios Git |
| **CI/CD** | Jenkins LTS | 8080 | Automatización de pipelines |
| **Registry** | Docker Registry | 5000 | Almacenamiento privado de imágenes |
| **Orquestador** | Minikube (K8s v1.34) | - | Despliegue y gestión de contenedores |

---

## 🔄 Flujo CI/CD Completo Implementado

### Pipeline End-to-End

```
1. Developer
   ↓ git push
2. GitLab (SCM)
   ↓ webhook trigger
3. Jenkins
   ├─ Checkout código
   ├─ Install dependencies
   ├─ Run tests (Maven: 181 tests | Angular: 43 tests)
   ├─ Build aplicación
   ├─ Build Docker image
   └─ Push to Registry (localhost:5000)
   ↓
4. Deploy to Kubernetes
   ├─ kubectl apply deployment
   ├─ Pull image from registry (con imagePullSecret)
   └─ Create pods + services
   ↓
5. Application Running ✅
```

### Proyectos Reales Implementados

**Frontend - Petclinic Angular:**
- Framework: Angular + TypeScript
- Tests: 43 tests automatizados con Karma + Chrome Headless
- Server: Nginx optimizado
- Imagen Docker: Multi-stage build (node:18 → nginx:alpine)

**Backend - Petclinic REST API:**
- Framework: Spring Boot + Maven
- Tests: 181 tests unitarios
- Empaquetado: JAR ejecutable
- Imagen Docker: Multi-stage build (maven:3.9 → eclipse-temurin:17-jre)

---

## 📚 Conceptos DevOps Fundamentales

### 1. CI/CD (Continuous Integration / Continuous Delivery)

#### Continuous Integration (CI)
- **Definición:** Práctica de integrar cambios de código frecuentemente (varias veces al día)
- **Objetivo:** Detectar errores temprano mediante tests automatizados
- **Herramientas:** Jenkins, GitLab CI, GitHub Actions
- **En mi proyecto:** Jenkins ejecuta tests automáticamente en cada push a GitLab

#### Continuous Delivery (CD)
- **Definición:** Capacidad de desplegar código a producción en cualquier momento
- **Objetivo:** Reducir el tiempo entre escribir código y ponerlo en producción
- **Diferencia con Continuous Deployment:** CD requiere aprobación manual; Deployment es 100% automático
- **En mi proyecto:** Jenkins construye y despliega automáticamente en Kubernetes

### 2. Contenedores y Docker

#### ¿Qué es Docker?
- **Definición:** Plataforma de contenedorización que empaqueta aplicaciones con todas sus dependencias
- **Ventaja principal:** "Funciona en mi máquina" = "Funciona en todas las máquinas"

#### Imagen vs Contenedor
| Concepto | Imagen | Contenedor |
|----------|--------|------------|
| **Definición** | Plantilla inmutable (read-only) | Instancia en ejecución (read-write) |
| **Estado** | Estática | Dinámica |
| **Comando** | `docker build` | `docker run` |
| **Analogía** | Receta de cocina | Plato cocinado |
| **Cantidad** | Una versión | Múltiples instancias |

#### Dockerfile
- **Definición:** Archivo de texto con instrucciones para construir una imagen Docker
- **Instrucciones clave:**
  - `FROM`: Imagen base
  - `RUN`: Ejecutar comandos durante el build
  - `COPY`: Copiar archivos del host
  - `WORKDIR`: Directorio de trabajo
  - `EXPOSE`: Puerto que expone la aplicación (informativo)
  - `CMD`: Comando por defecto al iniciar el contenedor
  - `ENTRYPOINT`: Punto de entrada fijo (no se puede sobrescribir)

#### Multi-Stage Builds
- **Definición:** Técnica para optimizar imágenes usando múltiples `FROM` en un solo Dockerfile
- **Ventaja:** Imagen final más pequeña (solo contiene runtime, no herramientas de build)
- **Ejemplo:**
  ```dockerfile
  # Stage 1: Build
  FROM maven:3.9 AS builder
  COPY . /app
  RUN mvn clean package
  
  # Stage 2: Runtime
  FROM eclipse-temurin:17-jre
  COPY --from=builder /app/target/app.jar /app.jar
  CMD ["java", "-jar", "/app.jar"]
  ```

#### Docker Registry
- **Definición:** Servidor que almacena y distribuye imágenes Docker
- **Tipos:**
  - **Público:** Docker Hub, GitHub Container Registry
  - **Privado:** Docker Registry local (puerto 5000 en mi proyecto)
- **Comandos:**
  - `docker push`: Subir imagen al registry
  - `docker pull`: Descargar imagen del registry
  - `docker tag`: Etiquetar imagen para registry específico

#### Redes Docker
- **Bridge (por defecto):** Contenedores en el mismo host pueden comunicarse
- **Custom Bridge (`devops-net` en mi proyecto):**
  - DNS automático entre contenedores (jenkins → gitlab:22)
  - Aislamiento de red
  - Mejor control de seguridad

### 3. Orquestación de Contenedores - Kubernetes

#### ¿Qué es Kubernetes (K8s)?
- **Definición:** Sistema de orquestación de contenedores que automatiza el despliegue, escalado y gestión de aplicaciones containerizadas
- **Función principal:** Gestionar múltiples contenedores en múltiples servidores
- **Ventajas:**
  - Auto-healing (reinicia contenedores caídos)
  - Load balancing (distribuye tráfico)
  - Rollouts/rollbacks automáticos
  - Escalado horizontal automático

#### Minikube
- **Definición:** Kubernetes local para desarrollo/testing
- **Ventaja:** Simula un cluster completo en tu máquina
- **Driver Docker:** Minikube corre como contenedor Docker

#### Componentes de Kubernetes

**Pod:**
- Unidad mínima de despliegue en K8s
- Puede contener uno o más contenedores
- Tiene IP propia dentro del cluster

**Deployment:**
- Define el estado deseado de tus pods (réplicas, imagen, etc.)
- K8s se encarga de mantener ese estado
- Permite rollouts y rollbacks

**Service:**
- Punto de entrada estable a un conjunto de pods
- Tipos:
  - `ClusterIP`: Solo accesible dentro del cluster (por defecto)
  - `NodePort`: Expone puerto en cada nodo
  - `LoadBalancer`: Crea balanceador de carga externo

**Namespace:**
- Espacio de nombres para agrupar recursos
- Permite aislar recursos por proyecto/equipo
- En mi proyecto: namespace `jenkins`

**Secret:**
- Almacena información sensible (contraseñas, tokens, certificados)
- Base64 encoded (NO encriptado)
- Tipos:
  - `docker-registry`: Credenciales para Docker Registry
  - `generic`: Datos arbitrarios
  - `tls`: Certificados SSL/TLS

**ServiceAccount:**
- Identidad para aplicaciones que corren en K8s
- Permite autenticación con el API de Kubernetes
- En mi proyecto: cuenta `jenkins` con rol cluster-admin

#### kubectl
- **Definición:** CLI para interactuar con Kubernetes
- **Comandos esenciales:**
  - `kubectl get pods`: Listar pods
  - `kubectl apply -f file.yaml`: Crear/actualizar recursos
  - `kubectl delete`: Eliminar recursos
  - `kubectl logs`: Ver logs de un pod
  - `kubectl describe`: Ver detalles de un recurso

#### imagePullSecrets
- **Definición:** Credenciales para descargar imágenes de registry privado
- **Configuración en deployment:**
  ```yaml
  spec:
    imagePullSecrets:
    - name: registry-secret
  ```

### 4. Jenkins - CI/CD Automation

#### ¿Qué es Jenkins?
- **Definición:** Servidor de automatización open-source para CI/CD
- **Función:** Ejecutar pipelines automatizadas (build, test, deploy)

#### Jenkinsfile
- **Definición:** Archivo que define la pipeline como código (Pipeline as Code)
- **Ubicación:** Raíz del repositorio Git
- **Sintaxis:** Groovy DSL

#### Pipeline Structure
```groovy
pipeline {
    agent { docker { image 'node:18' } }  // Dónde ejecutar
    
    stages {
        stage('Build') {           // Etapa
            steps {                // Pasos
                sh 'npm install'
            }
        }
        stage('Test') {
            steps {
                sh 'npm test'
            }
        }
    }
}
```

#### Shared Libraries
- **Definición:** Código Groovy reutilizable entre múltiples pipelines
- **Estructura obligatoria:**
  ```
  vars/
    commonSteps.groovy  ← Funciones globales
  ```
- **Ventaja:** DRY (Don't Repeat Yourself) - evitar código duplicado
- **En mi proyecto:** `@Library('jenkinspipelines')` para funciones comunes

#### Agents
- **Agent:** Dónde se ejecuta la pipeline
- **Tipos:**
  - `any`: Cualquier agente disponible
  - `docker { image }`: Dentro de un contenedor Docker
  - `kubernetes`: En un pod de Kubernetes

#### Docker-in-Docker (DinD)
- **Concepto:** Ejecutar comandos Docker desde dentro de un contenedor
- **Implementación:** Montar `/var/run/docker.sock` del host
- **En mi proyecto:** Jenkins container puede ejecutar `docker build` y `docker push`

### 5. Git y Control de Versiones

#### GitLab
- **Definición:** Plataforma DevOps completa con Git, CI/CD, Registry
- **GitLab CE:** Community Edition (self-hosted, gratis)
- **En mi proyecto:** Self-hosted en Docker para control total

#### Webhooks
- **Definición:** Notificaciones HTTP automáticas cuando ocurre un evento
- **Flujo:** GitLab detecta push → envía webhook → Jenkins inicia pipeline
- **Ventaja:** Integración automática sin polling

#### Branch Strategy
- **main/master:** Branch principal de producción
- **Feature branches:** Ramas para nuevas funcionalidades
- **Merge estrategias:**
  - `--allow-unrelated-histories`: Para fusionar historiales independientes
  - `--force`: Sobrescribir remoto (usar con precaución)

### 6. Helm - Package Manager para Kubernetes

#### ¿Qué es Helm?
- **Definición:** Gestor de paquetes para Kubernetes (el "npm" de K8s)
- **Ventaja:** Simplifica despliegues complejos de múltiples recursos

#### Helm Chart
- **Definición:** Paquete de archivos que describe recursos de K8s
- **Estructura:**
  ```
  chart/
  ├── Chart.yaml        ← Metadata del chart
  ├── values.yaml       ← Valores configurables
  └── templates/        ← Templates de K8s
      ├── deployment.yaml
      ├── service.yaml
      └── ingress.yaml
  ```

#### Templates y Values
- **Templates:** Archivos YAML con placeholders `{{ .Values.xxx }}`
- **Values:** Archivo con valores que inyectar en templates
- **Ventaja:** Mismo chart para dev, staging, prod con diferentes values

#### Helm Commands
- `helm install`: Desplegar chart
- `helm upgrade`: Actualizar release
- `helm rollback`: Volver a versión anterior
- `helm list`: Listar releases instalados

### 7. Ingress - Acceso Externo a Kubernetes

#### ¿Qué es Ingress?
- **Definición:** Recurso que gestiona acceso HTTP/HTTPS externo a servicios en K8s
- **Ventaja:** Un punto de entrada para múltiples servicios (routing por hostname/path)

#### Ingress Controller
- **Definición:** Implementación que hace funcionar Ingress
- **Más común:** NGINX Ingress Controller
- **En Minikube:** `minikube addons enable ingress`

#### Flujo de tráfico con Ingress
```
Navegador → Ingress Controller (puerto 80)
  ↓
Ingress rules (hostname/path)
  ↓
Service (ClusterIP)
  ↓
Pod (aplicación)
```

---

## 🛠️ Herramientas y Tecnologías Dominadas

### Infraestructura y Orquestación
- ✅ **Docker:** Contenedorización, Dockerfile, multi-stage builds, docker-compose
- ✅ **Kubernetes:** Deployments, Services, Secrets, Namespaces, ServiceAccounts
- ✅ **Minikube:** Setup local de K8s, addons (ingress)
- ✅ **Helm:** Charts, templates, values, releases

### CI/CD
- ✅ **Jenkins:** Pipelines declarativas, Jenkinsfile, Shared Libraries
- ✅ **GitLab:** Self-hosted, webhooks, repositorios Git
- ✅ **Docker Registry:** Registry privado local

### Redes y Conectividad
- ✅ **Docker Networks:** Custom bridge networks (devops-net)
- ✅ **DNS interno:** Resolución de nombres entre contenedores
- ✅ **Port forwarding:** Mapeo de puertos host ↔ contenedores

### Scripting y Automatización
- ✅ **Bash:** Scripts de automatización para startup, backup
- ✅ **Groovy:** Jenkinsfile y Shared Libraries
- ✅ **YAML:** Manifiestos de Kubernetes, docker-compose, Helm values

### Desarrollo
- ✅ **Frontend:** Angular, TypeScript, npm, Karma tests
- ✅ **Backend:** Spring Boot, Maven, Java, JUnit tests
- ✅ **Web Servers:** Nginx (configuración y optimización)

---

## 💡 Problemas Resueltos y Soluciones Implementadas

### 1. Comunicación entre Contenedores

**Problema:** Jenkins no podía conectar con GitLab usando `localhost`  
**Causa:** `localhost` dentro de un contenedor apunta al propio contenedor, no al host  
**Solución:** 
- Crear red Docker custom (`devops-net`)
- Usar hostname del contenedor (`gitlab:22` en lugar de `localhost:2222`)
- DNS automático de Docker resuelve nombres de contenedores

### 2. Branches Desincronizados (main vs master)

**Problema:** GitLab creaba repos con `main`, pero GitHub usa `master`  
**Causa:** Historiales Git independientes (unrelated histories)  
**Solución:**
- `git merge --allow-unrelated-histories`
- Force push del branch correcto: `git push origin master:main --force`
- Configuración global de Git para evitar inconsistencias

### 3. Docker-in-Docker y Registry

**Problema:** Build containers no podían resolver `registry:5000`  
**Causa:** DinD usa Docker daemon del host, que no está en `devops-net`  
**Solución:**
- Usar `localhost:5000` en lugar de `registry:5000`
- Registry expuesto en puerto 5000 del host (`-p 5000:5000`)
- Configurar `insecure-registries` en Docker daemon

### 4. Kubernetes imagePullSecrets

**Problema:** Pods no podían descargar imágenes del registry privado  
**Causa:** Kubernetes necesita credenciales para registries privados  
**Solución:**
- Crear Secret tipo `docker-registry`
- Configurar `imagePullSecrets` en deployment
- Usar `host.docker.internal:5000` desde Minikube

### 5. Minikube Network Isolation

**Problema:** WSL2 no podía alcanzar la red interna de Minikube (192.168.49.2)  
**Causa:** Minikube corre en una red aislada dentro de Docker  
**Solución:**
- Conectar Minikube container a `devops-net`
- `kubectl port-forward` para acceso desde host
- Nginx como proxy local + configuración en `/etc/hosts`

---

## 🎓 Diferencias de Terminología Clave

### CI vs CD vs CD

| Término | Significado | Diferencia |
|---------|-------------|-----------|
| **CI** | Continuous Integration | Integrar código frecuentemente + tests automáticos |
| **CD** | Continuous Delivery | Código listo para desplegar (requiere aprobación manual) |
| **CD** | Continuous Deployment | Despliegue 100% automático a producción |

### Docker: Build vs Run vs Push

| Comando | Acción | Resultado |
|---------|--------|-----------|
| `docker build` | Construir imagen desde Dockerfile | Imagen local |
| `docker run` | Crear contenedor desde imagen | Contenedor en ejecución |
| `docker push` | Subir imagen a registry | Imagen en registry remoto |

### Kubernetes: Deployment vs Pod vs ReplicaSet

| Recurso | Definición | Gestiona |
|---------|-----------|----------|
| **Pod** | Unidad mínima (uno o más contenedores) | Contenedores |
| **ReplicaSet** | Mantiene N réplicas de un pod | Pods |
| **Deployment** | Define estado deseado + rollouts | ReplicaSets |

### Service: ClusterIP vs NodePort vs LoadBalancer

| Tipo | Acceso | Uso típico |
|------|--------|-----------|
| **ClusterIP** | Solo dentro del cluster | Comunicación interna |
| **NodePort** | Puerto en cada nodo (30000-32767) | Desarrollo/testing |
| **LoadBalancer** | IP externa con balanceador | Producción (cloud) |

### Helm: Chart vs Release vs Repository

| Concepto | Definición | Analogía |
|----------|-----------|----------|
| **Chart** | Paquete de K8s | Imagen Docker |
| **Release** | Instancia desplegada de un chart | Contenedor corriendo |
| **Repository** | Colección de charts | Docker Registry |

### Jenkins: Stage vs Step vs Agent

| Elemento | Definición | Nivel |
|----------|-----------|-------|
| **Pipeline** | Definición completa del proceso | Top-level |
| **Stage** | Fase lógica (Build, Test, Deploy) | Nivel 1 |
| **Step** | Acción individual (sh, git, docker) | Nivel 2 |
| **Agent** | Dónde ejecutar (docker, kubernetes) | Configuración |

---

## 🔧 Comandos Críticos por Herramienta

### Docker
```bash
# Gestión de contenedores
docker ps                              # Listar contenedores corriendo
docker ps -a                           # Listar todos los contenedores
docker logs <container>                # Ver logs
docker exec -it <container> bash       # Entrar al contenedor

# Gestión de imágenes
docker images                          # Listar imágenes locales
docker build -t <name>:<tag> .        # Construir imagen
docker tag <image> <registry>/<name>  # Etiquetar imagen
docker push <registry>/<name>         # Subir a registry

# Redes
docker network ls                      # Listar redes
docker network create <name>           # Crear red
docker network connect <net> <cont>   # Conectar contenedor a red
docker network inspect <name>          # Ver detalles de red

# Limpieza
docker system prune -a                 # Limpiar todo (cuidado!)
docker volume prune                    # Limpiar volumes no usados
```

### Kubernetes (kubectl)
```bash
# Gestión de recursos
kubectl get pods                       # Listar pods
kubectl get deployments                # Listar deployments
kubectl get services                   # Listar services
kubectl get all -n <namespace>         # Todo en un namespace

# Aplicar configuración
kubectl apply -f <file.yaml>           # Crear/actualizar recursos
kubectl delete -f <file.yaml>          # Eliminar recursos

# Debugging
kubectl describe pod <name>            # Detalles de un pod
kubectl logs <pod>                     # Logs del pod
kubectl exec -it <pod> -- bash         # Entrar al pod

# Secrets
kubectl create secret docker-registry <name> \
  --docker-server=<registry> \
  --docker-username=<user> \
  --docker-password=<pass>

# Namespaces
kubectl create namespace <name>        # Crear namespace
kubectl config set-context --current --namespace=<name>
```

### Helm
```bash
# Gestión de charts
helm install <name> <chart>            # Instalar chart
helm upgrade <name> <chart>            # Actualizar release
helm rollback <name> <revision>        # Rollback

# Información
helm list                              # Listar releases
helm status <name>                     # Estado de release
helm history <name>                    # Historial de releases

# Testing
helm template <chart>                  # Renderizar templates
helm lint <chart>                      # Validar sintaxis
```

### Jenkins (Groovy)
```groovy
// Pipeline básica
pipeline {
    agent { docker { image 'maven:3.9' } }
    
    stages {
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
    }
}

// Shared Library
@Library('jenkinspipelines') _
commonSteps.setupGitCredentials()
```

### Git
```bash
# Básicos
git clone <url>                        # Clonar repositorio
git status                             # Ver estado
git add .                              # Añadir cambios
git commit -m "message"                # Commit
git push origin <branch>               # Subir cambios

# Branches
git branch                             # Listar branches
git checkout -b <branch>               # Crear y cambiar branch
git merge <branch>                     # Fusionar branch

# Avanzado
git push --force                       # Force push (cuidado!)
git merge --allow-unrelated-histories  # Merge historiales independientes
```

---

## 📊 Logros Técnicos Medibles

### Tests Automatizados
- ✅ **Backend (Maven):** 181 tests ejecutados exitosamente
- ✅ **Frontend (Angular):** 43 tests con Chrome Headless
- ✅ **Coverage:** Integración de tests en pipeline CI/CD

### Optimización de Imágenes Docker
- ✅ **Angular:** 1.2 GB (node:18) → 25 MB (nginx:alpine) [~95% reducción]
- ✅ **Maven:** 850 MB (maven:3.9) → 280 MB (eclipse-temurin:17-jre) [~67% reducción]
- ✅ **Técnica:** Multi-stage builds

### Pipelines Automatizadas
- ✅ **2 pipelines funcionales:** Angular + Maven
- ✅ **Shared Libraries:** Código reutilizable entre proyectos
- ✅ **Trigger automático:** Webhooks GitLab → Jenkins
- ✅ **Deploy automático:** Push a registry + deploy en K8s

### Infraestructura
- ✅ **4 servicios dockerizados:** Jenkins, GitLab, Registry, Minikube
- ✅ **Red custom:** Comunicación aislada entre servicios
- ✅ **Persistencia:** Volumes Docker para datos críticos
- ✅ **Secretos:** Gestión segura con Kubernetes Secrets

---

## 🚦 Próximos Pasos y Mejoras Planificadas

### Mejoras de Seguridad
- [ ] Implementar SSL/TLS en Registry (HTTPS)
- [ ] Secrets encriptados con herramientas como Sealed Secrets o HashiCorp Vault
- [ ] Escaneo de vulnerabilidades en imágenes (Trivy, Clair, Snyk)
- [ ] RBAC más granular en Kubernetes (roles específicos por namespace)
- [ ] Network Policies en K8s para restringir tráfico entre pods
- [ ] Image signing con Cosign/Notary

### Monitoreo y Observabilidad
- [ ] **Prometheus + Grafana** para métricas (CPU, memoria, latencia)
- [ ] **ELK Stack** (Elasticsearch, Logstash, Kibana) para logs centralizados
- [ ] **Jaeger/Zipkin** para distributed tracing
- [ ] Alertas automáticas (PagerDuty, Slack, email)
- [ ] Dashboards personalizados por aplicación

### Escalabilidad
- [ ] Cluster Kubernetes multi-nodo (en lugar de Minikube)
- [ ] **HPA** (Horizontal Pod Autoscaler) basado en CPU/memoria
- [ ] **VPA** (Vertical Pod Autoscaler) para optimizar resources
- [ ] Load balancer con Ingress + cert-manager para SSL automático
- [ ] CDN para assets estáticos (CloudFront, Cloudflare)

### Automatización Avanzada
- [ ] **GitOps con ArgoCD/Flux:** Deploy declarativo sincronizado con Git
- [ ] **Infrastructure as Code con Terraform:** Provisionar infraestructura cloud
- [ ] **Ansible** para configuración de servidores y compliance
- [ ] **Packer** para crear imágenes de máquinas inmutables

### Testing
- [ ] Tests de integración end-to-end (Selenium, Cypress, Playwright)
- [ ] Tests de carga y rendimiento (JMeter, k6, Gatling)
- [ ] Tests de seguridad (OWASP ZAP, Burp Suite)
- [ ] **Quality gates con SonarQube:** Code coverage, code smells, bugs
- [ ] Chaos Engineering (Chaos Monkey) para resiliencia

### CI/CD Avanzado
- [ ] Pipeline multi-stage (dev → staging → prod)
- [ ] Approval gates manuales para producción
- [ ] Blue/Green deployments
- [ ] Canary deployments (despliegue gradual)
- [ ] Feature flags (LaunchDarkly, Unleash)

---

## 💬 Respuestas a Preguntas Frecuentes de Entrevista

### 1. ¿Por qué DevOps?
*"DevOps elimina silos entre desarrollo y operaciones, acelerando el time-to-market y mejorando la calidad mediante automatización. Me apasiona porque combina infraestructura, código y procesos para crear sistemas eficientes y confiables. Además, permite a los desarrolladores tomar más responsabilidad sobre sus aplicaciones en producción, lo cual creo que es el futuro del desarrollo de software."*

### 2. ¿Qué te diferencia como Junior DevOps?
*"He construido un entorno DevOps completo desde cero por iniciativa propia, no solo seguí tutoriales. Implementé pipelines reales con aplicaciones frontend y backend, resolví problemas de networking complejos y optimicé imágenes Docker. Tengo experiencia práctica con la stack completa: Git, Jenkins, Docker, Kubernetes y Helm. Lo más importante es que documenté todo el proceso, demostrando que no solo sé hacer las cosas, sino explicarlas y compartirlas con el equipo."*

### 3. ¿Cuál fue tu mayor desafío técnico?
*"Integrar Minikube con Jenkins y el Docker Registry. El problema era que Minikube corre en su propia red aislada dentro de Docker. Tuve que entender en profundidad cómo funcionan las redes Docker a múltiples niveles: la red custom devops-net para comunicación entre contenedores, configurar imagePullSecrets en Kubernetes para autenticación contra el registry privado, y resolver problemas de DNS interno. La solución requirió conocer varios niveles de abstracción simultáneamente y comprender cómo Docker-in-Docker afecta la resolución de nombres."*

### 4. ¿Cómo aseguras la calidad en CI/CD?
*"Mediante tests automatizados en cada etapa: 181 tests en backend con JUnit y 43 en frontend con Karma y Chrome Headless que se ejecutan en cada push. La pipeline solo continúa si todos los tests pasan. Además, uso multi-stage builds para imágenes más pequeñas y seguras (reducción del 95% en tamaño), Kubernetes secrets para datos sensibles, y health checks (readiness/liveness probes) para asegurar que solo se enruta tráfico a pods saludables."*

### 5. ¿Qué aprendiste de tus errores?
*"Aprendí la importancia de la nomenclatura consistente (main vs master en Git causó muchos problemas de historiales no relacionados), la diferencia entre localhost en diferentes contextos (dentro de un contenedor vs en el host), y que la documentación es clave para el futuro. Cada error lo documenté en Markdown, creando una guía completa de troubleshooting que ahora me permite resolver problemas similares en minutos en lugar de horas."*

### 6. Explica tu experiencia con CI/CD
*"Implementé un entorno con GitLab y Jenkins dockerizados conectados mediante webhooks. Cuando hago push a GitLab, se dispara automáticamente un pipeline de Jenkins que: 1) Hace checkout del código, 2) Instala dependencias (npm/Maven), 3) Ejecuta tests unitarios, 4) Construye la aplicación, 5) Crea imagen Docker con multi-stage builds, 6) Push al registry local privado, 7) Despliega a Kubernetes usando Helm charts. Todo el proceso toma menos de 5 minutos y es completamente automatizado."*

### 7. ¿Qué es Docker y por qué usarlo?
*"Docker es una plataforma de contenedorización que empaqueta aplicaciones con todas sus dependencias en contenedores portables. Resuelve el problema de 'funciona en mi máquina pero no en producción' porque el mismo contenedor corre en cualquier entorno. A diferencia de VMs, los contenedores son ligeros (MBs vs GBs), arrancan en segundos, y comparten el kernel del host, lo que los hace ideales para microservicios y CI/CD."*

### 8. ¿Diferencia entre Docker y Kubernetes?
*"Docker es la plataforma que crea y ejecuta contenedores individuales. Kubernetes es el orquestador que gestiona esos contenedores a escala en múltiples servidores. Docker responde '¿cómo empaqueto mi app?', Kubernetes responde '¿cómo gestiono cientos de contenedores con auto-scaling, auto-healing y load balancing?'. En mi proyecto uso Docker para crear imágenes y Kubernetes para desplegarlas y gestionarlas."*

### 9. ¿Qué es Helm y por qué usarlo?
*"Helm es el gestor de paquetes para Kubernetes, como npm para Node o apt para Linux. Permite crear templates reutilizables (charts) en lugar de tener múltiples archivos YAML con valores hardcodeados. Puedo desplegar la misma aplicación en dev, staging y producción cambiando solo un archivo de valores. Además, Helm mantiene historial de versiones para hacer rollbacks con un solo comando si algo sale mal."*

### 10. ¿Cómo debuggeas un pod que falla?
*"Sigo este proceso sistemático: 1) `kubectl get pods` para ver el estado, 2) `kubectl describe pod <name>` para ver eventos y errores, 3) `kubectl logs <name>` para logs de la aplicación, 4) Si crashea inmediatamente uso `--previous` para ver logs del contenedor anterior, 5) `kubectl exec -it <name> -- sh` para entrar al pod y revisar archivos/procesos, 6) `kubectl get events` para ver eventos del cluster. También verifico que los health checks, recursos y secrets estén correctamente configurados."*

### 11. ¿Diferencia entre Deployment y StatefulSet?
*"Deployment es para aplicaciones stateless como APIs REST o frontends donde los pods son intercambiables y pueden tener nombres aleatorios. StatefulSet es para aplicaciones stateful como bases de datos o Kafka donde cada pod necesita identidad persistente (mysql-0, mysql-1), orden de arranque/parada garantizado, y volúmenes persistentes asociados a cada pod. En mi proyecto uso Deployments para Angular y Spring Boot porque son stateless."*

### 12. ¿Cómo gestionas secretos?
*"Uso múltiples capas: Jenkins Credentials para passwords del registry privado, Kubernetes Secrets para credenciales de base de datos y API tokens, imagePullSecrets específicos para autenticación contra el registry. Nunca hardcodeo secretos en código ni en archivos de configuración versionados. En producción recomendaría herramientas como HashiCorp Vault o Sealed Secrets para encriptación adicional."*

### 13. ¿Cómo aseguras zero-downtime deployments?
*"Uso Rolling Updates de Kubernetes configurando maxUnavailable (máximo 1 pod caído) y maxSurge (máximo 1 pod extra durante update). Implemento readinessProbe para que Kubernetes solo enrute tráfico a pods completamente listos, y livenessProbe para reiniciar pods que fallen. Además, Helm me permite hacer rollbacks instantáneos si detecto problemas después del despliegue."*

### 14. Explica un problema de networking que hayas resuelto
*"En WSL2 con Minikube, el LoadBalancer no funciona nativamente y la red de Minikube (192.168.49.2) no era alcanzable desde el host. Implementé una solución multicapa: 1) Ingress Controller (nginx) en Minikube para HTTP routing, 2) `kubectl port-forward` para exponer el Ingress al host, 3) Nginx local en WSL como proxy reverso escuchando en puerto 80, 4) Configuración de `/etc/hosts` para dominios personalizados. Esto me permitió acceder con URLs amigables como http://mi-app.local sin puerto."*

### 15. ¿Qué mejorarías en tu setup actual?
*"Actualmente implementaría: Prometheus y Grafana para monitoreo de métricas en tiempo real, ELK Stack para logs centralizados y debugging avanzado, Trivy para escaneo automático de vulnerabilidades en imágenes Docker, ArgoCD para GitOps (deploy sincronizado con Git), tests de integración end-to-end con Selenium, y Terraform para gestionar infraestructura como código. Estas mejoras llevarían el proyecto de entorno de desarrollo a nivel producción."*

### 16. ¿Por qué multi-stage builds en Docker?
*"Multi-stage builds separan la fase de compilación de la fase runtime. Por ejemplo, en Angular uso node:18 para compilar (npm install + npm run build) y luego nginx:alpine solo con los archivos estáticos finales. Esto reduce la imagen de 1.2GB a 25MB (~95%), mejora la seguridad al no incluir herramientas de build en producción, y acelera los deploys. Es una best practice fundamental en contenedorización."*

### 17. Explica tu flujo de trabajo Git
*"Uso GitFlow simplificado: main es producción, creo feature branches para desarrollar (`git checkout -b feature/nueva-feature`), hago commits descriptivos con conventional commits (`feat:`, `fix:`, `docs:`), push a GitLab, y el webhook dispara la pipeline automáticamente. Para hotfixes críticos tengo un proceso rápido de rama hotfix → merge a main → deploy automático. Toda la integración es continua gracias a los webhooks."*

### 18. ¿Qué es Infrastructure as Code?
*"Es gestionar infraestructura mediante código versionado en lugar de configuración manual. En mi proyecto uso Dockerfiles para definir imágenes, manifiestos YAML para Kubernetes (deployments, services, ingress), Helm charts para templates parametrizables, y Jenkinsfiles para pipelines. Las ventajas son reproducibilidad total, versionado en Git, auditoría de cambios, y posibilidad de hacer code reviews de infraestructura."*

### 19. ¿Diferencia entre CMD y ENTRYPOINT en Docker?
*"CMD define el comando por defecto que se puede sobrescribir al hacer `docker run`. ENTRYPOINT define el punto de entrada fijo que NO se puede sobrescribir fácilmente. Normalmente uso ENTRYPOINT para el ejecutable principal y CMD para argumentos por defecto. Por ejemplo: `ENTRYPOINT ["java", "-jar"]` y `CMD ["app.jar"]`. Esto permite ejecutar `docker run imagen custom.jar` para cambiar el JAR sin cambiar el comando Java."*

### 20. ¿Qué es un webhook y cómo lo usas?
*"Un webhook es una notificación HTTP automática cuando ocurre un evento. En mi setup, cuando hago push a GitLab, este envía una petición POST al endpoint de Jenkins con los detalles del commit. Jenkins recibe la notificación y dispara la pipeline automáticamente. Es mucho más eficiente que polling (preguntar cada X minutos si hay cambios) porque la integración es instantánea y no desperdicia recursos."*

---

## ✅ Mejores Prácticas Aplicadas

### 1. Inmutabilidad de Imágenes
```bash
# ❌ Mal: Siempre usar :latest (no sabes qué versión está corriendo)
image: myapp:latest

# ✅ Bien: Tag con versión o build number
image: myapp:1.2.3
image: myapp:${BUILD_NUMBER}
image: myapp:git-${GIT_COMMIT_SHORT}
```
**Razón:** Permite rollbacks precisos y saber exactamente qué código está en producción.

### 2. Health Checks (Probes)
```yaml
livenessProbe:    # ¿El contenedor está vivo?
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:   # ¿El contenedor está listo para tráfico?
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```
**Razón:** K8s reinicia pods muertos (liveness) y solo enruta tráfico a pods listos (readiness).

### 3. Resource Limits y Requests
```yaml
resources:
  requests:      # Mínimo garantizado
    memory: "256Mi"
    cpu: "500m"
  limits:        # Máximo permitido
    memory: "512Mi"
    cpu: "1000m"
```
**Razón:** Evita que un pod consuma todos los recursos del nodo y cause caídas.

### 4. Secrets Externos (No Hardcodeados)
```groovy
// ❌ Mal: Hardcodear passwords
def password = "admin123"

// ✅ Bien: Usar credenciales de Jenkins
withCredentials([usernamePassword(
    credentialsId: 'registry-creds',
    usernameVariable: 'USERNAME',
    passwordVariable: 'PASSWORD'
)]) {
    sh "docker login -u ${USERNAME} -p ${PASSWORD}"
}
```
**Razón:** Seguridad, auditoría y rotación de credenciales sin cambiar código.

### 5. Namespaces para Aislamiento
```bash
# Desarrollo
kubectl create namespace dev
kubectl apply -f app.yaml -n dev

# Producción
kubectl create namespace prod
kubectl apply -f app.yaml -n prod
```
**Razón:** Aislamiento de recursos, policies diferentes, y evita conflictos de nombres.

### 6. Labels y Selectors Consistentes
```yaml
metadata:
  labels:
    app: petclinic-angular
    environment: production
    version: "1.2.3"
    team: frontend
spec:
  selector:
    matchLabels:
      app: petclinic-angular
```
**Razón:** Facilita búsquedas (`kubectl get pods -l app=petclinic`) y debugging.

### 7. Logging Estructurado
```groovy
// En Jenkinsfile
echo "[INFO] ${env.JOB_NAME} - Starting build #${env.BUILD_NUMBER}"
echo "[DEBUG] Branch: ${env.GIT_BRANCH}"
echo "[ERROR] Build failed at stage ${STAGE_NAME}"
```
**Razón:** Facilita parsing de logs y creación de alertas automáticas.

### 8. Rollback Strategy con Helm
```bash
# Ver historial de releases
helm list
helm history petclinic-angular

# Rollback a versión anterior
helm rollback petclinic-angular 2

# Rollback a última versión estable
helm rollback petclinic-angular 0
```
**Razón:** Recuperación rápida de fallos sin redeployar manualmente.

### 9. .dockerignore para Builds Rápidos
```
node_modules/
dist/
.git/
*.md
.env
.vscode/
coverage/
```
**Razón:** Reduce tamaño del contexto de build, acelera `docker build` y evita secretos en imagen.

### 10. Conventional Commits
```bash
feat: add user authentication
fix: resolve memory leak in pod
docs: update README with new architecture
chore: upgrade Jenkins to 2.400
refactor: simplify Dockerfile
```
**Razón:** Changelogs automáticos, semantic versioning, y claridad en el historial de Git.

---

## 📖 Referencias y Recursos Utilizados

### Documentación Oficial
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Jenkins Documentation](https://www.jenkins.io/doc/)
- [Helm Documentation](https://helm.sh/docs/)
- [GitLab Documentation](https://docs.gitlab.com/)

### Proyectos de Referencia
- [Spring PetClinic Angular](https://github.com/spring-petclinic/spring-petclinic-angular)
- [Spring PetClinic REST](https://github.com/spring-petclinic/spring-petclinic-rest)

### Herramientas
- **OS:** Windows 11 + WSL2 (Ubuntu 24.04)
- **Container Runtime:** Docker Desktop 28.4.0
- **Editor:** Visual Studio Code
- **Shell:** Bash

---

## 🎯 Conclusión

He demostrado capacidad para:
- ✅ **Implementar** infraestructura DevOps completa desde cero
- ✅ **Automatizar** pipelines CI/CD con Jenkins y GitLab
- ✅ **Contenedorizar** aplicaciones con Docker y optimizar imágenes
- ✅ **Orquestar** contenedores con Kubernetes y Helm
- ✅ **Resolver problemas** técnicos complejos de networking y integración
- ✅ **Documentar** todo el proceso de forma clara y estructurada
- ✅ **Aprender** de forma autónoma y aplicar mejores prácticas

**Estoy preparado para contribuir como Junior DevOps Engineer, con fundamentos sólidos y ganas de seguir aprendiendo.**

---
---

# ⚡ MEGA RESUMEN - IMPRESCINDIBLES PARA LA ENTREVISTA

## 🎯 LO MÁS IMPORTANTE - MEMORIZA ESTO

### 1️⃣ TU ELEVATOR PITCH (30 segundos)
> *"Soy Adrián, Junior DevOps Engineer. He construido un entorno CI/CD completo desde cero con GitLab, Jenkins, Docker y Kubernetes. Implementé pipelines automatizadas para aplicaciones frontend (Angular) y backend (Spring Boot) que despliegan automáticamente en Kubernetes. Reduje imágenes Docker en 95% con multi-stage builds, ejecuto 224 tests automáticos en cada commit, y documenté todo el proceso. Busco aplicar y expandir estos conocimientos en un entorno profesional."*

---

## 🔴 CONCEPTOS CRÍTICOS QUE DEBES DOMINAR

### DevOps en 3 Frases
1. **Cultura:** Unir Dev + Ops, romper silos, colaboración
2. **Automatización:** CI/CD desde commit hasta producción
3. **Objetivo:** Entregar software rápido, confiable y frecuente

### CI/CD - La Base de Todo
```
CI (Continuous Integration):
  → Integrar código frecuentemente
  → Tests automáticos en cada commit
  → Detectar errores TEMPRANO

CD (Continuous Delivery):
  → Código SIEMPRE listo para producción
  → Deploy con aprobación manual
  
CD (Continuous Deployment):
  → Deploy AUTOMÁTICO a producción
  → Sin intervención humana
```

### Docker - Contenedores en 3 Niveles
```
Imagen:     Plantilla inmutable (receta)
Contenedor: Instancia ejecutable (plato cocinado)
Registry:   Almacén de imágenes (recetario)

Comando clave: docker build → docker tag → docker push
```

### Kubernetes - Orquestación en 5 Recursos
```
Pod:        Unidad mínima (1+ contenedores)
Deployment: Gestiona réplicas de pods
Service:    IP estable para acceder pods
Ingress:    HTTP routing externo
Secret:     Datos sensibles (passwords)
```

---

## 📊 TUS NÚMEROS - MEMORIZA ESTOS

| Métrica | Valor | Impacto |
|---------|-------|---------|
| **Tests ejecutados** | 181 (Maven) + 43 (Angular) = **224** | Calidad automática |
| **Reducción de imagen** | 1.2GB → 25MB = **95%** | Deploy 48x más rápido |
| **Tiempo deploy** | **< 5 minutos** | Commit → Producción |
| **Servicios dockerizados** | **4** (Jenkins, GitLab, Registry, Minikube) | Stack completo |
| **Pipelines funcionales** | **2** (Frontend + Backend) | Experiencia real |
| **Uptime** | **~100%** (con health checks) | Alta disponibilidad |

---

## 🎓 DIFERENCIAS QUE SIEMPRE PREGUNTAN

### 1. Docker vs Kubernetes
| Docker | Kubernetes |
|--------|------------|
| Crea y ejecuta contenedores | Orquesta contenedores |
| Single host | Multi-node cluster |
| docker run | kubectl apply |
| No auto-scaling | Auto-scaling nativo |

### 2. Image vs Container
| Imagen | Contenedor |
|--------|------------|
| Plantilla estática | Instancia ejecutable |
| `docker build` | `docker run` |
| En registry | En memoria |

### 3. Deployment vs StatefulSet
| Deployment | StatefulSet |
|------------|-------------|
| Apps **stateless** | Apps **stateful** |
| Pods intercambiables | Pods con identidad única |
| API REST, frontends | Bases de datos, Kafka |

### 4. Service Types
| ClusterIP | NodePort | LoadBalancer |
|-----------|----------|--------------|
| Solo interno | Puerto en nodo | IP pública (cloud) |
| Por defecto | Dev/testing | Producción |

### 5. CI vs CD vs CD
| CI | CD (Delivery) | CD (Deployment) |
|----|---------------|-----------------|
| Integrar código | Listo para deploy | Deploy automático |
| Tests automáticos | Aprobación manual | Sin humanos |

---

## 🔧 COMANDOS QUE DEBES SABER DE MEMORIA

### Docker (Top 10)
```bash
docker ps                    # Ver contenedores corriendo
docker images                # Ver imágenes locales
docker build -t app:v1 .     # Construir imagen
docker run -d -p 8080:80 app # Ejecutar contenedor
docker logs <container>      # Ver logs
docker exec -it <id> sh      # Entrar al contenedor
docker stop <container>      # Parar contenedor
docker rm <container>        # Eliminar contenedor
docker rmi <image>           # Eliminar imagen
docker system prune -a       # Limpiar todo
```

### Kubernetes (Top 10)
```bash
kubectl get pods             # Ver pods
kubectl get all              # Ver todos los recursos
kubectl describe pod <name>  # Detalles de pod
kubectl logs <pod>           # Ver logs
kubectl exec -it <pod> -- sh # Entrar al pod
kubectl apply -f file.yaml   # Crear/actualizar recursos
kubectl delete -f file.yaml  # Eliminar recursos
kubectl get events           # Ver eventos del cluster
kubectl scale deploy <name> --replicas=3  # Escalar
kubectl rollout restart deploy <name>     # Reiniciar deployment
```

### Git (Top 8)
```bash
git clone <url>              # Clonar repo
git status                   # Ver cambios
git add .                    # Añadir cambios
git commit -m "mensaje"      # Commit
git push origin main         # Subir cambios
git pull                     # Descargar cambios
git checkout -b <branch>     # Crear rama
git merge <branch>           # Fusionar rama
```

---

## 💡 TU PROYECTO EN 5 PUNTOS CLAVE

### 1. Arquitectura
```
GitLab (código) → Jenkins (CI/CD) → Registry (imágenes) → Kubernetes (deploy)
                       ↓
              devops-net (red Docker)
```

### 2. Flujo Completo
```
git push → webhook → Jenkins → build → test → dockerize → push → deploy → ✅
```

### 3. Problemas Resueltos
- ✅ Comunicación entre contenedores (red custom)
- ✅ Branches desincronizados (git merge --allow-unrelated-histories)
- ✅ Registry privado en K8s (imagePullSecrets)
- ✅ Networking WSL2 + Minikube (Ingress + proxy)
- ✅ Docker-in-Docker (mount /var/run/docker.sock)

### 4. Optimizaciones Aplicadas
- ✅ Multi-stage builds (95% reducción de imagen)
- ✅ Health checks (liveness + readiness)
- ✅ Shared Libraries (70% menos código)
- ✅ Resource limits (evitar crashes)
- ✅ Helm charts (deploy parametrizable)

### 5. Herramientas Dominadas
```
SCM:          Git, GitLab
CI/CD:        Jenkins (Jenkinsfile)
Containers:   Docker, Docker Compose
Orchestrator: Kubernetes, Minikube, Helm
Proxy:        Nginx, Ingress
Languages:    Bash, Groovy, YAML
```

---

## 🚨 ERRORES COMUNES A EVITAR EN LA ENTREVISTA

### ❌ NO Digas:
- "Instalé Docker y ya"
- "Usé Kubernetes" (sin especificar qué)
- "Lo hice con un tutorial"
- "No sé" (y te quedas callado)
- "Jenkins y GitLab" (sin explicar integración)

### ✅ SÍ Dí:
- "Implementé CI/CD con Jenkins y GitLab usando webhooks..."
- "En Kubernetes desplegué con Deployments, Services e Ingress..."
- "Adapté tutoriales y resolví problemas específicos como..."
- "No lo he usado, pero es similar a X que sí domino..."
- "Jenkins se integra con GitLab mediante webhooks que disparan pipelines..."

---

## 🎯 RESPUESTAS RÁPIDAS A PREGUNTAS TÍPICAS

### "¿Qué es DevOps?"
> *"Cultura y prácticas que automatizan el ciclo de vida del software desde desarrollo hasta producción usando CI/CD."*

### "¿Por qué contenedores?"
> *"Portabilidad, consistencia entre entornos, arranque rápido y aislamiento de procesos."*

### "¿Qué es CI/CD?"
> *"CI: integrar código frecuentemente con tests automáticos. CD: desplegar automáticamente a producción."*

### "¿Docker vs Kubernetes?"
> *"Docker crea contenedores. Kubernetes orquesta contenedores a escala con auto-scaling y auto-healing."*

### "¿Tu mayor logro?"
> *"Pipeline completa funcional que despliega automáticamente en Kubernetes con 224 tests y reducción del 95% en tamaño de imagen."*

### "¿Tu mayor desafío?"
> *"Integrar Minikube con Jenkins y registry privado resolviendo problemas de networking multicapa en WSL2."*

### "¿Cómo debuggeas un pod?"
> *"kubectl describe → kubectl logs → kubectl exec → kubectl get events"*

### "¿Cómo aseguras calidad?"
> *"Tests automáticos en pipeline + health checks + resource limits + secrets seguros"*

---

## 📋 CHECKLIST PRE-ENTREVISTA

### 24 Horas Antes:
- [ ] Leer este documento completo (30 min)
- [ ] Practicar elevator pitch en voz alta (10 veces)
- [ ] Revisar tus números (224 tests, 95% reducción, etc.)
- [ ] Repasar 3 problemas resueltos con soluciones
- [ ] Verificar que tu proyecto está corriendo
- [ ] Preparar ejemplos concretos para cada herramienta

### 1 Hora Antes:
- [ ] Revisar sección MEGA RESUMEN (esta página)
- [ ] Repasar diferencias clave (Docker vs K8s, etc.)
- [ ] Tener proyecto corriendo por si piden demo
- [ ] Respirar profundo y confiar en tu preparación

### Durante la Entrevista:
- [ ] Escuchar activamente la pregunta completa
- [ ] Responder con ejemplos concretos de tu proyecto
- [ ] Si no sabes algo, relaciona con lo que sí sabes
- [ ] Hacer preguntas al entrevistador (demuestra interés)
- [ ] Ser honesto sobre limitaciones pero mostrar ganas de aprender

---

## 🔥 FRASES QUE IMPRESIONAN

### Inicio Fuerte:
> *"He construido un entorno DevOps completo por iniciativa propia, no solo seguí tutoriales."*

### Demuestra Profundidad:
> *"Resolví el problema de X entendiendo cómo funcionan las redes Docker a nivel de namespaces y bridge networks."*

### Muestra Impacto:
> *"Optimicé las imágenes Docker reduciendo el tamaño en 95%, lo que acelera los deploys 48 veces."*

### Evidencia Mentalidad DevOps:
> *"Documenté todo el proceso para que cualquiera pueda replicarlo, porque el conocimiento debe ser compartido."*

### Cierre Memorable:
> *"Este proyecto es solo el comienzo. Estoy ansioso por aplicar estos conocimientos y aprender de profesionales experimentados en un entorno real."*

---

## 🧠 MENTALIDAD DEVOPS - VALORES CLAVE

### 1. Automatiza TODO lo posible
- Si lo haces 2 veces, automatízalo
- Tiempo invertido en automatización se recupera rápido

### 2. Falla rápido, recupera rápido
- Tests en cada commit
- Rollbacks con un comando
- Health checks para auto-healing

### 3. Infraestructura como Código
- Todo en Git
- Reproducible
- Versionado

### 4. Medir TODO
- Logs estructurados
- Métricas de performance
- Dashboards para visibilidad

### 5. Colaboración > Silos
- Dev y Ops trabajan juntos
- Shared responsibility
- Documentación clara

### 6. Mejora Continua
- Cada error es aprendizaje
- Documentar soluciones
- Optimizar constantemente

---

## 🎓 SI SOLO RECUERDAS 10 COSAS

1. **DevOps = Automatizar ciclo de vida del software con CI/CD**
2. **Tu proyecto: GitLab → Jenkins → Docker → Kubernetes**
3. **224 tests automáticos + 95% reducción de imagen**
4. **Docker crea contenedores, Kubernetes los orquesta**
5. **Multi-stage builds para imágenes pequeñas**
6. **Helm para deployments parametrizables**
7. **Health checks para auto-healing**
8. **Secrets en Kubernetes, no hardcodeados**
9. **Networking: devops-net + Ingress + proxy**
10. **Documentación de TODO el proceso**

---

## 💪 CONFIANZA FINAL

### TÚ HAS:
✅ Construido infraestructura completa desde cero  
✅ Resuelto problemas reales de networking  
✅ Optimizado imágenes Docker profesionalmente  
✅ Implementado CI/CD funcional end-to-end  
✅ Documentado exhaustivamente tu trabajo  
✅ Demostrado iniciativa y autodidactismo  

### ELLOS BUSCAN:
🎯 Alguien con fundamentos sólidos  
🎯 Mentalidad de automatización  
🎯 Capacidad de resolver problemas  
🎯 Ganas de aprender  
🎯 Trabajo en equipo  

### TÚ ERES ESA PERSONA ✨

---

## 🚀 ÚLTIMA RECOMENDACIÓN

**La noche antes:**
- Duerme bien (8 horas)
- Revisa SOLO este MEGA RESUMEN (no te sobrecargues)
- Visualiza éxito: ya has hecho lo difícil

**El día de la entrevista:**
- Desayuna bien
- Llega 10 minutos antes
- Respira profundo
- Recuerda: Sabes más de lo que crees

**Durante la entrevista:**
- Sonríe, mantén contacto visual
- Habla de tu proyecto con PASIÓN
- Si no sabes algo: "No lo he usado, pero sé X relacionado..."
- Haz preguntas al final (demuestra interés real)

---

## 🎯 TU MANTRA

> **"No soy el DevOps que todo lo sabe.**  
> **Soy el DevOps que aprende rápido, automatiza todo y documenta el proceso.**  
> **He demostrado que puedo construir sistemas completos desde cero.**  
> **Ahora quiero aplicar esto en un equipo real y seguir creciendo."**

---

# ✨ ¡CONFÍA EN TU PREPARACIÓN! ✨

**Has invertido cientos de horas.**  
**Has construido algo real.**  
**Has documentado todo.**  
**Estás listo.**  

## 🍀 ¡MUCHA SUERTE EN TU ENTREVISTA DEL JUEVES! 🍀

---

**Recordatorio Final:** Este documento es TU TRABAJO. Habla con orgullo de él. Muestra código, arquitecturas, problemas resueltos. Demuestra que no solo sabes teoría, sino que has HECHO las cosas.

---

**Última actualización:** Noviembre 11, 2025  
**Autor:** Adrián Martín Romo Cañadas  
**GitHub:** Adrianmrc94  
**Próxima actualización:** Después de que consigas el trabajo 😎
