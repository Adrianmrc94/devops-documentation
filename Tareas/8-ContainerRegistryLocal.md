# 📦 Guía Completa: Container Registry Local con Docker

## 🎯 Objetivo

Crear un **Docker Registry privado local** para almacenar y gestionar imágenes Docker personalizadas en nuestra arquitectura DevOps.

## 🏗️ Arquitectura Actualizada

```
WINDOWS HOST
└── WSL
    └── DOCKER DESKTOP
        ├── 🔴 Contenedor Jenkins (puerto 8080)
        ├── 🟢 Contenedor GitLab (puerto 8929)
        └── 🐳 Contenedor Registry (puerto 5000) ← NUEVO
```

## 🚀 Implementación Paso a Paso

### **Fase 1: Levantar Docker Registry**

#### **Paso 1.1: Crear directorio para datos del registry**

```bash
# Crear estructura de directorios
mkdir -p ~/docker-registry/data
mkdir -p ~/docker-registry/certs
mkdir -p ~/docker-registry/config
```

#### **Paso 1.2: Levantar contenedor Registry**

```bash
# Levantar Docker Registry en red devops-net
docker run -d \
  --name registry \
  --restart=always \
  -p 5000:5000 \
  -v ~/docker-registry/data:/var/lib/registry \
  --network devops-net \
  registry:2
```

### **Fase 2: Configuración para Registry Inseguro**

#### **Paso 2.1: Configurar Docker Desktop para registry inseguro**

**En Windows - Docker Desktop:**

1. **Docker Desktop** → **Settings** → **Docker Engine**
2. **Agregar configuración:**

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "features": {
    "buildkit": true
  },
  "insecure-registries": [
    "localhost:5000",
    "127.0.0.1:5000",
    "registry:5000"
  ]
}
```

3. **Apply & Restart**

#### **Paso 2.2: Verificar conectividad**

```bash
# Verificar que el registry esté corriendo
docker ps | grep registry

# Probar conectividad
curl http://localhost:5000/v2/
# Respuesta esperada: {}
```

### **Fase 3: Pruebas de Funcionamiento**

#### **Paso 3.1: Subir imagen de prueba**

```bash
# 1. Descargar imagen de prueba
docker pull hello-world

# 2. Etiquetar para nuestro registry
docker tag hello-world localhost:5000/hello-world:latest

# 3. Subir al registry local
docker push localhost:5000/hello-world:latest

# 4. Verificar que se subió
curl http://localhost:5000/v2/_catalog
# Respuesta: {"repositories":["hello-world"]}
```

#### **Paso 3.2: Descargar desde registry**

```bash
# 1. Eliminar contenedores que usen la imagen
docker ps -a | grep hello-world
docker rm $(docker ps -a -q --filter ancestor=hello-world) 2>/dev/null || true

# 2. Eliminar imagen local (forzar si es necesario)
docker rmi -f hello-world localhost:5000/hello-world:latest

# 3. Verificar que se eliminaron
docker images | grep hello-world

# 4. Descargar desde nuestro registry
docker pull localhost:5000/hello-world:latest

# 5. Ejecutar para verificar
docker run localhost:5000/hello-world:latest

# 6. Verificar que vino del registry local
docker images | grep localhost:5000
```
