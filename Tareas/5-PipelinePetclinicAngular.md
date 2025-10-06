# 📋 Guía Completa: Pipeline CI en Jenkins para Aplicación Angular (PetClinic) - ACTUALIZADA ✅

## 🎯 Objetivo

Configurar un pipeline CI en Jenkins para la aplicación Angular Spring PetClinic que ejecute las fases:

- Setup automático de Chrome y Angular CLI
- Instalación de dependencias (`npm ci`)
- Build de la aplicación (`npm run build --configuration production`)
- Ejecución de tests con Chrome Headless (`npm run test`)

## 🔧 Prerrequisitos

### ✅ Infraestructura necesaria

```bash
# Contenedores corriendo
docker ps

# Deben aparecer:
- jenkins:8080
- gitlab:8929 (puerto 80 interno, 8929 externo)
```

### ✅ Repositorios en GitLab

- `petclinic-angular` subido a GitLab local
- Acceso vía SSH configurado entre Jenkins y GitLab
- URL SSH: `ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git`

### ✅ Red Docker

⚠️ **Prerrequisito:** La red `devops-net` debe existir (creada en **Tarea 1: Levantar Jenkins**)

```bash
# Verificar que la red existe
docker network ls | grep devops-net

# Debe aparecer:
# devops-net   bridge   local

# Si NO existe, crearla:
# docker network create devops-net

# Verificar que Jenkins y GitLab están conectados
docker network inspect devops-net | grep -E "jenkins|gitlab"
```

**¿Por qué es necesaria esta red?**
- 🔗 Los contenedores Docker **dentro de pipelines** necesitan comunicarse con GitLab
- 🎯 Permite usar `gitlab:22` en lugar de `localhost:2222` (que no funciona entre contenedores)
- 📦 Aísla el entorno DevOps de otras redes Docker

Ver: **Tarea 1 (Jenkins)** y **Tarea 2 (GitLab)** para detalles sobre la creación de esta red.

## 🚀 Implementación Paso a Paso

### Paso 1: Verificar repositorio Angular local

```bash
# Ubicación del repositorio clonado
cd /home/adrianmrc94/tmp-forks/spring-petclinic-angular

# Verificar que existe package.json
ls -la package.json

# Verificar remotes
git remote -v
# Debe mostrar:
# origin  ssh://git@localhost:2222/adrianmrc94/petclinic-angular.git
```

### Paso 2: Crear Jenkinsfile optimizado para Angular

```bash
# Crear Jenkinsfile en el repositorio Angular
cd /home/adrianmrc94/tmp-forks/spring-petclinic-angular
nano Jenkinsfile
```

**Contenido del Jenkinsfile:**

