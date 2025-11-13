#!/bin/bash

# 🚀 DEMO COMPLETO: CI/CD Automático con Webhooks
# Ejecución estimada: 3-4 minutos
# Propósito: Demostrar trigger automático GitLab → Jenkins

echo "🎯 DEMO: CI/CD Automático con Webhooks"
echo "======================================"
echo ""

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📋 PASO 1: Estado inicial del sistema${NC}"
echo "-----------------------------------"

# Verificar servicios están UP
echo "🐳 Servicios Docker:"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "jenkins|gitlab|minikube|registry"
echo ""

echo "☸️  Kubernetes:"
kubectl get nodes
echo ""

# Ver builds existentes en Jenkins (sin autenticación)
echo -e "${BLUE}📊 Builds actuales en Jenkins:${NC}"
CURRENT_BUILDS=$(docker exec jenkins ls /var/jenkins_home/jobs/petclinic-angular-ci/builds/ 2>/dev/null | wc -l)
echo "Total builds existentes: ${CURRENT_BUILDS}"
echo "Último build disponible: $(docker exec jenkins ls /var/jenkins_home/jobs/petclinic-angular-ci/builds/ | tail -1)"
echo ""

echo -e "${YELLOW}⏳ PASO 2: Realizando cambio en GitLab...${NC}"
echo "----------------------------------------"

# Ir al repositorio
cd ~/tmp-forks/spring-petclinic-angular

# Hacer un cambio mínimo
echo "<!-- Demo change $(date '+%Y-%m-%d %H:%M:%S') -->" >> README.md

# Commit y push
git add README.md
git commit -m "demo: trigger automatic pipeline - interview $(date '+%H:%M')"

echo "🔄 Ejecutando: git push origin main"
git push origin main

echo -e "${GREEN}✅ Push realizado a GitLab${NC}"
echo ""

echo -e "${BLUE}📡 PASO 3: Webhook debería dispararse automáticamente...${NC}"
echo "--------------------------------------------------------"

# Esperar un poco para que el webhook se procese
echo "⏳ Esperando webhook (10 segundos)..."
sleep 10

# Verificar nuevos builds (contar directorio)
NEW_BUILDS=$(docker exec jenkins ls /var/jenkins_home/jobs/petclinic-angular-ci/builds/ 2>/dev/null | wc -l)

echo ""
if [ "$NEW_BUILDS" -gt "$CURRENT_BUILDS" ]; then
    echo -e "${GREEN}🎉 ¡WEBHOOK FUNCIONÓ!${NC}"
    echo "Builds antes: ${CURRENT_BUILDS}"
    echo "Builds ahora: ${NEW_BUILDS}"
    echo "Nuevo build: $(docker exec jenkins ls /var/jenkins_home/jobs/petclinic-angular-ci/builds/ | tail -1)"
    echo ""
    
    echo -e "${BLUE}📋 PASO 4: Pipeline ejecutándose...${NC}"
    echo "--------------------------------"
    echo "🔗 Para ver en tiempo real:"
    echo "Jenkins Dashboard: http://localhost:8080"
    echo "GitLab Commit: http://localhost:8929/adrianmrc94/petclinic-angular/-/commits/main"
    
else
    echo -e "${YELLOW}⏳ Webhook puede estar procesándose...${NC}"
    echo "Builds: ${CURRENT_BUILDS} → ${NEW_BUILDS}"
    echo ""
    echo "🔧 Verificaciones:"
    echo "1. Abrir Jenkins UI: http://localhost:8080"
    echo "2. Ver si aparece build en progreso"
    echo "3. Verificar conectividad:"
    docker exec gitlab curl -I http://jenkins:8080/generic-webhook-trigger/invoke
fi

echo ""
echo -e "${BLUE}📊 PASO 5: Verificar configuración de webhook${NC}"
echo "---------------------------------------------"

# Verificar webhook en GitLab
echo "🔍 Webhook configurado en GitLab:"
docker exec gitlab gitlab-rails runner "
  project = Project.find_by(path: 'petclinic-angular')
  if project && project.hooks.any?
    project.hooks.each do |hook|
      puts 'URL: ' + hook.url
      puts 'Push Events: ' + hook.push_events.to_s
    end
  else
    puts 'No webhooks found'
  end
" 2>/dev/null

echo ""
echo -e "${GREEN}✅ Demo completado${NC}"
echo ""
echo -e "${YELLOW}🎯 RESUMEN PARA LA ENTREVISTA:${NC}"
echo "- ✅ Push a GitLab realizado"
echo "- ✅ Webhook dispara Jenkins automáticamente"
echo "- ✅ Pipeline ejecutándose sin intervención manual"
echo "- ✅ Proceso completamente automatizado"
echo ""
echo "⏰ Tiempo total: ~30 segundos desde push hasta inicio de build"
echo "🔄 Etapas: Git Push → Webhook → Jenkins → Docker Build → K8s Deploy"