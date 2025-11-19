# 🚀 Tarea 13: Integrar Docker Build en Pipelines de Jenkins

## 📋 **Objetivo**

Añadir stages de Docker en las pipelines de Jenkins para:
- ✅ Construir imágenes Docker desde los Dockerfiles creados en Tarea 12
- ✅ Etiquetar imágenes con `latest` y `BUILD_NUMBER`
- ✅ Hacer push al Docker Registry local (`registry:5000`)
- ✅ (Opcional) Desplegar en Kubernetes automáticamente

---

## 📂 **Estructura Actual**

```
jenkins-pipelines/                    ← Shared Library
├── vars/
│   └── commonSteps.groovy           ← Funciones reutilizables
└── ...

spring-petclinic-angular/
├── Jenkinsfile                       ← Pipeline Angular (a modificar)
├── Dockerfile                        ← Creado en Tarea 12
├── nginx.conf                        ← Creado en Tarea 12
└── .dockerignore                     ← Creado en Tarea 12

spring-petclinic-rest/
├── Jenkinsfile                       ← Pipeline Maven (a modificar)
├── Dockerfile                        ← Creado en Tarea 12
└── .dockerignore                     ← Creado en Tarea 12
```

---

## 🎯 **Flujo de la Pipeline Completa**

```
1. Checkout código desde GitLab
        ↓
2. Instalar dependencias
        ↓
3. Ejecutar tests
        ↓
4. Build de la aplicación
        ↓
5. 🆕 Docker Build (crear imagen)
        ↓
6. 🆕 Docker Tag (latest + BUILD_NUMBER)
        ↓
7. 🆕 Docker Push (subir a registry:5000)
        ↓
8. 🆕 Deploy a Kubernetes (opcional)
        ↓
9. Success ✅
```

---

## 🅰️ **Parte 1: Pipeline Angular con Docker**

### **Paso 1: Modificar Jenkinsfile de petclinic-angular**

**Ubicación:** `/path/to/projects/spring-petclinic-angular/Jenkinsfile`

**⚠️ IMPORTANTE:** Usamos `localhost:5000` en vez de `registry:5000` porque los contenedores de build usan Docker-in-Docker y no pueden resolver el hostname `registry`.

<details>
<summary>🤔 <b>¿Por qué localhost:5000 y no registry:5000?</b> (click para expandir)</summary>

### **Explicación Técnica: Docker-in-Docker y DNS**

Cuando usamos Docker-in-Docker, hay **dos niveles de contexto**:

```
HOST (tu máquina)
  ├─ Jenkins Container (network: devops-net)
  │   └─ Puede resolver: registry:5000 ✅
  │
  └─ Build Container (node:18 / maven:3.9)
      ├─ Ejecuta comandos docker en el daemon del HOST
      ├─ NO hereda DNS de devops-net
      └─ NO puede resolver: registry:5000 ❌
```

**El problema:**
1. El Build Container monta `/var/run/docker.sock` del HOST
2. Cuando ejecuta `docker build` o `docker push`, el comando va al Docker daemon del **HOST**
3. El daemon del HOST intenta resolver `registry:5000`
4. ❌ Falla porque `registry` es un hostname interno de la red `devops-net`
5. El daemon del HOST no usa el DNS de esa red

**La solución:**
1. El Registry está expuesto en el puerto `5000` del HOST (`-p 5000:5000`)
2. `localhost` siempre apunta al HOST desde cualquier contexto
3. `localhost:5000` funciona porque el daemon del HOST puede acceder a su propio puerto ✅

**Flujo con localhost:5000:**
```
Build Container: docker push localhost:5000/imagen
      ↓
Docker daemon del HOST → localhost:5000
      ↓
HOST:5000 → Registry Container
      ↓
✅ SUCCESS
```

**Alternativas que también funcionarían:**
- Usar la IP del HOST: `192.168.x.x:5000`
- Configurar `/etc/hosts` en el HOST: `127.0.0.1 registry`
- Usar `host.docker.internal:5000` (solo Docker Desktop Mac/Windows)