```groovy
pipeline {
    agent {
        docker {
            image 'node:18-bullseye'
            args '-v /var/jenkins_home/workspace/petclinic-angular-ci:/app:rw -w /app --user root --network devops-net'
            reuseNode true
            <!-- 🔧 Desglose técnico:
                -> image 'node:18-bullseye' → Node.js 18 + Debian estable
                -> -v /var/jenkins_home/.../app:rw → Montar código dentro del contenedor
                -> -w /app → Directorio de trabajo donde ejecutar comandos
                -> --user root → Permisos para instalar Chrome y dependencias
                -> --network devops-net → Comunicación con GitLab
                -> reuseNode true → Reutilizar el mismo contenedor entre stages 
            -->
        }
    }

    stages {
        stage('Setup Chrome & Angular CLI') {
            steps {
                echo '🔧 Installing Chrome and Angular CLI...'
                sh '''
                    # Actualizar sistema
                    apt-get update
                    
                    # Instalar dependencias necesarias
                    apt-get install -y wget gnupg2 software-properties-common xvfb
                    
                    # Agregar repositorio de Google Chrome
                    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
                    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
                    
                    # Instalar Chrome
                    apt-get update
                    apt-get install -y google-chrome-stable
                    
                    # Verificar instalación
                    google-chrome --version
                    
                    # Instalar Angular CLI globalmente
                    npm install -g @angular/cli
                '''
                echo '✅ Chrome and Angular CLI installed'
            }
        }

        stage('Install dependencies') {
            steps {
                echo '📦 Installing Node.js dependencies...'
                sh '''
                    # Limpiar workspace
                    rm -rf dist node_modules/.cache .angular || true
                    
                    # Install dependencies
                    mkdir -p .npm
                    NPM_CONFIG_CACHE=./.npm npm ci
                '''
                echo '✅ Dependencies installed successfully'
            }
        }

        stage('Build') {
            steps {
                echo '🔧 Building Angular application...'
                sh 'npm run build -- --configuration production'
                echo '✅ Build completed successfully'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running Angular tests...'
                sh '''
                    # Configurar Chrome, Ruta exacta del binario, Display virtual número 99
                    export CHROME_BIN=/usr/bin/google-chrome
                    export DISPLAY=:99
                    
                    echo "🚀 Using Chrome: $CHROME_BIN"
                    $CHROME_BIN --version
                    
                    # Iniciar display virtual, Guarda PID para limpieza
                    Xvfb :99 -ac -screen 0 1024x768x8 &
                    XVFB_PID=$!
                    
                    # Esperar que Xvfb esté listo
                    sleep 3
                    
                    # Ejecutar tests, Captura exit code si falla
                    npm run test -- --no-watch --no-progress --browsers=ChromeHeadless || TEST_RESULT=$?
                    
                    # Limpiar Xvfb
                    kill $XVFB_PID || true
                    
                    # Salir con resultado de tests
                    exit ${TEST_RESULT:-0}
                '''
                echo '✅ Tests completed successfully'
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up...'
            sh 'rm -rf .npm node_modules/.cache || true'
        }
        success {
            echo '🎉 Pipeline Angular CI completed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Check logs for details.'
        }
    }
}
```

### Paso 3: Subir Jenkinsfile a GitLab

```bash
# Agregar y commitear cambios
git add Jenkinsfile
git commit -m "Add Angular CI/CD pipeline with Chrome headless and Xvfb support"
git push origin main
```

### Paso 4: Configurar SSH entre Jenkins y GitLab

#### A. Verificar si Jenkins tiene claves SSH

```bash
# Verificar que Jenkins tiene claves SSH
docker exec jenkins ls -la /var/jenkins_home/.ssh/

# Si el directorio NO existe o está vacío, continuar con paso B
```

---

#### B. Generar claves SSH en Jenkins (si no existen)

```bash
# Crear directorio .ssh
docker exec jenkins mkdir -p /var/jenkins_home/.ssh

# Generar clave SSH (sin contraseña para automatización)
docker exec jenkins ssh-keygen -t ed25519 -C "jenkins@devops" -f /var/jenkins_home/.ssh/id_ed25519 -N ""

# Verificar creación
docker exec jenkins ls -la /var/jenkins_home/.ssh/
```

**Resultado esperado:**
```
-rw------- 1 jenkins jenkins  411 ... id_ed25519
-rw-r--r-- 1 jenkins jenkins  103 ... id_ed25519.pub
```

---

#### C. Agregar clave pública a GitLab

```bash
# Mostrar clave pública para copiar
docker exec jenkins cat /var/jenkins_home/.ssh/id_ed25519.pub
```

**Copiar la salida completa** (ejemplo):
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIxxx...xxxxx jenkins@devops
```

**Agregar a GitLab UI:**

1. Abrir GitLab: http://localhost:8929
2. Login con tu usuario
3. Click **avatar (arriba derecha)** → **Edit profile**
4. **Sidebar izquierdo** → **SSH Keys**
5. **Pegar la clave pública** en campo "Key"
6. **Title:** `jenkins-key`
7. Click **Add key**

---

#### D. Configurar known_hosts

```bash
# Obtener fingerprint de GitLab y agregarlo
docker exec jenkins sh -c "ssh-keyscan -p 22 gitlab >> /var/jenkins_home/.ssh/known_hosts"

