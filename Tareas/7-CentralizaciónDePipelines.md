# 📋 Guía Completa: Centralización de Pipelines Jenkins con Shared Libraries

## 🎯 Objetivo

Crear un repositorio centralizado `jenkinspipelines` para gestionar todas las configuraciones de CI/CD de Jenkins, utilizando Jenkins Shared Libraries para reutilizar código y estandarizar procesos entre proyectos.

## ✅ Resultado Final

- ✅ **Pipeline Maven (Backend):** 181 tests ejecutados, JAR generado - **SUCCESS**
- ✅ **Pipeline Angular (Frontend):** 43 tests con Chrome Headless - **SUCCESS**
- ✅ **Funciones reutilizables** para futuros proyectos
- ✅ **Mantenimiento centralizado** de todas las configuraciones

## 🔧 Prerrequisitos

### ✅ Infraestructura necesaria

```bash
# Contenedores corriendo
docker ps

# Deben aparecer:
- jenkins:8080
- gitlab:8929
```

### ✅ Proyectos existentes funcionando

- `petclinic-rest` (Maven) - Pipeline funcionando con 181 tests ✅
- `petclinic-angular` - Pipeline funcionando con 43 tests ✅
- Jenkins con acceso SSH a GitLab configurado
- Red Docker `devops-net` operativa

## 🚀 Implementación Paso a Paso

### **Fase 1: Creación del Repositorio Centralizado**

#### **Paso 1.1: Crear repositorio en GitLab**

1. **Ir a GitLab:** `http://localhost:8929`
2. **New Project** → **Create blank project**
   - Project name: `jenkinspipelines`
   - Visibility: Private
   - Initialize with README: ✅
3. **Create project**

#### **Paso 1.2: Clonar repositorio localmente**

```bash
cd ~/jenkins-pipelines
git clone ssh://git@gitlab:22/adrianmrc94/jenkinspipelines.git
cd jenkinspipelines
```

### **Fase 2: Preparación de la Estructura**

#### **Paso 2.1: Crear estructura de directorios**
La estructura de Jenkins Shared Libraries es un estándar definido por Jenkins. No es arbitraria, sino que Jenkins busca automáticamente en directorios específicos:

```bash
mkdir -p pipelines/maven
mkdir -p pipelines/angular  
mkdir -p vars
mkdir -p docs
mkdir -p templates
```

**Estructura objetivo:**
```
jenkinspipelines/
├── README.md
├── vars/                            # ⭐ OBLIGATORIO - Global variables/functions
│   └── commonSteps.groovy           # ⭐ Funciones compartidas
├── pipelines/
│   ├── maven/
│   │   └── Jenkinsfile-petclinic-maven
│   └── angular/
│       └── Jenkinsfile-petclinic-angular
├── docs/
│   └── PIPELINE-GUIDE.md
└── templates/
    └── Jenkinsfile-template
```

#### **Paso 2.2: Crear archivo de funciones compartidas**