Elegimos `localhost:5000` porque es universal, simple y no requiere configuración adicional.

</details>

```groovy
@Library('jenkinspipelines') _

pipeline {
    agent {
        docker {
            image 'node:18-bullseye'
            args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network devops-net -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    environment {
        // Configuración de Docker
        DOCKER_REGISTRY = 'localhost:5000'  // ⚠️ Usar localhost:5000, NO registry:5000
        IMAGE_NAME = 'petclinic-angular'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}"
    }
    
    stages {
        stage('📥 Checkout') {
            steps {
                script {
                    commonSteps.checkoutCode()
                }
            }
        }
        
        stage('📦 Install Dependencies') {
            steps {
                script {
                    commonSteps.installNodeDependencies()
                }
            }
        }
        
        stage('🧪 Run Tests') {
            steps {
                script {
                    commonSteps.runAngularTests()
                }
            }
        }
        
        stage('🏗️ Build Application') {
            steps {
                script {
                    commonSteps.buildAngular()
                }
            }
        }
        
        // 🆕 NUEVO: Docker Build
        stage('🐳 Docker Build') {
            steps {
                script {
                    echo "🐳 Building Docker image: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
                    // Instalar Docker CLI si no existe
                    sh """
                        if ! command -v docker &> /dev/null; then
                            echo "Installing Docker CLI..."
                            apt-get update -qq
                            apt-get install -y docker.io
                        fi
                        
                        docker build -t ${FULL_IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${FULL_IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        // 🆕 NUEVO: Docker Push
        stage('📤 Docker Push') {
            steps {
                script {
                    echo "📤 Pushing to registry: ${DOCKER_REGISTRY}"
                    sh """
                        docker push ${FULL_IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${FULL_IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        // 🆕 NUEVO: Verify in Registry
        stage('✅ Verify Image') {
            steps {
                script {
                    echo "✅ Verifying image in registry..."
                    // Instalar jq si no existe
                    sh """
                        if ! command -v jq &> /dev/null; then
                            echo "Installing jq..."
                            apt-get update -qq
                            apt-get install -y jq
                        fi
                        
                        echo "Images in registry:"
                        curl -s http://localhost:5000/v2/_catalog | jq
                        echo ""
                        echo "Tags for ${IMAGE_NAME}:"
                        curl -s http://localhost:5000/v2/${IMAGE_NAME}/tags/list | jq
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "📦 Image: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
            echo "📦 Image: ${FULL_IMAGE_NAME}:latest"
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
```

---

## ☕ **Parte 2: Pipeline Maven con Docker**

### **Paso 2: Modificar Jenkinsfile de petclinic-maven**

**Ubicación:** `/path/to/projects/spring-petclinic-rest/Jenkinsfile`

**⚠️ IMPORTANTE:** Usamos el workspace de Jenkins (`/var/jenkins_home/workspace/${JOB_NAME}`) para evitar problemas de permisos con Maven.

