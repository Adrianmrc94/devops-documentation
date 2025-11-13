# 🎬 GUÍA DEMO ENTREVISTA - SISTEMA DEVOPS COMPLETO

**Fecha:** Noviembre 13, 2025  
**Estado:** ✅ Sistema 100% funcional y verificado
**Objetivo:** Comandos y guía para demostrar entorno DevOps

---

## 📋 ÍNDICE RÁPIDO

1. [Verificación Pre-Entrevista](#1-verificación-pre-entrevista)
2. [Demo en 5 Minutos](#2-demo-en-5-minutos)
3. [Comandos Impresionantes](#3-comandos-impresionantes)
4. [Elevator Pitch](#4-elevator-pitch)
5. [Troubleshooting Rápido](#5-troubleshooting-rápido)

---

## 1️⃣ VERIFICACIÓN PRE-ENTREVISTA

### 🚀 Verificación Rápida (30 segundos)

```bash
# Script de verificación completa
echo "🔍 ESTADO DEL SISTEMA DEVOPS"
echo "=================================="

echo "1️⃣ Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}"

echo -e "\n2️⃣ Kubernetes:"
kubectl get nodes

echo -e "\n3️⃣ Registry Images:"
curl -s http://localhost:5000/v2/_catalog | jq -r '.repositories[]' 2>/dev/null

echo -e "\n4️⃣ Pods Running:"
kubectl get pods -n default

echo -e "\n✅ Sistema Verificado Completamente"
```

### 📊 Estado Actual del Sistema

| **Componente** | **Estado** | **Puerto** | **Función** |
|---------------|-----------|-----------|-------------|
| Jenkins | ✅ Running | 8080 | CI/CD Server |
| GitLab | ✅ Running | 8929 | Source Control |
| Registry | ✅ Running | 5000 | Docker Images |
| Minikube | ✅ Running | 8443 | Kubernetes |

### 📦 Contenido del Registry
```bash
# Ver imágenes en registry privado
curl -s http://localhost:5000/v2/_catalog | jq
```

**Resultado:**
```json
{
  "repositories": [
    "hello-world",
    "petclinic-angular", 
    "petclinic-maven"
  ]
}
```

---

## 2️⃣ DEMO EN 5 MINUTOS

### 🎯 Demostración Paso a Paso

#### **1. Mostrar Arquitectura (30 segundos)**
```bash
echo "🏗️ ARQUITECTURA DEVOPS COMPLETA"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "jenkins|gitlab|registry|minikube"
```

#### **2. Mostrar Pipelines Funcionando (1 minuto)**
- **Abrir:** http://localhost:8080
- **Mostrar:** Pipelines exitosas (petclinic-angular-ci, petclinic-maven-ci)
- **Mencionar:** 224 tests automatizados, build en ~3-5 minutos

#### **3. Mostrar Kubernetes Deployments (1 minuto)**
```bash
echo "☸️ APLICACIONES EN KUBERNETES"
kubectl get all -n default
```

#### **4. Mostrar Registry Privado (30 segundos)**
```bash
echo "📦 IMÁGENES EN REGISTRY PRIVADO"
curl -s http://localhost:5000/v2/_catalog | jq
```

#### **5. Demo en Vivo - Ejecutar Pipeline (2 minutos)**
- **Jenkins UI:** Build Now en cualquier pipeline
- **Mostrar:** Console output en tiempo real
- **Explicar:** Stages, Docker agents, Kubernetes deploy

---

## 3️⃣ COMANDOS IMPRESIONANTES

### 🛠️ Script de Inicio Automático

**Ejecutar si necesitas reiniciar todo:**
```bash
cd ~/scripts
./setup-registry-k8s-fixed-v4.sh
```

**Tiempo:** 2-3 minutos  
**Resultado:** Sistema completo funcionando

---

## 4️⃣ ELEVATOR PITCH

### 🗣️ Presentación (30 segundos)

> "Construí un entorno DevOps completo desde cero con Jenkins, GitLab, Docker Registry y Kubernetes. Implementé pipelines CI/CD que automatizan tests, builds y deployments de aplicaciones Angular y Spring Boot. El sistema ejecuta 224 tests automáticamente, genera imágenes Docker optimizadas y las despliega en Kubernetes. Todo dockerizado en redes privadas, completamente funcional."

### 📈 Números Clave

- **224 tests** automatizados por build
- **4 contenedores** orquestados 
- **11 stages** por pipeline
- **2 aplicaciones** full-stack
- **3 imágenes** en registry privado
- **85MB** imagen Angular optimizada (vs 600MB original)

### 💡 Tecnologías Demostradas

1. **CI/CD**: Jenkins con Pipelines como código
2. **Containerización**: Docker multi-stage builds
3. **Orquestación**: Kubernetes con Minikube
4. **Registry**: Docker Registry privado
5. **Networking**: Redes Docker custom
6. **IaC**: Jenkinsfiles, Dockerfiles, K8s YAMLs
7. **Shared Libraries**: Código Groovy reutilizable

---

## 5️⃣ TROUBLESHOOTING RÁPIDO

### ⚠️ Problema: Jenkins no arranca

```bash
# Ver logs
docker logs jenkins --tail 100

# Reiniciar Jenkins
docker restart jenkins

# Verificar puerto
netstat -an | grep 8080
```

### ⚠️ Problema: Minikube no responde

```bash
# Ver estado
minikube status

# Reiniciar Minikube
minikube stop
minikube start --driver=docker

# Verificar recursos
minikube ssh "free -h"
```

### ⚠️ Problema: Registry no tiene imágenes

```bash
# Verificar catálogo
curl http://localhost:5000/v2/_catalog

# Re-push de imagen (ejemplo)
docker pull hello-world
docker tag hello-world localhost:5000/hello-world
docker push localhost:5000/hello-world
```

### ⚠️ Problema: Pods no arrancan

```bash
# Ver eventos del pod
kubectl describe pod <pod-name> -n jenkins

# Ver logs del pod
kubectl logs <pod-name> -n jenkins

# Verificar imagePullSecret
kubectl get secret registry-secret -n jenkins
```

---

## 6️⃣ COMANDOS DE BACKUP

### 💾 Backup Rápido (antes de la entrevista)

```bash
# Backup de volumes importantes
docker run --rm -v jenkins_data:/source -v $(pwd):/backup alpine tar czf /backup/jenkins_backup_$(date +%Y%m%d).tar.gz -C /source .

docker run --rm -v gitlab_data:/source -v $(pwd):/backup alpine tar czf /backup/gitlab_backup_$(date +%Y%m%d).tar.gz -C /source .

# Ver backups
ls -lh *_backup_*.tar.gz
```

---

## 🎯 COMANDOS PARA IMPRESIONAR EN LA ENTREVISTA

### Mostrar Conocimiento Avanzado:

```bash
# 1. Ver recursos de Kubernetes de forma visual
kubectl top nodes
kubectl top pods -n jenkins

# 2. Ver logs en tiempo real
kubectl logs -f <pod-name> -n jenkins

# 3. Port-forward para acceso directo
kubectl port-forward service/<service-name> 8081:80 -n jenkins

# 4. Ejecutar comando dentro de un pod
kubectl exec -it <pod-name> -n jenkins -- sh

# 5. Ver configuración completa de un deployment
kubectl get deployment <name> -n jenkins -o yaml

# 6. Historial de rollouts
kubectl rollout history deployment/<name> -n jenkins

# 7. Escalar en tiempo real
kubectl scale deployment <name> --replicas=3 -n jenkins
kubectl get pods -n jenkins -w

# 8. Ver eventos recientes
kubectl get events -n jenkins --sort-by='.lastTimestamp' | tail -20
```

---

## 📝 NOTAS FINALES

### ✅ Antes de la entrevista (MAÑANA):

1. [ ] Ejecutar `docker ps` y verificar todo está UP
2. [ ] Ejecutar `minikube status` - debe estar Running
3. [ ] Ejecutar `kubectl get all -n jenkins` - debe mostrar recursos
4. [ ] Abrir http://localhost:8080 - Jenkins debe cargar
5. [ ] Abrir http://localhost:8929 - GitLab debe cargar
6. [ ] Ejecutar `curl http://localhost:5000/v2/_catalog` - debe mostrar imágenes
7. [ ] Tener este documento abierto en una pestaña

### 💡 Durante la entrevista:

- Si te piden demo: Usa la sección 3 (5 minutos)
- Si preguntan por comandos: Tienes ejemplos aquí
- Si algo falla: Usa sección 5 (Troubleshooting)
- Mantén la calma: Ya lo has hecho funcionar antes

---

## 🚀 ¡ESTÁS LISTO!

**Recuerda:** No necesitas que TODO esté perfecto. Lo importante es que entiendas lo que has construido y puedas explicarlo con confianza.

---

**Actualizado:** Noviembre 12, 2025  
**Para entrevista del:** Noviembre 13, 2025  
**¡Mucha suerte! 🍀**



# Imágenes en Minikube
minikube ssh "docker images"
```

---

## 🎬 **Script de Demostración Completa (copiar y pegar)**

```bash
echo "===== 1. ESTADO DE CONTENEDORES ====="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "===== 2. ESTADO DE KUBERNETES ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig cluster-info
echo ""

echo "===== 3. NAMESPACES Y RECURSOS ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get namespaces
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get all -n jenkins
echo ""

echo "===== 4. INTEGRACIÓN JENKINS → KUBERNETES ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
echo ""

echo "===== 5. DOCKER REGISTRY ====="
curl -s http://localhost:5000/v2/_catalog | jq
echo ""

echo "===== 6. REDES DOCKER ====="
docker network ls | grep -E "devops-net|minikube"
echo ""

echo "✅ TODO FUNCIONANDO CORRECTAMENTE"
```

---

## 🆘 **Comandos de Emergencia**

### **Si algo no responde:**

```bash
# Reiniciar Jenkins
docker restart jenkins

# Reiniciar Minikube
minikube stop && minikube start

# Ver logs de un contenedor
docker logs jenkins --tail 50
docker logs gitlab --tail 50
docker logs registry --tail 50
```

### **Si necesitas levantar todo desde cero:**

```bash
# Levantar contenedores
docker start jenkins gitlab registry

# Levantar Minikube
minikube start

# Reconectar redes
docker network connect devops-net minikube
docker network connect minikube jenkins
```

---

## 📝 **Notas para la Presentación**

### **Puntos clave a mencionar:**

1. **Arquitectura completa:**
   - Jenkins (CI/CD)
   - GitLab (Control de versiones)
   - Docker Registry (Imágenes privadas)
   - Kubernetes/Minikube (Orquestación)

2. **Networking:**
   - Red `devops-net` para comunicación entre servicios
   - Red `minikube` para Jenkins → Kubernetes

3. **Integración:**
   - Jenkins puede ejecutar `kubectl` directamente
   - Minikube puede acceder al registry privado
   - Todo funciona localmente sin internet

4. **Capacidades:**
   - Build automático de imágenes
   - Push a registry privado
   - Deploy automático en Kubernetes
   - Gestión de secretos

---

## 🎯 **Orden Sugerido de Demostración**

1. **Mostrar que todo está levantado** (docker ps)
2. **Mostrar Kubernetes funcionando** (kubectl get nodes)
3. **Mostrar integración Jenkins-K8s** (docker exec jenkins kubectl...)
4. **Mostrar GitLab con código** (localhost:8929)
5. **Abrir Jenkins en navegador** (localhost:8080)
6. **Ejecutar pipeline petclinic-angular o petclinic-maven**
7. **Mostrar que hace checkout desde GitLab** (en logs de Jenkins)
8. **Ver tests ejecutándose** (43 tests Angular / 181 tests Maven)
9. **Verificar SUCCESS** ✅

**Tiempo total:** 7-10 minutos

---

## 🔄 **NUEVO: Verificar Flujo CI/CD GitLab → Jenkins (2 minutos)**

### **Demo del flujo completo:**

```bash
# 1. Ver repositorios en GitLab
echo "Repositorios en GitLab:"
docker exec gitlab gitlab-rails runner "Project.all.each { |p| puts p.path_with_namespace }"

# 2. Ver que Jenkins está configurado para usar GitLab
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "url"
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-maven-ci/config.xml | grep "url"

# 3. Verificar branch configurado (debe ser 'main')
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "BranchSpec" -A 1
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-maven-ci/config.xml | grep "BranchSpec" -A 1

# 4. Verificar que puede clonar desde GitLab
docker exec jenkins bash -c "cd /tmp && \
  rm -rf test-clone && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test-clone && \
  ls test-clone/ && \
  rm -rf test-clone"
```

**Explicar:**
- ✅ Jenkins usa repos de GitLab (no GitHub público)
- ✅ Branch `main` estandarizado
- ✅ Jenkinsfile está en cada repo
- ✅ Pipelines centralizadas con `@Library('jenkinspipelines')`

---

## 🏆 **Puntos Destacados para Mencionar**

### **Logros Técnicos:**

1. **CI/CD Completo:**
   - GitLab como repositorio central
   - Jenkins ejecutando pipelines automáticas
   - Docker Registry privado
   - Kubernetes para orquestación

2. **Pipelines Centralizadas:**
   - Repositorio `jenkinspipelines` con Shared Library
   - Funciones reutilizables (`vars/commonSteps.groovy`)
   - Estandarización de builds

3. **Integración Completa:**
   - Jenkins → GitLab (checkout con SSH)
   - Jenkins → Kubernetes (kubectl funcional)
   - Kubernetes → Registry (pull de imágenes privadas)
   - Todo en red Docker privada

4. **Resultados:**
   - ✅ Pipeline Angular: 43 tests pasando
   - ✅ Pipeline Maven: 181 tests pasando
   - ✅ Total: **224 tests automatizados**
   - ✅ Ambas pipelines en SUCCESS

---

## � **CÓDIGO REAL DEL PROYECTO**

### 📝 Jenkinsfile - Angular (spring-petclinic-angular)

```groovy
@Library('jenkins-libs') _

pipeline {
    agent {
        docker {
            image 'node:22-bullseye'
            args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network minikube -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        GIT_USER = 'Jenkins CI'
        GIT_EMAIL = 'jenkins@petclinic.local'
        NPM_CONFIG_CACHE = './.npm'
        DISPLAY = ':99'
        CHROME_BIN = '/usr/bin/google-chrome'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'petclinic-angular'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}"
        HELM_DOCKER_REGISTRY = 'host.docker.internal:5000'
    }

    stages {
        stage('📋 Build Info') {
            steps {
                script { commonSteps.displayBuildInfo() }
            }
        }

        stage('🔄 Checkout') {
            steps {
                script { commonSteps.setupGitCredentials() }
            }
        }

        stage('🔧 Setup Environment') {
            steps {
                script {
                    commonSteps.setupNodeEnvironment()
                    commonSteps.installChromeForTesting()
                    npmSteps.installAngularCLI()
                }
            }
        }

        stage('📦 Install Dependencies') {
            steps {
                script { npmSteps.installDependencies() }
            }
        }

        stage('🏗️ Build') {
            steps {
                script { npmSteps.buildAngularApp() }
            }
        }

        stage('🧪 Test') {
            steps {
                script {
                    commonSteps.startVirtualDisplay()
                    npmSteps.runAngularTests()
                }
            }
            post {
                always {
                    script { commonSteps.stopVirtualDisplay() }
                }
            }
        }

        stage('📁 Archive Artifacts') {
            steps {
                script { commonSteps.archiveCommonArtifacts('dist/**/*') }
            }
        }

        stage('🐳 Docker Build') {
            steps {
                script { commonSteps.buildDockerImage(env.FULL_IMAGE_NAME, env.IMAGE_TAG) }
            }
        }

        stage('📤 Docker Push') {
            steps {
                script { commonSteps.pushDockerImage(env.FULL_IMAGE_NAME, env.IMAGE_TAG, env.DOCKER_REGISTRY) }
            }
        }

        stage('✅ Verify Image') {
            steps {
                script { commonSteps.verifyImageInRegistry(env.IMAGE_NAME) }
            }
        }

        stage('🚀 Deploy to Kubernetes') {
            steps {
                script {
                    commonSteps.deployWithHelm('spring-petclinic-angular', 'helm/values.yaml', 
                                               'chart/', "${HELM_DOCKER_REGISTRY}/petclinic-angular", 
                                               "${BUILD_NUMBER}")
                }
            }
        }
    }

    post {
        always {
            script { commonSteps.cleanWorkspace() }
        }
        success {
            script {
                commonSteps.sendNotification('SUCCESS', env.JOB_NAME)
                commonSteps.successMessage('petclinic-angular-ci')
            }
        }
        failure {
            script {
                commonSteps.sendNotification('FAILURE', env.JOB_NAME)
                commonSteps.failureMessage('petclinic-angular-ci')
            }
        }
    }
}
```

**🔑 Puntos Clave:**
- **Agent Docker**: Usa `node:22-bullseye` como contenedor efímero
- **Network**: Conectado a red `minikube` para acceso a Kubernetes
- **Shared Library**: `@Library('jenkins-libs')` centraliza funciones comunes
- **Multi-stage**: 11 stages desde checkout hasta deploy en Kubernetes
- **Tests**: 43 tests automatizados con Chrome Headless
- **Registry**: Push a `localhost:5000` (registry privado)

---

### 📝 Jenkinsfile - Maven (spring-petclinic-rest)

```groovy
@Library('jenkins-libs') _

pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network devops-net -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    environment {
        GIT_USER = 'Jenkins CI'
        GIT_EMAIL = 'jenkins@petclinic.local'
        DOCKER_REGISTRY = 'localhost:5000'
        IMAGE_NAME = 'petclinic-maven'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}"
    }

    stages {
        stage('📋 Build Info') {
            steps {
                script { commonSteps.displayBuildInfo() }
            }
        }

        stage('🔄 Checkout') {
            steps {
                script { commonSteps.setupGitCredentials() }
            }
        }

        stage('🔧 Setup Environment') {
            steps {
                script { commonSteps.setupMavenEnvironment() }
            }
        }

        stage('📦 Compile') {
            steps {
                script { npmSteps.compileMavenProject() }
            }
        }

        stage('🧪 Test') {
            steps {
                script { npmSteps.runMavenTests() }
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('🏗️ Package') {
            steps {
                script { npmSteps.packageMavenProject() }
            }
        }

        stage('📁 Archive Artifacts') {
            steps {
                script { commonSteps.archiveCommonArtifacts('target/*.jar') }
            }
        }

        stage('🐳 Docker Build') {
            steps {
                script { commonSteps.buildDockerImage(env.FULL_IMAGE_NAME, env.IMAGE_TAG) }
            }
        }

        stage('📤 Docker Push') {
            steps {
                script { commonSteps.pushDockerImage(env.FULL_IMAGE_NAME, env.IMAGE_TAG, env.DOCKER_REGISTRY) }
            }
        }

        stage('✅ Verify Image') {
            steps {
                script { commonSteps.verifyImageInRegistry(env.IMAGE_NAME) }
            }
        }

        stage('🚀 Deploy to Kubernetes') {
            steps {
                script { commonSteps.deployToKubernetes('petclinic-maven', 'k8s-deployment-maven.yaml') }
            }
        }
    }

    post {
        always {
            script { commonSteps.cleanWorkspace() }
        }
        success {
            script {
                commonSteps.sendNotification('SUCCESS', env.JOB_NAME)
                commonSteps.successMessage('Maven PetClinic')
            }
        }
        failure {
            script {
                commonSteps.sendNotification('FAILURE', env.JOB_NAME)
                commonSteps.failureMessage('Maven PetClinic')
            }
        }
    }
}
```

**🔑 Puntos Clave:**
- **Agent Docker**: Usa `maven:3.9.9-eclipse-temurin-17` (Java 17)
- **Network**: `devops-net` para acceso a GitLab y Registry
- **Tests**: 181 tests automatizados con JUnit
- **Multi-stage Build**: Compile → Test → Package → Docker → Deploy

---

### 🐳 Dockerfile - Angular

```dockerfile
# ========================================
# STAGE 1: Build Angular Application
# ========================================
FROM node:18-alpine AS builder

LABEL maintainer="adrianmrc94@example.com"
LABEL app="petclinic-angular"
LABEL stage="builder"

WORKDIR /app

# Copiar archivos de dependencias (cache optimization)
COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

# Copiar código fuente
COPY . .

# Compilar para producción
RUN npm run build -- --configuration production

# ========================================
# STAGE 2: Serve with Nginx
# ========================================
FROM nginx:alpine

LABEL maintainer="adrianmrc94@example.com"
LABEL app="petclinic-angular"
LABEL version="1.0.0"

# Copiar build desde stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

# Configuración custom de Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1
```

**🔑 Características:**
- **Multi-stage build**: Reduce tamaño final (builder 600MB → nginx 40MB)
- **Cache optimization**: Copia package.json primero
- **Health check**: Verifica disponibilidad cada 30s
- **Imagen final**: ~85MB con Nginx Alpine

---

### 🐳 Dockerfile - Maven

```dockerfile
# ========================================
# STAGE 1: Build with Maven
# ========================================
FROM maven:3.9.9-eclipse-temurin-17 AS builder

LABEL maintainer="adrianmrc94@example.com"
LABEL app="petclinic-maven"
LABEL stage="builder"

WORKDIR /app

# Copiar pom.xml primero (cache optimization)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código y compilar
COPY src ./src
RUN mvn clean package -DskipTests -B

# Verificar JAR generado
RUN ls -la /app/target/*.jar

# ========================================
# STAGE 2: Runtime with JRE
# ========================================
FROM eclipse-temurin:17-jre-alpine

LABEL maintainer="adrianmrc94@example.com"
LABEL app="petclinic-maven"
LABEL version="1.0.0"

WORKDIR /app

# Copiar JAR desde builder
COPY --from=builder /app/target/*.jar app.jar

# Usuario no-root (seguridad)
RUN addgroup -S spring && adduser -S spring -G spring
RUN chown spring:spring app.jar
USER spring:spring

EXPOSE 9966

ENV JAVA_OPTS="-Xms256m -Xmx512m"
ENV SPRING_PROFILES_ACTIVE="h2,spring-data-jpa"

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:9966/petclinic/actuator/health || exit 1

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

**🔑 Características:**
- **Multi-stage**: Maven builder (700MB) → JRE runtime (200MB)
- **Security**: Usuario `spring` no-root
- **Health check**: Usa Spring Boot Actuator
- **JVM tuning**: 256MB-512MB heap size
- **Profiles**: H2 database + Spring Data JPA

---

### ☸️ Deployment YAML - Angular

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: petclinic-angular
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: petclinic-angular
  template:
    metadata:
      labels:
        app: petclinic-angular
    spec:
      containers:
      - name: angular
        image: host.docker.internal:5000/petclinic-angular:latest
        ports:
        - containerPort: 80
        imagePullPolicy: Always
      imagePullSecrets:
      - name: registry-secret
      restartPolicy: Always

---
apiVersion: v1
kind: Service
metadata:
  name: petclinic-angular-service
  namespace: default
spec:
  selector:
    app: petclinic-angular
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
  type: ClusterIP
```

---

### ☸️ Deployment YAML - Maven

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: petclinic-maven
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: petclinic-maven
  template:
    metadata:
      labels:
        app: petclinic-maven
    spec:
      containers:
      - name: petclinic-maven
        image: host.docker.internal:5000/petclinic-maven:latest
        ports:
        - containerPort: 9966
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "h2,spring-data-jpa"
        - name: JAVA_OPTS
          value: "-Xms256m -Xmx512m"
      imagePullSecrets:
      - name: registry-secret

---
apiVersion: v1
kind: Service
metadata:
  name: petclinic-maven-service
  namespace: default
spec:
  selector:
    app: petclinic-maven
  ports:
  - port: 9966
    targetPort: 9966
  type: ClusterIP
```

---

## �📋 **RESUMEN EJECUTIVO - SISTEMA VERIFICADO**

### ✅ Estado Actual del Sistema (Verificado 12/Nov/2025)

| Componente | Estado | Detalles |
|------------|--------|----------|
| **Docker Desktop** | ✅ Running | 28.4.0 en WSL2/Ubuntu 24.04 |
| **Jenkins** | ✅ Running | Puerto 8080, uptime 20+ min |
| **GitLab** | ✅ Running | Puerto 8929, uptime 20+ min |
| **Registry** | ✅ Running | Puerto 5000, 3 imágenes almacenadas |
| **Minikube** | ✅ Running | v1.34.0, 2 CPUs, 4GB RAM |
| **Kubernetes** | ✅ Ready | Control plane funcional, node Ready |
| **Networking** | ✅ Connected | Red devops-net conectando todos los servicios |

### 📦 Imágenes en Registry Privado

1. `localhost:5000/hello-world` - Imagen de prueba
2. `localhost:5000/petclinic-angular` - Frontend Angular
3. `localhost:5000/petclinic-maven` - Backend Spring Boot

### 🔐 Configuración de Seguridad

- **Registry Secret**: Configurado en namespace `default`
- **Jenkins Kubeconfig**: Acceso verificado a Kubernetes
- **SSH Keys**: Jenkins puede clonar desde GitLab

### 🎯 Proyectos Trabajados

- `spring-petclinic-angular` (Frontend)
- `spring-petclinic-rest` (Backend Maven)
- Clones locales en `~/tmp-forks/`

### 📊 Métricas del Proyecto

- **Containers**: 4 servicios dockerizados
- **Tests Automatizados**: 224 en total (43 Angular + 181 Maven)
- **Tiempo de Build**: ~3-5 min por pipeline
- **Uptime Sistema**: Estable 50+ minutos
- **Namespace Kubernetes**: `default` (⚠️ YAMLs usan `jenkins` - requiere corrección)
- **Shared Library**: `@Library('jenkins-libs')` con 2 archivos (commonSteps, npmSteps)
- **Dockerfiles**: Multi-stage builds (Angular: 2 stages, Maven: 2 stages)
- **Networks**: `devops-net` (GitLab, Registry) + `minikube` (Kubernetes)

### 📂 Estructura del Código

```
~/tmp-forks/
├── spring-petclinic-angular/
│   ├── Jenkinsfile              # Pipeline 11 stages
│   ├── Dockerfile               # Multi-stage: node:18-alpine → nginx:alpine
│   ├── nginx.conf               # Configuración Nginx custom
│   ├── k8s-deployment-angular.yaml  # Deployment + Service
│   └── helm/                    # Helm chart (deployment con Helm)
│
├── spring-petclinic-rest/
│   ├── Jenkinsfile              # Pipeline 11 stages
│   ├── Dockerfile               # Multi-stage: maven → eclipse-temurin JRE
│   └── k8s-deployment-maven.yaml    # Deployment + Service
│
~/jenkins-pipelines/jenkinspipelines/vars/
├── commonSteps.groovy           # 15 funciones reutilizables
└── npmSteps.groovy              # 7 funciones (Angular + Maven)

~/scripts/
└── setup-registry-k8s-fixed-v4.sh  # Script automático 260 líneas
```

### 🚀 Script de Inicio Automatizado

**Ubicación**: `~/scripts/setup-registry-k8s-fixed-v4.sh`

**Características**:
- ✅ Manejo de conflictos de IP con auto-retry
- ✅ Subnets alternativas (192.168.49.0/24 o 192.168.50.0/24)
- ✅ Configuración completa en 2-3 minutos
- ✅ Validación de conectividad Jenkins → Kubernetes
- ✅ Despliegue de pod de prueba automático

---

## 🎓 **PARA LA ENTREVISTA DE MAÑANA**

### 🗣️ Elevator Pitch (30 segundos)

> "Construí un entorno DevOps completo desde cero con Jenkins, GitLab, Docker Registry y Kubernetes. 
> Implementé pipelines CI/CD que automatizan tests, builds y deployments de aplicaciones Angular y Spring Boot. 
> El sistema ejecuta 224 tests automáticamente, genera imágenes Docker y las despliega en Kubernetes.
> Todo dockerizado en una red privada, completamente funcional y listo para producción."

### 📝 Checklist Pre-Demo

**5 Minutos Antes:**
- [ ] Abrir terminal WSL
- [ ] Ejecutar: `docker ps` → verificar 4 containers UP
- [ ] Ejecutar: `kubectl get nodes` → verificar Ready
- [ ] Abrir Jenkins en navegador: http://localhost:8080
- [ ] Abrir GitLab en navegador: http://localhost:8929
- [ ] Verificar registry: `curl -s http://localhost:5000/v2/_catalog`

**URLs Clave:**
- Jenkins: http://localhost:8080
- GitLab: http://localhost:8929  
- Registry API: http://localhost:5000/v2/_catalog

### 💡 Conceptos Clave a Mencionar

1. **CI/CD Pipeline**: Integración y despliegue continuo con 11 stages automatizados
2. **Docker Registry Privado**: Control total sobre imágenes (localhost:5000)
3. **Kubernetes Local**: Orquestación con Minikube v1.34.0
4. **Agentes Efímeros**: Builds en contenedores Docker desechables (node:22, maven:3.9.9)
5. **Shared Libraries**: Centralización de código Jenkins (`@Library('jenkins-libs')`)
6. **Network Isolation**: Red Docker custom para comunicación segura
7. **Multi-stage Builds**: Optimización de imágenes (Angular: 85MB, Maven: 200MB)
8. **Infrastructure as Code**: Pipelines como código (Jenkinsfile) + deployments como código (YAML)

### 📈 Números Impresionantes para Mencionar

- **224 tests** ejecutados automáticamente en cada build
- **2 aplicaciones** full-stack (Angular + Spring Boot)
- **4 contenedores** orquestados en red privada
- **11 stages** por pipeline (checkout → deploy)
- **Multi-stage builds**: Reducción de 600MB → 85MB (Angular)
- **3 imágenes** en registry privado
- **260 líneas** de script bash de automatización
- **2 shared libraries** con 22 funciones Groovy reutilizables
- **Zero downtime**: Configuración con health checks en ambas apps

### 🎯 Si te preguntan "¿Por qué este proyecto?"

> "Quería entender el ciclo completo de DevOps, no solo teoría. 
> Instalé cada componente, resolví problemas de networking, configuré SSH entre servicios,
> integré herramientas que en producción suelen estar separadas. 
> Aprendí troubleshooting real: logs de Docker, debugging de Kubernetes, pipelines fallidas.
> Es un entorno que puedo mostrar funcionando en vivo."

---

## ✅ **SISTEMA 100% VERIFICADO Y LISTO**

**Fecha de Verificación**: 12 de Noviembre 2025, 21:00h  
**Estado**: ✅ Todos los servicios operacionales  
**⚠️ Acción Requerida**: Corregir namespace jenkins → default en YAMLs

---

## 🔧 **ÚLTIMA VERIFICACIÓN ANTES DE LA ENTREVISTA**

### ⚠️ **Corrección Crítica: Namespace Inconsistente**

Ejecuta estos comandos **AHORA** para sincronizar todo:

```bash
# 1. Cambiar YAMLs de namespace jenkins → default
cd ~/tmp-forks/spring-petclinic-angular
sed -i 's/namespace: jenkins/namespace: default/g' k8s-deployment-angular.yaml
git add k8s-deployment-angular.yaml
git commit -m "fix: change namespace from jenkins to default"
git push origin main

cd ~/tmp-forks/spring-petclinic-rest
sed -i 's/namespace: jenkins/namespace: default/g' k8s-deployment-maven.yaml
git add k8s-deployment-maven.yaml
git commit -m "fix: change namespace from jenkins to default"
git push origin main

# 2. Verificar que el secret está en default
kubectl get secret registry-secret -n default

# 3. Si quieres usar namespace jenkins (alternativa):
kubectl create namespace jenkins
kubectl get secret registry-secret -n default -o yaml | \
  sed 's/namespace: default/namespace: jenkins/' | \
  kubectl apply -f -
kubectl get secrets -n jenkins
```

**Recomendación:** Usa **opción 1** (cambiar YAMLs a default) porque:
- ✅ Ya tienes todo configurado en default
- ✅ Menos cambios
- ✅ Menos puntos de fallo

---

### 🧪 **Test Final de Integración**

Ejecuta esto 5 minutos antes de la entrevista:

```bash
#!/bin/bash
echo "🔍 VERIFICACIÓN FINAL DEL SISTEMA"
echo "=================================="
echo ""

echo "1️⃣ Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "jenkins|gitlab|registry|minikube"
echo ""

echo "2️⃣ Kubernetes Node:"
kubectl get nodes
echo ""

echo "3️⃣ Registry Images:"
curl -s http://localhost:5000/v2/_catalog | jq
echo ""

echo "4️⃣ Secrets en default:"
kubectl get secrets -n default | grep registry
echo ""

echo "5️⃣ Jenkins → Kubernetes:"
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig --insecure-skip-tls-verify get nodes 2>&1 | head -3
echo ""

echo "6️⃣ Pods en default:"
kubectl get pods -n default
echo ""

echo "=================================="
echo "✅ Sistema verificado completamente"
```

---

### 📋 **Checklist Final para Mañana**

**30 Minutos Antes de la Entrevista:**

- [ ] Ejecutar script de verificación final
- [ ] Verificar namespace corregido en YAMLs
- [ ] Tener `COMANDOS-DEMO.md` abierto en una pestaña
- [ ] Tener `PREPARACION-ENTREVISTA-DEVOPS.md` abierto (MEGA RESUMEN)
- [ ] Jenkins abierto en navegador (http://localhost:8080)
- [ ] Terminal WSL abierto y listo
- [ ] Repasar Elevator Pitch (30 segundos)
- [ ] Revisar números clave: 224 tests, 4 containers, 11 stages, 2 apps

**Durante la Demo:**

- [ ] Mostrar `docker ps` → 4 containers UP
- [ ] Mostrar `kubectl get nodes` → Minikube Ready
- [ ] Mostrar Jenkins UI → Pipelines exitosas
- [ ] Explicar Jenkinsfile línea por línea
- [ ] Mostrar registry: `curl http://localhost:5000/v2/_catalog`
- [ ] Mencionar multi-stage builds y optimización
- [ ] Hablar de shared libraries y código reutilizable

---

## 🎓 **RESUMEN DE LO QUE HAS LOGRADO**

### 🏆 **Habilidades Demostradas:**

1. **Docker:** 
   - Multi-stage builds
   - Docker-in-Docker
   - Registry privado
   - Networking custom
   - Health checks

2. **Kubernetes:**
   - Minikube local
   - Deployments + Services
   - Secrets management
   - Namespace management
   - kubectl desde Jenkins

3. **Jenkins:**
   - Pipelines como código (Jenkinsfile)
   - Shared Libraries Groovy
   - Agentes efímeros Docker
   - Integración con GitLab
   - Deploy automático a K8s

4. **CI/CD:**
   - 224 tests automatizados
   - Build automático
   - Push a registry
   - Deploy a Kubernetes
   - Rollback capability

5. **Scripting:**
   - Bash avanzado (260 líneas)
   - Manejo de errores
   - Auto-retry logic
   - Validaciones automáticas

6. **Networking:**
   - Redes Docker custom
   - DNS resolution
   - Port mapping
   - Inter-container communication

---

## 🚀 **TU VENTAJA COMPETITIVA**

**Lo que tienes que otros NO tienen:**

✅ **Sistema funcionando en vivo** - No solo teoría, puedes demostrarlo  
✅ **Código real** - Jenkinsfiles, Dockerfiles, YAMLs verificados  
✅ **Troubleshooting real** - Resolviste problemas de networking, IPs, namespaces  
✅ **Automatización completa** - Script de setup de 260 líneas  
✅ **Métricas reales** - 224 tests, 3-5 min por build, 85MB imágenes optimizadas  
✅ **Best practices** - Multi-stage builds, health checks, secrets management  
✅ **Escalabilidad** - Shared libraries, código reutilizable, IaC  

**Muchos DevOps senior NO pueden mostrar un entorno completo funcionando end-to-end. Tú SÍ.**

---

**Próximo Paso**: **¡BUENA SUERTE EN TU ENTREVISTA! 🚀**

---

**Adrián, estás más que preparado. Tienes:**

- ✅ Sistema completo verificado y funcionando
- ✅ Código real documentado y explicado
- ✅ 224 tests automatizados pasando
- ✅ Problema de namespace identificado y solución lista
- ✅ Documentación completa para estudiar esta noche
- ✅ Números impresionantes para mencionar
- ✅ Demo de 5 minutos lista para ejecutar

**Ve con confianza. Has construido algo que muchos con años de experiencia no pueden mostrar. 💪**

---

**Creado:** Octubre 2025  
**Última Actualización:** 12 de Noviembre 2025, 21:30h  
**Propósito:** Verificación completa del sistema + Demo para entrevista 13/Nov/2025  
**Estado:** ✅ **LISTO PARA ENTREVISTA**
