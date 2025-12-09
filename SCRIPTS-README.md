# 📋 Scripts DevOps - Guía Rápida

## 🔄 Uso Diario

### Cada mañana al iniciar Docker:
```bash
cd ~/scripts/daily
./1-setup-devops.sh      # Levanta Minikube, K8s, redes (2-3 min)
./2-start-angular.sh     # Inicia port-forward para Ingress
```

### Al terminar el día:
```bash
cd ~/scripts/daily
./3-stop-angular.sh      # Detiene port-forward
./stop-all.sh            # Opcional: Detiene Minikube
```

---

## 🔧 Mantenimiento

### Backup semanal:
```bash
cd ~/scripts/maintenance
./backup-volumes.sh      # Guarda Jenkins, GitLab, Registry
```

---

## 🆘 Troubleshooting

### Diagnóstico general:
```bash
cd ~/scripts/troubleshooting
./diagnose-jenkins-k8s.sh   # Ver estado de conexión Jenkins-K8s
```

### Si Minikube tiene problemas:
```bash
cd ~/scripts/troubleshooting
./cleanup-minikube.sh       # Limpieza profunda (IP conflicts)
./reset-minikube.sh         # Reset completo
```

### Si contenedores Docker fallaron:
```bash
cd ~/scripts/troubleshooting
./recover-containers.sh     # Recupera Jenkins, GitLab, Registry
```

---

## 📂 Estructura

```
~/scripts/
├── daily/              → Uso diario
│   ├── 1-setup-devops.sh
│   ├── 2-start-angular.sh
│   ├── 3-stop-angular.sh
│   └── stop-all.sh
│
├── maintenance/        → Backups y mantenimiento
│   └── backup-volumes.sh
│
├── troubleshooting/    → Cuando algo falla
│   ├── diagnose-jenkins-k8s.sh
│   ├── cleanup-minikube.sh
│   ├── reset-minikube.sh
│   └── recover-containers.sh
│
└── backups/            → Almacén de backups
```

---

## 📝 Flujo Completo Diario

```bash
# 1. Setup inicial (ejecutar una vez al día)
cd ~/scripts/daily
./1-setup-devops.sh

# 2. Desplegar aplicación Angular (si es necesario)
cd ~/tmp-forks/spring-petclinic-angular
helm upgrade --install spring-petclinic-angular ./chart -f helm/values.yaml

# 3. Iniciar acceso con Ingress
cd ~/scripts/daily
./2-start-angular.sh

# 4. Acceder desde navegador Windows
# http://prueba.local.angular
```

---

## ✅ Verificación Rápida

```bash
# Ver estado de todo el sistema
docker ps                    # Contenedores corriendo
minikube status             # Estado de Minikube
kubectl get pods            # Pods en Kubernetes
kubectl get ingress         # Ingress configurado
sudo systemctl status nginx # Nginx local
```

---

**Creado:** Diciembre 9, 2025  
**Ubicación scripts:** `~/scripts/` (WSL)  
**Dominio configurado:** `http://prueba.local.angular`