```bash
# Crear vars/commonSteps.groovy
cat > vars/commonSteps.groovy << 'EOF'
#!/usr/bin/env groovy

/**
 * Shared Jenkins Pipeline Functions for PetClinic Projects
 */

def setupGitCredentials() {
    echo '🔐 Setting up Git credentials...'
    sh '''
        git config --global user.name "Jenkins CI"
        git config --global user.email "jenkins@petclinic.local"
    '''
}

def cleanWorkspace() {
    echo '🧹 Cleaning workspace...'
    sh '''
        rm -rf node_modules/.cache || true
        rm -rf .npm || true
        rm -rf target/surefire-reports || true
        rm -rf dist || true
        rm -rf .angular || true
    '''
}

def setupMavenEnvironment() {
    echo '🔧 Setting up Maven environment...'
    env.MAVEN_OPTS = '-Dmaven.repo.local=/tmp/maven-build/.m2/repository'
    env.MAVEN_CONFIG = '-B -DskipTests'
}

def setupNodeEnvironment() {
    echo '🔧 Setting up Node.js environment...'
    sh '''
        mkdir -p .npm
        export NPM_CONFIG_CACHE=./.npm
    '''
}

def installChromeForTesting() {
    echo '🔧 Installing Chrome for testing...'
    sh '''
        apt-get update
        apt-get install -y wget gnupg2 software-properties-common xvfb
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
        apt-get update
        apt-get install -y google-chrome-stable
        google-chrome --version
    '''
}

def startVirtualDisplay() {
    echo '📺 Starting virtual display...'
    sh '''
        export DISPLAY=:99
        Xvfb :99 -ac -screen 0 1024x768x8 &
        echo $! > /tmp/xvfb.pid
        sleep 3
    '''
}

def stopVirtualDisplay() {
    echo '📺 Stopping virtual display...'
    sh '''
        if [ -f /tmp/xvfb.pid ]; then
            kill $(cat /tmp/xvfb.pid) || true
            rm -f /tmp/xvfb.pid
        fi
    '''
}

def archiveCommonArtifacts(String pattern) {
    echo "📁 Archiving artifacts: ${pattern}"
    archiveArtifacts artifacts: pattern, fingerprint: true, allowEmptyArchive: true
}

def sendNotification(String status, String project) {
    echo "📢 Notification: ${project} pipeline ${status}"
}

def validateDockerNetwork() {
    echo '🔍 Validating Docker network connectivity...'
    sh '''
        echo "Checking GitLab connectivity..."
        nc -z gitlab 22 && echo "✅ GitLab SSH accessible" || echo "❌ GitLab SSH not accessible"
        echo "Checking network configuration..."
        ip route | grep devops-net || echo "⚠️ devops-net not found in routes"
    '''
}

def displayBuildInfo() {
    echo '''
🏗️ Build Information:
====================================
Job Name: ''' + env.JOB_NAME + '''
Build Number: ''' + env.BUILD_NUMBER + '''
Build URL: ''' + env.BUILD_URL + '''
Git Branch: ''' + env.GIT_BRANCH + '''
Git Commit: ''' + env.GIT_COMMIT + '''
====================================
'''
}

return this
EOF
```

⚠️ **CRÍTICO:** El archivo `vars/commonSteps.groovy` **DEBE terminar** con `return this` para que Jenkins lo reconozca.

#### **Paso 2.3: Subir estructura inicial**

```bash
git add .
git commit -m "✨ Initial setup: Jenkins pipelines repository with Maven/Angular support"
git push origin main
```

### **Fase 3: Configuración de Jenkins**

#### **Paso 3.1: Configurar Global Pipeline Library**

1. **Jenkins** → **Manage Jenkins** → **Configure System**
2. **Buscar:** "Global Pipeline Libraries"
3. **Add** nueva librería:
   - **Name:** `jenkinspipelines`
   - **Default version:** `main`
   - **Repository URL:** `ssh://git@gitlab:22/adrianmrc94/jenkinspipelines.git`
   - **Library Path:** **DEJAR VACÍO** ⚠️
   - **Credentials:** Usar las mismas SSH de GitLab
4. **Save**

⚠️ **MUY IMPORTANTE:** El **Library Path debe estar VACÍO**. Jenkins busca automáticamente en `vars/` cuando está vacío.

### **Fase 4: Migración de Pipelines Existentes**

#### **Paso 4.1: Migrar Pipeline Maven (Backend)**

**Ubicación:** `~/tmp-forks/spring-petclinic-rest/Jenkinsfile`

**Backup del original:**
```bash
cd ~/tmp-forks/spring-petclinic-rest/
cp Jenkinsfile Jenkinsfile.backup
```

