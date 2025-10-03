# 🔧 Solución: Sincronización GitLab-Jenkins

**Fecha:** 3 de octubre de 2025  
**Problema inicial:** Repositorios de GitLab vacíos (solo README), Jenkins no usa GitLab correctamente

---

## 🔍 Diagnóstico del Problema

### **Síntomas:**
- ✅ Jenkins tenía jobs configurados (`petclinic-angular-ci`, `petclinic-maven-ci`)
- ✅ Workspaces de Jenkins tenían código completo
- ❌ GitLab solo mostraba README.md
- ❌ No quedaba claro de dónde hacía checkout Jenkins

### **Causa Raíz:**
1. **Branches desincronizados:**
   - Branch `main` en GitLab: solo README (commit inicial)
   - Branch `master` en workspace Jenkins: código completo
   - Jenkins configurado para usar `*/master`

2. **Historiales no relacionados:**
   - `main` y `master` tenían historiales diferentes (unrelated histories)
   - No se podía hacer merge directo

---

## ✅ Solución Implementada

### **Paso 1: Verificar Estado Inicial**

```bash
# Verificar repositorios en GitLab
docker exec gitlab gitlab-rails runner "Project.all.each { |p| puts p.path_with_namespace }"

# Resultado:
# adrianmrc94/petclinic-rest
# adrianmrc94/petclinic-angular
# adrianmrc94/jenkinspipelines

# Verificar contenido (vacío)
curl -s "http://localhost:8929/api/v4/projects/2/repository/tree"
# Resultado: vacío (sin archivos)
```

### **Paso 2: Verificar Branches Locales vs Remotos**

```bash
# En workspace de Jenkins
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && git branch -a"

# Resultado:
# * (HEAD detached at 0a38fdd)
#   remotes/origin/main
#   remotes/origin/master

# Ver qué tiene cada branch
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && git checkout main && ls -la"
# Solo: README.md, node_modules

docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && git checkout master && ls -la"
# Todo el código: Jenkinsfile, src/, package.json, etc.
```

### **Paso 3: Desproteger Branch `main` en GitLab**

```bash
# Branch main estaba protegido, impedía force push
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-angular')
project.protected_branches.find_by(name: 'main')&.destroy
puts 'Branch main unprotected'
"

# Repetir para petclinic-rest
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-rest')
project.protected_branches.find_by(name: 'main')&.destroy
puts 'Branch main unprotected'
"
```

### **Paso 4: Forzar Push de `master` a `main`**

```bash
# Sobrescribir main con el contenido de master
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && \
  git checkout master && \
  git push origin master:main --force"

# Resultado:
# To ssh://gitlab:22/adrianmrc94/petclinic-angular.git
#  + 205c686...0a38fdd master -> main (forced update)

# Repetir para petclinic-rest
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git config user.email 'jenkins@example.com' && \
  git config user.name 'Jenkins CI' && \
  git checkout master && \
  git push origin master:main --force"
```

### **Paso 5: Verificar Código en GitLab**

```bash
# Ahora GitLab debe mostrar todo el código
# Verificar en UI: http://localhost:8929/adrianmrc94/petclinic-angular
# Debe mostrar: Jenkinsfile, src/, package.json, angular.json, etc.

# Verificar con checkout fresco
docker exec jenkins bash -c "cd /tmp && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test-checkout && \
  ls -la test-checkout/"

# Resultado: ✅ Todo el código presente
```

### **Paso 6: Cambiar Default Branch a `main` en GitLab**

```bash
# Cambiar default branch
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-angular')
project.update(default_branch: 'main')
project = Project.find_by_full_path('adrianmrc94/petclinic-rest')
project.update(default_branch: 'main')
puts 'Default branches changed to main'
"

# Verificar
docker exec gitlab gitlab-rails runner "
project = Project.find_by_full_path('adrianmrc94/petclinic-angular')
puts \"petclinic-angular default branch: #{project.default_branch}\"
project = Project.find_by_full_path('adrianmrc94/petclinic-rest')
puts \"petclinic-rest default branch: #{project.default_branch}\"
"

# Resultado:
# petclinic-angular default branch: main
# petclinic-rest default branch: main
```

### **Paso 7: Cambiar Jenkins para Usar `main`**

```bash
# Verificar configuración actual
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep -A 1 "BranchSpec"

# Resultado:
# <name>*/master</name>

# Cambiar a main
docker exec jenkins sed -i 's|<name>\*/master</name>|<name>*/main</name>|g' /var/jenkins_home/jobs/petclinic-angular-ci/config.xml
docker exec jenkins sed -i 's|<name>\*/master</name>|<name>*/main</name>|g' /var/jenkins_home/jobs/petclinic-maven-ci/config.xml

# Verificar cambio
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep -A 1 "BranchSpec"

# Resultado:
# <name>*/main</name>

# Reiniciar Jenkins para aplicar cambios
docker restart jenkins
```

