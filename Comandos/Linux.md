# 🐧 Comandos esenciales de Linux (ampliado)

---

## 📁 Navegación y directorios

| Comando | Descripción |
|---------|-------------|
| `pwd` | Ruta del directorio actual. |
| `ls` | Lista archivos y carpetas. |
| `ls -a` | **Muestra archivos ocultos** (los que empiezan por `.`). |
| `ls -l` | Lista con permisos, tamaño, fecha, etc. |
| `ls -lh` | Igual que `-l` pero tamaños en formato humano (MB, KB). |
| `ls -la` | **Ocultos + detalles**. |
| `cd` | Cambia de directorio. |
| `cd ~` | Ir al home del usuario. |
| `cd -` | Volver al directorio anterior. |
| `mkdir` | Crea carpeta. |
| `mkdir -p ruta/de/carpetas` | Crea estructura completa si no existe. |

---

## 📄 Archivos y contenido

| Comando | Descripción |
|---------|-------------|
| `touch archivo` | Crea archivo vacío o actualiza fecha. |
| `cat archivo` | Muestra todo el contenido. |
| `less archivo` | Vista paginada (mejor que `cat` para archivos largos). |
| `head archivo` | Muestra las primeras 10 líneas. |
| `head -n 20 archivo` | Primeras 20 líneas. |
| `tail archivo` | Últimas 10 líneas. |
| `tail -f archivo` | **Ver en tiempo real** (útil para logs). |
| `cp origen destino` | Copia. |
| `cp -r carpeta destino` | Copia carpetas recursivamente. |
| `mv viejo nuevo` | Mueve o renombra. |
| `rm archivo` | Borra archivo. |
| `rm -r carpeta` | Borra carpeta y su contenido. |
| `rm -rf carpeta` | **Forza borrado** (¡cuidado!). |

---

## 🔍 Búsqueda y filtros

| Comando | Descripción |
|---------|-------------|
| `find . -name "*.txt"` | Busca archivos por nombre. |
| `find . -type f -size +10M` | Archivos mayores de 10 MB. |
| `grep "texto" archivo` | Busca líneas que contengan “texto”. |
| `grep -i "texto" archivo` | **Insensible a mayúsculas**. |
| `grep -r "texto" carpeta/` | Busca en todos los archivos de la carpeta. |
| `which comando` | Muestra la ruta del binario (ej: `which python`). |
| `locate archivo` | Busca rápidamente por nombre en base de datos indexada (necesita `mlocate`). |

---

## 🔐 Permisos y usuarios

| Comando | Descripción |
|---------|-------------|
| `chmod 644 archivo` | Permisos estándar: lectura/escritura para dueño, lectura para otros. |
| `chmod +x script.sh` | Hace un archivo ejecutable. |
| `chown usuario:grupo archivo` | Cambia dueño y grupo. |
| `sudo !!` | **Repite el último comando con sudo** (atazo clave). |
| `su - usuario` | Cambia a otro usuario. |
| `whoami` | Usuario actual. |
| `id` | ID de usuario y grupos. |

---

## ⚙️ Procesos y sistema

| Comando | Descripción |
|---------|-------------|
| `ps aux` | Muestra todos los procesos. |
| `top` | Monitor interactivo. |
| `htop` | Versión mejorada de `top` (más visual, necesita instalar). |
| `kill PID` | Termina proceso por ID. |
| `killall nombre` | Mata todos los procesos con ese nombre. |
| `df -h` | Espacio en disco. |
| `du -sh carpeta` | Tamaño total de la carpeta. |
| `free -h` | Memoria RAM y swap. |
| `uptime` | Tiempo encendido y carga del sistema. |

---

## 📦 Compresión y archivos

| Comando | Descripción |
|---------|-------------|
| `tar -czvf archivo.tar.gz carpeta/` | Comprime en `.tar.gz`. |
| `tar -xzvf archivo.tar.gz` | Descomprime `.tar.gz`. |
| `zip -r archivo.zip carpeta/` | Comprime en `.zip`. |
| `unzip archivo.zip` | Descomprime `.zip`. |

---

## 🌐 Red

| Comando | Descripción |
|---------|-------------|
| `ip a` | Muestra interfaces de red y IPs. |
| `ping host` | Comprueba conectividad. |
| `curl url` | Descarga o muestra contenido de una URL. |
| `wget url` | Descarga archivos. |
| `scp usuario@host:ruta/archivo local` | Copia segura por SSH. |
| `ssh usuario@host` | Conexión remota segura. |

---

## 🧹 Útiles rápidas

| Comando | Descripción |
|---------|-------------|
| `clear` o `Ctrl+L` | Limpia la terminal. |
| `history` | Historial de comandos. |
| `!n` | Repite el comando número `n` del historial. |
| `alias` | Muestra tus atajos personalizados. |
| `unalias nombre` | Elimina un alias. |

---

## 🌐 Networking

| Comando | Descripción |
|---------|-------------|
| `ip a` | Muestra interfaces de red y IPs. |
| `ip route` | Muestra tabla de routing. |
| `ss -tuln` | Puertos abiertos (reemplazo moderno de `netstat`). |
| `ping -c 4 host` | Comprueba conectividad (4 pings). |
| `curl -I url` | Headers HTTP de una URL. |
| `wget -O archivo url` | Descarga archivos. |
| `rsync -av origen/ destino/` | Sincronización avanzada de archivos. |
| `scp archivo user@host:/ruta/` | Copia segura por SSH. |
| `ssh -L 8080:localhost:80 user@host` | SSH tunnel (port forwarding). |

---

## ⚙️ Systemd (gestión de servicios)

| Comando | Descripción |
|---------|-------------|
| `systemctl status servicio` | Ver estado de un servicio. |
| `systemctl start servicio` | Iniciar servicio. |
| `systemctl stop servicio` | Parar servicio. |
| `systemctl enable servicio` | Habilitar en boot. |
| `systemctl disable servicio` | Deshabilitar en boot. |
| `systemctl list-units --type=service` | Listar todos los servicios. |
| `journalctl -u servicio -f` | Logs en tiempo real de un servicio. |
| `systemctl daemon-reload` | Recargar configuración systemd. |

---

## 🔄 Gestión de paquetes

| Comando | Descripción (Debian/Ubuntu) |
|---------|------------------------------|
| `apt update` | Actualizar lista de paquetes. |
| `apt upgrade` | Actualizar paquetes instalados. |
| `apt install paquete` | Instalar paquete. |
| `apt remove paquete` | Desinstalar paquete. |
| `apt search texto` | Buscar paquetes. |
| `apt show paquete` | Ver información de paquete. |
| `dpkg -l` | Listar paquetes instalados. |
| `dpkg -L paquete` | Ver archivos de un paquete. |

---

## 🧪 Bonus: atajos de terminal

| Atajo | Función |
|--------|---------|
| `Ctrl + C` | Cancela comando actual. |
| `Ctrl + Z` | Suspende comando (luego puedes reanudar con `fg`). |
| `Ctrl + A` | Mueve cursor al inicio de la línea. |
| `Ctrl + E` | Mueve cursor al final. |
| `Ctrl + U` | Borra desde cursor al inicio. |
| `Ctrl + K` | Borra desde cursor al final. |
| `Ctrl + R` | Búsqueda reversa en historial. |
| `Tab` | Autocompleta nombres de archivos/comandos. |
| `Doble Tab` | Muestra opciones de autocompletado. |
| `!!` | Repite último comando. |
| `!n` | Ejecuta comando n del historial. |

---