**Nuevo Jenkinsfile:**
```groovy
@Library('jenkinspipelines') _

pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            args '-v /tmp/maven-build:/tmp/maven-build -w /tmp/maven-build --network devops-net'
            reuseNode true
        }
    }
    
    environment {
        // Variables comunes desde shared library
        GIT_USER = 'Jenkins CI'
        GIT_EMAIL = 'jenkins@petclinic.local'
    }

    stages {
        stage('📋 Build Info') {
            steps {
                script {
                    commonSteps.displayBuildInfo()
                    commonSteps.validateDockerNetwork()
                }
            }
        }
        
        stage('🔄 Checkout') {
            steps {
                echo '📥 Cloning repository...'
                checkout scm
                script {
                    commonSteps.setupGitCredentials()
                }
                sh 'ls -la'
            }
        }

        stage('🔧 Setup Environment') {
            steps {
                script {
                    commonSteps.setupMavenEnvironment()
                }
            }
        }

        stage('📦 Compile') {
            steps {
                echo '🔧 Compiling Maven project...'
                sh 'mvn compile -B -DskipTests'
                echo '✅ Compilation completed successfully'
            }
        }

        stage('🧪 Test') {
            steps {
                echo '🧪 Running tests...'
                sh 'mvn test -B'
                echo '✅ Tests completed successfully'
            }
            post {
                always {
                    junit testResults: 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('🏗️ Package') {
            steps {
                echo '📦 Packaging application...'
                sh 'mvn package -B -DskipTests'
                echo '✅ Packaging completed successfully'
                
                sh '''
                    echo "📋 Listing target directory:"
                    ls -la target/
                    echo "🔍 Looking for JAR files:"
                    find target/ -name "*.jar" -type f
                '''
            }
        }

        stage('📁 Archive Artifacts') {
            steps {
                script {
                    commonSteps.archiveCommonArtifacts('target/*.jar')
                }
                echo '✅ Artifacts archived successfully'
            }
        }
    }

    post {
        always {
            script {
                commonSteps.cleanWorkspace()
            }
        }
        success {
            script {
                commonSteps.sendNotification('SUCCESS', env.JOB_NAME)
            }
            echo '🎉 Pipeline Maven PetClinic completed successfully!'
        }
        failure {
            script {
                commonSteps.sendNotification('FAILURE', env.JOB_NAME)
            }
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
```

**Subir cambios:**
```bash
git add Jenkinsfile
git commit -m "🔄 Migrate to centralized pipeline using @Library('jenkinspipelines')"
git push origin main
```

#### **Paso 4.2: Migrar Pipeline Angular (Frontend)**

**Ubicación:** `~/tmp-forks/spring-petclinic-angular/Jenkinsfile`

**Backup del original:**
```bash
cd ~/tmp-forks/spring-petclinic-angular/
cp Jenkinsfile Jenkinsfile.backup
```

**Nuevo Jenkinsfile:**
```groovy
@Library('jenkinspipelines') _

pipeline {
    agent {
        docker {
            image 'node:18-bullseye'
            args '-v /var/jenkins_home/workspace/${JOB_NAME}:/app:rw -w /app --user root --network devops-net'
            reuseNode true
        }
    }
    
    environment {
        // Variables comunes desde shared library
        GIT_USER = 'Jenkins CI'
        GIT_EMAIL = 'jenkins@petclinic.local'
        NPM_CONFIG_CACHE = './.npm'
        DISPLAY = ':99'
        CHROME_BIN = '/usr/bin/google-chrome'
    }

    stages {
        stage('📋 Build Info') {
            steps {
                script {
                    commonSteps.displayBuildInfo()
                    commonSteps.validateDockerNetwork()
                }
            }
        }
        
        stage('🔄 Checkout') {
            steps {
                echo '📥 Cloning repository...'
                checkout scm
                script {
                    commonSteps.setupGitCredentials()
                }
            }
        }

        stage('🔧 Setup Environment') {
            steps {
                script {
                    commonSteps.setupNodeEnvironment()
                    commonSteps.installChromeForTesting()
                }
                echo '🔧 Installing Angular CLI globally...'
                sh 'npm install -g @angular/cli'
                echo '✅ Chrome and Angular CLI installed'
            }
        }

        stage('📦 Install Dependencies') {
            steps {
                echo '📦 Installing Node.js dependencies...'
                sh '''
                    # Limpiar workspace
                    rm -rf dist node_modules/.cache .angular || true
                    
                    # Install dependencies
                    NPM_CONFIG_CACHE=./.npm npm ci
                '''
                echo '✅ Dependencies installed successfully'
            }
        }

        stage('🏗️ Build') {
            steps {
                echo '🔧 Building Angular application...'
                sh 'npm run build -- --configuration production'
                echo '✅ Build completed successfully'
            }
        }

        stage('🧪 Test') {
            steps {
                echo '🧪 Running Angular tests...'
                script {
                    commonSteps.startVirtualDisplay()
                }
                sh '''
                    echo "🚀 Using Chrome: $CHROME_BIN"
                    $CHROME_BIN --version
                    
                    # Ejecutar tests
                    npm run test -- --no-watch --no-progress --browsers=ChromeHeadless
                '''
                echo '✅ Tests completed successfully'
            }
            post {
                always {
                    script {
                        commonSteps.stopVirtualDisplay()
                    }
                }
            }
        }

        stage('📁 Archive Artifacts') {
            steps {
                script {
                    commonSteps.archiveCommonArtifacts('dist/**/*')
                }
                echo '✅ Artifacts archived successfully'
            }
        }
    }

    post {
        always {
            script {
                commonSteps.cleanWorkspace()
            }
        }
        success {
            script {
                commonSteps.sendNotification('SUCCESS', env.JOB_NAME)
            }
            echo '🎉 Pipeline Angular CI completed successfully!'
        }
        failure {
            script {
                commonSteps.sendNotification('FAILURE', env.JOB_NAME)
            }
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
```

