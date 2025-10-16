# 🔒 Guía Completa de Backups para Evitar Pérdida de Datos

## 📋 Índice

1. [Introducción](#introducción)
2. [Conceptos Clave](#conceptos-clave)
3. [Prerrequisitos](#prerrequisitos)
4. [Backup de Volumes Docker](#backup-de-volumes-docker)
5. [Restauración desde Backup](#restauración-desde-backup)
6. [Backup Automatizado](#backup-automatizado)
7. [Troubleshooting](#troubleshooting)
8. [Checklist Final](#checklist-final)

---

## 🎯 Introducción

### ¿Por qué hacer backups?

Los contenedores Docker no guardan datos de forma permanente por defecto. Si eliminas un contenedor o ejecutas comandos como `docker system prune`, pierdes todo (repositorios de GitLab, configuraciones de Jenkins, etc.). Los volumes Docker persistentes resuelven esto, pero necesitas backups para protegerte contra accidentes.

### ¿Qué vamos a lograr?

**Backup Seguro → Restauración Rápida → Datos Intactos**

Servicios que cubrimos:
- ✅ GitLab (repositorios, usuarios, configuraciones)
- ✅ Jenkins (jobs, configuraciones, plugins)
- ✅ Registry Docker (imágenes privadas)
- ✅ Otros volumes personalizados

---

## 📚 Conceptos Clave

Un **volume Docker** es un directorio especial en el host que persiste fuera del ciclo de vida del contenedor. A diferencia de los datos dentro del contenedor (que se pierden), los volumes sobreviven a:

- Eliminación de contenedores
- Reinicio de Docker
- Actualizaciones del sistema

### Ejemplos de volumes en tu setup:

- `gitlab_data`: Datos de GitLab (`/var/opt/gitlab`)
- `jenkins_data`: Datos de Jenkins (`/var/jenkins_home`)
- `registry_data`: Imágenes del registry

### Ver volumes existentes:

```bash
docker volume ls
```

---

## ✅ Prerrequisitos

### Verificar que tienes:

- ✅ Docker Desktop funcionando
- ✅ Contenedores corriendo (Jenkins, GitLab, Registry)
- ✅ Volumes persistentes activos
- ✅ Espacio en disco suficiente (al menos 2GB libres)

### Comandos de verificación:

```bash
# Ver estado de contenedores
docker ps --format "table {{.Names}}\t{{.Status}}"

# Ver volumes
docker volume ls

# Ver espacio en disco
df -h
```

---

## 📦 Backup de Volumes Docker

### Método 1: Backup Manual de un Volume

#### Paso 1: Crear contenedor temporal para backup

```bash
# Backup de gitlab_data (ejemplo)
docker run --rm -v gitlab_data:/source -v $(pwd):/backup alpine tar czf /backup/gitlab_data_backup.tar.gz -C /source .
```

**¿Qué hace este comando?**
- `--rm`: Elimina el contenedor después de usarlo
- `-v gitlab_data:/source`: Monta el volume como `/source`
- `tar czf`: Comprime todo en un archivo `.tar.gz`

#### Paso 2: Verificar el backup

```bash
ls -lh gitlab_data_backup.tar.gz
```

#### Repetir para otros volumes:

```bash
# Jenkins
docker run --rm -v jenkins_data:/source -v $(pwd):/backup alpine tar czf /backup/jenkins_data_backup.tar.gz -C /source .

# Registry
docker run --rm -v registry_data:/source -v $(pwd):/backup alpine tar czf /backup/registry_data_backup.tar.gz -C /source .
```

---

### Método 2: Backup Completo de Todos los Volumes

**Script automatizado** (guárdalo como `backup-volumes.sh`):

```bash
#!/bin/bash
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "📦 Iniciando backup de volumes..."

# Backup de cada volume
docker run --rm -v gitlab_data:/source -v $BACKUP_DIR:/backup alpine tar czf /backup/gitlab_data.tar.gz -C /source .
docker run --rm -v jenkins_data:/source -v $BACKUP_DIR:/backup alpine tar czf /backup/jenkins_data.tar.gz -C /source .
docker run --rm -v registry_data:/source -v $BACKUP_DIR:/backup alpine tar czf /backup/registry_data.tar.gz -C /source .

echo "✅ Backup completado en $BACKUP_DIR"
echo "Archivos creados:"
ls -lh $BACKUP_DIR/*.tar.gz
```

#### Ejecutar el script:

```bash
chmod +x backup-volumes.sh
./backup-volumes.sh
```

---

### Método 3: Backup de Configuraciones Específicas de GitLab

**Backup interno de GitLab** (opcional, para repositorios):

```bash
# Ejecutar backup desde dentro del contenedor
docker exec gitlab gitlab-rake gitlab:backup:create

# Copiar el backup al host
docker cp gitlab:/var/opt/gitlab/backups/$(date +%Y%m%d_%H%M%S)_gitlab_backup.tar /tmp/
```

---

## 🔄 Restauración desde Backup

### Paso 1: Detener contenedores (si es necesario)

```bash
# Detener servicios antes de restaurar
docker stop gitlab jenkins registry
```

### Paso 2: Crear volume si no existe

```bash
# Ejemplo para gitlab_data
docker volume create gitlab_data
```

### Paso 3: Restaurar desde backup

```bash
# Restaurar gitlab_data
docker run --rm -v gitlab_data:/dest -v $(pwd)/backups/20251016_120000:/backup alpine tar xzf /backup/gitlab_data.tar.gz -C /dest

# Repetir para otros volumes
docker run --rm -v jenkins_data:/dest -v $(pwd)/backups/20251016_120000:/backup alpine tar xzf /backup/jenkins_data.tar.gz -C /dest
docker run --rm -v registry_data:/dest -v $(pwd)/backups/20251016_120000:/backup alpine tar xzf /backup/registry_data.tar.gz -C /dest
```

### Paso 4: Reiniciar contenedores

```bash
# Levantar servicios
docker start gitlab jenkins registry

# Verificar que funcionan
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Paso 5: Verificar restauración

```bash
# Verificar GitLab
docker exec gitlab gitlab-rake gitlab:check

# Verificar Jenkins (accede a localhost:8080)

# Verificar Registry
curl http://localhost:5000/v2/_catalog
```

---

## ⏰ Backup Automatizado

### Programar backups diarios con cron (Linux/Mac):

```bash
# Editar crontab
crontab -e

# Agregar línea para backup diario a las 2 AM
0 2 * * * /ruta/a/backup-volumes.sh
```

### Backup en la nube (opcional):

```bash
# Subir a Google Drive, Dropbox, etc.
# Ejemplo con rclone (instálalo primero)
rclone copy ./backups remote:backups
```

---

## 🛠️ Troubleshooting

### Problema 1: "No space left on device"

**Causa:** Disco lleno.

**Solución:**

```bash
# Liberar espacio
docker system prune -a
rm -rf ./backups/antiguos/
```

---

### Problema 2: "Volume not found"

**Causa:** Volume eliminado accidentalmente.

**Solución:**

```bash
# Crear volume vacío
docker volume create gitlab_data

# Restaurar desde backup
# (ver Paso 3 de restauración)
```

---

### Problema 3: Backup corrupto

**Causa:** Archivo dañado.

**Solución:**

```bash
# Verificar integridad
tar -tzf backup.tar.gz > /dev/null && echo "OK" || echo "CORRUPTO"

# Usar backup anterior
```

---

### Problema 4: Contenedor no arranca después de restaurar

**Causa:** Permisos incorrectos.

**Solución:**

```bash
# Ajustar permisos
docker exec -u root gitlab chown -R gitlab:gitlab /var/opt/gitlab
```

---

## ✅ Checklist Final

- ✅ Volumes identificados (`gitlab_data`, `jenkins_data`, `registry_data`)
- ✅ Script de backup creado y probado
- ✅ Backup manual realizado al menos una vez
- ✅ Restauración probada en entorno de test
- ✅ Backups almacenados en lugar seguro
- ✅ Cron configurado para backups automáticos (opcional)
- ✅ Espacio en disco monitoreado

---

**Documentación creada:** Octubre 2025  
**Última actualización:** Octubre 2025  
**Versión:** 1.0