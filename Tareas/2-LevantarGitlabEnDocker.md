# 🦊 Levantar GitLab en Docker

## 📋 Preparación

GitLab necesita directorios persistentes para configuración, logs y repositorios.

### 1. Crear estructura de directorios

```bash
export GITLAB_HOME=$HOME/gitlab
mkdir -p $GITLAB_HOME/config $GITLAB_HOME/logs $GITLAB_HOME/data
```

### 2. Descargar imagen GitLab

```bash
docker pull gitlab/gitlab-ce:latest
```

## 🚀 Levantar contenedor GitLab en red `devops-net`

⚠️ **Prerrequisito:** La red `devops-net` debe existir (creada en **Tarea 1: Levantar Jenkins**)

```bash
# Verificar que la red existe
docker network ls | grep devops-net

# Si no existe, crearla:
# docker network create devops-net
```

⚠️ **¿Ya levantaste GitLab sin conectarlo a devops-net?** Ver: **0-MigracionRedDocker.md** para reconectar contenedores existentes.

**Levantar GitLab conectado a `devops-net`:**

```bash
docker run -d \
  --hostname gitlab.local \
  --network devops-net \
  --publish 8929:80 \
  --publish 2222:22 \
  --name gitlab \
  --restart always \
  --volume $GITLAB_HOME/config:/etc/gitlab \
  --volume $GITLAB_HOME/logs:/var/log/gitlab \
  --volume $GITLAB_HOME/data:/var/opt/gitlab \
  --shm-size 256m \
  gitlab/gitlab-ce:latest
```

**Explicación de parámetros:**
- `--hostname gitlab.local` → Nombre de red interna del contenedor
- `--network devops-net` → **CRÍTICO:** Conecta a la red compartida con Jenkins
- `--publish 8929:80` → Puerto web GitLab (NGINX) - acceso desde host
- `--publish 2222:22` → Puerto SSH de GitLab - acceso desde host
- `--name gitlab` → Nombre del contenedor (usado por Jenkins para conectarse)
- `--restart always` → Reinicio automático si cae
- `--volume` → Volúmenes persistentes (config, logs, datos)
- `--shm-size 256m` → Memoria compartida (por defecto 64M)

### 🔍 **Entendiendo la comunicación de red:**

| Contexto | URL GitLab SSH | Explicación |
|----------|----------------|-------------|
| **Desde tu máquina (host)** | `ssh://git@localhost:2222` | Puerto mapeado en host |
| **Desde Jenkins (contenedor)** | `ssh://git@gitlab:22` | Comunicación interna via `devops-net` |
| **Desde otro contenedor en devops-net** | `ssh://git@gitlab:22` | DNS automático de Docker |

⚠️ **Importante:** Jenkins **NO puede** usar `localhost:2222` porque `localhost` dentro de un contenedor apunta al propio contenedor, no al host.

## ✅ Verificación

### A. Verificar contenedor corriendo

```bash
docker ps
```

### B. Verificar conectividad en la red `devops-net`

```bash
# Ver contenedores en la red
docker network inspect devops-net

# Debe mostrar:
# "Containers": {
#     "jenkins": { ... },
#     "gitlab": { ... }
# }

# Probar conectividad desde Jenkins a GitLab
docker exec jenkins ping -c 3 gitlab

# Resultado esperado:
# PING gitlab (172.x.x.x): 56 data bytes
# 64 bytes from 172.x.x.x: icmp_seq=0 ttl=64 time=0.123 ms
# ...
```

✅ Si el `ping` funciona, Jenkins y GitLab pueden comunicarse correctamente.

## 🔧 Configuración inicial

### 1. Acceder a GitLab

- Abrir **http://localhost:8929** en navegador
- Esperar a que GitLab termine de inicializar (puede tardar varios minutos)

### 2. Obtener contraseña root

```bash
docker exec -it gitlab grep "Password:" /etc/gitlab/initial_root_password
```

### 3. Login inicial

- Usuario: `root`
- Contraseña: La obtenida en el paso anterior
- Cambiar contraseña en el primer login

---

## 📝 Resumen de Configuración

| Componente | Valor |
|------------|-------|
| **Red Docker** | `devops-net` (compartida con Jenkins) |
| **Nombre contenedor** | `gitlab` |
| **Hostname interno** | `gitlab.local` |
| **Puerto Web (host)** | `8929` → `80` |
| **Puerto SSH (host)** | `2222` → `22` |
| **Puerto SSH (interno)** | `gitlab:22` (desde otros contenedores) |
| **Acceso Web** | http://localhost:8929 |
| **Acceso SSH (host)** | `ssh://git@localhost:2222` |
| **Acceso SSH (Jenkins)** | `ssh://git@gitlab:22` |

⚠️ **Importante:** En la **Tarea 3 (Integración Jenkins-GitLab)** configuraremos SSH para que Jenkins pueda clonar repositorios usando `ssh://git@gitlab:22`.