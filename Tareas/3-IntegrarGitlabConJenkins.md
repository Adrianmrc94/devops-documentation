# 🔗 Integrar GitLab con Jenkins

## 🎯 Objetivo

Configurar integración **GitLab webhook → Jenkins** para CI/CD automático, aprovechando la red Docker `devops-net` para comunicación entre contenedores.

## 📋 Prerrequisitos

✅ **Ambos contenedores deben estar en la red `devops-net`:**

```bash
# Verificar que ambos contenedores están en la red
docker network inspect devops-net | grep -E "jenkins|gitlab"

# Resultado esperado:
# "jenkins": { ... }
# "gitlab": { ... }
```

✅ **Verificar conectividad:**

```bash
# Desde Jenkins → GitLab
docker exec jenkins ping -c 2 gitlab

# Desde GitLab → Jenkins
docker exec gitlab ping -c 2 jenkins
```

Si ambos `ping` funcionan, la red está correctamente configurada. ✅

---

## 🔍 Entendiendo URLs de GitLab según contexto

| Desde dónde | URL correcta | Explicación |
|-------------|-------------|-------------|
| **Tu máquina (navegador)** | `http://localhost:8929` | Puerto mapeado en host |
| **Tu máquina (git SSH)** | `ssh://git@localhost:2222` | Puerto SSH mapeado en host |
| **Jenkins (checkout repo)** | `ssh://git@gitlab:22` | Comunicación interna via devops-net |
| **Jenkins (API calls)** | `http://gitlab:80` | HTTP interno (sin puerto mapeado) |

⚠️ **CRÍTICO:** En pipelines de Jenkins, **SIEMPRE usar `gitlab:22`**, NO `localhost:2222`.

---

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

