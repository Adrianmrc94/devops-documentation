# 🎬 Comandos para Demostración Rápida

## 📋 **Guía Rápida de Demostración**

Esta es tu **chuleta** para demostrar todo el entorno funcionando en 5 minutos.

---

## 🚀 **Paso 1: Verificar que Todo Está Levantado (30 segundos)**

```bash
# Ver estado de todos los contenedores
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Deberías ver:**
- ✅ `jenkins` → Up (8080)
- ✅ `gitlab` → Up (8929)
- ✅ `registry` → Up (5000)
- ✅ `minikube` → Up

---

## ☸️ **Paso 2: Verificar Kubernetes (1 minuto)**

```bash
# Estado del contenedor Minikube
docker ps --filter "name=minikube" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Ver nodos del cluster (desde Jenkins)
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes

# Ver todos los pods en namespace jenkins
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get pods -n jenkins

# Ver todos los namespaces
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get namespaces

# Ver recursos en namespace jenkins
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get all -n jenkins
```

**Deberías ver:**
- ✅ Contenedor Minikube: Up (19 minutes)
- ✅ Node minikube: Ready, control-plane
- ✅ Namespace jenkins: Active
- ✅ Pod hello-from-registry: Completed

---

## 🔗 **Paso 3: Verificar Integración Jenkins → Kubernetes (30 segundos)**

```bash
# Jenkins puede ver el cluster
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes

# Ver recursos en namespace jenkins
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get all -n jenkins
```

**Deberías ver:**
- ✅ Jenkins puede ejecutar kubectl
- ✅ Ve el nodo minikube

---

## 🐳 **Paso 4: Verificar Docker Registry (30 segundos)**

```bash
# Ver imágenes en el registry local
curl http://localhost:5000/v2/_catalog

# Desde Minikube
minikube ssh "curl http://registry:5000/v2/_catalog"
```

**Deberías ver:**
```json
{"repositories":["hello-world"]}
```

---

## 🌐 **Paso 5: Verificar Redes Docker (30 segundos)**

```bash
# Ver redes
docker network ls

# Ver qué contenedores están en cada red
docker network inspect devops-net --format='{{range .Containers}}{{.Name}} {{end}}'
docker network inspect minikube --format='{{range .Containers}}{{.Name}} {{end}}'
```

**Deberías ver:**
- ✅ Red `devops-net`: jenkins, gitlab, registry, minikube
- ✅ Red `minikube`: minikube, jenkins

---

## 🎯 **Paso 6: Demo Completa - Desplegar Pod en Kubernetes (2 minutos)**

### **Opción A: Desde línea de comandos**

```bash
# Crear pod de prueba desde Jenkins
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig run nginx-demo --image=nginx:alpine --port=80 -n jenkins

# Ver el pod
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get pods -n jenkins

# Esperar a que esté listo
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig wait --for=condition=Ready pod/nginx-demo -n jenkins --timeout=60s

# Ver logs
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig logs nginx-demo -n jenkins

# Eliminar (limpieza)
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig delete pod nginx-demo -n jenkins
```

### **Opción B: Ejecutar Pipeline en Jenkins (más impresionante)**

1. Abrir navegador: **http://localhost:8080**
2. Ejecutar job: **`deploy-to-kubernetes`**
3. Ver Console Output en tiempo real
4. Verificar pod creado:

```bash
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get pods -n jenkins
```

---

## 📊 **Comandos Extra - Información Detallada**

### **Ver estado completo del cluster**

```bash
# Info del cluster
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig cluster-info

# Recursos del nodo
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig describe node minikube

# Eventos recientes
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get events -n jenkins --sort-by='.lastTimestamp'
```

### **Ver configuración de Minikube**

```bash
# Estado del contenedor
docker inspect minikube --format='{{.Name}}: {{.State.Status}}'

# IPs de Minikube (múltiples redes)
docker inspect minikube --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'

# Acceder a Minikube por SSH
minikube ssh
```

### **Ver imágenes en todos los contenedores**

```bash
# Imágenes en Docker host
docker images

# Imágenes en Minikube
minikube ssh "docker images"
```

---

## 🎬 **Script de Demostración Completa (copiar y pegar)**

```bash
echo "===== 1. ESTADO DE CONTENEDORES ====="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "===== 2. ESTADO DE KUBERNETES ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig cluster-info
echo ""

echo "===== 3. NAMESPACES Y RECURSOS ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get namespaces
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get all -n jenkins
echo ""

echo "===== 4. INTEGRACIÓN JENKINS → KUBERNETES ====="
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
echo ""

