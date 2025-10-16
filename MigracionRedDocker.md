# 🔄 Migración: Conectar Jenkins y GitLab a `devops-net`

## 🎯 Situación

Ya has levantado Jenkins y GitLab siguiendo las **Tareas 1 y 2**, pero **sin crear la red `devops-net`**. Los contenedores están en la red por defecto (`bridge`), y necesitas conectarlos a `devops-net` para que se comuniquen correctamente.

---

## ⚠️ ¿Por qué necesitas hacer esto?

- 🔗 **Comunicación entre contenedores:** Jenkins necesita acceder a GitLab usando `gitlab:22` (DNS interno)
- ❌ **`localhost` no funciona:** Dentro de contenedores, `localhost` apunta al propio contenedor, no al host
- 📦 **Pipelines futuros:** Los contenedores Docker dentro de pipelines necesitan comunicarse con GitLab

---

## 🔍 Verificar estado actual

### **Paso 1: Ver qué redes existen**

```bash
docker network ls
```

**Resultado esperado:**
```
NETWORK ID     NAME      DRIVER    SCOPE
xxxxx          bridge    bridge    local
xxxxx          host      host      local
xxxxx          none      null      local
```

⚠️ Si **NO aparece `devops-net`**, necesitas crearla y conectar los contenedores.

---

### **Paso 2: Ver a qué red están conectados Jenkins y GitLab**

```bash
# Ver redes de Jenkins
docker inspect jenkins --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'

# Ver redes de GitLab
docker inspect gitlab --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'
```

**Resultado típico (ANTES de migración):**
```
bridge     ← Solo conectados a red por defecto
```

---

## 🚀 Solución 1: Reconectar SIN perder datos (RECOMENDADO) ✅

Esta opción **NO requiere detener contenedores** ni perder configuración.

### **Paso 1: Crear red `devops-net`**

```bash
# Crear red bridge
docker network create devops-net

# Verificar creación
docker network ls | grep devops-net
```

**Resultado esperado:**
```
xxxxx    devops-net    bridge    local
```

---

### **Paso 2: Conectar Jenkins a `devops-net`**

```bash
# Conectar Jenkins (sin detenerlo)
docker network connect devops-net jenkins

# Verificar
docker inspect jenkins --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'
```

**Resultado esperado:**
```
bridge devops-net     ← Ahora está en AMBAS redes
```

---

### **Paso 3: Conectar GitLab a `devops-net`**

```bash
# Conectar GitLab (sin detenerlo)
docker network connect devops-net gitlab

# Verificar
docker inspect gitlab --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'
```

**Resultado esperado:**
```
bridge devops-net     ← Ahora está en AMBAS redes
```

---

### **Paso 4: Verificar conectividad**

#### **A. Ver contenedores en la red**

```bash
docker network inspect devops-net
```

**Resultado esperado (sección Containers):**
```json
"Containers": {
    "jenkins": {
        "Name": "jenkins",
        "IPv4Address": "172.18.0.2/16",
        ...
    },
    "gitlab": {
        "Name": "gitlab",
        "IPv4Address": "172.18.0.3/16",
        ...
    }
}
```

#### **B. Probar conectividad Jenkins → GitLab**

⚠️ **Nota:** La imagen oficial de Jenkins **no incluye** `ping`, `nslookup`, ni `nc` por defecto. Usa métodos alternativos:

**Método 1: Usar `curl` (RECOMENDADO)** ✅

```bash
# Probar conectividad HTTP a GitLab
docker exec jenkins curl -I http://gitlab:80
```

**Resultado esperado:**
```
HTTP/1.1 302 Found
Server: nginx
Location: http://gitlab/users/sign_in
...
```

✅ Si ves el header HTTP, **la conectividad funciona correctamente**.

**Método 2: Usar `wget`** ✅

```bash
# Probar conectividad con wget
docker exec jenkins wget --spider -q http://gitlab:80 && echo "✅ GitLab accessible from Jenkins"
```

**Método 3: Probar con `bash` (si está disponible)**

```bash
# Forzar uso de bash para /dev/tcp
docker exec jenkins bash -c 'exec 3<>/dev/tcp/gitlab/22 && echo "✅ SSH port accessible"'
```

**Método 4: Instalar herramientas temporalmente** (opcional)

```bash
# Instalar netcat (temporal, se pierde al reiniciar)
docker exec -u root jenkins apt-get update
docker exec -u root jenkins apt-get install -y netcat-openbsd
docker exec jenkins nc -zv gitlab 22
```

✅ Si cualquiera de estos métodos funciona, **la conexión es correcta**.

#### **C. Probar conectividad GitLab → Jenkins**

```bash
# Ping desde GitLab a Jenkins (GitLab SÍ tiene ping)
docker exec gitlab ping -c 3 jenkins
```

**Resultado esperado:**
```
PING jenkins (172.18.0.2): 56 data bytes
64 bytes from 172.18.0.2: seq=0 ttl=64 time=1.420 ms
64 bytes from 172.18.0.2: seq=1 ttl=64 time=0.103 ms
64 bytes from 172.18.0.2: seq=2 ttl=64 time=0.217 ms

--- jenkins ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
```

