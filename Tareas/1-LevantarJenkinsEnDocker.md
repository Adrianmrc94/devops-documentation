# 🏗️ Levantar Jenkins

## 📋 Prerrequisitos

- **Instalar Docker Desktop en Windows** (no dentro del WSL)
  - WSL2 no arranca systemd por defecto
  - El socket de Docker queda invisible para Windows

## ✅ Verificar instalación

```bash
docker run hello-world
```

## 🚀 Pasos de instalación

### 1. Crear red Docker para comunicación entre contenedores

```bash
# Crear red bridge para Jenkins, GitLab y futuros contenedores
docker network create devops-net

# Verificar creación
docker network ls | grep devops-net
```

**¿Por qué necesitamos esta red?**
- 🔗 **Comunicación entre contenedores:** Jenkins necesitará conectarse a GitLab usando el nombre del contenedor (`gitlab:22`) en lugar de `localhost:2222`
- 🔒 **Aislamiento:** Los contenedores solo se comunican dentro de esta red
- 🎯 **DNS automático:** Docker resuelve nombres de contenedores automáticamente (`jenkins`, `gitlab`, etc.)
- 📦 **Escalabilidad:** Futuros contenedores (registry, minikube, etc.) usarán la misma red

⚠️ **¿Ya levantaste Jenkins sin crear esta red?** Ver: **0-MigracionRedDocker.md** para reconectar contenedores existentes.

---

### 2. Crear volumen para datos persistentes

```bash
docker volume create jenkins_data
```

---

### 3. Levantar contenedor Jenkins en la red `devops-net` con acceso a Docker

```bash
docker run -d \
  --name jenkins \
  --network devops-net \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

**Explicación de parámetros:**
- `-d` → Ejecuta en segundo plano (daemon mode)
- `--name jenkins` → Nombre del contenedor
- `--network devops-net` → Conecta a red Docker personalizada
- `-p 8080:8080` → Mapea puerto web de Jenkins
- `-p 50000:50000` → Puerto para comunicación master-nodos
- `-v jenkins_data:/var/jenkins_home` → Volumen persistente para datos
- `-v /var/run/docker.sock:/var/run/docker.sock` → **CRÍTICO:** Acceso al Docker del host
- `jenkins/jenkins:lts` → Imagen oficial LTS (Long-Term Support)

**¿Por qué montar el socket de Docker?**
- Permite que Jenkins ejecute contenedores Docker (necesario para pipelines)
- Los pipelines de las Tareas 5 y 6 usan `agent { docker { ... } }`
- Sin esto, Jenkins no puede usar Docker y los pipelines fallan

---

### 3.1. Instalar Docker CLI en Jenkins

```bash
# Instalar Docker CLI dentro del contenedor Jenkins
docker exec -u root jenkins sh -c "
  apt-get update && \
  apt-get install -y apt-transport-https ca-certificates curl gnupg && \
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable' > /etc/apt/sources.list.d/docker.list && \
  apt-get update && \
  apt-get install -y docker-ce-cli
"

# Dar permisos al usuario jenkins para usar Docker
docker exec -u root jenkins chmod 666 /var/run/docker.sock

# Verificar instalación
docker exec jenkins docker --version
```

**Resultado esperado:**
```
Docker version 24.x.x, build...
```

✅ Si ves la versión de Docker, Jenkins está listo para ejecutar pipelines con Docker.

---

### 4. Verificar que Jenkins está en la red correcta

```bash
# Listar contenedores en la red devops-net
docker network inspect devops-net

# Debe mostrar:
# "Containers": {
#     "jenkins": { ... }
# }
```

---

### 5. Obtener contraseña inicial

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

---

### 6. Configurar Jenkins

- Abrir **http://localhost:8080** en navegador
- Introducir contraseña inicial
- Instalar plugins recomendados
- Crear usuario administrador

---

### 7. Instalar plugins adicionales necesarios

Una vez completada la configuración inicial, instalar plugins adicionales para pipelines:

1. **Jenkins** → **Manage Jenkins** → **Plugins**
2. **Available plugins** (pestaña)
3. Buscar e instalar:
   - ✅ **Docker Pipeline** (necesario para `agent { docker { ... } }` en Jenkinsfiles)
   - ✅ **Docker** (plugin base de Docker)
   - ✅ **Pipeline: Stage View** (opcional, mejora visualización de pipelines)
4. **Install without restart**

**¿Por qué son necesarios?**
- **Docker Pipeline:** Permite ejecutar stages de pipelines dentro de contenedores Docker
- **Docker:** Proporciona integración base con Docker
- Serán necesarios en las **Tareas 5 y 6** (Pipelines Angular y Maven)

**Verificar instalación:**
1. **Jenkins** → **Manage Jenkins** → **Plugins**
2. **Installed plugins** (pestaña)
3. Buscar `Docker Pipeline` → Debe aparecer en la lista ✅

---

## 📝 Resumen de Configuración

| Componente | Valor |
|------------|-------|
| **Red Docker** | `devops-net` (bridge) |
| **Nombre contenedor** | `jenkins` |
| **Puerto Web** | `8080` |
| **Puerto Agentes** | `50000` |
| **Volumen datos** | `jenkins_data` |
| **Acceso Web** | http://localhost:8080 |

⚠️ **Importante:** La red `devops-net` se reutilizará en la **Tarea 2 (GitLab)** para permitir comunicación entre contenedores.

