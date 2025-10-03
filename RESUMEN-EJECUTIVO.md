# 📊 Resumen Ejecutivo - Infraestructura DevOps

**Fecha:** Octubre 2025  
**Objetivo:** Construir un entorno DevOps completo con CI/CD en local

---

## 🎯 Arquitectura Implementada

```
┌─────────────────────────────────────────────────────────────────┐
│                        Host (Windows/WSL)                       │
│                                                                 │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   GitLab     │  │   Jenkins    │  │   Registry   │        │
│  │   :8929      │◄─┤   :8080      │─►│   :5000      │        │
│  │  (SCM)       │  │   (CI/CD)    │  │  (Images)    │        │
│  └──────────────┘  └───────┬──────┘  └──────────────┘        │
│                            │                                    │
│                    devops-net (172.18.0.0/16)                  │
│                            │                                    │
│                            ├─────────────────┐                 │
│                            │                 │                 │
│  ┌─────────────────────────▼─────────────────▼──────────────┐ │
│  │              Minikube (Kubernetes)                        │ │
│  │         192.168.49.2 (cluster IP)                         │ │
│  │                                                            │ │
│  │  Namespace: jenkins                                       │ │
│  │  - Secret: registry-secret (docker-registry)              │ │
│  │  - ServiceAccount: jenkins (admin)                        │ │
│  │  - Pods: hello-from-registry ✅                           │ │
│  └───────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📋 Componentes Implementados

| Componente | Versión/Imagen | Puerto | Función | Estado |
|------------|----------------|--------|---------|--------|
| **GitLab** | `gitlab/gitlab-ce:latest` | 8929 | Control de versiones (SCM) | ✅ Funcionando |
| **Jenkins** | `jenkins/jenkins:lts` | 8080 | Servidor CI/CD + kubectl | ✅ Funcionando |
| **Docker Registry** | `registry:2` | 5000 | Almacén de imágenes privado | ✅ Funcionando |
| **Minikube** | v1.37.0 | - | Kubernetes local (v1.34.0) | ✅ Funcionando |

---

## 🔄 Flujo CI/CD Implementado

### **Fase 1: Desarrollo → GitLab**
```
Developer → git push → GitLab (webhook) → Jenkins
```

### **Fase 2: CI/CD en Jenkins**
```
Jenkins recibe webhook
    ↓
Clona código de GitLab
    ↓
Build (Maven/npm) usando Shared Libraries
    ↓
Tests automatizados
    ↓
Construye imagen Docker
    ↓
Push a Registry local (localhost:5000)
    ↓
Deploy a Kubernetes (Minikube)
```

### **Fase 3: Despliegue en Kubernetes**
```
kubectl (desde Jenkins)
    ↓
Usa Secret registry-secret
    ↓
Pull imagen desde Registry
    ↓
Despliega Pod en namespace jenkins
    ↓
Aplicación corriendo ✅
```

---

## 🎓 Conceptos Clave Aprendidos

### **1. CI/CD (Continuous Integration/Continuous Delivery)**
- **Jenkins:** Servidor de automatización
- **Pipeline:** Código que define el proceso CI/CD (Jenkinsfile)
- **Shared Libraries:** Código reutilizable entre pipelines
- **Webhook:** GitLab notifica a Jenkins automáticamente

### **2. Containerización**
- **Docker:** Plataforma de contenedores
- **Imagen:** Plantilla inmutable de una aplicación
- **Registry:** Almacén de imágenes (como Docker Hub, pero privado)
- **Dockerfile:** Receta para construir una imagen

### **3. Orquestación (Kubernetes)**
- **Cluster:** Conjunto de nodos que ejecutan contenedores
- **Pod:** Unidad mínima desplegable (1+ contenedores)
- **Namespace:** Aislamiento lógico de recursos
- **Secret:** Credenciales cifradas (para acceder al registry)
- **ServiceAccount:** Identidad para pods con permisos RBAC

### **4. Networking**
- **Docker Networks:** Comunicación entre contenedores
- **Insecure Registry:** Registry HTTP sin TLS
- **host.docker.internal:** Hostname especial para acceder al host desde contenedores

---

## 📚 Tareas Completadas

### **Tarea 7: Centralización de Pipelines** 📦
- **Objetivo:** Reutilizar código en Jenkinsfiles
- **Solución:** Jenkins Shared Libraries (`@Library('jenkinspipelines')`)
- **Resultado:** Funciones comunes en `vars/` (setupGitCredentials, cleanWorkspace, etc.)
- **Beneficio:** Reducción de código duplicado en pipelines

### **Tarea 8: Docker Registry Local** 🐳
- **Objetivo:** Almacén privado de imágenes Docker
- **Configuración:** 
  - Registry en puerto 5000
  - Configurado como "insecure" en Docker Desktop
  - Conectado a red `devops-net`
- **Verificación:** `curl http://localhost:5000/v2/_catalog`
- **Resultado:** Imagen `hello-world` almacenada y disponible

