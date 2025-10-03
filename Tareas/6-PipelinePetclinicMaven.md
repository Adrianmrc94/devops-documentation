# 📋 Guía Completa: Pipeline CI en Jenkins para Aplicación Maven (PetClinic REST)

## 🎯 Objetivo

Configurar un pipeline CI en Jenkins para la aplicación Maven Spring PetClinic REST que ejecute las fases:

- Checkout del código desde GitLab
- Compilación (`mvn compile`)
- Ejecución de tests (`mvn test`)
- Empaquetado (`mvn package`)
- Archivado de artefactos JAR

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

- `petclinic-rest` (Maven) subido a GitLab local
- Acceso vía SSH configurado entre Jenkins y GitLab
- URL SSH: `ssh://git@gitlab:22/adrianmrc94/petclinic-rest.git`

### ✅ Red Docker

```bash
# Verificar red devops-net
docker network ls

# Debe aparecer:
- devops-net (bridge)
```

## 🚀 Implementación Paso a Paso

### Paso 1: Verificar repositorio Maven local

```bash
# Ubicación del repositorio clonado
cd /home/adrianmrc94/tmp-forks/spring-petclinic-rest

# Verificar que existe pom.xml
ls -la pom.xml

# Verificar remotes
git remote -v
# Debe mostrar:
# origin  ssh://git@localhost:2222/adrianmrc94/petclinic-rest.git
```

### Paso 2: Crear Jenkinsfile optimizado

```bash
# Crear Jenkinsfile en el repositorio Maven
cd /home/adrianmrc94/tmp-forks/spring-petclinic-rest
nano Jenkinsfile
```

**Contenido del Jenkinsfile:**

```groovy
pipeline {
    agent {
        docker {
            image 'maven:3.9.9-eclipse-temurin-17'
            args '-v /tmp/maven-build:/tmp/maven-build -w /tmp/maven-build --network devops-net'
            ### --volume (abreviado -v): monta la carpeta host /tmp/maven-build dentro del contenedor en la misma ruta /tmp/maven-build, 
            el .jar que genere Maven queda disponible en tu máquina cuando el contenedor termine.
            --workdir (abreviado -w): indica que dentro del contenedor el directorio de trabajo será /tmp/maven-build. 
            Maven se ejecutará ahí y dejará los artefactos (target/, etc.) en ese punto, que gracias al volumen anterior ya están fuera del contenedor, Comunicación con GitLab###
            reuseNode true
        }
    }
    
    environment { 
        MAVEN_OPTS = '-Dmaven.repo.local=/tmp/maven-build/.m2/repository'
        ### Usar cache persistente en lugar de ~/.m2/
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📥 Cloning repository...'
                checkout scm (SCM ya maneja credenciales SSH automáticamente)
                sh 'ls -la'(confirmar que código se clonó correctamente)
            }
        }

        stage('Compile') {
            steps {
                echo '🔧 Compiling Maven project...'
                sh 'mvn compile -B -DskipTests' ( si no compila, no ejecutar tests. -B Suprime output interactivo de Maven, asi no se queda esperando confirmacion. Solo queremos compilar, tests van en stage separado  )
                echo '✅ Compilation completed successfully'
            }
        }

        stage('Test') {
            steps {
                echo '🧪 Running tests...'
                sh 'mvn test -B'
                echo '✅ Tests completed successfully'
            }
        }

        stage('Package') {
            steps {
                echo '📦 Packaging application...'
                sh 'mvn package -B -DskipTests' (Compila, ejecuta tests, genera JAR)
                echo '✅ Packaging completed successfully'
                
                sh '''
                    echo "📋 Listing target directory:"
                    ls -la target/
                    echo "🔍 Looking for JAR files:"
                    find target/ -name "*.jar" -type f
                '''
            }
        }

        stage('Archive Artifacts') {
            steps {
                echo '📁 Archiving artifacts...'
                archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                echo '✅ Artifacts archived successfully'
            }
        }
    }

    post {
        always {
            echo '🧹 Cleaning up workspace...'
            cleanWs()
        }
        success {
            echo '🎉 Pipeline Maven PetClinic completed successfully!'
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
git commit -m "Add Maven CI/CD pipeline with Docker optimization"
git push origin main
```

### Paso 4: Verificar comunicación Jenkins-GitLab

#### A. Verificar claves SSH existentes

```bash
# Verificar que Jenkins tiene claves SSH
docker exec jenkins ls -la /var/jenkins_home/.ssh/

# Debe mostrar:
# - id_ed25519 (clave privada)
# - id_ed25519.pub (clave pública)
# - known_hosts
```

#### B. Verificar clave pública en GitLab

```bash
# Mostrar clave pública de Jenkins
docker exec jenkins cat /var/jenkins_home/.ssh/id_ed25519.pub
```

1. Copiar la salida
2. Ir a GitLab: `http://localhost:8929`
3. **Perfil** → **SSH Keys**
4. Pegar clave pública y guardar