✅ Si el ping funciona, la red está correctamente configurada.

---

### **Paso 5: Probar resolución DNS**

⚠️ **Nota:** Jenkins no incluye `nslookup` ni herramientas de DNS. La mejor forma es probar desde GitLab:

**Método 1: Verificar DNS desde GitLab (RECOMENDADO)** ✅

```bash
# Verificar que GitLab puede resolver "jenkins"
docker exec gitlab nslookup jenkins
```

**Resultado esperado:**
```
Server:    127.0.0.11
Address:   127.0.0.11:53

Non-authoritative answer:
Name:   jenkins
Address: 172.18.0.2
```

**Método 2: Verificar conectividad HTTP desde Jenkins** ✅

```bash
# Si Jenkins puede conectarse usando el nombre "gitlab", el DNS funciona
docker exec jenkins curl -I http://gitlab:80
```

Si `curl` puede conectarse usando el nombre `gitlab` (no una IP), significa que DNS está funcionando.

✅ Si cualquiera funciona, Docker DNS está resolviendo correctamente los nombres.

---

### **Paso 6: (Opcional) Desconectar de la red `bridge`**

Si quieres dejar los contenedores **solo** en `devops-net`:

```bash
# Desconectar Jenkins de bridge
docker network disconnect bridge jenkins

# Desconectar GitLab de bridge
docker network disconnect bridge gitlab

# Verificar que solo están en devops-net
docker inspect jenkins --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'
docker inspect gitlab --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'
```

**Resultado esperado:**
```
devops-net     ← Solo en esta red
```

⚠️ **Importante:** Si desconectas de `bridge`, asegúrate de que los puertos mapeados (`-p`) siguen funcionando. Generalmente no hay problema, pero verifica que puedes acceder a:
- Jenkins: http://localhost:8080
- GitLab: http://localhost:8929

---

## 🚀 Solución 2: Recrear contenedores (limpio desde cero)

Si prefieres empezar completamente limpio con la configuración correcta:

### **⚠️ ADVERTENCIA:**
- ✅ **Datos persistentes:** Jenkins y GitLab **NO perderán datos** (están en volúmenes)
- ❌ **Contenedores:** Se eliminarán y recrearán
- ⏱️ **Tiempo:** GitLab tardará ~5 minutos en reinicializar

---

### **Paso 1: Detener y eliminar contenedores**

```bash
# Detener contenedores
docker stop jenkins gitlab

# Eliminar contenedores (NO elimina volúmenes)
docker rm jenkins gitlab

# Verificar que se eliminaron
docker ps -a | grep -E "jenkins|gitlab"
```

**Resultado esperado:** No debe aparecer nada.

---

### **Paso 2: Crear red `devops-net`**

```bash
# Crear red bridge
docker network create devops-net

# Verificar
docker network ls | grep devops-net
```

---

### **Paso 3: Recrear Jenkins con `devops-net`**

```bash
docker run -d \
  --name jenkins \
  --network devops-net \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkins/jenkins:lts
```

⏱️ Esperar ~30 segundos y verificar:
```bash
docker logs jenkins --tail 50
```

Buscar: `Jenkins is fully up and running`

---

### **Paso 4: Recrear GitLab con `devops-net`**

```bash
# Definir GITLAB_HOME
export GITLAB_HOME=$HOME/gitlab

# Recrear GitLab
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

⏱️ Esperar ~5 minutos y verificar:
```bash
docker logs gitlab --tail 100 | grep "Reconfigured"
```

---

### **Paso 5: Verificar todo funciona**

```bash
# 1. Contenedores corriendo
docker ps

# 2. En la red correcta
docker network inspect devops-net

# 3. Conectividad
docker exec jenkins ping -c 2 gitlab
docker exec gitlab ping -c 2 jenkins

# 4. Servicios accesibles
curl -I http://localhost:8080  # Jenkins
curl -I http://localhost:8929  # GitLab
```

---

## ✅ Verificación Final: ¿Cómo saber si funcionó?

### **Checklist completo:**

- [ ] Red `devops-net` existe: `docker network ls | grep devops-net`
- [ ] Jenkins conectado: `docker inspect jenkins | grep devops-net`
- [ ] GitLab conectado: `docker inspect gitlab | grep devops-net`
- [ ] Conectividad Jenkins → GitLab: `docker exec jenkins curl -I http://gitlab:80`
- [ ] Conectividad GitLab → Jenkins: `docker exec gitlab ping -c 2 jenkins`
- [ ] DNS funciona: `docker exec gitlab nslookup jenkins`
- [ ] Jenkins accesible: http://localhost:8080
- [ ] GitLab accesible: http://localhost:8929
- [ ] SSH GitLab accesible: `ssh -T git@localhost -p 2222`

---

## 🐛 Troubleshooting

### **❌ Error: "network devops-net already exists"**

```bash
# Ver contenedores en esa red
docker network inspect devops-net

# Si está vacía o tiene contenedores obsoletos, eliminar y recrear
docker network rm devops-net
docker network create devops-net
```

---

### **❌ Error: "cannot connect container to multiple networks"**

