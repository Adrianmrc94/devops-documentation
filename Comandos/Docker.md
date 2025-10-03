# 🐳 Comandos esenciales de Docker

---

## 🔧 Gestión del daemon

| Acción | Comando |
|--------|---------|
| Ver versión | `docker --version` |
| Info del sistema | `docker info` |
| Descargar imagen | `docker pull nginx:alpine` |
| Listar imágenes | `docker images` |
| Listar contenedores activos | `docker ps` |
| Listar todos (incluidos parados) | `docker ps -a` |

---

## 🚀 Contenedores

| Acción | Comando |
|--------|---------|
| Crear y arrancar | `docker run -d --name web -p 8080:80 nginx` |
| Arrancar existente | `docker start web` |
| Parar | `docker stop web` |
| Reiniciar | `docker restart web` |
| Ver logs | `docker logs -f web` |
| Entrar en ejecución | `docker exec -it web bash` |
| Eliminar contenedor | `docker rm web` |
| Eliminar forzado (corriendo) | `docker rm -f web` |

---

## 📦 Imágenes

| Acción | Comando |
|--------|---------|
| Construir desde Dockerfile | `docker build -t mi-app:1.0 .` |
| Etiquetar imagen | `docker tag mi-app:1.0 usuario/mi-app:latest` |
| Subir a Docker Hub | `docker push usuario/mi-app:latest` |
| Eliminar imagen | `docker rmi mi-app:1.0` |
| Limpiar imágenes huérfanas | `docker image prune -a` |

---

## 🗂️ Volúmenes

| Acción | Comando |
|--------|---------|
| Crear volumen | `docker volume create db_data` |
| Listar volúmenes | `docker volume ls` |
| Inspeccionar | `docker volume inspect db_data` |
| Borrar volumen sin usar | `docker volume prune` |
| Montar al ejecutar | `docker run -v db_data:/var/lib/mysql mysql:8` |

---

## 🌐 Redes

| Acción | Comando |
|--------|---------|
| Listar redes | `docker network ls` |
| Crear red bridge personalizada | `docker network create mi_red` |
| Ejecutar dentro de red | `docker run -d --name app --network mi_red nginx` |
| Ver info de red | `docker network inspect mi_red` |
| Borrar red sin usar | `docker network prune` |

---

## 🧹 Limpieza total (¡cuidado!)

| Acción | Comando |
|--------|---------|
| Parar todos los contenedores | `docker stop $(docker ps -aq)` |
| Borrar todos los contenedores | `docker rm $(docker ps -aq)` |
| Borrar todas las imágenes no usadas | `docker image prune -a -f` |
| Borrar volúmenes no usados | `docker volume prune -f` |
| Borrar TODO (contenedores, imágenes, redes, volúmenes) | `docker system prune -a --volumes -f` |

---

## 🐙 Docker Compose (completo)

| Acción | Comando |
|--------|---------|
| Levantar stack | `docker-compose up -d` |
| Bajar y borrar contenedores/redes | `docker-compose down` |
| Ver logs compose | `docker-compose logs -f` |
| Logs de servicio específico | `docker-compose logs -f servicio` |
| Reconstruir tras cambios | `docker-compose up -d --build` |
| Escalar servicios | `docker-compose up -d --scale web=3` |
| Ejecutar comando en servicio | `docker-compose exec web bash` |
| Ver estado servicios | `docker-compose ps` |
| Restart servicio | `docker-compose restart web` |
| Validar compose file | `docker-compose config` |

---

## 🔧 Troubleshooting

| Problema | Comando/Solución |
|----------|------------------|
| Ver uso de recursos | `docker stats` |
| Espacio usado por Docker | `docker system df` |
| Inspeccionar contenedor | `docker inspect contenedor` |
| Ver procesos en contenedor | `docker top contenedor` |
| Copiar archivos | `docker cp archivo.txt contenedor:/ruta/` |
| Variables de entorno | `docker exec contenedor env` |
| Attach a contenedor | `docker attach contenedor` |
| Crear imagen desde contenedor | `docker commit contenedor nueva-imagen` |

---

## 🚀 Docker en producción

| Acción | Comando |
|--------|---------|
| Limitar memoria | `docker run -m 512m imagen` |
| Limitar CPU | `docker run --cpus="1.5" imagen` |
| Healthcheck | `docker run --health-cmd="curl -f http://localhost" imagen` |
| Restart policies | `docker run --restart=unless-stopped imagen` |
| Usuario no root | `docker run --user 1000:1000 imagen` |
| Solo lectura | `docker run --read-only imagen` |

