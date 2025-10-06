# 🏥 Configurar Proyectos PetClinic (Angular + Java)

## 🎯 Objetivo

Clonar proyectos PetClinic públicos y subirlos a tu GitLab local para CI/CD, **asegurando sincronización correcta de branches** entre repositorio clonado y GitLab.

---

## ⚠️ DIRECTRICES IMPORTANTES: Evitar Problemas con Branches

### 🔴 **Problema común: `main` vs `master`**

Los repositorios públicos de GitHub **usan branch `master`**, pero GitLab crea proyectos nuevos con **branch `main`**. Esto causa:

- ❌ **Historiales no relacionados** (`unrelated histories`)
- ❌ **Conflictos de merge** en README.md
- ❌ **Referencias desincronizadas** (`origin/master` vs `origin/main`)
- ❌ **Jenkins confundido** sobre qué branch usar

### ✅ **Solución: Estandarizar en `main` desde el inicio**

1. **Renombrar branch local `master` → `main` ANTES de hacer push**
2. **Sincronizar con GitLab usando merge con `--allow-unrelated-histories`**
3. **Limpiar referencias obsoletas de `master`**
4. **Configurar Git globalmente** para evitar inconsistencias futuras

---

## 🚀 Pasos de Configuración (MEJORADOS)

### **Paso 0: Configuración Git global (OBLIGATORIO)**

```bash
# Configurar identidad Git (una sola vez)
git config --global user.name "Adrianmrc94"
git config --global user.email "adrianmrc94@gmail.com"

# Verificar configuración
git config --global --list | grep user
```

⚠️ **Importante:** Esto evita warnings de identidad durante commits.

---

### **Paso 1: Clonar repositorios públicos**

```bash
# Crear directorio temporal para forks
mkdir ~/tmp-forks && cd ~/tmp-forks

# Clonar proyectos públicos de GitHub
git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
```

**Verificar branches clonados:**
```bash
cd spring-petclinic-angular
git branch -a
# Resultado esperado:
# * master                    ← Branch local actual
#   remotes/origin/HEAD -> origin/master
#   remotes/origin/master

cd ../spring-petclinic-rest
git branch -a
# Resultado esperado:
# * master                    ← Branch local actual
#   remotes/origin/HEAD -> origin/master
#   remotes/origin/master
```

---

### **Paso 2: Crear proyectos en GitLab local**

#### **A. Proyecto Angular:**
1. Abrir GitLab → `http://localhost:8929`
2. **New project** → **Create blank project**
3. Configuración:
   - **Project name:** `petclinic-angular`
   - **Slug:** `petclinic-angular`
   - **Visibility:** Private
   - ✅ **Initialize repository with a README** ← **IMPORTANTE**
4. **Create project**

#### **B. Proyecto Java/REST:**
1. Repetir proceso anterior
2. Configuración:
   - **Project name:** `petclinic-rest`
   - **Slug:** `petclinic-rest`
   - **Visibility:** Private
   - ✅ **Initialize repository with a README** ← **IMPORTANTE**
3. **Create project**

⚠️ **Nota:** GitLab crea proyectos con branch **`main`** por defecto, con un commit inicial (README.md).

---

### **Paso 3: Configurar SSH entre local y GitLab**

#### **A. Generar clave SSH (si no existe)**

```bash
# Generar nueva clave SSH
ssh-keygen -t ed25519 -C "adrianmrc94@gmail.com" -f ~/.ssh/id_ed25519

# Mostrar clave pública
cat ~/.ssh/id_ed25519.pub
```

#### **B. Agregar clave SSH a GitLab**

1. Copiar la salida de `cat ~/.ssh/id_ed25519.pub`
2. GitLab → **Avatar (arriba derecha)** → **Edit profile** → **SSH Keys**
3. Pegar clave pública y **Add key**

#### **C. Verificar acceso SSH**

```bash
# Probar conexión SSH con GitLab (puerto 2222)
ssh -T git@localhost -p 2222

# Resultado esperado:
# Welcome to GitLab, @adrianmrc94!
```

✅ Si aparece "Welcome to GitLab", la configuración SSH es correcta.

---

### **Paso 4: Subir repositorios a GitLab (PROCEDIMIENTO CORRECTO)**

#### **🔵 A. Proyecto Angular (petclinic-angular)**

