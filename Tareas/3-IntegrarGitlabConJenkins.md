# 🔗 Integrar GitLab con Jenkins

## 🎯 Objetivo

Configurar integración **GitLab webhook → Jenkins** para CI/CD automático.

## 🚀 Pasos de integración

### Paso 1: Instalar plugin GitLab en Jenkins

1. **Jenkins** → **Manage Jenkins** → **Plugins** → **Available**
2. Buscar **"GitLab"** (el oficial: GitLab Plugin)
3. Marcar la casilla y **Install without restart** Decidir flujo


### Paso 2: Crear token de acceso en GitLab

1. **GitLab** → **Avatar** → **Edit profile** → **Access Tokens**
2. **Crear nuevo token:**
   - **Name:** `jenkins-token`
   - **Scopes:** `api`, `read_repository`, `write_repository`
3. **Generate token** y copiarlo (solo se muestra una vez)


### Paso 3: Configurar credenciales en Jenkins

1. **Jenkins** → **Manage Jenkins** → **Credentials** → **System** → **Global credentials**
2. **Add Credentials:**
   - **Kind:** GitLab API token
   - **API token:** Pegar el token de GitLab
   - **ID:** `gitlab-token`
   - **Description:** GitLab Access for Jenkins
3. **Create**