#### C. Verificar acceso Docker en Jenkins

```bash
# Confirmar que Jenkins puede usar Docker
docker exec jenkins docker --version
# Debe mostrar: Docker version 28.4.0 o similar
```

### Paso 5: Configurar Pipeline en Jenkins UI

**A. Crear Pipeline Job**

1. Acceder a Jenkins: `http://localhost:8080`
2. Click **"New Item"**
3. Name: `petclinic-maven-ci`
4. Type: **"Pipeline"**
5. Click **"OK"**

**B. Configurar Pipeline**

**General:**
- Description: `CI pipeline para Maven PetClinic REST API`

**Pipeline:**
- Definition: **"Pipeline script from SCM"**
- SCM: **"Git"**
- Repository URL: `ssh://git@gitlab:22/adrianmrc94/petclinic-rest.git`
  
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

1. En Jenkins UI, ir a `petclinic-maven-ci`
2. Click **"Build Now"**
3. Ver progreso en **"Console Output"**

## ✅ Resultados Esperados

```text
[Pipeline] Start of Pipeline
[Pipeline] stage (Checkout)
✓ Código clonado desde GitLab
[Pipeline] stage (Compile)
✓ mvn compile -B -DskipTests
[Pipeline] stage (Test)
✓ mvn test -B (181 tests, 0 failures)
[Pipeline] stage (Package)
✓ mvn package -B -DskipTests
✓ JAR generado: spring-petclinic-rest-3.4.3.jar
[Pipeline] stage (Archive Artifacts)
✓ Artefactos archivados en Jenkins
[Pipeline] Post Actions
✓ Workspace limpiado
[Pipeline] End of Pipeline
Finished: SUCCESS
```

## 🐛 Solución de Problemas Comunes

### ❌ Error: "Host key verification failed"

```bash
# Desde contenedor Jenkins, aceptar clave de GitLab
docker exec jenkins ssh -p 22 git@gitlab
# Escribir 'yes' para aceptar
```

### ❌ Error: "No such DSL method 'publishTestResults'"

**Problema:** Método obsoleto en Jenkinsfile

**Solución:** Cambiar en el stage Test:
```groovy
# ❌ Incorrecto
publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'

# ✅ Correcto  
junit testResults: 'target/surefire-reports/*.xml'

# 🔧 O simplificar eliminando la línea por completo
```

### ❌ Error: "docker: permission denied"

```bash
# Verificar acceso Docker desde Jenkins
docker exec jenkins docker --version

# Si falla, revisar que el contenedor Jenkins tenga acceso al socket Docker
```

### ❌ Pipeline termina inmediatamente sin ejecutar stages

**Causa:** Jenkinsfile vacío o con errores de sintaxis

**Solución:**
```bash
# Verificar contenido del Jenkinsfile
cd /home/adrianmrc94/tmp-forks/spring-petclinic-rest
cat Jenkinsfile

# Si está vacío, crear con el contenido completo mostrado arriba
```

## 🔧 Características Técnicas del Pipeline

### **Docker Optimization:**
- **Imagen:** `maven:3.9.9-eclipse-temurin-17`
- **Volumen:** `/tmp/maven-build` para cache Maven
- **Red:** `devops-net` para comunicación entre contenedores
- **Workspace:** Persistent entre stages con `reuseNode true`

### **Maven Configuration:**
- **MAVEN_OPTS:** Cache local en `/tmp/maven-build/.m2/repository`
- **Build flags:** `-B` (batch mode), `-DskipTests` para package
- **Test execution:** Separado del package para mejor control

### **Jenkins Features:**
- **Artifact Management:** JARs automáticamente archivados
- **Workspace Cleanup:** Limpieza automática post-ejecución
- **Error Handling:** Post actions para success/failure

## 📊 Métricas de Rendimiento

**Tiempos típicos de ejecución:**
- Checkout: ~5 segundos
- Compile: ~15 segundos  
- Test: ~30 segundos (181 tests)
- Package: ~10 segundos
- Archive: ~2 segundos
- **Total:** ~1-2 minutos

## 🚀 Mejoras Futuras

**Optimizaciones:**
- Cache Maven dependencies entre builds
- Parallel test execution  
- Stages paralelos para compile/test

**Integración Avanzada:**
- Webhooks automáticos desde GitLab
- Quality gates con SonarQube
- Automated deployment a staging
- Slack/email notifications

**Monitoring:**
- Build trends y métricas
- Test coverage reports
- Performance regression detection

## 🎉 ¡Pipeline CI Maven configurado exitosamente!

### 📁 **Artefacto generado:**
- `spring-petclinic-rest-3.4.3.jar`
- Disponible en Jenkins UI → Pipeline → Build → **Artifacts**

### 🔄 **Automatización:**
- Pipeline se ejecuta automáticamente con `git push`
- Tests completos en cada commit
- JAR listo para deployment

**¡Tu aplicación Maven PetClinic ahora tiene CI/CD completo con Jenkins!** 🎯