### **Paso 8: Eliminar Branch `master` (Limpieza)**

```bash
# Ya no necesitamos master, todo está en main
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-angular-ci && \
  git push origin --delete master"

docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git push origin --delete master"
```

### **Paso 9: Solucionar Error Maven**

```bash
# Problema: Maven no podía escribir en /tmp/maven-build/.m2/repository

# Ver Jenkinsfile actual
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && cat Jenkinsfile | head -10"

# Cambiar directorio Maven
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git config user.email 'jenkins@example.com' && \
  git config user.name 'Jenkins CI' && \
  cp Jenkinsfile Jenkinsfile.backup && \
  sed -i \"s|args '-v /tmp/maven-build:/tmp/maven-build -w /tmp/maven-build --network devops-net'|args '-v /var/jenkins_home/.m2:/root/.m2 --network devops-net'|g\" Jenkinsfile"

# Commit y push
docker exec jenkins bash -c "cd /var/jenkins_home/workspace/petclinic-maven-ci && \
  git checkout main && \
  git add Jenkinsfile && \
  git commit -m 'Fix: Change Maven workspace to use Jenkins home directory' && \
  git push origin main"
```

### **Paso 10: Verificar Pipelines Funcionando**

```bash
# Ejecutar pipeline petclinic-angular-ci desde Jenkins UI
# Resultado: ✅ SUCCESS - 43 tests pasando

# Ejecutar pipeline petclinic-maven-ci desde Jenkins UI
# Resultado: ✅ SUCCESS - 181 tests pasando
```

---

## 📊 Verificación Final

### **Comandos de Verificación:**

```bash
# 1. Verificar repos en GitLab
docker exec gitlab gitlab-rails runner "Project.all.each { |p| puts p.path_with_namespace }"

# 2. Verificar default branch
docker exec gitlab gitlab-rails runner "
Project.all.each do |p|
  puts \"#{p.path_with_namespace} -> #{p.default_branch}\"
end
"

# 3. Verificar configuración Jenkins
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "url"
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "BranchSpec" -A 1

# 4. Verificar checkout funcional
docker exec jenkins bash -c "cd /tmp && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test && \
  ls test/ && \
  cat test/Jenkinsfile | head -5 && \
  rm -rf test"
```

### **Resultado Esperado:**

```
Repositorios GitLab:
- adrianmrc94/petclinic-rest -> main
- adrianmrc94/petclinic-angular -> main
- adrianmrc94/jenkinspipelines -> main

Jenkins configurado:
- URL: ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git
- Branch: */main

Checkout funcional:
- Jenkinsfile presente
- @Library('jenkinspipelines') _
- Todo el código clonado correctamente
```

---

## 🎯 Estado Final

| Componente | Antes | Después |
|------------|-------|---------|
| **GitLab petclinic-angular** | Solo README | Código completo ✅ |
| **GitLab petclinic-rest** | Solo README | Código completo ✅ |
| **Default branch** | main (vacío) | main (con código) ✅ |
| **Jenkins branch config** | */master | */main ✅ |
| **Branch master** | Existía con código | Eliminado ✅ |
| **Pipeline Angular** | No funcionaba | SUCCESS - 43 tests ✅ |
| **Pipeline Maven** | Error permisos | SUCCESS - 181 tests ✅ |

---

## 📝 Lecciones Aprendidas

### **1. Importancia de verificar sincronización:**
- No asumir que GitLab está actualizado
- Verificar visualmente en UI de GitLab
- Usar `git ls-remote` para ver commits remotos

### **2. Branches protegidos:**
- GitLab protege `main` por defecto
- Necesario desproteger para force push
- Usar `gitlab-rails runner` para operaciones administrativas

### **3. HEAD detached:**
- Común en Jenkins workspaces
- Necesario hacer `git checkout <branch>` antes de push
- Verificar estado con `git status` y `git branch -a`

### **4. Estandarización de branches:**
- `main` es el estándar moderno (desde 2020)
- Mantener `master` y `main` causa confusión
- Mejor elegir uno y eliminar el otro

### **5. Permisos en Docker:**
- Volúmenes montados pueden tener problemas de permisos
- Mejor usar directorios dentro del contenedor principal
- Maven: usar `/root/.m2` en lugar de `/tmp/maven-build`

---

## 🔄 Flujo Final Verificado

```
1. Desarrollador modifica código localmente

2. git push origin main → GitLab

3. Jenkins detecta cambio (manual o webhook)

4. Jenkins: git clone ssh://git@gitlab:22/.../repo.git

5. Jenkins: carga Jenkinsfile del repo

6. Jenkinsfile: @Library('jenkinspipelines')

7. Pipeline ejecuta: build → test → package

8. Resultado: SUCCESS ✅
```

---

**Documentado por:** Adrián  
**Fecha:** 3 de octubre de 2025  
**Tiempo de resolución:** ~2 horas  
**Resultado:** ✅ Completamente funcional