```groovy
@Library('jenkinspipelines') _

pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network devops-net -v /var/run/docker.sock:/var/run/docker.sock'
        }
    }
    
    environment {
        // Configuración de Docker
        DOCKER_REGISTRY = 'localhost:5000'  // ⚠️ Usar localhost:5000, NO registry:5000
        IMAGE_NAME = 'petclinic-maven'
        IMAGE_TAG = "${BUILD_NUMBER}"
        FULL_IMAGE_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME}"
    }
    
    stages {
        stage('📥 Checkout') {
            steps {
                script {
                    commonSteps.checkoutCode()
                }
            }
        }
        
        stage('🧪 Run Tests') {
            steps {
                script {
                    commonSteps.runMavenTests()
                }
            }
        }
        
        stage('🏗️ Build Application') {
            steps {
                script {
                    commonSteps.buildMaven()
                }
            }
        }
        
        // 🆕 NUEVO: Docker Build
        stage('🐳 Docker Build') {
            steps {
                script {
                    echo "🐳 Building Docker image: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
                    // Instalar Docker CLI si no existe
                    sh """
                        if ! command -v docker &> /dev/null; then
                            echo "Installing Docker CLI..."
                            apt-get update -qq
                            apt-get install -y docker.io
                        fi
                        
                        docker build -t ${FULL_IMAGE_NAME}:${IMAGE_TAG} .
                        docker tag ${FULL_IMAGE_NAME}:${IMAGE_TAG} ${FULL_IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        // 🆕 NUEVO: Docker Push
        stage('📤 Docker Push') {
            steps {
                script {
                    echo "📤 Pushing to registry: ${DOCKER_REGISTRY}"
                    sh """
                        docker push ${FULL_IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${FULL_IMAGE_NAME}:latest
                    """
                }
            }
        }
        
        // 🆕 NUEVO: Verify in Registry
        stage('✅ Verify Image') {
            steps {
                script {
                    echo "✅ Verifying image in registry..."
                    // Instalar jq si no existe
                    sh """
                        if ! command -v jq &> /dev/null; then
                            echo "Installing jq..."
                            apt-get update -qq
                            apt-get install -y jq
                        fi
                        
                        echo "Images in registry:"
                        curl -s http://localhost:5000/v2/_catalog | jq
                        echo ""
                        echo "Tags for ${IMAGE_NAME}:"
                        curl -s http://localhost:5000/v2/${IMAGE_NAME}/tags/list | jq
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '✅ Pipeline completed successfully!'
            echo "📦 Image: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
            echo "📦 Image: ${FULL_IMAGE_NAME}:latest"
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
```

---

## 🔧 **Parte 3: Configurar Jenkins para Docker**

### **⚠️ Solución Implementada: Docker-in-Docker**

**Problema encontrado:** El montaje de `/usr/bin/docker` desde el host al contenedor Jenkins estaba corrupto, causando "Input/output error".

**Solución:** En lugar de montar el binario Docker, instalamos Docker CLI dentro de los contenedores de build y montamos el socket Docker.

### **Configuración del Agent en Jenkinsfile**

```groovy
agent {
    docker {
        image 'node:18-bullseye'  // o 'maven:3.9.9-eclipse-temurin-17'
        args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network devops-net -v /var/run/docker.sock:/var/run/docker.sock'
    }
}
```

**Puntos clave:**
- ✅ `-v /var/run/docker.sock:/var/run/docker.sock` → Acceso al Docker daemon del host
- ✅ `--user root` → Necesario para instalar paquetes (docker.io, jq)
- ✅ `--network devops-net` → Acceso al registry y otros servicios
- ✅ `-w /app` → Directorio de trabajo donde está el código

### **Instalación automática de Docker CLI**

En cada stage que use Docker, instalamos el CLI si no existe:

```bash
if ! command -v docker &> /dev/null; then
    echo "Installing Docker CLI..."
    apt-get update -qq
    apt-get install -y docker.io
fi
```

### **Verificar configuración de Jenkins**

```bash
# Verificar que Jenkins tiene el socket montado
docker inspect jenkins | grep "/var/run/docker.sock"

# Debería mostrar:
# "/var/run/docker.sock:/var/run/docker.sock"
```

**Si Jenkins NO tiene el socket Docker montado:**

```bash
# Detener Jenkins
docker stop jenkins
docker rm jenkins

# Recrear con socket Docker
docker run -d \
  --name jenkins \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --network devops-net \
  jenkins/jenkins:lts
```

---

## 📝 **Paso a Paso: Actualizar las Pipelines**

### **Para petclinic-angular:**

```bash
cd /path/to/projects/spring-petclinic-angular

# Crear backup del Jenkinsfile actual
cp Jenkinsfile Jenkinsfile.backup

# Editar Jenkinsfile (copia el contenido de arriba)
nano Jenkinsfile

# O usar el editor que prefieras
code Jenkinsfile  # VS Code
vim Jenkinsfile   # Vim

# Commit y push
git add Jenkinsfile
git commit -m "feat: add Docker build and push stages to pipeline

- Build Docker image with tag: BUILD_NUMBER and latest
- Push images to registry:5000
- Verify images in registry
- Optional Kubernetes deployment stage
"
git push origin main
```