echo "===== 5. DOCKER REGISTRY ====="
curl -s http://localhost:5000/v2/_catalog | jq
echo ""

echo "===== 6. REDES DOCKER ====="
docker network ls | grep -E "devops-net|minikube"
echo ""

echo "✅ TODO FUNCIONANDO CORRECTAMENTE"
```

---

## 🆘 **Comandos de Emergencia**

### **Si algo no responde:**

```bash
# Reiniciar Jenkins
docker restart jenkins

# Reiniciar Minikube
minikube stop && minikube start

# Ver logs de un contenedor
docker logs jenkins --tail 50
docker logs gitlab --tail 50
docker logs registry --tail 50
```

### **Si necesitas levantar todo desde cero:**

```bash
# Levantar contenedores
docker start jenkins gitlab registry

# Levantar Minikube
minikube start

# Reconectar redes
docker network connect devops-net minikube
docker network connect minikube jenkins
```

---

## 📝 **Notas para la Presentación**

### **Puntos clave a mencionar:**

1. **Arquitectura completa:**
   - Jenkins (CI/CD)
   - GitLab (Control de versiones)
   - Docker Registry (Imágenes privadas)
   - Kubernetes/Minikube (Orquestación)

2. **Networking:**
   - Red `devops-net` para comunicación entre servicios
   - Red `minikube` para Jenkins → Kubernetes

3. **Integración:**
   - Jenkins puede ejecutar `kubectl` directamente
   - Minikube puede acceder al registry privado
   - Todo funciona localmente sin internet

4. **Capacidades:**
   - Build automático de imágenes
   - Push a registry privado
   - Deploy automático en Kubernetes
   - Gestión de secretos

---

## 🎯 **Orden Sugerido de Demostración**

1. **Mostrar que todo está levantado** (docker ps)
2. **Mostrar Kubernetes funcionando** (kubectl get nodes)
3. **Mostrar integración Jenkins-K8s** (docker exec jenkins kubectl...)
4. **Mostrar GitLab con código** (localhost:8929)
5. **Abrir Jenkins en navegador** (localhost:8080)
6. **Ejecutar pipeline petclinic-angular o petclinic-maven**
7. **Mostrar que hace checkout desde GitLab** (en logs de Jenkins)
8. **Ver tests ejecutándose** (43 tests Angular / 181 tests Maven)
9. **Verificar SUCCESS** ✅

**Tiempo total:** 7-10 minutos

---

## 🔄 **NUEVO: Verificar Flujo CI/CD GitLab → Jenkins (2 minutos)**

### **Demo del flujo completo:**

```bash
# 1. Ver repositorios en GitLab
echo "Repositorios en GitLab:"
docker exec gitlab gitlab-rails runner "Project.all.each { |p| puts p.path_with_namespace }"

# 2. Ver que Jenkins está configurado para usar GitLab
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "url"
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-maven-ci/config.xml | grep "url"

# 3. Verificar branch configurado (debe ser 'main')
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "BranchSpec" -A 1
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-maven-ci/config.xml | grep "BranchSpec" -A 1

# 4. Verificar que puede clonar desde GitLab
docker exec jenkins bash -c "cd /tmp && \
  rm -rf test-clone && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test-clone && \
  ls test-clone/ && \
  rm -rf test-clone"
```

**Explicar:**
- ✅ Jenkins usa repos de GitLab (no GitHub público)
- ✅ Branch `main` estandarizado
- ✅ Jenkinsfile está en cada repo
- ✅ Pipelines centralizadas con `@Library('jenkinspipelines')`

---

## 🏆 **Puntos Destacados para Mencionar**

### **Logros Técnicos:**

1. **CI/CD Completo:**
   - GitLab como repositorio central
   - Jenkins ejecutando pipelines automáticas
   - Docker Registry privado
   - Kubernetes para orquestación

2. **Pipelines Centralizadas:**
   - Repositorio `jenkinspipelines` con Shared Library
   - Funciones reutilizables (`vars/commonSteps.groovy`)
   - Estandarización de builds

3. **Integración Completa:**
   - Jenkins → GitLab (checkout con SSH)
   - Jenkins → Kubernetes (kubectl funcional)
   - Kubernetes → Registry (pull de imágenes privadas)
   - Todo en red Docker privada

4. **Resultados:**
   - ✅ Pipeline Angular: 43 tests pasando
   - ✅ Pipeline Maven: 181 tests pasando
   - ✅ Ambas en SUCCESS

---

**Creado:** Octubre 2025  
**Actualizado:** 3 de Octubre 2025  
**Propósito:** Demo completa para presentación a mentora
