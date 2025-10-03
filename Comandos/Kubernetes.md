# ☸️ Comandos esenciales de Kubernetes

---

## 🔍 Información general

| Acción | Comando |
|--------|---------|
| Versión cliente y servidor | `kubectl version --short` |
| Información del cluster | `kubectl cluster-info` |
| Nodos del cluster | `kubectl get nodes` |
| Top de nodos | `kubectl top nodes` |
| Ver contextos | `kubectl config get-contexts` |
| Cambiar contexto | `kubectl config use-context mi-cluster` |
| Cambiar namespace por defecto | `kubectl config set-context --current --namespace=mi-ns` |

---

## 📦 Pods

| Acción | Comando |
|--------|---------|
| Listar pods | `kubectl get pods` |
| Listar pods (todos los namespaces) | `kubectl get pods -A` |
| Listar pods en namespace específico | `kubectl get pods -n NAMESPACE` |
| Ver logs de un pod | `kubectl logs POD_NAME` |
| Ver logs en namespace | `kubectl logs POD_NAME -n NAMESPACE` |
| Seguir logs en tiempo real | `kubectl logs -f POD_NAME` |
| Describir pod | `kubectl describe pod POD_NAME` |
| Describir pod en namespace | `kubectl describe pod POD_NAME -n NAMESPACE` |
| Ejecutar comando dentro | `kubectl exec -it POD_NAME -- /bin/bash` |
| Aplicar pod desde YAML | `kubectl apply -f pod.yaml` |
| Eliminar pod | `kubectl delete pod POD_NAME` |
| Eliminar pod en namespace | `kubectl delete pod POD_NAME -n NAMESPACE` |
| Forzar borrado de pod | `kubectl delete pod POD_NAME --grace-period=0 --force` |
| Ver eventos del pod | `kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'` |

---

## 🚀 Despliegues (Deployments)

| Acción | Comando |
|--------|---------|
| Listar deployments | `kubectl get deploy` |
| Crear deployment rápido | `kubectl create deploy mi-app --image=nginx` |
| Escalar réplicas | `kubectl scale deploy mi-app --replicas=3` |
| Ver rollout status | `kubectl rollout status deploy/mi-app` |
| Revertir rollout | `kubectl rollout undo deploy/mi-app` |
| Eliminar deployment | `kubectl delete deploy mi-app` |

---

## 🌐 Servicios (Services)

| Acción | Comando |
|--------|---------|
| Listar servicios | `kubectl get svc` |
| Exponer deployment | `kubectl expose deploy mi-app --port=80 --type=NodePort` |
| Ver detalles del servicio | `kubectl describe svc mi-app` |
| Eliminar servicio | `kubectl delete svc mi-app` |

---

## 🔐 Secrets

| Acción | Comando |
|--------|---------|
| Crear secret genérico literal | `kubectl create secret generic mi-secret --from-literal=key1=superpass` |
| Crear secret docker-registry | `kubectl create secret docker-registry registry-secret --docker-server=SERVER --docker-username=USER --docker-password=PASS --namespace=NAMESPACE` |
| Listar secrets | `kubectl get secrets` |
| Listar secrets en namespace | `kubectl get secrets -n NAMESPACE` |
| Describir secret | `kubectl describe secret SECRET_NAME -n NAMESPACE` |
| Ver contenido decodificado | `kubectl get secret SECRET_NAME -n NAMESPACE -o jsonpath='{.data.\.dockerconfigjson}' \| base64 -d` |
| Eliminar secret | `kubectl delete secret SECRET_NAME -n NAMESPACE` |

---

## 📋 ConfigMaps

| Acción | Comando |
|--------|---------|
| Crear ConfigMap literal | `kubectl create configmap mi-cm --from-literal=app.color=blue` |
| Crear ConfigMap desde archivo | `kubectl create configmap mi-cm --from-file=config.properties` |
| Listar ConfigMaps | `kubectl get cm` |
| Describir ConfigMap | `kubectl describe cm mi-cm` |
| Eliminar ConfigMap | `kubectl delete cm mi-cm` |

---

## 🔄 Manifiesto-first

| Acción | Comando |
|--------|---------|
| Aplicar manifiesto YAML | `kubectl apply -f mi-app.yaml` |
| Ver recursos por etiqueta | `kubectl get all -l app=mi-app` |
| Borrar desde manifiesto | `kubectl delete -f mi-app.yaml` |

---

## 🧹 Limpieza

| Acción | Comando |
|--------|---------|
| Borrar recursos con etiqueta | `kubectl delete all -l app=mi-app` |
| Forzar borrado de pod | `kubectl delete pod mi-pod --grace-period=0 --force` |

---

## 🏷️ Namespaces

