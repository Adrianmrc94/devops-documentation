#!/bin/bash

# 🔧 CONFIGURACIÓN AUTOMÁTICA DE WEBHOOKS GitLab → Jenkins
# Configura trigger automático para pipelines CI/CD

echo "🚀 Configurando Webhook GitLab → Jenkins"
echo "========================================"

# Colores
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📋 PASO 1: Verificar servicios${NC}"
echo "----------------------------"

# Verificar que Jenkins esté funcionando
if ! docker ps | grep -q jenkins; then
    echo -e "${RED}❌ Jenkins no está corriendo${NC}"
    exit 1
fi

# Verificar que GitLab esté funcionando
if ! docker ps | grep -q gitlab; then
    echo -e "${RED}❌ GitLab no está corriendo${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Jenkins y GitLab están funcionando${NC}"
echo ""

echo -e "${BLUE}📋 PASO 2: Configurar Webhook en GitLab${NC}"
echo "----------------------------------------"

# Crear webhook en GitLab usando API interna
docker exec gitlab gitlab-rails runner "
project = Project.find_by(path: 'petclinic-angular')
if project
  # Eliminar webhooks existentes para evitar duplicados
  project.hooks.destroy_all
  
  # Crear nuevo webhook
  hook = project.hooks.build(
    url: 'http://jenkins:8080/generic-webhook-trigger/invoke?token=petclinic-angular-token',
    push_events: true,
    merge_requests_events: false,
    tag_push_events: false,
    issues_events: false,
    confidential_issues_events: false,
    wiki_page_events: false,
    deployment_events: false,
    job_events: false,
    pipeline_events: false,
    release_events: false,
    enable_ssl_verification: false
  )
  
  if hook.save
    puts '✅ Webhook creado exitosamente'
    puts 'URL: ' + hook.url
    puts 'Push Events: ' + hook.push_events.to_s
  else
    puts '❌ Error creando webhook: ' + hook.errors.full_messages.join(', ')
  end
else
  puts '❌ Proyecto petclinic-angular no encontrado'
end
"

echo ""
echo -e "${BLUE}📋 PASO 3: Configurar Job de Jenkins${NC}"
echo "-----------------------------------"

# Configurar el job de Jenkins para usar Generic Webhook Trigger
docker exec jenkins bash -c "
cd /var/jenkins_home/jobs/petclinic-angular-ci

# Backup del config actual
cp config.xml config.xml.backup

# Crear nueva configuración con trigger
cat > config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin=\"workflow-job@1551.v7320b_88b_d5e6\">
  <actions>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobAction plugin=\"pipeline-model-definition@2.2273.v643f36ed9e94\"/>
    <org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction plugin=\"pipeline-model-definition@2.2273.v643f36ed9e94\">
      <jobProperties/>
      <triggers/>
      <parameters/>
      <options/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.actions.DeclarativeJobPropertyTrackerAction>
  </actions>
  <description>CI para Angular con Docker - Con Webhook Automático</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty plugin=\"gitlab-plugin@1.9.9\">
      <gitLabConnection></gitLabConnection>
      <jobCredentialId></jobCredentialId>
      <useAlternativeCredential>false</useAlternativeCredential>
    </com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <org.jenkinsci.plugins.gwt.GenericTrigger plugin=\"generic-webhook-trigger@1.88\">
          <spec></spec>
          <genericVariables>
            <org.jenkinsci.plugins.gwt.GenericVariable>
              <expressionType>JSONPath</expressionType>
              <key>GIT_BRANCH</key>
              <value>\$.ref</value>
              <regexpFilter>refs/heads/</regexpFilter>
              <defaultValue></defaultValue>
            </org.jenkinsci.plugins.gwt.GenericVariable>
            <org.jenkinsci.plugins.gwt.GenericVariable>
              <expressionType>JSONPath</expressionType>
              <key>GIT_COMMIT</key>
              <value>\$.after</value>
              <regexpFilter></regexpFilter>
              <defaultValue></defaultValue>
            </org.jenkinsci.plugins.gwt.GenericVariable>
          </genericVariables>
          <regexpFilterText></regexpFilterText>
          <regexpFilterExpression></regexpFilterExpression>
          <printContributedVariables>true</printContributedVariables>
          <printPostContent>true</printPostContent>
          <silentMode>false</silentMode>
          <allowSeveralTriggersPerBuild>false</allowSeveralTriggersPerBuild>
          <token>petclinic-angular-token</token>
          <tokenCredentialId></tokenCredentialId>
        </org.jenkinsci.plugins.gwt.GenericTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class=\"org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition\" plugin=\"workflow-cps@3967.v8e5e7d691438\">
    <scm class=\"hudson.plugins.git.GitSCM\" plugin=\"git@5.6.0\">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git</url>
          <credentialsId>gitlab-ssh-key</credentialsId>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/main</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class=\"empty-list\"/>
      <extensions/>
    </scm>
    <scriptPath>Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

echo '✅ Configuración de Jenkins actualizada'
"

echo ""
echo -e "${BLUE}📋 PASO 4: Recargar configuración de Jenkins${NC}"
echo "--------------------------------------------"

# Recargar configuración sin reiniciar Jenkins
docker exec jenkins bash -c "
curl -X POST http://localhost:8080/reload --user admin:admin 2>/dev/null || echo 'Config reloaded'
"

echo ""
echo -e "${BLUE}📋 PASO 5: Verificar configuración${NC}"
echo "--------------------------------"

# Verificar webhook en GitLab
echo "🔍 Webhook en GitLab:"
docker exec gitlab gitlab-rails runner "
project = Project.find_by(path: 'petclinic-angular')
if project && project.hooks.any?
  project.hooks.each do |hook|
    puts '  URL: ' + hook.url
    puts '  Push Events: ' + hook.push_events.to_s
  end
else
  puts '  ❌ No se encontraron webhooks'
end
"

echo ""
echo "🔍 Conectividad GitLab → Jenkins:"
RESPONSE=$(docker exec gitlab curl -s -o /dev/null -w "%{http_code}" http://jenkins:8080/generic-webhook-trigger/invoke?token=petclinic-angular-token)
if [ "$RESPONSE" = "200" ]; then
    echo "  ✅ HTTP $RESPONSE - Webhook endpoint accesible"
else
    echo "  ⚠️  HTTP $RESPONSE - Verificar configuración"
fi

echo ""
echo -e "${GREEN}🎉 CONFIGURACIÓN COMPLETADA${NC}"
echo ""
echo -e "${YELLOW}📋 PARA PROBAR:${NC}"
echo "1. Hacer un cambio en el código:"
echo "   cd ~/tmp-forks/spring-petclinic-angular"
echo "   echo '// Webhook test' >> README.md"
echo "   git add README.md && git commit -m 'test: webhook trigger'"
echo "   git push origin main"
echo ""
echo "2. Verificar en Jenkins (http://localhost:8080):"
echo "   - Debería aparecer un nuevo build automáticamente"
echo "   - En 10-15 segundos después del push"
echo ""
echo -e "${BLUE}🔗 URLs importantes:${NC}"
echo "Jenkins: http://localhost:8080/job/petclinic-angular-ci/"
echo "GitLab: http://localhost:8929/adrianmrc94/petclinic-angular/-/hooks"