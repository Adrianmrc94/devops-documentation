# Guía Completa de Helm para DevOps

## 📋 Índice
- [Course Introduction](#course-introduction)
- [Conceptos Fundamentales](#conceptos-fundamentales)
- [Instalación y Configuración](#instalación-y-configuración)
- [Trabajando con Helm](#trabajando-con-helm)
- [Creación de Charts Personalizados](#creación-de-charts-personalizados)
- [Templates Avanzados](#templates-avanzados)
- [Gestión de Dependencias](#gestión-de-dependencias)

---

## Course Introduction

### Prerequisitos del Curso
- ✅ Docker Desktop instalado
- ✅ WSL2 con Ubuntu
- ✅ Minikube funcionando
- ✅ Registry configurado
- ✅ Conocimientos de Kubernetes básicos
- ✅ Experiencia con pipelines (Maven/Angular)

### Objetivos de Aprendizaje
1. Entender qué es Helm y por qué es necesario
2. Instalar y configurar Helm en tu entorno
3. Trabajar con Charts y Repositorios
4. Crear tus propios Helm Charts
5. Dominar templates y valores dinámicos
6. Gestionar dependencias entre charts

---

## Conceptos Fundamentales

### Before HELM or Without HELM

#### ❌ Problemas sin Helm
```bash
# Necesitas mantener múltiples archivos YAML manualmente
deployment.yaml
service.yaml
configmap.yaml
ingress.yaml
secret.yaml

# Cada entorno necesita archivos separados
deployment-dev.yaml
deployment-staging.yaml
deployment-prod.yaml

# Dificultad para versionar aplicaciones
# No hay rollback fácil
# Difícil reutilización de configuraciones
```

#### Ejemplo sin Helm
```yaml
# deployment.yaml - Código repetitivo y difícil de mantener
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-production
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myregistry/myapp:1.0.0
        ports:
        - containerPort: 8080
```

**Problemas:**
- Valores hardcodeados (replicas, image, name)
- Difícil cambiar entre entornos
- No hay gestión de versiones
- Rollback manual complicado

---

### What is HELM

**Helm es el gestor de paquetes para Kubernetes** - Piensa en él como el "apt" o "npm" para Kubernetes.

#### 🎯 Definición
> Helm es una herramienta que simplifica la instalación, actualización y gestión de aplicaciones en Kubernetes mediante el uso de "Charts" (paquetes preconfigurados).

#### Componentes Principales

1. **Helm CLI**: Herramienta de línea de comandos
2. **Charts**: Paquetes de recursos de Kubernetes
3. **Releases**: Instancias de un Chart en el cluster
4. **Repositories**: Colecciones de Charts

#### Analogías
```
Docker Hub    → Helm Repository
Docker Image  → Helm Chart
Container     → Helm Release
```

---

### With HELM or After HELM

#### ✅ Beneficios con Helm

```bash
# Un solo comando para desplegar toda tu aplicación
helm install myapp ./myapp-chart

# Fácil gestión de valores por entorno
helm install myapp ./chart -f values-dev.yaml
helm install myapp ./chart -f values-prod.yaml

# Rollback instantáneo
helm rollback myapp 1

# Versionado automático
helm list
```

#### Ventajas Clave

| Sin Helm | Con Helm |
|----------|----------|
| Múltiples archivos YAML | Un Chart reutilizable |
| Valores hardcodeados | Templates con variables |
| Sin versionado | Control de versiones automático |
| Rollback manual | Rollback con un comando |
| Difícil compartir | Publicar en repositorios |

---

### HELM Charts and Repos

#### ¿Qué es un Chart?

Un **Chart** es un paquete de archivos que describe un conjunto de recursos de Kubernetes.

```
mychart/
├── Chart.yaml          # Metadatos del chart
├── values.yaml         # Valores por defecto
├── charts/             # Dependencias (sub-charts)
├── templates/          # Templates de Kubernetes
│   ├── deployment.yaml
│   ├── service.yaml
│   └── _helpers.tpl
└── README.md
```

#### Repositorios de Charts

**Repositorios Públicos Populares:**
- **Bitnami**: https://charts.bitnami.com/bitnami
- **Stable**: https://charts.helm.sh/stable
- **Prometheus Community**: https://prometheus-community.github.io/helm-charts

**Tu Propio Repositorio:**
```bash
# Puedes usar tu registry existente
# O servicios como Harbor, ChartMuseum, GitHub Pages
```

---

## Instalación y Configuración

### HELM Installation Preparation

#### Verificar Prerequisitos

```bash
# 1. Verificar Minikube está corriendo
minikube status

# 2. Verificar kubectl funciona
kubectl cluster-info
kubectl get nodes

# 3. Verificar Docker
docker --version

# 4. Verificar permisos WSL
whoami
```

---

### Create Cloud Machine for Env SetUp

**Nota:** Como ya tienes Minikube en WSL/Ubuntu, puedes saltar este paso. Tu máquina local es tu entorno.

#### Tu Setup Actual (Recomendado)
```bash
# Trabajarás en WSL2 Ubuntu con:
- Minikube (cluster local)
- Docker Desktop como runtime
- Kubectl ya configurado
```

---

### Install Kubernetes using MiniKube

#### Verificación de Minikube

```bash
# Ver estado de Minikube
minikube status

# Si no está corriendo
minikube start --driver=docker

# Verificar versión
minikube version

# Ver configuración
kubectl config current-context
```

#### Recursos Útiles
```bash
# Acceder al dashboard
minikube dashboard

# Ver addons disponibles
minikube addons list

# Habilitar registry addon si no lo tienes
minikube addons enable registry
```

---

### SetUp Execution Environment

#### Preparar el Entorno para Helm

```bash
# 1. Actualizar sistema (Ubuntu WSL)
sudo apt update && sudo apt upgrade -y

# 2. Instalar herramientas necesarias
sudo apt install -y curl wget git

# 3. Verificar kubectl
kubectl version --client

# 4. Crear namespace para pruebas
kubectl create namespace helm-demo

# 5. Configurar context
kubectl config set-context --current --namespace=helm-demo
```

---

### Install HELM

#### Instalación en Ubuntu (WSL)

```bash
# Método 1: Script oficial (Recomendado)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Método 2: Con snap
sudo snap install helm --classic

# Método 3: Descarga binaria manual
wget https://get.helm.sh/helm-v3.13.0-linux-amd64.tar.gz
tar -zxvf helm-v3.13.0-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
```

#### Verificar Instalación

```bash
# Verificar versión
helm version

# Output esperado:
# version.BuildInfo{Version:"v3.x.x", ...}

# Ver comandos disponibles
helm help

# Verificar que se conecta a Kubernetes
helm list
```

#### Configuración Inicial

```bash
# Inicializar repositorio stable (opcional)
helm repo add stable https://charts.helm.sh/stable

# Actualizar repositorios
helm repo update

# Ver repos configurados
helm repo list
```

---

## Trabajando con Helm

### Work with Repos

#### Gestión de Repositorios

```bash
# Añadir repositorio Bitnami
helm repo add bitnami https://charts.bitnami.com/bitnami

# Añadir Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Listar repositorios
helm repo list

# Actualizar índice de repositorios
helm repo update

# Buscar charts en repositorios
helm search repo nginx
helm search repo wordpress

# Buscar en Artifact Hub (hub público)
helm search hub wordpress

# Ver información de un chart
helm show chart bitnami/nginx
helm show values bitnami/nginx
helm show readme bitnami/nginx

# Remover repositorio
helm repo remove stable
```

---

### Execute Services using HELM

#### Instalar tu Primera Aplicación

```bash
# Instalar NGINX desde Bitnami
helm install my-nginx bitnami/nginx

# Ver el estado
helm status my-nginx

# Ver los recursos creados
kubectl get all -l app.kubernetes.io/instance=my-nginx

# Ver los pods
kubectl get pods

# Acceder al servicio (Minikube)
minikube service my-nginx --url
(minikube service my-nginx --url -n helm-demo)
```

#### Instalación con Nombre Personalizado

```bash
# Sintaxis básica
helm install [RELEASE-NAME] [CHART] [FLAGS]

# Ejemplos
helm install mywebapp bitnami/apache
helm install mydb bitnami/postgresql
helm install myredis bitnami/redis
```

#### Ver Instalaciones Activas

```bash
# Listar todas las releases
helm list

# Ver en todos los namespaces
helm list --all-namespaces

# Ver releases desinstaladas también
helm list --all
```

---

### Re-Use Deployment Naming

#### Convenciones de Nombres

```bash
# Buenas prácticas para nombres
helm install frontend-dev bitnami/nginx       # entorno-propósito
helm install backend-staging bitnami/tomcat   # app-ambiente
helm install db-production bitnami/postgresql # servicio-env

# Evitar nombres genéricos
helm install nginx bitnami/nginx  # ❌ No descriptivo
helm install test bitnami/nginx   # ❌ Muy genérico
```

#### Generar Nombres Automáticamente

```bash
# Helm puede generar nombres únicos
helm install bitnami/nginx --generate-name

# Con prefijo
helm install bitnami/nginx --generate-name --name-template "myapp-{{randAlpha 6}}"
```

---

### Provide Custom Values to HELM Chart

#### Método 1: Archivo de Valores

```bash
# Ver valores por defecto del chart
helm show values bitnami/nginx > nginx-values.yaml

# Editar valores
nano nginx-values.yaml
```

```yaml
# nginx-values.yaml - Ejemplo de personalización
replicaCount: 2

service:
  type: LoadBalancer
  port: 80

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

ingress:
  enabled: true
  hostname: myapp.local
```

```bash
# Instalar con valores personalizados
helm install my-nginx bitnami/nginx -f nginx-values.yaml

# Múltiples archivos (último sobrescribe)
helm install my-nginx bitnami/nginx \
  -f values-common.yaml \
  -f values-prod.yaml
```

#### Método 2: Valores en Línea de Comandos

```bash
# Usar --set para valores individuales
helm install my-nginx bitnami/nginx \
  --set replicaCount=3 \
  --set service.type=NodePort

# Valores complejos
helm install my-nginx bitnami/nginx \
  --set resources.requests.memory=512Mi \
  --set resources.requests.cpu=500m

# Arrays
helm install my-nginx bitnami/nginx \
  --set ingress.hosts[0].name=app1.local \
  --set ingress.hosts[1].name=app2.local
```

#### Método 3: Combinado

```bash
# Archivo base + override específico
helm install my-nginx bitnami/nginx \
  -f values.yaml \
  --set replicaCount=5
```

---

### Upgrade Services Using HELM

#### Actualizar una Release

```bash
# Actualizar con nuevos valores
helm upgrade my-nginx bitnami/nginx \
  --set replicaCount=5

# Actualizar con archivo
helm upgrade my-nginx bitnami/nginx \
  -f values-updated.yaml

# Ver diferencias antes de aplicar (dry-run)
helm upgrade my-nginx bitnami/nginx \
  -f values-new.yaml \
  --dry-run --debug

# Instalar si no existe, actualizar si existe
helm upgrade --install my-nginx bitnami/nginx \
  -f values.yaml

# Actualizar con timeout
helm upgrade my-nginx bitnami/nginx \
  --timeout 10m \
  --wait
```

#### Actualizar a Nueva Versión del Chart

```bash
# Ver versiones disponibles
helm search repo bitnami/nginx --versions

# Actualizar a versión específica
helm upgrade my-nginx bitnami/nginx --version 13.2.0

# Ver qué cambió
helm diff upgrade my-nginx bitnami/nginx
```

---

### HELM Release Records

#### Historia de Releases

```bash
# Ver historial de una release
helm history my-nginx

# Output:
# REVISION  UPDATED                   STATUS      CHART         DESCRIPTION
# 1         Mon Jan 15 10:00:00 2024  superseded  nginx-13.0.0  Install complete
# 2         Mon Jan 15 11:00:00 2024  superseded  nginx-13.1.0  Upgrade complete
# 3         Mon Jan 15 12:00:00 2024  deployed    nginx-13.2.0  Upgrade complete

# Ver con más detalles
helm history my-nginx --max 10

# Ver todas las revisiones
helm history my-nginx --max 0
```

#### Información de Release

```bash
# Ver estado actual
helm status my-nginx

# Ver valores usados en la release
helm get values my-nginx

# Ver valores incluyendo los por defecto
helm get values my-nginx --all

# Ver manifest completo desplegado
helm get manifest my-nginx

# Ver todo (hooks, values, manifest, notes)
helm get all my-nginx

# Ver revisión específica
helm get values my-nginx --revision 2
```

---

### HELM Deployment Workflow

#### Flujo Completo de Despliegue

```bash
# 1. BÚSQUEDA - Encontrar el chart
helm search repo wordpress

# 2. INSPECCIÓN - Revisar el chart
helm show chart bitnami/wordpress
helm show values bitnami/wordpress > wordpress-values.yaml

# 3. PERSONALIZACIÓN - Editar valores
nano wordpress-values.yaml

# 4. VALIDACIÓN - Dry run
helm install my-wordpress bitnami/wordpress \
  -f wordpress-values.yaml \
  --dry-run --debug

# 5. INSTALACIÓN - Despliegue real
helm install my-wordpress bitnami/wordpress \
  -f wordpress-values.yaml \
  --wait --timeout 5m

# 6. VERIFICACIÓN - Comprobar estado
helm status my-wordpress
kubectl get pods -l app.kubernetes.io/instance=my-wordpress

# 7. ACCESO - Obtener información de conexión
helm status my-wordpress | grep -A 10 "NOTES:"

# 8. MONITOREO - Ver logs
kubectl logs -l app.kubernetes.io/instance=my-wordpress

# 9. ACTUALIZACIÓN - Cuando sea necesario
helm upgrade my-wordpress bitnami/wordpress \
  -f wordpress-values-updated.yaml

# 10. LIMPIEZA - Desinstalar cuando termine
helm uninstall my-wordpress
```

---

### Validate Resource before Deployment

#### Validación con Dry-Run

```bash
# Simular instalación sin ejecutar
helm install my-nginx bitnami/nginx \
  -f values.yaml \
  --dry-run

# Con debug para ver template renderizado
helm install my-nginx bitnami/nginx \
  -f values.yaml \
  --dry-run --debug

# Validar template completo
helm template my-nginx bitnami/nginx \
  -f values.yaml > rendered-template.yaml

# Ver el output
cat rendered-template.yaml
```

#### Validación de Sintaxis

```bash
# Lint: Verificar sintaxis del chart
helm lint ./mychart/

# Con valores específicos
helm lint ./mychart/ -f values-prod.yaml

# Output esperado:
# ==> Linting ./mychart/
# [INFO] Chart.yaml: icon is recommended
# 1 chart(s) linted, 0 chart(s) failed
```

#### Validación con Kubernetes

```bash
# Usar kubectl para validar sin aplicar
helm template my-nginx bitnami/nginx | kubectl apply --dry-run=client -f -

# Validación del servidor
helm template my-nginx bitnami/nginx | kubectl apply --dry-run=server -f -
```

---

### Generate K8s Deployable YAML using HELM

#### Generar YAML desde Chart

```bash
# Generar YAML completo
helm template my-release bitnami/nginx > kubernetes-manifests.yaml

# Con valores personalizados
helm template my-release bitnami/nginx \
  -f my-values.yaml > manifests.yaml

# Ver en salida estándar
helm template my-release bitnami/nginx -f values.yaml

# Generar para namespace específico
helm template my-release bitnami/nginx \
  --namespace production > prod-manifests.yaml
```

#### Uso del YAML Generado

```bash
# Aplicar directamente con kubectl
kubectl apply -f manifests.yaml

# Revisar antes de aplicar
kubectl diff -f manifests.yaml

# Aplicar en namespace específico
kubectl apply -f manifests.yaml -n production
```

---

### Details of HELM Deployment Releases

#### Información Detallada de Releases

```bash
# Ver todas las releases en el namespace actual
helm list

# En todos los namespaces
helm list -A

# Solo releases en estado "deployed"
helm list --deployed

# Releases fallidas
helm list --failed

# Todas (incluyendo desinstaladas)
helm list --all

# Filtrar por nombre
helm list --filter 'nginx'

# Output personalizado
helm list -o json
helm list -o yaml
```

---

### Get Details of Deployed Deployment

#### Inspeccionar Deployment Específico

```bash
# Ver estado de la release
helm status my-nginx

# Ver valores usados
helm get values my-nginx

# Ver manifest de Kubernetes
helm get manifest my-nginx

# Ver hooks
helm get hooks my-nginx

# Ver notas post-instalación
helm get notes my-nginx

# Todo junto
helm get all my-nginx

# De una revisión específica
helm get values my-nginx --revision 2
```

#### Debugging

```bash
# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Logs de pods
kubectl logs -l app.kubernetes.io/instance=my-nginx

# Describir recursos
kubectl describe deployment my-nginx

# Ver recursos creados por Helm
kubectl get all -l app.kubernetes.io/managed-by=Helm
```

---

### Rollback Application using HELM

#### Hacer Rollback

```bash
# Ver historial
helm history my-nginx

# Rollback a la versión anterior
helm rollback my-nginx

# Rollback a revisión específica
helm rollback my-nginx 2

# Rollback con timeout
helm rollback my-nginx 2 --timeout 5m

# Dry-run del rollback
helm rollback my-nginx 2 --dry-run

# Rollback y esperar a que complete
helm rollback my-nginx 2 --wait

# Forzar recreación de recursos
helm rollback my-nginx 2 --force
```

#### Estrategia de Rollback

```bash
# Escenario completo
# 1. Algo salió mal después de upgrade
helm upgrade my-app ./chart -f values-new.yaml

# 2. Ver qué falló
kubectl get pods
kubectl logs <pod-name>

# 3. Ver historial
helm history my-app

# 4. Rollback inmediato
helm rollback my-app

# 5. Verificar
helm status my-app
kubectl get pods
```

---

### Wait HELM Deployment for Successful Installation

#### Uso de --wait Flag

```bash
# Esperar a que todos los recursos estén ready
helm install my-nginx bitnami/nginx --wait

# Con timeout personalizado (default 5m)
helm install my-nginx bitnami/nginx \
  --wait --timeout 10m

# Esperar en upgrade también
helm upgrade my-nginx bitnami/nginx \
  -f new-values.yaml \
  --wait --timeout 10m

# Atomic: rollback automático si falla
helm install my-nginx bitnami/nginx \
  --atomic --timeout 5m
```

#### Comportamiento de --wait

```yaml
# Espera a que:
# - Deployments: todos los pods estén Ready
# - StatefulSets: todos los pods estén Ready
# - DaemonSets: todos los pods estén Ready
# - Jobs: completen exitosamente
# - Services: tengan endpoints disponibles (si type LoadBalancer)
```

---

## Creación de Charts Personalizados

### Introduction

En esta sección aprenderás a crear tus propios Helm Charts desde cero, adaptados a tus aplicaciones Maven y Angular.

---

### Create HELM Chart

#### Crear Estructura de Chart

```bash
# Crear chart vacío
helm create myapp

# Ver estructura creada
tree myapp/

# Output:
# myapp/
# ├── Chart.yaml
# ├── charts/
# ├── templates/
# │   ├── NOTES.txt
# │   ├── _helpers.tpl
# │   ├── deployment.yaml
# │   ├── hpa.yaml
# │   ├── ingress.yaml
# │   ├── service.yaml
# │   ├── serviceaccount.yaml
# │   └── tests/
# └── values.yaml
```

#### Crear Chart para tu Aplicación Maven

```bash
# Crear chart para backend
helm create my-java-backend

# Limpiar templates no necesarios
cd my-java-backend/templates
rm -rf hpa.yaml ingress.yaml serviceaccount.yaml tests/
```

---

### Install the Custom Chart

#### Instalar tu Chart

```bash
# Desde directorio local
helm install my-release ./myapp

# Con valores personalizados
helm install my-release ./myapp -f custom-values.yaml

# Dry run primero
helm install my-release ./myapp --dry-run --debug

# Con namespace
helm install my-release ./myapp --namespace dev --create-namespace
```

---

### Understanding Chart YAML

#### Chart.yaml - Metadatos del Chart

```yaml
# Chart.yaml
apiVersion: v2  # v2 para Helm 3
name: my-java-backend
description: A Helm chart for Java Spring Boot backend
type: application  # o 'library'
version: 0.1.0  # Versión del chart (SemVer)
appVersion: "1.0.0"  # Versión de tu aplicación

# Opcional pero recomendado
keywords:
  - java
  - springboot
  - backend
home: https://github.com/tu-usuario/tu-repo
sources:
  - https://github.com/tu-usuario/tu-repo
maintainers:
  - name: Tu Nombre
    email: tu@email.com
icon: https://example.com/icon.png
deprecated: false  # true si está deprecado
```

#### Campos Importantes

```yaml
# apiVersion:
# - v1: Helm 2 (obsoleto)
# - v2: Helm 3 (actual)

# type:
# - application: Chart desplegable
# - library: Chart de utilidades (solo templates helper)

# version: Versión del CHART (no de la app)
# - Debe seguir SemVer (1.2.3)
# - Incrementar cuando cambies el chart

# appVersion: Versión de TU APLICACIÓN
# - Puede ser cualquier string
# - Generalmente tag de Docker
```

---

### HELM Templates

#### Estructura de Templates

Los templates usan Go Template Language con funciones adicionales de Sprig.

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-deployment
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        ports:
        - containerPort: {{ .Values.service.port }}
```

#### Objetos Built-in Principales

```yaml
# .Release - Información de la release
{{ .Release.Name }}       # Nombre de la release
{{ .Release.Namespace }}  # Namespace donde se despliega
{{ .Release.Service }}    # Siempre "Helm"
{{ .Release.IsUpgrade }}  # true si es upgrade
{{ .Release.IsInstall }}  # true si es install nueva

# .Chart - Contenido de Chart.yaml
{{ .Chart.Name }}         # Nombre del chart
{{ .Chart.Version }}      # Versión del chart
{{ .Chart.AppVersion }}   # Versión de la app

# .Values - Contenido de values.yaml
{{ .Values.replicaCount }}
{{ .Values.image.repository }}

# .Files - Acceso a archivos del chart
{{ .Files.Get "config.txt" }}

# .Capabilities - Info del cluster
{{ .Capabilities.KubeVersion }}
```

---

### Helper File in HELM Template

#### _helpers.tpl - Funciones Reutilizables

```yaml
# templates/_helpers.tpl

{{/* Generar nombre completo */}}
{{- define "myapp.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Labels comunes */}}
{{- define "myapp.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Selector labels */}}
{{- define "myapp.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Service account name */}}
{{- define "myapp.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "myapp.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
```

#### Usar Helpers en Templates

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}
spec:
  selector:
    matchLabels:
      {{- include "myapp.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "myapp.selectorLabels" . | nindent 8 }}
```

---

### Values File in HELM

#### values.yaml - Configuración Por Defecto

```yaml
# values.yaml - Para aplicación Java Spring Boot

# Réplicas
replicaCount: 1

# Imagen Docker
image:
  repository: myregistry.local/my-java-backend
  pullPolicy: IfNotPresent
  tag: "1.0.0"

# Secretos para pull de imagen
imagePullSecrets: []

# Service Account
serviceAccount:
  create: true
  name: ""

# Service
service:
  type: ClusterIP
  port: 8080
  targetPort: 8080

# Ingress
ingress:
  enabled: false
  className: "nginx"
  annotations: {}
  hosts:
    - host: myapp.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# Recursos
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

# Autoscaling
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80

# Health checks
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 5

# Variables de entorno
env:
  - name: SPRING_PROFILES_ACTIVE
    value: "production"
  - name: DATABASE_URL
    value: "jdbc:postgresql://postgres:5432/mydb"

# ConfigMap adicional
config:
  application.properties: |
    server.port=8080
    logging.level.root=INFO
```

#### values-dev.yaml - Valores para Desarrollo

```yaml
# values-dev.yaml
replicaCount: 1

image:
  tag: "latest"
  pullPolicy: Always

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

env:
  - name: SPRING_PROFILES_ACTIVE
    value: "development"
  - name: DATABASE_URL
    value: "jdbc:postgresql://postgres-dev:5432/mydb"
```

---

### Package Your HELM Chart

#### Empaquetar Chart

```bash
# Crear paquete .tgz
helm package ./myapp

# Output: myapp-0.1.0.tgz

# Con versión específica
helm package ./myapp --version 1.2.3

# Con directorio de destino
helm package ./myapp --destination ./packages/

# Con dependencias actualizadas
helm package ./myapp --dependency-update

# Firmar el paquete (seguridad)
helm package ./myapp --sign --key 'my-key' --keyring ~/.gnupg/secring.gpg
```

#### Crear Repositorio Local

```bash
# Crear directorio para repo
mkdir my-helm-repo
mv myapp-0.1.0.tgz my-helm-repo/

# Generar índice del repositorio
helm repo index my-helm-repo/ --url http://localhost:8080

# Servir repositorio localmente
cd my-helm-repo
python3 -m http.server 8080

# En otra terminal, añadir el repo
helm repo add myrepo http://localhost:8080
helm repo update

# Instalar desde tu repo
helm install my-release myrepo/myapp
```

#### Subir a Registry (Harbor/ChartMuseum)

```bash
# Si tienes Harbor o ChartMuseum
helm plugin install https://github.com/chartmuseum/helm-push

# Push al registry
helm cm-push myapp-0.1.0.tgz myrepo

# O usando registry OCI (Docker registry)
helm push myapp-0.1.0.tgz oci://myregistry.local/helm-charts
```

---

### Validate HELM Chart

#### Validación Completa del Chart

```bash
# 1. Lint - Verificar sintaxis y mejores prácticas
helm lint ./myapp

# Con valores específicos
helm lint ./myapp -f values-prod.yaml

# 2. Template - Renderizar sin instalar
helm template test-release ./myapp

# Con debug
helm template test-release ./myapp --debug

# 3. Dry-run - Simular instalación
helm install test-release ./myapp --dry-run

# Con valores personalizados
helm install test-release ./myapp \
  -f values-dev.yaml \
  --dry-run --debug

# 4. Validar contra API de Kubernetes
helm template test-release ./myapp | kubectl apply --dry-run=server -f -
```

#### Errores Comunes y Soluciones

```bash
# Error: YAML indentation
# Solución: Usar nindent en helpers
{{- include "myapp.labels" . | nindent 4 }}

# Error: valores undefined
# Solución: Usar valores por defecto
{{ .Values.image.tag | default "latest" }}

# Error: nombres muy largos (>63 caracteres)
# Solución: Truncar en helpers
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
```

---

## Templates Avanzados

### Actions in Template

#### Acciones Básicas

```yaml
# {{ }} - Imprime valor
{{ .Values.replicaCount }}

# {{- }} - Elimina espacios a la izquierda
{{- .Values.image.repository }}

# {{ -}} - Elimina espacios a la derecha
{{ .Values.image.tag -}}

# {{- -}} - Elimina espacios en ambos lados
{{- .Values.service.port -}}

# Comentarios (no aparecen en output)
{{/* Este es un comentario */}}
```

#### Control de Espacios en Blanco

```yaml
# Sin control:
labels:
  app: {{ .Chart.Name }}
  # Genera líneas vacías

# Con control:
labels:
  {{- if .Values.customLabels }}
  {{- range $key, $value := .Values.customLabels }}
  {{ $key }}: {{ $value }}
  {{- end }}
  {{- end }}
```

---

### Access Information in Template

#### Acceder a Valores Anidados

```yaml
# values.yaml
database:
  host: postgres
  port: 5432
  credentials:
    username: admin
    password: secret123

# En template:
{{ .Values.database.host }}                    # postgres
{{ .Values.database.port }}                    # 5432
{{ .Values.database.credentials.username }}    # admin
{{ .Values.database.credentials.password }}    # secret123
```

#### Acceso a Archivos

```yaml
# Leer archivo del chart
apiVersion: v1
kind: ConfigMap
metadata:
  name: config
data:
  config.json: {{ .Files.Get "configs/config.json" | quote }}
  
  # Leer múltiples archivos
  {{- range $path, $content := .Files.Glob "configs/**" }}
  {{ $path | base }}: {{ $content | b64enc }}
  {{- end }}
```

#### Acceso a Capabilities

```yaml
# Verificar versión de Kubernetes
{{- if .Capabilities.APIVersions.Has "networking.k8s.io/v1" }}
apiVersion: networking.k8s.io/v1
{{- else }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}
kind: Ingress

# Verificar versión específica
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion }}
# Usar características de K8s 1.19+
{{- end }}
```

---

### Pipe Func in Template

#### Pipes en Templates

```yaml
# Sintaxis: valor | función1 | función2 | función3

# Ejemplo 1: Quote y upper
name: {{ .Values.name | upper | quote }}
# Si name: "myapp" → name: "MYAPP"

# Ejemplo 2: Default y trim
repository: {{ .Values.image.repository | default "nginx" | trim }}

# Ejemplo 3: Indentación
data:
{{ .Values.config | toYaml | indent 2 }}

# Ejemplo 4: Encoding
password: {{ .Values.password | b64enc | quote }}
```

#### Pipes Complejos

```yaml
# Combinar múltiples pipes
labels:
{{- range $key, $value := .Values.labels }}
  {{ $key }}: {{ $value | quote | lower | trim }}
{{- end }}

# Con condicionales
image: {{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}
```

---

### Functions in Template

#### Funciones de String

```yaml
# upper / lower
{{ .Values.name | upper }}                    # MYAPP
{{ .Values.name | lower }}                    # myapp

# trim / trimPrefix / trimSuffix
{{ .Values.name | trim }}                     # elimina espacios
{{ .Values.name | trimPrefix "pre-" }}        # elimina prefijo
{{ .Values.name | trimSuffix "-post" }}       # elimina sufijo

# replace
{{ .Values.name | replace "-" "_" }}          # reemplaza - por _

# quote / squote
{{ .Values.name | quote }}                    # "myapp"
{{ .Values.name | squote }}                   # 'myapp'

# printf
{{ printf "%s-%s" .Release.Name .Chart.Name }}  # concat con formato
```

#### Funciones de Listas

```yaml
# list - crear lista
{{ list "a" "b" "c" }}                        # [a b c]

# append / prepend
{{ list "a" "b" | append "c" }}               # [a b c]
{{ list "b" "c" | prepend "a" }}              # [a b c]

# has - verificar si contiene
{{ if has "prod" .Values.environments }}
  # ...
{{ end }}

# first / last
{{ list "a" "b" "c" | first }}                # a
{{ list "a" "b" "c" | last }}                 # c
```

#### Funciones de Diccionarios

```yaml
# dict - crear diccionario
{{ dict "name" "app" "version" "1.0" }}

# get - obtener valor
{{ get .Values.config "database.host" }}

# set - establecer valor
{{ $myDict := dict }}
{{ $_ := set $myDict "key" "value" }}

# merge - combinar diccionarios
{{ $result := merge $dict1 $dict2 }}
```

#### Funciones de Encoding

```yaml
# b64enc / b64dec - Base64
{{ .Values.password | b64enc }}               # cGFzc3dvcmQ=
{{ .Values.encoded | b64dec }}                # decodifica

# toJson / fromJson
{{ .Values.config | toJson }}                 # convertir a JSON
{{ .Values.jsonString | fromJson }}           # parsear JSON

# toYaml / fromYaml
data:
{{ .Values.config | toYaml | indent 2 }}      # convertir a YAML
```

#### Funciones Matemáticas

```yaml
# add / sub / mul / div
{{ add 1 2 }}                                 # 3
{{ sub 5 2 }}                                 # 3
{{ mul 3 4 }}                                 # 12
{{ div 10 2 }}                                # 5

# max / min
{{ max 1 2 3 }}                               # 3
{{ min 1 2 3 }}                               # 1

# mod / floor / ceil / round
{{ mod 10 3 }}                                # 1
{{ floor 4.9 }}                               # 4
{{ ceil 4.1 }}                                # 5
{{ round 4.5 }}                               # 5
```

#### Funciones de Fecha

```yaml
# now - fecha actual
{{ now | date "2006-01-02" }}                 # 2025-10-16

# date - formatear fecha
{{ .Values.timestamp | date "2006-01-02 15:04:05" }}

# dateInZone - con zona horaria
{{ now | dateInZone "2006-01-02" "UTC" }}
```

#### Funciones de Comparación Semántica

```yaml
# semverCompare - comparar versiones
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion }}
apiVersion: networking.k8s.io/v1
{{- else }}
apiVersion: networking.k8s.io/v1beta1
{{- end }}

# semver - parsear versión
{{ semver .Chart.Version }}
```

---

### Conditional Logic in Template

#### If / Else / Else If

```yaml
# If básico
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
# ...
{{- end }}

# If / Else
{{- if .Values.serviceAccount.create }}
serviceAccountName: {{ include "myapp.serviceAccountName" . }}
{{- else }}
serviceAccountName: default
{{- end }}

# If / Else If / Else
{{- if eq .Values.environment "production" }}
replicas: 3
{{- else if eq .Values.environment "staging" }}
replicas: 2
{{- else }}
replicas: 1
{{- end }}
```

#### Operadores de Comparación

```yaml
# eq - igual
{{- if eq .Values.type "frontend" }}

# ne - no igual
{{- if ne .Values.type "backend" }}

# lt - menor que
{{- if lt .Values.replicas 3 }}

# le - menor o igual
{{- if le .Values.replicas 3 }}

# gt - mayor que
{{- if gt .Values.replicas 1 }}

# ge - mayor o igual
{{- if ge .Values.replicas 1 }}
```

#### Operadores Lógicos

```yaml
# and - Y lógico
{{- if and .Values.ingress.enabled .Values.ingress.tls }}
# Ambos son verdaderos
{{- end }}

# or - O lógico
{{- if or .Values.useConfigMap .Values.useSecret }}
# Al menos uno es verdadero
{{- end }}

# not - Negación
{{- if not .Values.serviceAccount.create }}
# serviceAccount.create es false
{{- end }}

# Combinados
{{- if and (eq .Values.type "web") (or .Values.ingress.enabled .Values.nodePort) }}
# Tipo es web Y (ingress habilitado O nodePort definido)
{{- end }}
```

#### Verificar Existencia

```yaml
# Verificar si valor existe y no es vacío
{{- if .Values.customConfig }}
configMap: {{ .Values.customConfig }}
{{- end }}

# Con default
configMap: {{ .Values.customConfig | default "default-config" }}

# Verificar nil
{{- if not (empty .Values.annotations) }}
annotations:
  {{- toYaml .Values.annotations | nindent 4 }}
{{- end }}
```

---

### TypeCast Values to YAML in Template

#### Conversión de Tipos

```yaml
# toYaml - Convertir objeto a YAML
{{- if .Values.resources }}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{- end }}

# Ejemplo con values.yaml:
# resources:
#   limits:
#     cpu: 1000m
#     memory: 1Gi

# Resultado:
# resources:
#   limits:
#     cpu: 1000m
#     memory: 1Gi
```

#### toJson vs toYaml

```yaml
# toJson - Para ConfigMaps con JSON
apiVersion: v1
kind: ConfigMap
metadata:
  name: json-config
data:
  config.json: {{ .Values.jsonConfig | toJson | quote }}

# toYaml - Para configuraciones YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: yaml-config
data:
  config.yaml: |
    {{- toYaml .Values.yamlConfig | nindent 4 }}
```

#### Indentación Correcta

```yaml
# nindent - Nueva línea + indent
spec:
  template:
    metadata:
      labels:
        {{- include "myapp.labels" . | nindent 8 }}

# indent - Solo indent (sin nueva línea)
data:
  config.yaml: |
{{ .Values.config | toYaml | indent 4 }}
```

---

### Variable in Template

#### Declarar Variables

```yaml
# Asignar valor a variable
{{- $releaseName := .Release.Name }}
{{- $chartName := .Chart.Name }}

# Usar variables
metadata:
  name: {{ $releaseName }}-{{ $chartName }}

# Variables complejas
{{- $image := printf "%s:%s" .Values.image.repository .Values.image.tag }}
spec:
  containers:
  - name: app
    image: {{ $image }}
```

#### Variables en Loops

```yaml
# Variable en range
{{- range $key, $value := .Values.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}

# Múltiples variables
{{- range $index, $service := .Values.services }}
---
apiVersion: v1
kind: Service
metadata:
  name: {{ $.Release.Name }}-{{ $service.name }}-{{ $index }}
spec:
  ports:
  - port: {{ $service.port }}
{{- end }}
```

#### Scope de Variables

```yaml
# $ - acceso al contexto raíz
{{- range .Values.services }}
metadata:
  name: {{ $.Release.Name }}-{{ .name }}  # $ para acceder al contexto padre
{{- end }}

# . - contexto actual (cambia en range/with)
{{- with .Values.database }}
host: {{ .host }}      # .host del database
port: {{ .port }}      # .port del database
{{- end }}
```

---

### Loops in Templates

#### Range sobre Lista

```yaml
# values.yaml
environments:
  - dev
  - staging
  - prod

# template
{{- range .Values.environments }}
- {{ . }}  # . es cada elemento
{{- end }}

# Resultado:
# - dev
# - staging
# - prod
```

#### Range sobre Diccionario

```yaml
# values.yaml
labels:
  app: myapp
  tier: frontend
  environment: production

# template
metadata:
  labels:
    {{- range $key, $value := .Values.labels }}
    {{ $key }}: {{ $value }}
    {{- end }}

# Resultado:
# labels:
#   app: myapp
#   tier: frontend
#   environment: production
```

#### Range con Índice

```yaml
# values.yaml
replicas:
  - name: web
    count: 3
  - name: api
    count: 2

# template
{{- range $index, $replica := .Values.replicas }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $.Release.Name }}-{{ $replica.name }}-{{ $index }}
spec:
  replicas: {{ $replica.count }}
{{- end }}
```

#### Range Condicional

```yaml
# Solo iterar si existe y no está vacío
{{- if .Values.extraPorts }}
ports:
{{- range .Values.extraPorts }}
- port: {{ .port }}
  name: {{ .name }}
  protocol: {{ .protocol | default "TCP" }}
{{- end }}
{{- end }}
```

---

### Template Validation

#### Herramientas de Validación

```bash
# 1. Helm Lint - Validación básica
helm lint ./mychart/

# 2. Yamllint - Validación de sintaxis YAML
yamllint ./mychart/templates/

# 3. Kubeval - Validación contra esquemas de K8s
helm template test ./mychart/ | kubeval

# 4. Kubeconform - Alternativa moderna a kubeval
helm template test ./mychart/ | kubeconform

# 5. Pluto - Detectar APIs deprecadas
helm template test ./mychart/ | pluto detect -
```

#### Pre-commit Hooks

```bash
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gruntwork-io/pre-commit
    rev: v0.1.17
    hooks:
      - id: helm-lint

# Instalar
pip install pre-commit
pre-commit install
```

#### Validación en CI/CD

```yaml
# .github/workflows/helm-validate.yml
name: Validate Helm Charts
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: azure/setup-helm@v3
      
      - name: Lint
        run: helm lint ./charts/*
      
      - name: Template
        run: |
          for chart in charts/*; do
            helm template test "$chart"
          done
      
      - name: Kubeval
        run: |
          helm template test ./charts/myapp | kubeval
```

---

## Gestión de Dependencias

### Manage Chart Dependencies

#### Definir Dependencias en Chart.yaml

```yaml
# Chart.yaml
apiVersion: v2
name: my-fullstack-app
version: 1.0.0
dependencies:
  - name: postgresql
    version: 12.1.0
    repository: https://charts.bitnami.com/bitnami
  
  - name: redis
    version: 17.3.0
    repository: https://charts.bitnami.com/bitnami
  
  - name: nginx
    version: 13.2.0
    repository: https://charts.bitnami.com/bitnami
    condition: nginx.enabled  # Opcional
```

#### Gestionar Dependencias

```bash
# Descargar dependencias
helm dependency update ./my-fullstack-app

# Ver dependencias
helm dependency list ./my-fullstack-app

# Output:
# NAME        VERSION  REPOSITORY                           STATUS
# postgresql  12.1.0   https://charts.bitnami.com/bitnami   ok
# redis       17.3.0   https://charts.bitnami.com/bitnami   ok
# nginx       13.2.0   https://charts.bitnami.com/bitnami   ok

# Construir dependencias (crea charts/*.tgz)
helm dependency build ./my-fullstack-app

# Ver estructura resultante
tree my-fullstack-app/
# my-fullstack-app/
# ├── Chart.yaml
# ├── charts/
# │   ├── postgresql-12.1.0.tgz
# │   ├── redis-17.3.0.tgz
# │   └── nginx-13.2.0.tgz
# └── values.yaml
```

#### Dependencias Locales

```yaml
# Chart.yaml - Dependencia de chart local
dependencies:
  - name: my-common-lib
    version: 1.0.0
    repository: file://../my-common-lib
```

```bash
# Actualizar dependencias locales
helm dependency update ./myapp
```

---

### Conditional Chart Dependency

#### Dependencias Condicionales

```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: 12.1.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled  # Se instala solo si postgresql.enabled=true
  
  - name: mysql
    version: 9.4.0
    repository: https://charts.bitnami.com/bitnami
    condition: mysql.enabled
  
  - name: redis
    version: 17.3.0
    repository: https://charts.bitnami.com/bitnami
    tags:
      - cache
    condition: redis.enabled
```

#### values.yaml - Controlar Dependencias

```yaml
# values.yaml del chart padre
postgresql:
  enabled: true  # Instalar PostgreSQL
  auth:
    username: myuser
    password: mypassword
    database: mydb

mysql:
  enabled: false  # NO instalar MySQL

redis:
  enabled: true  # Instalar Redis
  architecture: standalone
```

#### Usar Tags para Grupos

```yaml
# Chart.yaml
dependencies:
  - name: prometheus
    version: 15.0.0
    repository: https://prometheus-community.github.io/helm-charts
    tags:
      - monitoring
  
  - name: grafana
    version: 6.50.0
    repository: https://grafana.github.io/helm-charts
    tags:
      - monitoring
  
  - name: loki
    version: 3.0.0
    repository: https://grafana.github.io/helm-charts
    tags:
      - monitoring
      - logging
```

```yaml
# values.yaml
tags:
  monitoring: true  # Instala prometheus, grafana, loki
  logging: false    # Sobrescribe loki (por el tag logging)
```

```bash
# Instalar deshabilitando un tag
helm install myapp ./chart --set tags.monitoring=false

# Combinar condition y tags
helm install myapp ./chart \
  --set postgresql.enabled=true \
  --set tags.monitoring=false
```

---

### Pass Values to Dependencies at Runtime

#### Pasar Valores a Sub-Charts

```yaml
# values.yaml del chart padre
# Los valores bajo el nombre del sub-chart se pasan automáticamente

postgresql:
  enabled: true
  auth:
    username: appuser
    password: secretpass
    database: appdb
  primary:
    persistence:
      enabled: true
      size: 10Gi
  
redis:
  enabled: true
  architecture: standalone
  auth:
    password: redispass
  master:
    persistence:
      enabled: false

# Valores propios de la app padre
replicaCount: 2
image:
  repository: myapp
  tag: 1.0.0
```

#### Desde Command Line

```bash
# Pasar valores a dependencia específica
helm install myapp ./chart \
  --set postgresql.auth.password=newsecret \
  --set redis.replica.replicaCount=3

# Con archivo de valores
helm install myapp ./chart \
  -f values.yaml \
  -f values-prod.yaml

# values-prod.yaml
# postgresql:
#   primary:
#     resources:
#       requests:
#         memory: 2Gi
#         cpu: 1000m
```

#### Global Values - Compartir entre Charts

```yaml
# values.yaml
global:
  storageClass: "standard"
  imagePullSecrets:
    - name: myregistry-secret
  postgresql:
    auth:
      postgresPassword: globalpass

# Accesible en TODOS los sub-charts
postgresql:
  enabled: true
  # Hereda global.postgresql.auth.postgresPassword
  # Hereda global.storageClass

redis:
  enabled: true
  # También puede acceder a global values
```

#### En Templates - Acceder a Global

```yaml
# templates/deployment.yaml del chart padre
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
spec:
  template:
    spec:
      {{- if .Values.global.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml .Values.global.imagePullSecrets | nindent 8 }}
      {{- end }}
      containers:
      - name: app
        image: {{ .Values.image.repository }}:{{ .Values.image.tag }}
        env:
        - name: DATABASE_HOST
          value: {{ .Release.Name }}-postgresql  # Nombre del servicio de la dependencia
        - name: DATABASE_PORT
          value: "5432"
        - name: REDIS_HOST
          value: {{ .Release.Name }}-redis-master
```

---

### Child to Parent chart Data Exchange

#### Export Values desde Sub-Chart

```yaml
# Sub-chart: charts/database/Chart.yaml
apiVersion: v2
name: database
version: 1.0.0

# Sub-chart: charts/database/values.yaml
host: "db.local"
port: 5432
credentials:
  username: admin

# Para exportar valores al padre, NO se hace en values.yaml
# Se hace en los templates del sub-chart
```

#### Named Templates para Compartir

```yaml
# Sub-chart: charts/common/templates/_helpers.tpl
{{- define "common.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{- define "common.database.host" -}}
{{- printf "%s-postgresql" .Release.Name }}
{{- end }}
```

```yaml
# Chart padre: templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}
  labels:
    {{- include "common.labels" . | nindent 4 }}  # Usa helper del sub-chart
spec:
  template:
    spec:
      containers:
      - name: app
        env:
        - name: DB_HOST
          value: {{ include "common.database.host" . }}  # Usa función del sub-chart
```

#### Library Charts

```yaml
# charts/mylib/Chart.yaml
apiVersion: v2
name: mylib
type: library  # Tipo library: solo helpers, no recursos
version: 1.0.0

# charts/mylib/templates/_helpers.tpl
{{- define "mylib.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 }}
{{- end }}

{{- define "mylib.labels" -}}
app: {{ .Chart.Name }}
release: {{ .Release.Name }}
{{- end }}

{{- define "mylib.databaseUrl" -}}
{{- $host := include "mylib.fullname" . }}
{{- printf "postgresql://%s-postgresql:5432" $host }}
{{- end }}
```

```yaml
# Chart padre: Chart.yaml
dependencies:
  - name: mylib
    version: 1.0.0
    repository: file://../mylib

# Chart padre: templates/deployment.yaml
metadata:
  labels:
    {{- include "mylib.labels" . | nindent 4 }}
spec:
  containers:
  - name: app
    env:
    - name: DATABASE_URL
      value: {{ include "mylib.databaseUrl" . }}
```

---

## Ejemplos Prácticos Completos

### Ejemplo 1: Chart para Aplicación Java Spring Boot

```yaml
# Chart.yaml
apiVersion: v2
name: spring-boot-app
description: Helm chart para aplicación Spring Boot
type: application
version: 1.0.0
appVersion: "2.7.0"
dependencies:
  - name: postgresql
    version: 12.1.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
```

```yaml
# values.yaml
replicaCount: 2

image:
  repository: myregistry.local/spring-app
  pullPolicy: IfNotPresent
  tag: "1.0.0"

service:
  type: ClusterIP
  port: 8080

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: myapp.local
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8080
  initialDelaySeconds: 60

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8080
  initialDelaySeconds: 30

env:
  - name: SPRING_PROFILES_ACTIVE
    value: "production"

postgresql:
  enabled: true
  auth:
    username: springuser
    password: springpass
    database: springdb
```

```bash
# Instalar
helm install my-spring-app ./spring-boot-app -f values-prod.yaml

# Upgrade
helm upgrade my-spring-app ./spring-boot-app --set replicaCount=3

# Rollback
helm rollback my-spring-app
```

---

### Ejemplo 2: Chart para Aplicación Angular

```yaml
# Chart.yaml
apiVersion: v2
name: angular-app
description: Helm chart para aplicación Angular con NGINX
type: application
version: 1.0.0
appVersion: "14.0.0"
```

```yaml
# values.yaml
replicaCount: 3

image:
  repository: myregistry.local/angular-app
  pullPolicy: IfNotPresent
  tag: "1.0.0"

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: true
  className: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  hosts:
    - host: frontend.local
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: frontend-tls
      hosts:
        - frontend.local

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

# Configuración NGINX
nginxConfig:
  default.conf: |
    server {
      listen 80;
      location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
      }
    }

autoscaling:
  enabled: true
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
```

```yaml
# templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "angular-app.fullname" . }}-nginx
  labels:
    {{- include "angular-app.labels" . | nindent 4 }}
data:
  {{- range $key, $value := .Values.nginxConfig }}
  {{ $key }}: |
    {{- $value | nindent 4 }}
  {{- end }}
```

```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "angular-app.fullname" . }}
  labels:
    {{- include "angular-app.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "angular-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "angular-app.selectorLabels" . | nindent 8 }}
    spec:
      containers:
      - name: {{ .Chart.Name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
        livenessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /
            port: http
          initialDelaySeconds: 5
          periodSeconds: 5
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        volumeMounts:
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
      volumes:
      - name: nginx-config
        configMap:
          name: {{ include "angular-app.fullname" . }}-nginx
```

---

### Ejemplo 3: Full Stack con Dependencias

```yaml
# Chart.yaml
apiVersion: v2
name: fullstack-app
description: Full stack application con backend, frontend y base de datos
type: application
version: 1.0.0
appVersion: "1.0.0"

dependencies:
  # Base de datos
  - name: postgresql
    version: 12.1.0
    repository: https://charts.bitnami.com/bitnami
    condition: postgresql.enabled
  
  # Cache
  - name: redis
    version: 17.3.0
    repository: https://charts.bitnami.com/bitnami
    condition: redis.enabled
  
  # Backend (sub-chart local)
  - name: backend
    version: 1.0.0
    repository: file://./charts/backend
    condition: backend.enabled
  
  # Frontend (sub-chart local)
  - name: frontend
    version: 1.0.0
    repository: file://./charts/frontend
    condition: frontend.enabled
```

```yaml
# values.yaml
global:
  storageClass: "standard"
  imagePullSecrets:
    - name: registry-secret

# PostgreSQL
postgresql:
  enabled: true
  auth:
    username: appuser
    password: apppass
    database: appdb
  primary:
    persistence:
      enabled: true
      size: 10Gi
    resources:
      requests:
        memory: 512Mi
        cpu: 250m

# Redis
redis:
  enabled: true
  architecture: standalone
  auth:
    password: redispass
  master:
    persistence:
      enabled: false

# Backend
backend:
  enabled: true
  replicaCount: 2
  image:
    repository: myregistry.local/backend
    tag: "1.0.0"
  service:
    type: ClusterIP
    port: 8080
  env:
    - name: SPRING_DATASOURCE_URL
      value: "jdbc:postgresql://fullstack-app-postgresql:5432/appdb"
    - name: SPRING_DATASOURCE_USERNAME
      value: "appuser"
    - name: SPRING_REDIS_HOST
      value: "fullstack-app-redis-master"

# Frontend
frontend:
  enabled: true
  replicaCount: 3
  image:
    repository: myregistry.local/frontend
    tag: "1.0.0"
  service:
    type: ClusterIP
    port: 80
  ingress:
    enabled: true
    className: nginx
    hosts:
      - host: myapp.local
        paths:
          - path: /
            pathType: Prefix
```

```bash
# Descargar dependencias
helm dependency update ./fullstack-app

# Instalar aplicación completa
helm install myapp ./fullstack-app \
  -f values-production.yaml \
  --namespace production \
  --create-namespace

# Ver todo lo desplegado
helm list -n production
kubectl get all -n production

# Upgrade solo del frontend
helm upgrade myapp ./fullstack-app \
  --set frontend.image.tag=1.1.0 \
  --reuse-values
```

---

## Comandos Helm - Referencia Rápida

### Gestión de Repositorios

```bash
# Añadir repositorio
helm repo add <name> <url>

# Listar repositorios
helm repo list

# Actualizar repositorios
helm repo update

# Remover repositorio
helm repo remove <name>

# Buscar charts
helm search repo <keyword>
helm search hub <keyword>
```

### Instalación y Gestión

```bash
# Instalar chart
helm install <release> <chart>
helm install <release> <chart> -f values.yaml
helm install <release> <chart> --set key=value

# Listar releases
helm list
helm list -A  # todos los namespaces
helm list -n <namespace>

# Ver estado
helm status <release>

# Upgrade
helm upgrade <release> <chart>
helm upgrade --install <release> <chart>  # instala si no existe

# Rollback
helm rollback <release>
helm rollback <release> <revision>

# Desinstalar
helm uninstall <release>
helm uninstall <release> --keep-history
```

### Información y Debugging

```bash
# Ver valores
helm show values <chart>
helm get values <release>
helm get values <release> --all

# Ver manifest
helm get manifest <release>

# Ver historial
helm history <release>

# Template (renderizar sin instalar)
helm template <release> <chart>
helm template <release> <chart> --debug

# Dry-run
helm install <release> <chart> --dry-run
helm upgrade <release> <chart> --dry-run

# Lint
helm lint <chart>
```

### Gestión de Charts

```bash
# Crear chart
helm create <name>

# Empaquetar
helm package <chart-dir>

# Dependencias
helm dependency list <chart>
helm dependency update <chart>
helm dependency build <chart>

# Validar
helm lint <chart>
helm template <release> <chart> | kubectl apply --dry-run=client -f -
```

---

## Mejores Prácticas

### 1. Nomenclatura

```yaml
# ✅ BUENO: Nombres descriptivos y consistentes
helm install backend-prod ./backend-chart
helm install frontend-staging ./frontend-chart

# ❌ MALO: Nombres genéricos
helm install app ./chart
helm install test ./chart
```

### 2. Versionado

```yaml
# Chart.yaml
version: 1.2.3  # Versión del CHART (SemVer)
appVersion: "2.7.0"  # Versión de la APLICACIÓN

# Incrementar version cuando cambies:
# - MAJOR: Cambios incompatibles
# - MINOR: Nuevas funcionalidades compatibles
# - PATCH: Bug fixes
```

### 3. Values y Configuración

```yaml
# ✅ BUENO: Valores con defaults sensatos
replicaCount: 1  # default para dev
resources:
  requests:
    cpu: 100m
    memory: 128Mi

# ✅ BUENO: Documentar valores
# values.yaml
## Number of replicas
## @param replicaCount - Number of pod replicas
replicaCount: 1

## Image configuration
## @param image.repository - Image repository
## @param image.tag - Image tag
image:
  repository: nginx
  tag: "1.21"
```

### 4. Templates

```yaml
# ✅ BUENO: Usar helpers para lógica común
metadata:
  name: {{ include "myapp.fullname" . }}
  labels:
    {{- include "myapp.labels" . | nindent 4 }}

# ❌ MALO: Repetir código
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
```

### 5. Recursos y Límites

```yaml
# ✅ BUENO: Siempre definir requests y limits
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

# ✅ BUENO: Hacer configurable
{{- if .Values.resources }}
resources:
  {{- toYaml .Values.resources | nindent 2 }}
{{- end }}
```

### 6. Health Checks

```yaml
# ✅ BUENO: Configurar probes apropiadamente
livenessProbe:
  httpGet:
    path: /health
    port: 8080
  initialDelaySeconds: 60  # Tiempo para que app inicie
  periodSeconds: 10
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 10
  periodSeconds: 5
  failureThreshold: 3
```

### 7. Secrets

```yaml
# ✅ BUENO: No hardcodear secrets
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "myapp.fullname" . }}
type: Opaque
data:
  password: {{ .Values.password | b64enc | quote }}

# ✅ MEJOR: Usar external-secrets o sealed-secrets
# ❌ NUNCA: Commits secrets en Git
```

### 8. Dependencias

```yaml
# ✅ BUENO: Versiones específicas
dependencies:
  - name: postgresql
    version: 12.1.0  # Versión específica
    repository: https://charts.bitnami.com/bitnami

# ❌ MALO: Versiones dinámicas
dependencies:
  - name: postgresql
    version: ~12.0.0  # Puede romper en cualquier momento
```

### 9. Documentación

```markdown
# README.md del chart

## Requisitos
- Kubernetes 1.19+
- Helm 3.0+

## Instalación
\`\`\`bash
helm install myapp ./chart -f values-prod.yaml
\`\`\`

## Parámetros

| Parámetro | Descripción | Default |
|-----------|-------------|---------|
| replicaCount | Número de réplicas | 1 |
| image.repository | Repositorio de imagen | nginx |
| image.tag | Tag de imagen | 1.21 |

## Ejemplos

### Producción
\`\`\`bash
helm install myapp ./chart -f values-prod.yaml
\`\`\`

### Development
\`\`\`bash
helm install myapp ./chart --set replicaCount=1
\`\`\`
```

### 10. Testing

```yaml
# templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  name: "{{ include "myapp.fullname" . }}-test-connection"
  annotations:
    "helm.sh/hook": test
spec:
  containers:
  - name: wget
    image: busybox
    command: ['wget']
    args: ['{{ include "myapp.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

```bash
# Ejecutar tests
helm test <release>
```

---

## Troubleshooting Común

### Problema 1: Chart no se instala

```bash
# Debug completo
helm install myapp ./chart --dry-run --debug

# Verificar sintaxis
helm lint ./chart

# Ver manifest renderizado
helm template myapp ./chart > output.yaml
cat output.yaml
```

### Problema 2: Valores no se aplican

```bash
# Verificar valores usados
helm get values myapp

# Ver todos los valores (incluidos defaults)
helm get values myapp --all

# Verificar precedencia de valores
# CLI --set > -f values2.yaml > -f values1.yaml > values.yaml del chart
```

### Problema 3: Dependencias no se descargan

```bash
# Limpiar y recargar
rm -rf charts/*.tgz
rm Chart.lock
helm dependency update ./mychart

# Verificar repositorios
helm repo list
helm repo update
```

### Problema 4: Release queda en estado pending-install

```bash
# Ver qué falló
kubectl get pods
kubectl describe pod <pod-name>

# Ver eventos
kubectl get events --sort-by='.lastTimestamp'

# Limpiar release fallida
helm uninstall myapp

# Reinstalar con --wait y --timeout
helm install myapp ./chart --wait --timeout 10m
```

### Problema 5: Template no renderiza correctamente

```bash
# Ver template sin instalar
helm template myapp ./chart --debug

# Verificar valores específicos
helm template myapp ./chart --set key=value --debug

# Verificar con values file
helm template myapp ./chart -f values.yaml --debug
```

---

## Integración con CI/CD

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy with Helm

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install Helm
        uses: azure/setup-helm@v3
        with:
          version: '3.12.0'
      
      - name: Configure kubectl
        uses: azure/k8s-set-context@v3
        with:
          kubeconfig: ${{ secrets.KUBE_CONFIG }}
      
      - name: Lint Chart
        run: helm lint ./charts/myapp
      
      - name: Deploy
        run: |
          helm upgrade --install myapp ./charts/myapp \
            --namespace production \
            --create-namespace \
            --set image.tag=${{ github.sha }} \
            --wait \
            --timeout 5m
```

### GitLab CI

```yaml
# .gitlab-ci.yml
stages:
  - validate
  - deploy

validate:
  stage: validate
  image: alpine/helm:3.12.0
  script:
    - helm lint ./charts/myapp
    - helm template test ./charts/myapp --debug

deploy:
  stage: deploy
  image: alpine/helm:3.12.0
  script:
    - helm upgrade --install myapp ./charts/myapp
        --namespace $CI_ENVIRONMENT_NAME
        --create-namespace
        --set image.tag=$CI_COMMIT_SHORT_SHA
        --wait
  only:
    - main
```

### ArgoCD (GitOps)

```yaml
# argocd-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/myuser/myrepo
    targetRevision: HEAD
    path: charts/myapp
    helm:
      valueFiles:
        - values-production.yaml
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

---

## Recursos y Referencias

### Documentación Oficial
- **Helm Docs**: https://helm.sh/docs/
- **Chart Best Practices**: https://helm.sh/docs/chart_best_practices/
- **Sprig Functions**: http://masterminds.github.io/sprig/

### Repositorios Populares
- **Bitnami**: https://github.com/bitnami/charts
- **Prometheus**: https://github.com/prometheus-community/helm-charts
- **Ingress NGINX**: https://github.com/kubernetes/ingress-nginx/tree/main/charts

### Herramientas
- **Helmfile**: Gestión declarativa de releases
- **Helm Diff**: Plugin para ver diferencias
- **Chart Testing**: Testing automatizado de charts
- **Kubeval**: Validación de manifests

### Comandos para Copiar

```bash
# Setup inicial
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add stable https://charts.helm.sh/stable
helm repo update

# Crear y trabajar con charts
helm create myapp
helm lint ./myapp
helm template test ./myapp --debug
helm package ./myapp

# Instalar y gestionar
helm install myapp ./myapp -f values.yaml
helm upgrade myapp ./myapp --reuse-values
helm rollback myapp
helm uninstall myapp

# Debugging
helm get values myapp
helm get manifest myapp
helm history myapp
kubectl get all -l app.kubernetes.io/instance=myapp
```

---

## Próximos Pasos

### 1. Práctica Básica
- [ ] Instalar Helm en tu sistema
- [ ] Añadir repositorios (Bitnami, Stable)
- [ ] Instalar un chart público (nginx, wordpress)
- [ ] Hacer upgrade y rollback

### 2. Crear tu Primer Chart
- [ ] Crear chart con `helm create`
- [ ] Personalizar templates
- [ ] Modificar values.yaml
- [ ] Instalar tu chart localmente

### 3. Aplicación Real
- [ ] Crear chart para tu app Java/Maven
- [ ] Crear chart para tu app Angular
- [ ] Añadir dependencias (PostgreSQL, Redis)
- [ ] Configurar diferentes entornos (dev, prod)

### 4. Avanzado
- [ ] Implementar sub-charts
- [ ] Crear library charts
- [ ] Configurar CI/CD con Helm
- [ ] Publicar charts en repositorio

---

## Glosario

| Término | Definición |
|---------|------------|
| **Chart** | Paquete de recursos de Kubernetes |
| **Release** | Instancia de un Chart en el cluster |
| **Repository** | Colección de Charts |
| **values.yaml** | Archivo de configuración con valores por defecto |
| **Template** | Archivo YAML con placeholders para valores dinámicos |
| **Helper** | Función reutilizable definida en _helpers.tpl |
| **Dependency** | Chart requerido por otro chart (sub-chart) |
| **Hook** | Acción que se ejecuta en momentos específicos del ciclo de vida |
| **Revision** | Versión específica de una release |

---

## Notas Finales

### ⚠️ Importantes
- Helm 3 no usa Tiller (a diferencia de Helm 2)
- Siempre usa `--dry-run --debug` antes de instalar
- Los secrets en values.yaml deben manejarse con cuidado
- Versiona tus charts siguiendo SemVer

### 💡 Tips
- Usa `--wait` en producción para asegurar deployment exitoso
- Implementa health checks en todas tus apps
- Documenta tus charts con README.md
- Usa `helm diff` plugin para ver cambios antes de aplicar

### 🎯 Para tu Setup
Con tu entorno actual (Minikube + Docker Desktop + WSL):
1. Helm funcionará perfectamente sin configuración adicional
2. Puedes usar tu registry local para almacenar imágenes
3. Minikube será tu cluster de desarrollo
4. Integra Helm en tus pipelines de Maven y Angular

---