### **Tarea 9: Integración Minikube-Jenkins** ☸️
- **Objetivo:** Jenkins desplegando en Kubernetes
- **Retos resueltos:**
  1. Problema de múltiples IPs en Minikube
  2. Certificados autofirmados (insecure-skip-tls-verify)
  3. Conectividad entre redes Docker
  4. Configuración de kubeconfig para Jenkins
- **Configuración final:**
  - Minikube: `--driver=docker --cpus=2 --memory=4096`
  - kubectl instalado en contenedor Jenkins
  - Namespace `jenkins` con ServiceAccount y permisos admin
- **Comandos clave aprendidos:**
  - `minikube start --insecure-registry`
  - `kubectl config set-cluster`
  - `docker network connect`

### **Tarea 10: Secrets y Despliegue desde Registry** 🔐
- **Objetivo:** Kubernetes descargando imágenes del registry privado
- **Conceptos:**
  - **Secret tipo docker-registry:** Credenciales para pull de imágenes
  - **imagePullSecrets:** Referencia al secret en el pod
- **Reto principal:** HTTP vs HTTPS en registry
- **Solución:** 
  ```bash
  minikube start --insecure-registry="host.docker.internal:5000"
  ```
- **Resultado:** Pod `hello-from-registry` ejecutado exitosamente
- **Verificación:** `kubectl logs hello-from-registry` muestra "Hello from Docker!"

---

## 🔑 Comandos Esenciales Usados

### **Docker**
```bash
docker ps                          # Ver contenedores corriendo
docker network ls                  # Ver redes
docker network connect NET CONT    # Conectar contenedor a red
docker exec CONT COMMAND           # Ejecutar comando en contenedor
curl http://localhost:5000/v2/_catalog  # Verificar registry
```

### **Minikube/Kubernetes**
```bash
minikube start --insecure-registry="host.docker.internal:5000"
minikube status                    # Ver estado
kubectl get nodes                  # Ver nodos del cluster
kubectl create namespace jenkins   # Crear namespace
kubectl create secret docker-registry registry-secret ...
kubectl apply -f pod.yaml          # Desplegar pod
kubectl get pods -n jenkins        # Ver pods
kubectl logs POD_NAME -n jenkins   # Ver logs
kubectl describe pod POD_NAME      # Ver detalles y eventos
```

### **Jenkins**
```bash
docker exec jenkins kubectl --kubeconfig=/var/jenkins_home/kubeconfig get nodes
```

---

## 🐛 Problemas Principales Resueltos

| Problema | Causa | Solución |
|----------|-------|----------|
| Minikube con 3 IPs | Conectado a múltiples redes | Desconectar de devops-net |
| "x509: certificate signed by unknown authority" | Certificados autofirmados | `--insecure-skip-tls-verify=true` |
| "HTTP response to HTTPS client" | Registry usa HTTP | `--insecure-registry` en Minikube |
| Jenkins no puede acceder a Kubernetes | kubeconfig con localhost | Crear contexto con IP de Minikube |
| ImagePullBackOff | Registry no accesible | Usar `host.docker.internal:5000` |

---

## 📈 Métricas del Proyecto

- **Contenedores corriendo:** 4 (GitLab, Jenkins, Registry, Minikube)
- **Redes Docker:** 2 (devops-net, minikube)
- **Repositorios GitLab:** 3 (jenkinspipelines, petclinic-angular, petclinic-rest)
- **Pipelines funcionales:** 2 (petclinic-maven ✅ 181 tests, petclinic-angular ✅ 43 tests)
- **Namespaces Kubernetes:** 1 (jenkins)
- **Secrets configurados:** 1 (registry-secret)
- **Branch estandarizado:** main (master eliminado)
- **Documentación generada:** ~5000 líneas en 5 archivos
- **Tiempo invertido:** ~12-18 horas

---

## 🔄 Flujo CI/CD Verificado

### **Pipeline Completo Funcionando:**

```
1. 💻 CÓDIGO EN GITLAB
   └─> Repositorios: petclinic-angular, petclinic-rest
   └─> Branch: main
   └─> Contienen: código fuente + Jenkinsfile

2. 🔗 JENKINS HACE CHECKOUT
   └─> git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git
   └─> Descarga código completo desde GitLab

3. 📦 CARGA SHARED LIBRARY
   └─> @Library('jenkinspipelines')
   └─> Funciones reutilizables desde repo centralizado

4. 🏗️ EJECUTA PIPELINE
   └─> Build → Test → Package
   └─> Angular: 43 tests con Chrome Headless ✅
   └─> Maven: 181 tests con JUnit ✅

5. ✅ RESULTADO: SUCCESS
   └─> Artefactos generados
   └─> Logs disponibles
```

### **Repositorios en GitLab:**