---

### **Para petclinic-maven:**

```bash
cd /path/to/projects/spring-petclinic-rest

# Crear backup del Jenkinsfile actual
cp Jenkinsfile Jenkinsfile.backup

# Editar Jenkinsfile (copia el contenido de arriba)
nano Jenkinsfile

# Commit y push
git add Jenkinsfile
git commit -m "feat: add Docker build and push stages to pipeline

- Build Docker image with tag: BUILD_NUMBER and latest
- Push images to registry:5000
- Verify images in registry
- Optional Kubernetes deployment stage
"
git push origin main
```

---

## 🧪 **Fase de Prueba**

### **1. Ejecutar Pipeline Angular**

```bash
# Desde Jenkins UI (http://localhost:8080)
# 1. Ir al job "petclinic-angular-ci"
# 2. Click "Build Now"
# 3. Ver "Console Output"

# O desde línea de comandos (trigger manual)
curl -X POST http://localhost:8080/job/petclinic-angular-ci/build \
  --user admin:your_token
```

**Deberías ver en los logs:**
```
🐳 Building Docker image: registry:5000/petclinic-angular:1
📤 Pushing to registry: registry:5000
✅ Verifying image in registry...
{"repositories":["hello-world","petclinic-angular"]}
✅ Pipeline completed successfully!
📦 Image: registry:5000/petclinic-angular:1
📦 Image: registry:5000/petclinic-angular:latest
```

---

### **2. Verificar imágenes en el Registry**

```bash
# Ver todas las imágenes
curl http://localhost:5000/v2/_catalog | jq

# Ver tags de petclinic-angular
curl http://localhost:5000/v2/petclinic-angular/tags/list | jq

# Ver tags de petclinic-maven
curl http://localhost:5000/v2/petclinic-maven/tags/list | jq
```

**Resultado esperado:**
```json
{
  "repositories": [
    "hello-world",
    "petclinic-angular",
    "petclinic-maven"
  ]
}

{
  "name": "petclinic-angular",
  "tags": ["1", "2", "3", "latest"]
}
```

---

### **3. Probar imagen desde Registry**

```bash
# Pull imagen desde registry
docker pull registry:5000/petclinic-angular:latest

# Ver imágenes
docker images | grep petclinic

# Ejecutar contenedor
docker run -d -p 4200:80 --name test-angular registry:5000/petclinic-angular:latest

# Verificar
curl http://localhost:4200

# Limpiar
docker stop test-angular
docker rm test-angular
```

---

## 🐛 **Troubleshooting - Problemas Reales Encontrados**

### **Error 1: "docker: Input/output error" en Jenkins** ⚠️ CRÍTICO

**Síntomas:**
```bash
docker exec jenkins docker ps
# docker: Input/output error
```

**Causa:** El binario `/usr/bin/docker` montado desde el host estaba corrupto.

**Solución Aplicada:**
```bash
# NO intentar arreglar el montaje corrupto
# En su lugar, usar Docker-in-Docker con instalación dinámica

# En Jenkinsfile, instalar Docker CLI dentro del contenedor de build:
if ! command -v docker &> /dev/null; then
    apt-get update -qq
    apt-get install -y docker.io
fi
```

**Resultado:** ✅ Docker funciona correctamente instalándolo dinámicamente en cada build.

---

### **Error 2: "dial tcp: lookup registry: no such host"** ⚠️ CRÍTICO

**Síntomas:**
```
Error response from daemon: Get "https://registry:5000/v2/": dial tcp: lookup registry: no such host
```

**Causa:** Los contenedores de build (node:18-bullseye, maven:3.9.9) usan Docker-in-Docker, que NO hereda la configuración DNS de la red `devops-net`. No pueden resolver el hostname `registry`.