```bash
cd ~/tmp-forks/spring-petclinic-angular

# 1. Renombrar remote de GitHub
git remote rename origin upstream

# 2. Agregar remote de GitLab local
git remote add origin ssh://git@localhost:2222/Adrianmrc94/petclinic-angular.git

# 3. CRÍTICO: Renombrar branch master → main
git branch -m master main

# 4. Fetch del remote GitLab (trae el README inicial con branch main)
git fetch origin

# 5. Merge con historiales no relacionados (permite unir los dos commits iniciales)
git pull origin main --allow-unrelated-histories --no-rebase

# Si hay conflicto en README.md:
# - Editar README.md manualmente (nano README.md)
# - Resolver conflictos (quitar marcadores <<<<<<, ======, >>>>>>)
# - git add README.md
# - git commit -m "Merge fork: resolved README.md conflict"

# 6. Push del código completo a GitLab
git push -u origin main

# 7. Actualizar HEAD de remote a main
git remote set-head origin -a

# 8. Verificar sincronización
git status
git branch -a
# Debe mostrar:
# * main
#   remotes/origin/HEAD -> origin/main
#   remotes/origin/main
```

**Resultado esperado:**
```
To ssh://localhost:2222/Adrianmrc94/petclinic-angular.git
   c08912b..555dd0d  main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

#### **🔵 B. Proyecto Java/REST (petclinic-rest)**

```bash
cd ~/tmp-forks/spring-petclinic-rest

# 1. Agregar remote de GitLab local (NO renombrar upstream si quieres mantener acceso a GitHub)
git remote add origin ssh://git@localhost:2222/Adrianmrc94/petclinic-rest.git

# 2. CRÍTICO: Renombrar branch master → main
git branch -m master main

# 3. Fetch del remote GitLab
git fetch origin

# 4. Merge con historiales no relacionados
git pull origin main --allow-unrelated-histories --no-rebase

# Si hay conflicto en README.md, resolverlo:
# nano README.md → resolver conflictos → guardar
# git add README.md
# git commit -m "Merge: resolved README conflict"

# 5. Push del código completo a GitLab
git push -u origin main

# 6. Actualizar HEAD de remote a main
git remote set-head origin -a

# 7. Verificar sincronización
git status
git branch -a
# Debe mostrar:
# * main
#   remotes/origin/HEAD -> origin/main
#   remotes/origin/main
```

**Resultado esperado:**
```
To ssh://localhost:2222/Adrianmrc94/petclinic-rest.git
   1f83fa9..1777892  main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

---

### **Paso 5: Verificación Final**

#### **A. Verificar repositorios en GitLab UI**

1. **Angular:** `http://localhost:8929/Adrianmrc94/petclinic-angular`
   - ✅ Debe mostrar: `package.json`, `src/`, `angular.json`, `README.md`
   - ✅ Branch por defecto: **main**
   - ✅ Commit más reciente: código completo (no solo README)

2. **Java/REST:** `http://localhost:8929/Adrianmrc94/petclinic-rest`
   - ✅ Debe mostrar: `pom.xml`, `src/`, `README.md`
   - ✅ Branch por defecto: **main**
   - ✅ Commit más reciente: código completo (no solo README)

#### **B. Verificar estado local**

```bash
# Petclinic Angular
cd ~/tmp-forks/spring-petclinic-angular
git log --oneline -3
git status
# Debe mostrar:
# On branch main
# Your branch is up to date with 'origin/main'.
# nothing to commit, working tree clean

# Petclinic REST
cd ~/tmp-forks/spring-petclinic-rest
git log --oneline -3
git status
# Debe mostrar:
# On branch main
# Your branch is up to date with 'origin/main'.
# nothing to commit, working tree clean
```

#### **C. Verificar acceso desde Docker (Jenkins)**

```bash
# Clonar repositorio desde perspectiva de Jenkins
docker exec jenkins bash -c "cd /tmp && \
  git clone ssh://git@gitlab:22/Adrianmrc94/petclinic-angular.git test-checkout && \
  ls -la test-checkout/ && \
  rm -rf test-checkout"

# Resultado esperado:
# Cloning into 'test-checkout'...
# total XX
# drwxr-xr-x ... .
# drwxr-xr-x ... ..
# -rw-r--r-- ... package.json
# -rw-r--r-- ... angular.json
# drwxr-xr-x ... src
# ...
```