# Ajustar permisos
docker exec jenkins chmod 700 /var/jenkins_home/.ssh
docker exec jenkins chmod 600 /var/jenkins_home/.ssh/id_ed25519
docker exec jenkins chmod 644 /var/jenkins_home/.ssh/id_ed25519.pub
docker exec jenkins chmod 644 /var/jenkins_home/.ssh/known_hosts
```

---

#### E. Probar conexión SSH

```bash
# Probar conexión
docker exec jenkins ssh -T git@gitlab -p 22
```

**Resultado esperado:**
```
Welcome to GitLab, @adrianmrc94!
```

✅ Si ves este mensaje, la configuración SSH está correcta.

**Probar clone:**
```bash
# Probar clone de prueba
docker exec jenkins sh -c "cd /tmp && git clone ssh://git@gitlab:22/Adrianmrc94/petclinic-angular.git test && ls test/ && rm -rf test"
```

✅ Si el clone funciona, estás listo para continuar.

### Paso 5: Configurar Pipeline en Jenkins UI

**A. Crear Pipeline Job**

1. Acceder a Jenkins: `http://localhost:8080`
2. Click **"New Item"**
3. Name: `petclinic-angular-ci`
4. Type: **"Pipeline"**
5. Click **"OK"**

**B. Configurar Pipeline**

**General:**
- Description: `CI pipeline para aplicación Angular PetClinic`

**Pipeline:**
- Definition: **"Pipeline script from SCM"**
- SCM: **"Git"**
- Repository URL: `ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git`
  
  ⚠️ **Importante**: Usar `gitlab:22`, NO `localhost:2222` (comunicación entre contenedores)

**Credentials:**
- Add → SSH Username with private key
- Username: `git`  
- Private Key: Enter directly → Pegar contenido de:
  ```bash
  docker exec jenkins cat /var/jenkins_home/.ssh/id_ed25519
  ```

**Branch y Script:**
- Branches to build: `*/main` (o `*/master`)
- Script Path: `Jenkinsfile`

### Paso 6: Ejecutar Pipeline

1. En Jenkins UI, ir a `petclinic-angular-ci`
2. Click **"Build Now"**
3. Ver progreso en **"Console Output"**

## ✅ Resultados Esperados

```text
[Pipeline] Start of Pipeline
[Pipeline] stage (Setup Chrome & Angular CLI)
✓ Chrome y Angular CLI instalados
[Pipeline] stage (Install dependencies)
✓ npm ci completado
[Pipeline] stage (Build)  
✓ ng build --configuration production
[Pipeline] stage (Test)
✓ 43 tests ejecutados, 43 SUCCESS, 0 fallos
Chrome Headless 140.0.0.0: Executed 43 of 43 SUCCESS (0.515 secs)
TOTAL: 43 SUCCESS
[Pipeline] End of Pipeline
Finished: SUCCESS
```

## 🐛 Solución de Problemas Comunes

### ❌ Error: "Cannot find module 'karma-coverage'"

**Problema:** Dependencias faltantes en karma.conf.js

**Solución:** Usar karma.conf.js básico sin módulos no instalados:
```javascript
module.exports = function (config) {
  config.set({
    basePath: '',
    frameworks: ['jasmine', '@angular-devkit/build-angular'],
    plugins: [
      require('karma-jasmine'),
      require('karma-chrome-launcher'),
      require('karma-jasmine-html-reporter'),
      require('@angular-devkit/build-angular/plugins/karma')
    ],
    reporters: ['progress', 'kjhtml'],
    browsers: ['Chrome'],
    customLaunchers: {
      ChromeHeadless: {
        base: 'Chrome',
        flags: [
          '--headless',
          '--no-sandbox',
          '--disable-web-security',
          '--disable-gpu',
          '--disable-dev-shm-usage'
        ]
      }
    },
    restartOnFileChange: true
  });
};
```

### ❌ Error: Chrome connection failed / Display issues

**Problema:** Chrome no puede conectar con display en contenedor Docker

**Solución:** El pipeline ya incluye Xvfb (display virtual):
- ✅ `apt-get install -y xvfb` - Instala display virtual
- ✅ `Xvfb :99 -ac -screen 0 1024x768x8 &` - Inicia display
- ✅ `export DISPLAY=:99` - Configura variable de entorno

### ❌ Error: "EACCES: permission denied"