**Subir cambios:**
```bash
git add Jenkinsfile
git commit -m "🔄 Migrate to centralized pipeline using @Library('jenkinspipelines')"
git push origin main
```

### **Fase 5: Resolución de Problemas**

#### **Problema común: "Library is empty after retrieval"**

**Síntoma:**
```
Library jenkinspipelines@main:shared/vars/ is empty after retrieval
```

**Causa:** Configuración incorrecta del Library Path en Jenkins.

**Solución:**
1. **Jenkins** → **Manage Jenkins** → **Configure System**
2. **Global Pipeline Libraries** → **jenkinspipelines**
3. **Library Path:** **DEJAR COMPLETAMENTE VACÍO** ⚠️
4. **Save**

**Verificar estructura correcta:**
```bash
cd ~/jenkins-pipelines/jenkinspipelines
git ls-tree -r HEAD vars/
# Debe mostrar: vars/commonSteps.groovy
```

**Limpiar cache de Jenkins:**
```bash
docker exec jenkins rm -rf /var/jenkins_home/caches/
```

### **Fase 6: Verificación y Pruebas**

#### **Paso 6.1: Probar Pipeline Maven**

1. **Jenkins** → **petclinic-maven-ci** → **Build Now**
2. **Verificar salida:**
   - ✅ Librería carga correctamente
   - ✅ Funciones `commonSteps.*` se ejecutan
   - ✅ 181 tests pasan
   - ✅ JAR generado y archivado

#### **Paso 6.2: Probar Pipeline Angular**

1. **Jenkins** → **petclinic-angular-ci** → **Build Now**
2. **Verificar salida:**
   - ✅ Chrome se instala automáticamente
   - ✅ Display virtual funciona
   - ✅ 43 tests pasan con Chrome Headless
   - ✅ Build production generado

## 🎯 Beneficios Logrados

### ✅ **Reutilización de código:**
- Funciones comunes en `commonSteps.groovy`
- Configuraciones estandarizadas
- Mantenimiento centralizado

### ✅ **Mejores prácticas implementadas:**
- Display detallado de información de build
- Validación automática de conectividad Docker
- Limpieza automática de workspace
- Notificaciones estructuradas
- Configuración Git automatizada

### ✅ **Facilidad de mantenimiento:**
- Cambios en un lugar afectan todos los proyectos
- Versionado de pipelines
- Documentación centralizada
- Template para proyectos futuros

### ✅ **Escalabilidad:**
- Estructura preparada para nuevos proyectos
- Funciones reutilizables para diferentes tecnologías
- Configuraciones modulares

## 📊 Métricas de Éxito

### **Pipeline Maven ✅**
- ✅ 181/181 tests pasando
- ✅ JAR generado correctamente
- ✅ Tiempo: ~2-3 minutos
- ✅ Funciones centralizadas funcionando

### **Pipeline Angular ✅**
- ✅ 43/43 tests pasando
- ✅ Chrome Headless funcional
- ✅ Build production exitoso
- ✅ Tiempo: ~4-5 minutos



## 📚 Archivos de Referencia

- **Repositorio centralizado:** `ssh://git@gitlab:22/adrianmrc94/jenkinspipelines.git`
- **Funciones compartidas:** `vars/commonSteps.groovy`
- **Templates:** `templates/Jenkinsfile-template`
- **Documentación:** `docs/PIPELINE-GUIDE.md`

---

## 🔄 Flujo de Trabajo Completo

### **Ciclo CI/CD Real:**

```
1. 💻 DESARROLLO
   └─> Desarrollador modifica código localmente

2. 📤 COMMIT & PUSH A GITLAB
   └─> git add .
   └─> git commit -m "Feature: nueva funcionalidad"
   └─> git push origin main

3. 🚀 JENKINS CHECKOUT
   └─> Pipeline detecta cambios (manual o webhook)
   └─> git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git
   └─> Descarga código actualizado desde GitLab

4. �️ JENKINS BUILD
   └─> Lee Jenkinsfile del repositorio
   └─> Carga @Library('jenkinspipelines')
   └─> Ejecuta stages: build → test → deploy

5. ✅ RESULTADO
   └─> Tests ejecutados
   └─> Artefactos generados
   └─> Notificaciones enviadas
```

