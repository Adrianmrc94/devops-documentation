# 🏥 Configurar Proyectos PetClinic (Angular + Java)

## 🎯 Objetivo

Clonar proyectos PetClinic públicos y subirlos a tu GitLab local para CI/CD.

## 🚀 Pasos de configuración

### Paso 1: Clonar repositorios públicos

```bash
mkdir ~/tmp-forks && cd ~/tmp-forks
git clone https://github.com/spring-petclinic/spring-petclinic-angular.git
git clone https://github.com/spring-petclinic/spring-petclinic-rest.git
```

### Paso 2: Crear proyectos en GitLab local

1. **Proyecto Angular:**
   - GitLab → **New project** → **Create blank project**
   - **Project name:** `petclinic-angular`
   - **Slug:** `petclinic-angular`
   - **Visibility:** Private
   - **Create project**

2. **Proyecto Java/REST:**
   - Repetir proceso anterior
   - **Project name:** `petclinic-rest`
   - **Slug:** `petclinic-rest`

### Paso 3: Generar clave SSH

```bash
ssh-keygen -t ed25519 -C "tu@email.com" -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

- Copiar la clave pública
- GitLab → **Profile** → **SSH Keys** → Pegar y guardar

### Paso 4: Subir repositorios a GitLab

**Proyecto Angular:**
```bash
cd spring-petclinic-angular
git remote rename origin upstream
git remote add origin ssh://git@localhost:2222/TU-USUARIO/petclinic-angular.git
git push -u origin main
```

**Proyecto Java/REST:**
```bash
cd ../spring-petclinic-rest
git remote rename origin upstream
git remote add origin ssh://git@localhost:2222/TU-USUARIO/petclinic-rest.git
git push -u origin main
```

⚠️ **Nota:** Reemplaza `TU-USUARIO` por tu nombre de usuario en GitLab