Esto **NO debería pasar**. Docker permite múltiples redes por contenedor. Si ocurre:

```bash
# Ver estado del contenedor
docker inspect jenkins

# Reiniciar Docker daemon (Windows)
# Docker Desktop → Restart
```

---

### **❌ Error: Jenkins no puede clonar de GitLab**

**Causa:** Configuración SSH o credenciales en Jenkins.

**Solución: Verificar conectividad paso a paso**

```bash
# 1. Verificar que GitLab está corriendo
docker ps | grep gitlab

# 2. Verificar conectividad HTTP (confirma DNS + red)
docker exec jenkins curl -I http://gitlab:80

# 3. Verificar desde GitLab hacia Jenkins (confirma red bidireccional)
docker exec gitlab ping -c 2 jenkins

# 4. Verificar que ambos están en devops-net
docker network inspect devops-net | grep -E "jenkins|gitlab"
```

Si todas las verificaciones pasan pero el clone SSH falla, el problema es de **configuración SSH**, no de red:

1. ✅ Verificar claves SSH en Jenkins (ver **Tarea 3: Integración**)
2. ✅ Verificar que la URL en Jenkins es `ssh://git@gitlab:22/...` (NO `localhost:2222`)
3. ✅ Verificar credenciales SSH en Jenkins UI

---

### **❌ Ping funciona pero URL `localhost:2222` tampoco funciona**

Esto es **normal** y es **exactamente por qué necesitas `devops-net`**.

**Explicación:**
- ✅ `gitlab:22` → Funciona (DNS interno de Docker en devops-net)
- ❌ `localhost:2222` → NO funciona (dentro de contenedor, `localhost` = el propio contenedor)
- ✅ `localhost:2222` → Funciona desde tu máquina (puerto mapeado en host)

**Solución:** Usa `gitlab:22` en configuraciones de Jenkins (Repository URL).

---

## 📊 Comparación: Antes vs Después

| Aspecto | ANTES (sin devops-net) | DESPUÉS (con devops-net) |
|---------|------------------------|--------------------------|
| **Red Jenkins** | `bridge` (default) | `devops-net` |
| **Red GitLab** | `bridge` (default) | `devops-net` |
| **Comunicación** | ❌ Solo via puertos mapeados en host | ✅ DNS interno (`gitlab:22`) |
| **URL en pipelines** | ❌ `localhost:2222` (no funciona) | ✅ `ssh://git@gitlab:22` |
| **Resolución DNS** | ❌ No funciona entre contenedores | ✅ Automática por Docker |
| **Acceso desde host** | ✅ `localhost:8080`, `localhost:8929` | ✅ `localhost:8080`, `localhost:8929` |

---

## 🎯 Próximos Pasos

Una vez migrados Jenkins y GitLab a `devops-net`:

1. ✅ **Tarea 3:** Configurar integración GitLab-Jenkins (usar `ssh://git@gitlab:22`)
2. ✅ **Tarea 4:** Clonar proyectos PetClinic
3. ✅ **Tarea 5:** Crear pipeline Angular (usará `--network devops-net`)
4. ✅ **Tarea 6:** Crear pipeline Maven (usará `--network devops-net`)

---

## 📝 Comandos útiles de referencia

```bash
# Ver todas las redes
docker network ls

# Ver contenedores en una red específica
docker network inspect devops-net

# Ver a qué redes está conectado un contenedor
docker inspect jenkins --format='{{range $net,$v := .NetworkSettings.Networks}}{{$net}} {{end}}'

# Conectar contenedor a red (sin detenerlo)
docker network connect devops-net <contenedor>

# Desconectar contenedor de red (sin detenerlo)
docker network disconnect bridge <contenedor>

# Probar conectividad desde Jenkins (métodos que SÍ funcionan)
docker exec jenkins curl -I http://gitlab:80
docker exec jenkins wget --spider -q http://gitlab:80 && echo "OK"

# Probar conectividad desde GitLab (tiene todas las herramientas)
docker exec gitlab ping -c 3 jenkins
docker exec gitlab nslookup jenkins
docker exec gitlab nc -zv jenkins 8080

# Ver logs
docker logs jenkins --tail 50
docker logs gitlab --tail 100

# Verificar ambos están en la misma red
docker network inspect devops-net | grep -E "jenkins|gitlab"
```

---

## ✨ Resumen

| Método | Pros | Contras | Recomendado para |
|--------|------|---------|------------------|
| **Solución 1: Reconectar** | ✅ No pierde datos<br>✅ No requiere reiniciar<br>✅ Rápido (30 seg) | ⚠️ Contenedores en 2 redes | ✅ Producción<br>✅ Datos importantes |
| **Solución 2: Recrear** | ✅ Configuración limpia<br>✅ Solo 1 red | ❌ Requiere reiniciar<br>⏱️ GitLab tarda ~5 min | ✅ Desarrollo<br>✅ Aprendizaje |

**Recomendación:** Usar **Solución 1** (reconectar). Es más rápida, segura y no interrumpe servicios.

---

🎉 **¡Listo!** Ahora Jenkins y GitLab pueden comunicarse correctamente via `devops-net`.