✅ Si el checkout funciona y muestra el código completo, **la configuración es correcta**.

---

## 🐛 Solución de Problemas Comunes

### ❌ **Error: "Permission denied (publickey)"**

**Causa:** URL SSH incorrecta o clave SSH no agregada a GitLab.

**Solución:**
```bash
# 1. Verificar URL del remote
git remote -v
# Debe ser: ssh://git@localhost:2222/Adrianmrc94/petclinic-angular.git

# 2. Corregir URL si es necesario
git remote set-url origin ssh://git@localhost:2222/Adrianmrc94/petclinic-angular.git

# 3. Verificar acceso SSH
ssh -T git@localhost -p 2222
# Debe decir: Welcome to GitLab, @adrianmrc94!
```

---

### ❌ **Error: "! [rejected] main -> main (fetch first)"**

**Causa:** GitLab tiene commits que no tienes localmente (README inicial).

**Solución:**
```bash
# Fetch cambios remotos
git fetch origin

# Merge con historiales no relacionados
git pull origin main --allow-unrelated-histories --no-rebase

# Si hay conflicto en README.md, resolverlo manualmente
nano README.md  # Resolver conflictos
git add README.md
git commit -m "Merge: resolved README conflict"

# Push final
git push origin main
```

---

### ❌ **Error: "Your branch is ahead of 'origin/master' by X commits"**

**Causa:** Referencia local apuntando a `master` remoto que ya no existe/está desactualizado.

**Solución:**
```bash
# Actualizar HEAD del remote a main
git remote set-head origin -a

# Verificar
git branch -a
# Debe mostrar: remotes/origin/HEAD -> origin/main
```

---

### ❌ **Conflictos en README.md al hacer merge**

**Solución manual:**
```bash
# 1. Abrir README.md en editor
nano README.md

# 2. Buscar marcadores de conflicto:
# <<<<<<< HEAD
#   (tu contenido local)
# =======
#   (contenido de GitLab)
# >>>>>>> xxxxx

# 3. Decidir qué contenido mantener (normalmente el del proyecto clonado)

# 4. Guardar y salir (Ctrl+O, Enter, Ctrl+X)

# 5. Agregar y commitear
git add README.md
git commit -m "Merge fork: resolved README.md conflict"

# 6. Push
git push origin main
```

---

### ❌ **Error: "error: src refspec main does not match any"**

**Causa:** No existe branch `main` localmente (todavía se llama `master`).

**Solución:**
```bash
# Renombrar branch local
git branch -m master main

# Verificar
git branch
# Debe mostrar: * main
```

---

## 📋 Checklist Final

Antes de continuar con Jenkins pipelines, verificar:

- ✅ **Configuración Git global:**
  - `git config --global user.name` configurado
  - `git config --global user.email` configurado

- ✅ **SSH funcionando:**
  - `ssh -T git@localhost -p 2222` → "Welcome to GitLab"
  - Clave pública agregada en GitLab UI

- ✅ **Branches sincronizados:**
  - Branch local: `main` (NO `master`)
  - Branch remoto: `origin/main` (NO `origin/master`)
  - Default branch GitLab: `main`

- ✅ **Repositorios en GitLab:**
  - `petclinic-angular`: código completo visible en UI
  - `petclinic-rest`: código completo visible en UI

- ✅ **Estado local limpio:**
  - `git status` → "nothing to commit, working tree clean"
  - `git log` → commits del proyecto clonado + merge commit

---

## 🎯 Próximos Pasos

Una vez completada esta configuración:

1. ✅ Agregar `Jenkinsfile` a cada repositorio (ver **5-PipelinePetclinicAngular.md** y **6-PipelinePetclinicMaven.md**)
2. ✅ Configurar pipelines en Jenkins UI
3. ✅ Ejecutar builds automáticos
4. ✅ Centralizar pipelines con Shared Libraries (ver **7-CentralizaciónDePipelines.md**)

---

## 📚 Referencias

- **Solución detallada de branches:** `SOLUCION-GITLAB-JENKINS.md`
- **Pipeline Angular:** `5-PipelinePetclinicAngular.md`
- **Pipeline Maven:** `6-PipelinePetclinicMaven.md`
- **Centralización:** `7-CentralizaciónDePipelines.md`

---

⚠️ **Nota:** Reemplaza `Adrianmrc94` por tu nombre de usuario en GitLab en todos los comandos.