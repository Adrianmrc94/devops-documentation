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

# Probar conectividad (usar HTTP/1.1 para evitar problemas)
curl --http1.1 http://localhost:5000/v2/
# Respuesta esperada: {}

# Si curl falla con "Connection reset by peer", usar wget:
wget -qO- http://localhost:5000/v2/
# O verificar logs del contenedor:
docker logs registry --tail 20
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

# 4. Verificar que se subió (usar HTTP/1.1 para evitar problemas de conexión)
curl --http1.1 http://localhost:5000/v2/_catalog
# Respuesta esperada: {"repositories":["hello-world"]}

# Si curl falla, verificar directamente en el filesystem:
docker exec registry ls -la /var/lib/registry/docker/registry/v2/repositories/
# Debe mostrar: hello-world/

# Alternativa con wget (más robusto):
# wget -qO- http://localhost:5000/v2/_catalog
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

---

## 🐛 Troubleshooting

### **Error: "curl: (56) Recv failure: Connection reset by peer"**

**Síntoma:**
```bash
curl http://localhost:5000/v2/_catalog
# curl: (56) Recv failure: Connection reset by peer
```

**Causa:** Problema de compatibilidad HTTP/2 entre curl y el registry.

**Soluciones:**

```bash
# Solución 1: Forzar HTTP/1.1
curl --http1.1 http://localhost:5000/v2/_catalog

# Solución 2: Usar wget
wget -qO- http://localhost:5000/v2/_catalog

# Solución 3: Verificar directamente en filesystem
docker exec registry ls -la /var/lib/registry/docker/registry/v2/repositories/

# Solución 4: Verificar con Python
python3 -c "import urllib.request; print(urllib.request.urlopen('http://localhost:5000/v2/_catalog').read().decode())"
```

**Verificación funcional (lo importante):**
```bash
# Si docker push/pull funcionan, el registry está OK
docker pull localhost:5000/hello-world:latest
# Si esto funciona ✅, el problema de curl es solo cosmético
```

---

### **Error: "no basic auth credentials"**

**Síntoma:**
```bash
docker push localhost:5000/my-image
# unauthorized: authentication required
```

**Solución:** El registry está configurado sin autenticación básica. Para uso local está OK. Si necesitas autenticación, consulta la documentación oficial de Docker Registry.

---

### **Error: "http: server gave HTTP response to HTTPS client"**

**Síntoma:**
```bash
docker push localhost:5000/my-image
# http: server gave HTTP response to HTTPS client
```

**Causa:** Docker intenta usar HTTPS pero el registry está en HTTP.

**Solución:** Verificar que `localhost:5000` está en `insecure-registries` (ver Paso 2.1).

---

## ✅ Verificación Final

```bash
# Script de verificación completo
cat > ~/verify-registry.sh << 'EOF'
#!/bin/bash
echo "🔍 Verificando Docker Registry Local..."
echo ""

echo "1️⃣ Estado del contenedor:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "NAMES|registry"
echo ""

echo "2️⃣ Repositorios almacenados:"
docker exec registry ls -la /var/lib/registry/docker/registry/v2/repositories/ 2>/dev/null || echo "Sin repositorios"
echo ""

echo "3️⃣ Imágenes locales taggeadas para registry:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep -E "REPOSITORY|localhost:5000"
echo ""

echo "4️⃣ Test de conectividad API:"
curl --http1.1 -s http://localhost:5000/v2/_catalog || echo "❌ curl falló, pero registry puede estar OK"
echo ""

echo "✅ Verificación completada"
EOF

chmod +x ~/verify-registry.sh
~/verify-registry.sh
```
