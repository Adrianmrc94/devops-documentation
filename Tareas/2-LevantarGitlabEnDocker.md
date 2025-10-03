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

## 🚀 Levantar contenedor GitLab

```bash
docker run -d \
  --hostname gitlab.local \
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
- `--publish 8929:80` → Puerto web GitLab (NGINX)
- `--publish 2222:22` → Puerto SSH de GitLab
- `--name gitlab` → Nombre del contenedor
- `--restart always` → Reinicio automático si cae
- `--volume` → Volúmenes persistentes (config, logs, datos)
- `--shm-size 256m` → Memoria compartida (por defecto 64M)

## ✅ Verificación

```bash
docker ps
```

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