| Acción | Comando |
|--------|---------|
| Listar namespaces | `kubectl get namespaces` |
| Crear namespace | `kubectl create namespace mi-ns` |
| Cambiar namespace por defecto | `kubectl config set-context --current --namespace=mi-ns` |
| Ver recursos en namespace | `kubectl get all -n mi-ns` |
| Eliminar namespace | `kubectl delete namespace mi-ns` |

---

## ⛵ Helm (Package Manager)

| Acción | Comando |
|--------|---------|
| Añadir repositorio | `helm repo add stable https://charts.helm.sh/stable` |
| Buscar charts | `helm search repo nginx` |
| Instalar chart | `helm install my-release stable/nginx` |
| Listar releases | `helm list` |
| Actualizar release | `helm upgrade my-release stable/nginx` |
| Desinstalar | `helm uninstall my-release` |
| Ver valores | `helm show values stable/nginx` |
| Crear chart | `helm create mi-chart` |

---

## 🐛 Troubleshooting

| Problema | Comando |
|----------|---------|
| Pod no arranca | `kubectl describe pod POD_NAME` |
| Ver eventos del cluster | `kubectl get events --sort-by=.metadata.creationTimestamp` |
| Ver eventos en namespace | `kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'` |
| Recursos de nodos | `kubectl describe node NODE_NAME` |
| Port-forward para debug | `kubectl port-forward pod/POD_NAME 8080:80` |
| Ejecutar pod temporal | `kubectl run debug --image=busybox -it --rm -- sh` |
| Copiar archivos desde pod | `kubectl cp POD_NAME:/ruta/archivo ./archivo` |
| Copiar archivos a pod | `kubectl cp ./archivo POD_NAME:/ruta/archivo` |
| Ver métricas de pods | `kubectl top pods --sort-by=memory` |
| Ver métricas de nodos | `kubectl top nodes` |

---

## 🔧 YAML útiles

| Recurso | Ejemplo básico |
|---------|----------------|
| Pod simple | `apiVersion: v1; kind: Pod; metadata: name: mi-pod; spec: containers: - name: app, image: nginx` |
| Deployment | `kubectl create deployment nginx --image=nginx --dry-run=client -o yaml` |
| Service | `kubectl expose deployment nginx --port=80 --dry-run=client -o yaml` |
| ConfigMap | `kubectl create configmap mi-config --from-literal=key=value --dry-run=client -o yaml` |

---

## 🐙 Bonus kubectl

| Acción | Comando |
|--------|---------|
| Alias temporal (shell) | `alias k=kubectl` |
| Autocompletado bash | `source <(kubectl completion bash)` |
| Formato de salida JSON | `kubectl get pods -o json` |
| Formato de salida YAML | `kubectl get pods -o yaml` |
| Formato wide (más info) | `kubectl get pods -o wide` |
| JSONPath personalizado | `kubectl get pods -o jsonpath='{.items[*].metadata.name}'` |
| Ver API resources | `kubectl api-resources` |
| Explicar recurso | `kubectl explain pod.spec.containers` |

---

## 🎯 Minikube

| Acción | Comando |
|--------|---------|
| Iniciar Minikube | `minikube start` |
| Iniciar con configuración | `minikube start --driver=docker --cpus=2 --memory=4096` |
| Iniciar con insecure-registry | `minikube start --insecure-registry="host.docker.internal:5000"` |
| Detener Minikube | `minikube stop` |
| Ver estado | `minikube status` |
| Ver IP | `minikube ip` |
| SSH a Minikube | `minikube ssh` |
| Ver dashboard (interfaz web) | `minikube dashboard` |
| Eliminar cluster | `minikube delete` |
| Eliminar todo | `minikube delete --all --purge` |
| Ver logs de Minikube | `minikube logs` |
| Actualizar contexto de kubectl | `minikube update-context` |
| Ver addons disponibles | `minikube addons list` |
| Habilitar addon | `minikube addons enable ADDON_NAME` |

---

## 🔍 Diagnóstico avanzado

| Acción | Comando |
|--------|---------|
| Ver configuración de insecure-registry | `minikube ssh 'ps aux \| grep dockerd \| grep insecure'` |
| Ver redes de un contenedor | `docker inspect CONTAINER --format='{{range $k, $v := .NetworkSettings.Networks}}{{$k}}: {{.IPAddress}} {{end}}'` |
| Ver gateway de una red | `docker network inspect NETWORK \| grep Gateway` |
| Verificar conectividad al registry | `docker exec minikube curl http://host.docker.internal:5000/v2/_catalog` |
| Ver certificados del cluster | `kubectl config view --raw` |
| Verificar API server | `curl -k https://$(minikube ip):8443/version` |