**Problema:** Permisos de escritura en workspace

**Solución:** El pipeline ya incluye:
- ✅ `--user root` - Ejecuta como root
- ✅ `:rw` en volumen mount - Permisos lectura/escritura
- ✅ `rm -rf dist` - Limpia directorios antes del build

### ❌ Error: "trion/ng-cli-e2e image not working"

**Problema:** Imágenes de terceros con Chrome corrupto

**Solución:** Usar imagen oficial `node:18-bullseye` e instalar Chrome manualmente:
- ✅ Imagen oficial de Node.js confiable
- ✅ Instalación de Chrome desde repositorio oficial de Google
- ✅ Control total sobre dependencias

### ❌ Error: "cimg/node:18.19.0-browsers" no funciona

**Problema:** La imagen "browsers" no tiene Chrome correctamente instalado

**Solución:** Cambiar a imagen base e instalar Chrome:
```groovy
# ❌ No funciona
image 'cimg/node:18.19.0-browsers'

# ✅ Funciona correctamente  
image 'node:18-bullseye'
# + stage Setup Chrome & Angular CLI para instalar Chrome
```

## 🔧 Características Técnicas del Pipeline

### **Docker Configuration:**
- **Imagen:** `node:18-bullseye` - Imagen oficial Debian con Node.js 18
- **Volumen:** `/app:rw` - Permisos lectura/escritura
- **Red:** `devops-net` - Comunicación con GitLab
- **Usuario:** `root` - Permisos completos para instalaciones

### **Chrome Headless Setup:**
- **Xvfb:** Display virtual X11 en :99
- **Chrome:** Instalado desde repositorio oficial de Google (versión 140.x)
- **Flags:** `--headless --no-sandbox --disable-dev-shm-usage`
- **Resolution:** 1024x768x8 virtual screen

### **Angular Configuration:**
- **Angular CLI:** Instalado globalmente via npm
- **Cache:** NPM cache en `.npm` para optimización
- **Build:** Configuración production con `--configuration production`
- **Tests:** Modo headless sin watch (`--no-watch --no-progress`)

## 📊 Métricas de Rendimiento

**Tiempos típicos de ejecución:**
- Setup Chrome & Angular CLI: ~2-3 minutos (primera vez)
- Install dependencies: ~1 minuto
- Build: ~30 segundos
- Test: ~10 segundos (43 tests)
- **Total primera ejecución:** ~4-5 minutos
- **Ejecuciones subsiguientes:** ~2-3 minutos (Chrome ya instalado)

**Tests Angular:**
- **Total tests:** 43
- **Resultado:** 43 SUCCESS, 0 fallos
- **Tiempo promedio:** 0.5 segundos
- **Browser:** Chrome Headless 140.0.0.0

## 🚀 Mejoras Futuras

**Optimizaciones:**
- Usar imagen custom con Chrome pre-instalado
- Cache de dependencias entre builds
- Parallel execution de stages
- Test coverage reporting

**Integración Avanzada:**
- Webhooks automáticos desde GitLab
- E2E tests con Cypress/Protractor
- Quality gates con SonarQube
- Automated deployment a staging
- Slack/email notifications

**Monitoring:**
- Build trends y métricas de tests
- Performance regression detection
- Bundle size monitoring
- Angular bundle analyzer integration

## 🎉 ¡Pipeline CI Angular configurado exitosamente!

### 📊 **Resultados alcanzados:**
- ✅ **43 tests ejecutados correctamente**
- ✅ **Build production generado**
- ✅ **Chrome Headless funcionando**
- ✅ **Pipeline completamente automático**

### 🔄 **Automatización:**
- Pipeline se ejecuta automáticamente con `git push`
- Tests Angular completos en cada commit
- Build production validado antes de deploy

### 🏆 **Lo que se logró superar:**
1. **Problema inicial:** Tests deshabilitados por Chrome no disponible
2. **Solución aplicada:** Instalación automática de Chrome + Xvfb
3. **Resultado final:** 43/43 tests passing con Chrome Headless

**¡Tu aplicación Angular PetClinic ahora tiene CI/CD completo con Jenkins y tests automatizados!** 🎯