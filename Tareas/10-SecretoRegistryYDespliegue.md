# Tarea 10: Crear Secreto para Docker Registry y Desplegar Pod desde Registry Local

## 📋 Índice

1. [Objetivo](#objetivo)
2. [Prerrequisitos](#prerrequisitos)
3. [Arquitectura](#arquitectura)
4. [Paso 1: Verificación de Infraestructura](#paso-1-verificación-de-infraestructura)
5. [Paso 2: Configuración de Minikube](#paso-2-configuración-de-minikube)
6. [Paso 3: Configuración de Kubernetes](#paso-3-configuración-de-kubernetes)
7. [Paso 4: Creación del Secreto](#paso-4-creación-del-secreto)
8. [Paso 5: Despliegue del Pod](#paso-5-despliegue-del-pod)
9. [Verificación Final](#verificación-final)
10. [Troubleshooting](#troubleshooting)
11. [Resumen](#resumen)

---

## 🎯 Objetivo

Crear un **secreto de Docker Registry** en Kubernetes para permitir que los pods descarguen imágenes desde un **registry local privado** y desplegar un pod de prueba que utilice una imagen almacenada en ese registry.

### Resultados esperados:
- ✅ Secret de tipo `docker-registry` creado en Kubernetes
- ✅ Pod desplegado correctamente usando imagen del registry local
- ✅ Verificación de logs del contenedor

---

## 📦 Prerrequisitos

### Infraestructura requerida:

1. **Docker Registry local** (del Tarea 8):
   - Contenedor: `registry`
   - Puerto: `5000`
   - Red: `devops-net`
   - Imagen de prueba: `hello-world`

2. **Minikube** (de Tarea 9):
   - Driver: Docker
   - CPUs: 2
   - Memoria: 4096 MB

3. **Jenkins** (de Tarea 7):
   - Contenedor: `jenkins`
   - Puerto: 8080
   - Red: `devops-net` y `minikube`

### Verificación de prerrequisitos:

```bash
# Verificar Registry
docker ps --filter "name=registry" --format "{{.Names}} - {{.Status}}"

# Verificar imágenes en registry
curl http://localhost:5000/v2/_catalog

# Verificar Minikube
minikube status

# Verificar Jenkins
docker ps --filter "name=jenkins" --format "{{.Names}} - {{.Status}}"
```

---

## 🏗️ Arquitectura

```
┌─────────────────────────────────────────────────────────────┐
│                         Host (WSL)                          │
│                                                             │
│  ┌─────────────────┐         ┌─────────────────┐          │
│  │   Registry      │         │   Jenkins       │          │
│  │  localhost:5000 │         │  localhost:8080 │          │
│  │  172.18.0.2     │◄────────│  172.18.0.4     │          │
│  └────────┬────────┘         └────────┬────────┘          │
│           │                           │                     │
│           │    devops-net             │                     │
│           └───────────────────────────┘                     │
│                                       │                     │
│                            minikube network                 │
│                                       │                     │
│  ┌────────────────────────────────────▼──────────────────┐ │
│  │              Minikube Container                       │ │
│  │         192.168.49.2 (internal IP)                    │ │
│  │                                                       │ │
│  │  ┌──────────────────────────────────────────────┐   │ │
│  │  │         Kubernetes Cluster                    │   │ │
│  │  │                                               │   │ │
│  │  │  Namespace: jenkins                           │   │ │
│  │  │  ┌─────────────────────────────────────────┐ │   │ │
│  │  │  │  Secret: registry-secret                │ │   │ │
│  │  │  │  Type: docker-registry                  │ │   │ │
│  │  │  │  Server: host.docker.internal:5000      │ │   │ │
│  │  │  └─────────────────────────────────────────┘ │   │ │
│  │  │                                               │   │ │
│  │  │  ┌─────────────────────────────────────────┐ │   │ │
│  │  │  │  Pod: hello-from-registry               │ │   │ │
│  │  │  │  Image: host.docker.internal:5000/      │ │   │ │
│  │  │  │         hello-world:latest              │ │   │ │
│  │  │  │  imagePullSecrets: registry-secret      │ │   │ │
│  │  │  └─────────────────────────────────────────┘ │   │ │
│  │  └──────────────────────────────────────────────┘   │ │
│  └──────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘

Flujo de descarga de imagen:
1. Kubernetes lee el Secret registry-secret
2. Kubelet intenta descargar imagen desde host.docker.internal:5000
3. host.docker.internal resuelve al host de Docker (192.168.65.254)
4. La solicitud llega al Registry (localhost:5000)
5. Registry devuelve la imagen hello-world
6. Kubelet crea y arranca el contenedor
```

**Puntos clave:**
- `host.docker.internal`: Hostname especial que resuelve al host de Docker desde dentro de contenedores
- Minikube debe tener `--insecure-registry="host.docker.internal:5000"` configurado
- El secret permite autenticación (aunque el registry no tiene auth real)

---

## 🔍 Paso 1: Verificación de Infraestructura

### 1.1 Verificar Registry

```bash
# Ver estado del contenedor
docker ps --filter "name=registry" --format "{{.Names}} - {{.Status}}"
```

**Salida esperada:**
```
registry - Up X hours
```

### 1.2 Verificar imágenes en Registry

```bash
# Listar repositorios
curl http://localhost:5000/v2/_catalog
```

**Salida esperada:**
```json
{"repositories":["hello-world"]}
```

### 1.3 Verificar Minikube

```bash
minikube status
```

**Salida esperada:**
```
minikube
type: Control Plane
host: Running
kubelet: Running
apiserver: Running
kubeconfig: Configured
```

### 1.4 Verificar IP del Registry en devops-net

```bash
docker network inspect devops-net --format='{{range .Containers}}{{.Name}}: {{.IPv4Address}}{{"\n"}}{{end}}'
```

**Salida esperada:**
```
registry: 172.18.0.2/16
jenkins: 172.18.0.4/16
gitlab: 172.18.0.3/16
```

---

## ⚙️ Paso 2: Configuración de Minikube

### 2.1 Problema: Registry Inseguro (HTTP vs HTTPS)

Kubernetes por defecto intenta conectar a registries usando **HTTPS**. Como nuestro registry usa **HTTP**, obtendremos el error:

```
Error: http: server gave HTTP response to HTTPS client
```

**Solución:** Configurar Minikube para aceptar el registry como "insecure".

### 2.2 Eliminar Minikube actual (si existe)

```bash
minikube delete
```

**Salida:**
```
🔥  Deleting "minikube" in docker ...
🔥  Deleting container "minikube" ...
🔥  Removing /home/USER/.minikube/machines/minikube ...
💀  Removed all traces of the "minikube" cluster.
```

### 2.3 Iniciar Minikube con configuración correcta

```bash
minikube start --driver=docker --cpus=2 --memory=4096 \
  --insecure-registry="host.docker.internal:5000"
```

**Parámetros:**
- `--driver=docker`: Usar Docker como driver
- `--cpus=2`: 2 CPUs para el cluster
- `--memory=4096`: 4GB de RAM
- `--insecure-registry="host.docker.internal:5000"`: **CRÍTICO** - Permite conexiones HTTP al registry

**Salida esperada:**
```
😄  minikube v1.37.0 on Ubuntu 24.04 (kvm/amd64)
✨  Using the docker driver based on user configuration
📌  Using Docker driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.48 ...
🔥  Creating docker container (CPUs=2, Memory=4096MB) ...
🐳  Preparing Kubernetes v1.34.0 on Docker 28.4.0 ...
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Verifying Kubernetes components...
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

### 2.4 Verificar que Minikube puede acceder al Registry

```bash
docker exec minikube curl http://host.docker.internal:5000/v2/_catalog
```

**Salida esperada:**
```json
{"repositories":["hello-world"]}
```

✅ **Si ves esta salida, la conectividad es correcta**

---

## ☸️ Paso 3: Configuración de Kubernetes

### 3.1 Verificar cluster

```bash
kubectl get nodes
```

**Salida esperada:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   2m    v1.34.0
```

### 3.2 Crear namespace jenkins

```bash
kubectl create namespace jenkins
```

**Salida:**
```
namespace/jenkins created
```

### 3.3 Crear Service Account

```bash
kubectl create serviceaccount jenkins -n jenkins
```

**Salida:**
```
serviceaccount/jenkins created
```

### 3.4 Dar permisos de administrador al Service Account

```bash
kubectl create rolebinding jenkins-admin-binding \
  --clusterrole=admin \
  --serviceaccount=jenkins:jenkins \
  --namespace=jenkins
```

**Salida:**
```
rolebinding.rbac.authorization.k8s.io/jenkins-admin-binding created
```

### 3.5 Verificar Service Account

```bash
kubectl get serviceaccount jenkins -n jenkins
```

**Salida:**
```
NAME      SECRETS   AGE
jenkins   0         10s
```

### 3.6 Configurar kubeconfig para Jenkins

Necesitamos un kubeconfig que use la IP de Minikube (no localhost) para que Jenkins pueda acceder.

#### 3.6.1 Crear cluster específico para Jenkins

```bash
kubectl config set-cluster minikube-jenkins \
  --server=https://192.168.49.2:8443 \
  --insecure-skip-tls-verify=true
```

#### 3.6.2 Crear contexto

```bash
kubectl config set-context minikube-jenkins \
  --cluster=minikube-jenkins \
  --user=minikube
```

#### 3.6.3 Exportar kubeconfig

```bash
kubectl config view --flatten > /tmp/kubeconfig-jenkins
```

#### 3.6.4 Cambiar contexto por defecto

```bash
sed -i 's/current-context: minikube/current-context: minikube-jenkins/' /tmp/kubeconfig-jenkins
```

#### 3.6.5 Copiar a Jenkins

```bash
docker cp /tmp/kubeconfig-jenkins jenkins:/var/jenkins_home/kubeconfig
```

**Salida:**
```
Successfully copied 8.19kB to jenkins:/var/jenkins_home/kubeconfig
```

### 3.7 Conectar Jenkins a la red de Minikube

```bash
docker network connect minikube jenkins
```

**Nota:** Si recibes `Error: endpoint with name jenkins already exists`, significa que ya está conectado. ✅

### 3.8 Verificar conectividad desde Jenkins

```bash
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
```

**Salida esperada:**
```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   5m    v1.34.0
```

✅ **Si ves esta salida, Jenkins puede comunicarse con Kubernetes**

---

## 🔐 Paso 4: Creación del Secreto

### 4.1 ¿Qué es un Secret de tipo docker-registry?

Un **Secret de tipo `docker-registry`** en Kubernetes almacena credenciales para autenticarse contra un registry de Docker. Aunque nuestro registry local **no tiene autenticación real**, Kubernetes igualmente requiere el secret para el flujo de `imagePullSecrets`.

### 4.2 Crear el Secret

```bash
kubectl create secret docker-registry registry-secret \
  --docker-server=host.docker.internal:5000 \
  --docker-username=dummy \
  --docker-password=dummy \
  --docker-email=dummy@example.com \
  --namespace=jenkins
```

**Parámetros:**
- `registry-secret`: Nombre del secret
- `--docker-server=host.docker.internal:5000`: **IMPORTANTE** - Debe coincidir con la imagen del pod
- `--docker-username=dummy`: Usuario dummy (el registry no tiene auth)
- `--docker-password=dummy`: Contraseña dummy
- `--docker-email=dummy@example.com`: Email dummy
- `--namespace=jenkins`: Namespace donde se crea el secret

**Salida:**
```
secret/registry-secret created
```

### 4.3 Verificar el Secret

```bash
kubectl get secret registry-secret -n jenkins
```

**Salida:**
```
NAME              TYPE                             DATA   AGE
registry-secret   kubernetes.io/dockerconfigjson   1      5s
```

### 4.4 Ver detalles del Secret (opcional)

```bash
kubectl describe secret registry-secret -n jenkins
```

**Salida:**
```
Name:         registry-secret
Namespace:    jenkins
Labels:       <none>
Annotations:  <none>

Type:  kubernetes.io/dockerconfigjson

Data
====
.dockerconfigjson:  XXX bytes
```

### 4.5 Decodificar el Secret (opcional)

```bash
kubectl get secret registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d | jq
```

**Salida:**
```json
{
  "auths": {
    "host.docker.internal:5000": {
      "username": "dummy",
      "password": "dummy",
      "email": "dummy@example.com",
      "auth": "ZHVtbXk6ZHVtbXk="
    }
  }
}
```

---

## 🚀 Paso 5: Despliegue del Pod

### 5.1 Crear el archivo YAML del Pod

Crea un archivo llamado `pod-from-registry.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hello-from-registry
  namespace: jenkins
spec:
  containers:
  - name: hello
    image: host.docker.internal:5000/hello-world:latest
    imagePullPolicy: Always
  imagePullSecrets:
  - name: registry-secret
  restartPolicy: Never
```

**Explicación:**
- `image: host.docker.internal:5000/hello-world:latest`: Imagen desde el registry local
- `imagePullPolicy: Always`: Fuerza la descarga (útil para desarrollo)
- `imagePullSecrets`: Referencia al secret creado
- `restartPolicy: Never`: El pod no se reinicia (ideal para jobs one-shot como hello-world)

### 5.2 Aplicar el Pod

```bash
kubectl apply -f pod-from-registry.yaml
```

**Salida:**
```
pod/hello-from-registry created
```

### 5.3 Ver el estado del Pod

```bash
kubectl get pods -n jenkins
```

**Progresión esperada:**

```
# Primero: ContainerCreating
NAME                  READY   STATUS              RESTARTS   AGE
hello-from-registry   0/1     ContainerCreating   0          3s

# Después: Completed (porque hello-world ejecuta y termina)
NAME                  READY   STATUS      RESTARTS   AGE
hello-from-registry   0/1     Completed   0          15s
```

✅ **Estado `Completed` significa éxito**

### 5.4 Ver los eventos del Pod

```bash
kubectl describe pod hello-from-registry -n jenkins
```

**Eventos exitosos:**
```
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  20s   default-scheduler  Successfully assigned jenkins/hello-from-registry to minikube
  Normal  Pulling    20s   kubelet            Pulling image "host.docker.internal:5000/hello-world:latest"
  Normal  Pulled     18s   kubelet            Successfully pulled image "host.docker.internal:5000/hello-world:latest" in 2.1s
  Normal  Created    18s   kubelet            Created container hello
  Normal  Started    18s   kubelet            Started container hello
```

**Puntos clave:**
- ✅ `Pulling image`: Kubernetes está descargando desde el registry
- ✅ `Successfully pulled`: La imagen se descargó correctamente
- ✅ `Created container`: El contenedor se creó
- ✅ `Started container`: El contenedor arrancó

---

## ✅ Verificación Final

### 6.1 Ver los logs del Pod

```bash
kubectl logs hello-from-registry -n jenkins
```

**Salida esperada:**
```
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

✅ **Esta salida confirma que:**
1. La imagen se descargó desde tu registry local
2. El secret funcionó correctamente
3. El pod arrancó y ejecutó
4. Todo el flujo de autenticación y despliegue funciona

### 6.2 Verificar desde Jenkins

```bash
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get pods -n jenkins
```

**Salida:**
```
NAME                  READY   STATUS      RESTARTS   AGE
hello-from-registry   0/1     Completed   0          2m
```

### 6.3 Verificar logs desde Jenkins

```bash
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig logs hello-from-registry -n jenkins
```

Debería mostrar el mismo output de "Hello from Docker!".

---

## 🐛 Troubleshooting

### Problema 1: "ImagePullBackOff" - HTTP vs HTTPS

**Síntoma:**
```
Failed to pull image: Error response from daemon: Get "https://host.docker.internal:5000/v2/": 
http: server gave HTTP response to HTTPS client
```

**Causa:** Minikube no tiene configurado el registry como insecure.

**Solución:**
```bash
# Reiniciar Minikube con insecure-registry
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096 \
  --insecure-registry="host.docker.internal:5000"
```

---

### Problema 2: "ErrImagePull" - No puede resolver host

**Síntoma:**
```
Failed to pull image: Error response from daemon: Get "http://host.docker.internal:5000/v2/": 
dial tcp: lookup host.docker.internal: no such host
```

**Causa:** El hostname `host.docker.internal` no está disponible.

**Diagnóstico:**
```bash
docker exec minikube nslookup host.docker.internal
```

**Solución:** Usar IP del gateway de Docker:
```bash
# Ver gateway de minikube
docker network inspect minikube | grep Gateway
# Salida: "Gateway": "192.168.49.1"

# Actualizar YAML para usar IP del gateway
image: 192.168.49.1:5000/hello-world:latest

# Actualizar secret
kubectl delete secret registry-secret -n jenkins
kubectl create secret docker-registry registry-secret \
  --docker-server=192.168.49.1:5000 \
  --docker-username=dummy \
  --docker-password=dummy \
  --docker-email=dummy@example.com \
  --namespace=jenkins
```

---

### Problema 3: Secret no funciona

**Síntoma:**
```
Failed to pull image: Error response from daemon: unauthorized
```

**Diagnóstico:**
```bash
# Verificar que el secret existe
kubectl get secret registry-secret -n jenkins

# Verificar el servidor en el secret
kubectl get secret registry-secret -n jenkins -o jsonpath='{.data.\.dockerconfigjson}' | base64 -d

# Verificar que el pod referencia el secret
kubectl get pod hello-from-registry -n jenkins -o yaml | grep -A 2 imagePullSecrets
```

**Solución:**
1. El `--docker-server` en el secret debe coincidir exactamente con el registry en la imagen
2. El secret debe estar en el mismo namespace que el pod
3. El pod debe referenciar el secret en `imagePullSecrets`

---

### Problema 4: "Completed" pero no veo logs

**Síntoma:**
El pod está en estado `Completed` pero `kubectl logs` no muestra nada.

**Diagnóstico:**
```bash
kubectl describe pod hello-from-registry -n jenkins
```

**Posibles causas:**
1. El contenedor terminó antes de escribir logs
2. La imagen no tiene un comando que produzca output

**Solución:**
Verificar los eventos en `kubectl describe` para confirmar que el contenedor arrancó correctamente.

---

### Problema 5: Timeout al descargar imagen

**Síntoma:**
```
Failed to pull image: Error response from daemon: Get "http://host.docker.internal:5000/v2/": 
context deadline exceeded
```

**Diagnóstico:**
```bash
# Verificar que el registry está corriendo
docker ps --filter "name=registry"

# Verificar conectividad desde Minikube
docker exec minikube curl http://host.docker.internal:5000/v2/_catalog
```

**Soluciones:**

1. **Registry no está corriendo:**
```bash
docker start registry
```

2. **Registry no es accesible desde Minikube:**
```bash
# Verificar puerto forwarding
docker port registry

# Verificar que está en puerto 5000
curl http://localhost:5000/v2/_catalog
```

3. **Problema de red Docker:**
```bash
# Reiniciar Docker Desktop
# O reiniciar servicio Docker en Linux
sudo systemctl restart docker
```

---

### Problema 6: Múltiples IPs en Minikube

**Síntoma:**
```
E1001 18:29:38.798930 status.go:458] kubeconfig endpoint: got: 192.168.49.2:8443, want: 127.0.0.1:63369
failed to get driver ip: getting IP: container addresses should have 2 values, got 3 values
```

**Causa:** Minikube está conectado a múltiples redes Docker.

**Diagnóstico:**
```bash
docker inspect minikube --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}: {{.IPAddress}} {{end}}'
```

**Solución:**
```bash
# Desconectar de redes extra
docker network disconnect devops-net minikube

# Si persiste, recrear Minikube
minikube delete
minikube start --driver=docker --cpus=2 --memory=4096 \
  --insecure-registry="host.docker.internal:5000"
```

---

## 📝 Resumen

### ✅ Lo que logramos:

1. **Configuración de Minikube** con soporte para registry inseguro HTTP
2. **Creación de Secret** de tipo `docker-registry` en Kubernetes
3. **Despliegue exitoso** de un pod usando imagen del registry local
4. **Verificación completa** del flujo end-to-end

### 🔑 Conceptos clave aprendidos:

- **Secretos de Docker Registry:** Permiten a Kubernetes autenticarse contra registries privados
- **imagePullSecrets:** Mecanismo para asociar secrets con pods
- **Insecure Registries:** Configuración necesaria para registries HTTP (sin TLS)
- **host.docker.internal:** Hostname especial para acceder al host desde contenedores
- **Kubeconfig para Jenkins:** Configuración específica para acceso remoto a Kubernetes

### 📊 Arquitectura final:

```
Registry (localhost:5000)
    ↓ HTTP
host.docker.internal
    ↓
Minikube (con --insecure-registry)
    ↓
Kubernetes
    ↓ usa secret
Pod (hello-from-registry)
    ↓ descarga imagen
Registry ✅
```




---

**Fecha de creación:** 1 de octubre de 2025  
**Tarea anterior:** [9-IntegracionMinikubeJenkins.md](9-IntegracionMinikubeJenkins.md)  
**Siguiente tarea:** Pipeline CI/CD completo con Registry y Kubernetes
