# 🏗️ Comandos esenciales de Jenkins (CLI + Groovy + Shell)

---

## 🔧 Instalar y arrancar

| Acción | Comando |
|--------|---------|
| Instalar paquete Debian | `sudo apt update && sudo apt install jenkins` |
| Arrancar servicio | `sudo systemctl start jenkins` |
| Habilitar auto-arranque | `sudo systemctl enable jenkins` |
| Ver logs en vivo | `sudo journalctl -u jenkins -f` |
| Password inicial (Debian/Ubuntu) | `sudo cat /var/lib/jenkins/secrets/initialAdminPassword` |

---

## 📦 CLI oficial (jenkins-cli.jar)

| Acción | Comando |
|--------|---------|
| Descargar CLI | `curl -O http://localhost:8080/jnlpJars/jenkins-cli.jar` |
| Login vía clave | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token who-am-i` |
| Listar jobs | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token list-jobs` |
| Ejecutar build | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token build mi-job -s -v` |
| Obtener configuración XML | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token get-job mi-job &gt; job.xml` |
| Crear/actualizar job desde XML | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token create-job mi-job &lt; job.xml` |
| Borrar job | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token delete-job mi-job` |
| Reiniciar Jenkins | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token safe-restart` |

---

## 🐚 Scripts Groovy útiles (Consola / CLI)

| Acción | Código Groovy |
|--------|---------------|
| Listar todos los jobs | `Jenkins.instance.getAllItems(Job.class).each { println it.fullName }` |
| Deshabilitar job | `Jenkins.instance.getItemByFullName('mi-job').disable()` |
| Habilitar job | `Jenkins.instance.getItemByFullName('mi-job').enable()` |
| Borrar builds antiguos (conservar últimos 5) | `Jenkins.instance.getItemByFullName('mi-job').builds.drop(5).each { it.delete() }` |
| Crear usuario local | `Jenkins.instance.securityRealm.createAccount('usuario','pass')` |

---

## 🔐 Token de API (vía CLI)

| Acción | Comando |
|--------|---------|
| Generar token (user/pass) | `curl -u user:pass -X POST "http://localhost:8080/me/descriptorByName/jenkins.security.ApiTokenProperty/generateToken?newTokenName=mi-token"` |

---

## 📊 Plugins desde CLI

| Acción | Comando |
|--------|---------|
| Listar plugins instalados | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token list-plugins` |
| Instalar plugin | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token install-plugin blueocean -deploy` |
| Reiniciar tras plugins | `java -jar jenkins-cli.jar -s http://localhost:8080/ -auth user:token safe-restart` |

---

## 🧪 Pipeline syntax básico

| Concepto | Código |
|----------|--------|
| Pipeline básico | `pipeline { agent any; stages { stage('Build') { steps { sh 'echo Hello' } } } }` |
| Múltiples agentes | `agent { label 'linux' }` o `agent { docker { image 'maven:3' } }` |
| Variables ambiente | `environment { MY_VAR = 'valor' }` |
| Condicionales | `when { branch 'main' }` o `when { environment name: 'DEPLOY', value: 'true' }` |
| Paralelo | `parallel { stage('Test A') {...} stage('Test B') {...} }` |
| Post actions | `post { always {...} success {...} failure {...} }` |

---

## 📦 Shared Libraries

| Acción | Código |
|--------|--------|
| Cargar library | `@Library('my-lib') _` |
| Función global | `@Library('my-lib') import com.company.MyClass` |
| Vars directory | `commonSteps.setupEnvironment()` |
| Con versión específica | `@Library('my-lib@v1.0') _` |

---

## 🧪 Pipeline-shell snippets avanzados

| Acción | Código |
|--------|--------|
| Abortar build si falla comando | `sh 'set -e; ./mvnw test'` |
| Capturar salida | `def out = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()` |
| Condicional basado en archivo | `sh '[ -f pom.xml ] && echo Es Maven'` |
| Ejecutar con credenciales | `withCredentials([usernamePassword(credentialsId: 'nexus', usernameVariable: 'USER', passwordVariable: 'PASS')]) { sh 'curl -u $USER:$PASS https://nexus/repo' }` |
| Timeout | `timeout(time: 5, unit: 'MINUTES') { sh './long-script.sh' }` |
| Retry | `retry(3) { sh './flaky-test.sh' }` |
| Stash/Unstash | `stash includes: 'target/*.jar', name: 'app'` → `unstash 'app'` |
| Input manual | `input message: 'Deploy to production?', ok: 'Deploy'` |