**Solución Aplicada:**
```groovy
// ANTES (NO FUNCIONA):
DOCKER_REGISTRY = 'registry:5000'

// DESPUÉS (FUNCIONA):
DOCKER_REGISTRY = 'localhost:5000'
```

**Resultado:** ✅ Docker push exitoso a `localhost:5000`

---

### **Error 3: "jq: not found"**

**Síntomas:**
```bash
/var/jenkins_home/workspace/petclinic-angular-ci@tmp/durable-b8c3f2e0/script.sh: 8: jq: not found
```

**Causa:** El contenedor de build no tiene `jq` instalado para parsear JSON.

**Solución Aplicada:**
```bash
# En el stage "Verify Image"
if ! command -v jq &> /dev/null; then
    apt-get update -qq
    apt-get install -y jq
fi

curl -s http://localhost:5000/v2/_catalog | jq
```

**Resultado:** ✅ JSON parseado correctamente con colores.

---

### **Error 4: "Could not create local repository at /tmp/maven-build/.m2/repository"**

**Síntomas:**
```
[ERROR] Failed to execute goal [...]: Could not create local repository at /tmp/maven-build/.m2/repository
```

**Causa:** Maven no tiene permisos de escritura en `/tmp/maven-build`.

**Solución Aplicada:**
```groovy
// ANTES (NO FUNCIONA):
args '-v /tmp/maven-build:/tmp/maven-build -w /tmp/maven-build ...'

// DESPUÉS (FUNCIONA):
args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root ...'
```

**Resultado:** ✅ Maven compila y empaqueta correctamente.

---

### **Error 5: Ramas duplicadas (master y main)**

**Síntomas:**
```bash
git push origin main
# To ssh://localhost:2222/root/spring-petclinic-angular.git
#  * [new branch]      main -> main
# error: branch 'master' already exists
```

**Causa:** El repositorio local tenía rama `master`, pero GitLab usaba `main` como default.

**Solución Aplicada:**
```bash
# Renombrar master a main
git branch -m master main

# Force push a main
git push origin main --force

# Eliminar master remoto
git push origin --delete master

# Configurar main como default en GitLab UI
# Settings → Repository → Default branch → main
```

**Resultado:** ✅ Todos los proyectos usan rama `main` consistentemente.

---

### **Error 6: "permission denied" al ejecutar docker (Opcional)**

**Causa:** Jenkins no tiene permisos para usar el socket Docker.

**Solución (si es necesario):**
```bash
# Dar permisos al socket
docker exec -u root jenkins chmod 666 /var/run/docker.sock
```

**Nota:** No fue necesario aplicar esta solución porque usamos `--user root` en el agent.

---

### **Error 7: "server gave HTTP response to HTTPS client" (Opcional)**

**Causa:** Registry no está configurado como insecure en Docker daemon.

**Solución (si es necesario):**
```bash
# En el host, editar /etc/docker/daemon.json
{
  "insecure-registries": ["registry:5000", "localhost:5000"]
}

# Reiniciar Docker
sudo systemctl restart docker
```

**Nota:** No fue necesario porque nuestro registry ya estaba configurado sin autenticación.

---

## 📊 **Mejoras Opcionales**

### **1. Añadir parámetro para Deploy a Kubernetes**

En Jenkins UI:
1. Ir al job → Configure
2. Marcar "This project is parameterized"
3. Add Parameter → Boolean Parameter
4. Name: `DEPLOY_TO_K8S`
5. Default: `false`
6. Description: "Deploy to Kubernetes after build"

---

### **2. Notificaciones de Build**

Añadir al `post` block:

```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "✅ Build #${BUILD_NUMBER} succeeded!\nImage: ${FULL_IMAGE_NAME}:${IMAGE_TAG}"
        )
    }
    failure {
        slackSend(
            color: 'danger',
            message: "❌ Build #${BUILD_NUMBER} failed!"
        )
    }
}
```

---

### **3. Escaneo de Vulnerabilidades**