| Repositorio | Ubicación | Propósito | Estado |
|-------------|-----------|-----------|--------|
| `jenkinspipelines` | adrianmrc94/jenkinspipelines | 📦 Shared Library | ✅ Activo |
| `petclinic-angular` | adrianmrc94/petclinic-angular | 🎨 Frontend (Angular) | ✅ Pipeline SUCCESS |
| `petclinic-rest` | adrianmrc94/petclinic-rest | ⚙️ Backend (Java/Maven) | ✅ Pipeline SUCCESS |

---

## 🎬 Comandos para Demostración Rápida

> **⏱️ Tiempo de demo:** 5-7 minutos | **📋 Ver guía completa:** COMANDOS-DEMO.md

### **✅ Verificación Rápida del Stack (1 min)**

```bash
# Ver todos los contenedores activos
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Verificar redes
docker network inspect devops-net --format "{{range .Containers}}{{.Name}} {{end}}"

# Estado de Minikube y Kubernetes
minikube status
kubectl get nodes
kubectl get namespace jenkins
```

### **🔗 Pruebas de Integración GitLab-Jenkins (2-3 min)**

```bash
# 1. Ver repositorios en GitLab
docker exec gitlab gitlab-rails runner "Project.all.each { |p| puts p.path_with_namespace }"

# 2. Verificar que Jenkins usa GitLab (no GitHub público)
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "url"

# 3. Verificar branch configurado (debe ser 'main')
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep "BranchSpec" -A 1

# 4. Verificar que puede clonar desde GitLab
docker exec jenkins bash -c "cd /tmp && \
  rm -rf test && \
  git clone ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git test && \
  ls test/ | head -5 && \
  rm -rf test"
```

### **☸️ Pruebas de Integración Jenkins-Kubernetes (1-2 min)**

```bash
# 1. Jenkins puede ejecutar kubectl
docker exec jenkins kubectl get nodes
docker exec jenkins kubectl get all -n jenkins

# 2. Minikube puede acceder al Registry
minikube ssh "curl http://registry:5000/v2/_catalog"

# 3. Verificar conectividad completa
docker exec jenkins kubectl get serviceaccount -n jenkins
```

### **🚀 Demo de Despliegue (2-3 min)**

```bash
# Crear deployment de prueba desde Registry
docker exec jenkins kubectl run nginx-demo \
  --image=host.docker.internal:5000/hello-world \
  --namespace=jenkins \
  --image-pull-policy=Always

# Verificar creación
docker exec jenkins kubectl get pods -n jenkins

# Ver logs del pod
docker exec jenkins kubectl logs -n jenkins <POD_NAME>

# Limpiar
docker exec jenkins kubectl delete pod nginx-demo -n jenkins
```

### **🆘 Comandos de Emergencia**

```bash
# Si algo falla, reiniciar servicios
docker restart jenkins gitlab registry
minikube stop && minikube start

# Verificar logs
docker logs jenkins --tail 50
minikube logs --tail 50

# Reset rápido de Kubernetes
kubectl delete pod --all -n jenkins
```

### **📊 Comandos para Mostrar Métricas**

```bash
# Ver imágenes en Registry
curl http://localhost:5000/v2/_catalog
curl http://localhost:5000/v2/hello-world/tags/list

# Ver recursos de Kubernetes
kubectl get all -n jenkins
kubectl describe serviceaccount jenkins -n jenkins

# Ver configuración de redes
docker network inspect minikube --format "{{json .Containers}}" | python -m json.tool
```

---

## 🏆 Logros Destacados

### **✅ Infraestructura Completa:**
- 4 contenedores orquestados en redes Docker
- GitLab como SCM local (no dependencia de GitHub)
- Jenkins con integración completa a Kubernetes
- Registry privado funcionando

### **✅ CI/CD Funcionando:**
- Pipeline Angular: 43 tests ✅ SUCCESS
- Pipeline Maven: 181 tests ✅ SUCCESS
- Checkout automático desde GitLab
- Pipelines centralizadas con Shared Library

### **✅ Integración Verificada:**
- GitLab ↔ Jenkins (SSH con credenciales)
- Jenkins ↔ Kubernetes (kubectl funcional)
- Kubernetes ↔ Registry (pull de imágenes)
- Todo en red privada local

### **✅ Buenas Prácticas:**
- Branch `main` estandarizado (master eliminado)
- Pipelines reutilizables (`@Library('jenkinspipelines')`)
- Documentación completa y actualizada
- Comandos de demo preparados

---

## 📝 Próximos Pasos Sugeridos

1. **Webhooks GitLab → Jenkins** (auto-trigger en push)
2. **SonarQube** para análisis de código
3. **Helm Charts** para despliegues en Kubernetes
4. **Prometheus + Grafana** para monitoreo
5. **ArgoCD** para GitOps

---

**Preparado por:** Adrián  
**Fecha inicial:** 1 de octubre de 2025  
**Última actualización:** 3 de octubre de 2025  
**Propósito:** Presentación completa a mentora
