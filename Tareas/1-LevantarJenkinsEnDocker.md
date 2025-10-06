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

### 3. Levantar contenedor Jenkins en la red `devops-net`

```bash
docker run -d \
  --name jenkins \
  --network devops-net \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Explicación de parámetros:**
- `-d` → Ejecuta en segundo plano (daemon mode)
- `--name jenkins` → Nombre del contenedor
- `--network devops-net` → **NUEVO:** Conecta a red Docker personalizada
- `-p 8080:8080` → Mapea puerto web de Jenkins
- `-p 50000:50000` → Puerto para comunicación master-nodos
- `-v jenkins_data:/var/jenkins_home` → Volumen persistente para datos
- `jenkins/jenkins:lts` → Imagen oficial LTS (Long-Term Support)

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