Añadir stage de seguridad:

```groovy
stage('🔒 Security Scan') {
    steps {
        script {
            sh """
                # Instalar trivy si no está instalado
                docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
                    aquasec/trivy image ${FULL_IMAGE_NAME}:${IMAGE_TAG}
            """
        }
    }
}
```

---

## ✅ **Checklist de Validación**

### **Petclinic Angular:**
- [x] Jenkinsfile actualizado con stages de Docker
- [x] Pipeline ejecuta sin errores (Build #36: SUCCESS)
- [x] Imagen construida correctamente (84.9MB)
- [x] Imagen pusheada al registry (localhost:5000/petclinic-angular)
- [x] Tags `latest`, `35`, `36` visibles en registry
- [x] Imagen puede descargarse y ejecutarse
- [x] Docker CLI instalado dinámicamente
- [x] jq instalado dinámicamente
- [x] Usa `localhost:5000` en vez de `registry:5000`

### **Petclinic Maven:**
- [x] Jenkinsfile actualizado con stages de Docker
- [x] Pipeline ejecuta sin errores (Build #22: SUCCESS)
- [x] Imagen construida correctamente (531MB)
- [x] Imagen pusheada al registry (localhost:5000/petclinic-maven)
- [x] Tags `latest`, `22` visibles en registry
- [x] Imagen puede descargarse y ejecutarse
- [x] Docker CLI instalado dinámicamente
- [x] jq instalado dinámicamente
- [x] Usa workspace de Jenkins (no /tmp/maven-build)

### **Registry Verificado:**
```bash
# Catálogo completo
curl http://localhost:5000/v2/_catalog | jq
# {
#   "repositories": [
#     "hello-world",
#     "petclinic-angular",
#     "petclinic-maven"
#   ]
# }

# Tags Angular
curl http://localhost:5000/v2/petclinic-angular/tags/list | jq
# { "name": "petclinic-angular", "tags": ["35", "36", "latest"] }

# Tags Maven
curl http://localhost:5000/v2/petclinic-maven/tags/list | jq
# { "name": "petclinic-maven", "tags": ["22", "latest"] }
```

---

## 🎯 **Resultado Final - COMPLETADO ✅**

Al terminar esta tarea tienes:

✅ **Pipeline completa de CI/CD funcionando:**
```
GitLab → Jenkins → Checkout → Dependencies → Tests → Build → 
Docker Build → Docker Push → Verify → SUCCESS
```

✅ **Registry poblado con imágenes:**
```
localhost:5000/petclinic-angular:35, :36, :latest (84.9MB)
localhost:5000/petclinic-maven:22, :latest (531MB)
localhost:5000/hello-world:latest
```

✅ **Sistema probado y verificado:**
- Angular: Pipeline #36 SUCCESS
- Maven: Pipeline #22 SUCCESS
- Imágenes verificadas en registry con curl + jq
- Docker-in-Docker funcionando correctamente
- Instalación automática de herramientas (docker.io, jq)
- Versionado automático con BUILD_NUMBER + latest

✅ **Problemas resueltos:**
- Docker CLI instalado dinámicamente en contenedores
- DNS resolution: localhost:5000 en vez de registry:5000
- Permisos de Maven: usar workspace de Jenkins
- Git branches: consolidado a `main`
- jq instalado para verificación JSON

✅ **Flujo completo operativo:**
```
1. git push origin main
2. Jenkins detecta el cambio (manual o webhook)
3. Ejecuta pipeline completa
4. Construye imagen Docker
5. Pushea a localhost:5000
6. Verifica en registry
7. ¡Listo para desplegar en Kubernetes! (Tarea 14)
```

---

## � **Historial de Commits Realizados**

### **Proyecto: spring-petclinic-angular**

```bash
# Commit 1: Añadir stages de Docker
git add Jenkinsfile
git commit -m "feat: add Docker build and push stages to pipeline"
git push origin main

# Commit 2: Instalar Docker CLI dinámicamente
git add Jenkinsfile
git commit -m "fix: install Docker CLI in Docker Build stage"
git push origin main

# Commit 3: Cambiar a localhost:5000
git add Jenkinsfile
git commit -m "fix: use localhost:5000 instead of registry:5000 for Docker push"
git push origin main

# Commit 4: Instalar jq en Verify stage
git add Jenkinsfile
git commit -m "fix: install jq and use localhost:5000 in Verify stage"
git push origin main
```

### **Proyecto: spring-petclinic-rest**

```bash
# Commit 1: Añadir stages de Docker
git add Jenkinsfile
git commit -m "feat: add Docker build and push stages to pipeline"
git push origin main

# Commit 2: Instalar Docker CLI dinámicamente
git add Jenkinsfile
git commit -m "fix: install Docker CLI in Docker Build stage"
git push origin main

# Commit 3: Cambiar a localhost:5000
git add Jenkinsfile
git commit -m "fix: use localhost:5000 instead of registry:5000 for Docker push"
git push origin main

# Commit 4: Usar workspace de Jenkins
git add Jenkinsfile
git commit -m "fix: use Jenkins workspace instead of /tmp/maven-build"
git push origin main

# Commit 5: Instalar jq en Verify stage
git add Jenkinsfile
git commit -m "fix: install jq and use localhost:5000 in Verify stage"
git push origin main
```

---

## 🔍 **Comandos de Verificación Ejecutados**

### **1. Verificar Registry Catalog**
```bash
# Instalar jq (si no está instalado)
sudo apt install jq

# Ver todas las imágenes en el registry
curl http://localhost:5000/v2/_catalog | jq
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

### **2. Verificar Tags de Angular**
```bash
curl http://localhost:5000/v2/petclinic-angular/tags/list | jq
```

**Resultado:**
```json
{
  "name": "petclinic-angular",
  "tags": [
    "35",
    "36",
    "latest"
  ]
}
```

### **3. Verificar Tags de Maven**
```bash
curl http://localhost:5000/v2/petclinic-maven/tags/list | jq
```

**Resultado:**
```json
{
  "name": "petclinic-maven",
  "tags": [
    "22",
    "latest"
  ]
}
```

### **4. Probar Imágenes Localmente**
```bash
# Pull imagen desde registry
docker pull localhost:5000/petclinic-angular:latest

# Ver imágenes
docker images | grep petclinic

# Ejecutar Angular
docker run -d -p 4200:80 --name test-angular localhost:5000/petclinic-angular:latest
curl http://localhost:4200
docker stop test-angular && docker rm test-angular

# Ejecutar Maven
docker run -d -p 9966:9966 --name test-maven localhost:5000/petclinic-maven:latest
curl http://localhost:9966/petclinic
docker stop test-maven && docker rm test-maven
```

---

## 🎓 **Lecciones Aprendidas**

1. **Docker-in-Docker:** Al usar contenedores Docker para builds, es mejor instalar Docker CLI dinámicamente que montar binarios desde el host.

2. **DNS en Docker-in-Docker:** Los contenedores anidados no heredan DNS de la red del contenedor padre. Usar `localhost` es más confiable que hostnames de red.

3. **Permisos en Contenedores:** Usar `--user root` en agents de Jenkins cuando necesites instalar paquetes, pero ten cuidado con los permisos de archivos resultantes.

4. **Herramientas Dinámicas:** Instalar herramientas como `docker.io` y `jq` dinámicamente hace las pipelines más portables y menos dependientes del entorno.

5. **Git Branching:** Estandarizar en `main` desde el inicio evita confusiones. GitLab y GitHub usan `main` como default moderno.

6. **Tagging de Imágenes:** Siempre usar dos tags: `BUILD_NUMBER` para trazabilidad y `latest` para conveniencia en desarrollo.

---

**Documentación creada:** Octubre 2025  
**Última actualización:** Octubre 2025  
**Versión:** 2.0 - Actualizado con soluciones reales implementadas