### **Repositorios GitLab y su Función:**

| Repositorio | Ubicación GitLab | Propósito | Contenido |
|-------------|-----------------|-----------|-----------|
| **jenkinspipelines** | `adrianmrc94/jenkinspipelines` | 📦 Shared Library | Funciones compartidas (`vars/`), templates |
| **petclinic-angular** | `adrianmrc94/petclinic-angular` | 🎨 Frontend | Código Angular + Jenkinsfile |
| **petclinic-rest** | `adrianmrc94/petclinic-rest` | ⚙️ Backend | Código Java/Maven + Jenkinsfile |

### **Verificación de Checkout Correcto:**

```bash
# Verificar que Jenkins clona desde GitLab correctamente
docker exec jenkins bash -c "cd /tmp && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test-checkout && \
  ls -la test-checkout/ && \
  cat test-checkout/Jenkinsfile | head -5 && \
  rm -rf test-checkout"

# Debe mostrar:
# - Todos los archivos del proyecto (src/, package.json, etc.)
# - Jenkinsfile con @Library('jenkinspipelines')
```

---

## 🐛 Troubleshooting: Sincronización GitLab

### **Problema: GitLab solo muestra README (código no sincronizado)**

**Síntoma:** Al abrir `http://localhost:8929/adrianmrc94/petclinic-angular` solo aparece README.md

**Causa:** Branch `main` (default) está vacío. El código está en branch `master`.

**Solución:**

```bash
# 1. Desproteger branch main en GitLab (si está protegido)
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-angular')
project.protected_branches.find_by(name: 'main')&.destroy
puts 'Branch main unprotected'
"

# 2. Desde Jenkins workspace, forzar push de master a main
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && \
  git checkout master && \
  git push origin master:main --force"

# 3. Cambiar default branch a main en GitLab
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-angular')
project.update(default_branch: 'main')
puts 'Default branch changed to main'
"

# 4. Actualizar configuración de Jenkins para usar main
# (Ver siguiente sección)
```

**Repetir para petclinic-rest:**

```bash
# Desproteger y sincronizar petclinic-rest
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-rest')
project.protected_branches.find_by(name: 'main')&.destroy
project.update(default_branch: 'main')
"

docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git config user.email 'jenkins@example.com' && \
  git config user.name 'Jenkins CI' && \
  git checkout master && \
  git push origin master:main --force"
```

### **Estandarización: Usar solo branch `main`**

**Motivo:** `main` es el estándar moderno (GitHub/GitLab desde 2020). Mantener `master` y `main` causa confusión.

**Pasos:**

1. **Cambiar configuración de Jenkins jobs a `main`:**

```bash
# Editar job petclinic-angular-ci
# Jenkins → petclinic-angular-ci → Configure → Branch Specifier
# Cambiar: */master → */main

# Editar job petclinic-maven-ci
# Jenkins → petclinic-maven-ci → Configure → Branch Specifier
# Cambiar: */master → */main
```

2. **Eliminar branch `master` de GitLab (opcional):**

```bash
# Desde Jenkins workspace
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && \
  git push origin --delete master"

docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git push origin --delete master"
```

---

## �🎉 ¡Centralización Completada Exitosamente!

**✅ Resultado final:** Pipelines Jenkins centralizadas, reutilizables y escalables con Jenkins Shared Libraries funcionando perfectamente para proyectos Maven y Angular.

**🏆 Proyectos beneficiados:**
- `petclinic-rest` (Maven) - 181 tests ✅
- `petclinic-angular` - 43 tests ✅

**🔄 Flujo verificado:**
1. ✅ Código en GitLab (repos `petclinic-angular` y `petclinic-rest`)
2. ✅ Jenkins hace checkout desde GitLab
3. ✅ Jenkinsfiles usan `@Library('jenkinspipelines')`
4. ✅ Pipelines centralizadas funcionando

**📝 Mantenimiento:** Cualquier cambio en `vars/commonSteps.groovy` se propaga automáticamente a todas las pipelines que usen `@Library('jenkinspipelines')`.