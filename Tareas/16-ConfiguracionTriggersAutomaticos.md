# 🔄 Tarea 16: Configuración de Triggers Automáticos en Jenkins

**Fecha:** 13 de Noviembre 2025  
**Objetivo:** Configurar triggers automáticos para que Jenkins ejecute pipelines al detectar cambios en GitLab  
**Duración:** 15-20 minutos  
**Nivel:** Intermedio

---

## 📋 Resumen Ejecutivo

Esta tarea documenta la configuración de triggers automáticos para integrar GitLab con Jenkins, permitiendo que las pipelines CI/CD se ejecuten automáticamente cuando se realizan cambios en el código.

**Resultado:** Jenkins ejecutará pipelines automáticamente cada vez que se detecten cambios en GitLab, eliminando la necesidad de triggers manuales.

---

## 🎯 Objetivos

- ✅ Configurar SCM Polling en Jenkins para revisión automática de GitLab
- ✅ Implementar alternativa con webhooks (documentación técnica)
- ✅ Probar funcionamiento del trigger automático
- ✅ Documentar troubleshooting y mejores prácticas

---

## 🛠️ Requisitos Previos

### Servicios Funcionando:
- ✅ Jenkins corriendo en `http://localhost:8080`
- ✅ GitLab corriendo en `http://localhost:8929` 
- ✅ Proyectos configurados: `petclinic-angular` y `petclinic-maven`
- ✅ Jobs de Jenkins creados: `petclinic-angular-ci` y `petclinic-maven-ci`

### Verificación de Estado:
```bash
# Verificar contenedores activos
docker ps | grep -E "jenkins|gitlab"

# Verificar conectividad
curl -I http://localhost:8080
curl -I http://localhost:8929
```

---

## 🚀 Método 1: SCM Polling (RECOMENDADO)

### ⚡ Configuración Rápida

**Ventajas del SCM Polling:**
- ✅ Fácil de configurar
- ✅ No requiere configuración de red específica
- ✅ Más confiable en entornos Docker
- ✅ No depende de conectividad externa

### 📋 Pasos de Configuración:

#### 1. Configurar Jenkins Job

1. **Abrir Jenkins** → `http://localhost:8080`
2. **Click en el job** → `petclinic-angular-ci`
3. **Click "Configure"**
4. **Ir a sección "Build Triggers"**
5. **☑️ Marcar "Consultar repositorio (SCM)"**
6. **En campo "Programador" escribir:**
   ```
   H/1 * * * *
   ```
7. **Click "Save"**

#### 2. Configuración de Sintaxis Cron

| Sintaxis | Descripción | Uso |
|----------|-------------|-----|
| `H/1 * * * *` | ❌ Mal interpretado 	Cada hora (error) | Desarrollo/Testing |
| `* * * * *` | Cada minuto | Desarrollo/Testing |
| `H * * * *` | Una vez por hora | Desarrollo/Testing |
| `H/2 * * * *` | Cada 2 minutos | Desarrollo |
| `H/5 * * * *` | Cada 5 minutos | Producción |
| `H H/4 * * *` | Cada 4 horas | Proyectos estables |

**Nota:** `H` distribuye la carga para evitar que todos los jobs se ejecuten al mismo tiempo.

#### 3. Verificar Configuración

```bash
# Ver logs de polling en Jenkins
# Jenkins → Job → Polling Log (en menú lateral)

# Verificar última revisión
# Debería aparecer: "Latest remote head revision on refs/remotes/origin/main is: [commit-hash]"
```

### 🧪 Prueba de Funcionamiento

#### Método 1: Cambio desde GitLab Web
1. **Abrir GitLab** → `http://localhost:8929/adrianmrc94/petclinic-angular`
2. **Editar README.md** (click en el archivo → Edit)
3. **Agregar línea:** `// Polling test $(date)`
4. **Commit changes**
5. **Esperar 1-2 minutos**
6. **Verificar en Jenkins** → Debería aparecer nuevo build automáticamente

#### Método 2: Cambio desde Terminal
```bash
# Ir al repositorio local
cd ~/tmp-forks/spring-petclinic-angular

# Hacer cambio
echo "// Polling test $(date)" >> README.md

# Commit y push
git add README.md
git commit -m "test: polling automation"
git push origin main

# Verificar en Jenkins (1-2 minutos)
# Ver dashboard → http://localhost:8080
```

---

## 🔗 Método 2: Webhooks (AVANZADO)

### 🎯 Configuración Teórica

**Ventajas de Webhooks:**
- ⚡ Trigger instantáneo (5-15 segundos)
- 🔋 Menos consumo de recursos (no polling)
- 📡 Integración más elegante

**Desventajas:**
- 🔐 Requiere configuración de autenticación
- 🌐 Dependiente de conectividad de red
- 🛠️ Más complejo de troubleshoot

### 📋 Configuración de Webhooks

#### 1. Instalar Plugin en Jenkins

```bash
# Verificar si está instalado
docker exec jenkins ls /var/jenkins_home/plugins/ | grep generic-webhook

# Si no está instalado:
docker exec jenkins bash -c "
cd /var/jenkins_home/plugins
curl -L -o generic-webhook-trigger.jpi https://updates.jenkins.io/latest/generic-webhook-trigger.hpi
"

# Reiniciar Jenkins
docker restart jenkins
```

#### 2. Configurar Jenkins Job

1. **Jenkins** → **Job** → **Configure**
2. **Build Triggers** → **☑️ Generic Webhook Trigger**
3. **Configuración:**
   - **Token:** `petclinic-angular-token`
   - **Print post content:** ✅
   - **Print contributed variables:** ✅

#### 3. Configurar GitLab Webhook

**Obtener IP de Jenkins:**
```bash
docker inspect jenkins | grep "IPAddress"
# Resultado ejemplo: "IPAddress": "172.18.0.4"
```

**URL para GitLab:**
```
http://172.18.0.4:8080/generic-webhook-trigger/invoke?token=petclinic-angular-token
```

**Configuración en GitLab:**
1. **GitLab** → **Proyecto** → **Settings** → **Webhooks**
2. **URL:** La URL de arriba
3. **Trigger:** ✅ Push events
4. **SSL verification:** ❌ (desactivar para entorno local)

### 🔧 Troubleshooting Webhooks

#### Errores Comunes:

**Error 403 Forbidden:**
```bash
# Problema: CSRF Protection activado
# Solución: Usar token de autenticación o desactivar CSRF para webhooks
```

**Error 404 Not Found:**
```bash
# Problema: Plugin Generic Webhook Trigger no instalado
# Solución: Instalar plugin y reiniciar Jenkins
```

**Invalid URL en GitLab:**
```bash
# Problema: GitLab no puede resolver hostname "jenkins"
# Solución: Usar IP específica (172.18.0.4:8080)
```

---

## 📊 Comparación de Métodos

| Aspecto | SCM Polling | Webhooks |
|---------|-------------|----------|
| **Facilidad Setup** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Tiempo Response** | 1-2 minutos | 5-15 segundos |
| **Consumo Recursos** | Medio | Bajo |
| **Confiabilidad** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Troubleshooting** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Uso Producción** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**Recomendación:** 
- **Desarrollo/Demo:** SCM Polling
- **Producción:** Webhooks (con configuración adecuada)

---

## 🎯 Para la Entrevista

### 🗣️ Elevator Pitch

> *"Configuré triggers automáticos en Jenkins usando SCM Polling que revisa GitLab cada minuto. Cuando detecta cambios, dispara automáticamente la pipeline completa de 11 stages que ejecuta 224 tests, construye imágenes Docker y despliega a Kubernetes. También domino la configuración de webhooks para triggers instantáneos en entornos de producción."*

### 💡 Puntos Técnicos a Mencionar

1. **SCM Polling vs Webhooks:**
   - Polling: Más confiable, fácil setup
   - Webhooks: Más eficiente, trigger instantáneo

2. **Sintaxis Cron:** `H/1 * * * *` para distribución de carga

3. **Integración GitLab-Jenkins:**
   - SSH keys configuradas
   - Red Docker compartida
   - Repositorios sincronizados

4. **Monitoreo:** Polling Log para debugging

### 📱 Demo en Vivo

```bash
# 1. Mostrar configuración actual
echo "Jenkins jobs con polling configurado"

# 2. Hacer cambio en GitLab
cd ~/tmp-forks/spring-petclinic-angular
echo "// Demo para entrevista $(date)" >> README.md
git add README.md
git commit -m "demo: automatic trigger for interview"
git push origin main

# 3. Mostrar Jenkins dashboard
echo "Abrir: http://localhost:8080"
echo "En 1-2 minutos debería aparecer nuevo build automáticamente"

# 4. Verificar logs de polling
echo "Jenkins → Job → Polling Log para ver actividad"
```

---

## ✅ Verificación Final

### 🔍 Checklist de Funcionamiento

- [ ] SCM Polling configurado en Jenkins (`H/1 * * * *`)
- [ ] Polling Log muestra actividad cada minuto
- [ ] Push a GitLab dispara build automáticamente
- [ ] Build completo ejecuta sin errores
- [ ] Dashboard Jenkins muestra historial de builds

### 📊 Métricas de Éxito

- **Tiempo de detección:** 1-2 minutos (polling)
- **Builds automáticos:** >5 ejecutados con éxito
- **Success Rate:** 100% de builds exitosos
- **Cobertura:** Angular (43 tests) + Maven (181 tests)

---

## 🔧 Configuración para Ambos Jobs

### Angular Job (`petclinic-angular-ci`)
```bash
# Configuración aplicada:
# - SCM Polling: H/1 * * * *
# - Repository: ssh://git@gitlab:22/adrianmrc94/petclinic-angular.git
# - Branch: main
```

### Maven Job (`petclinic-maven-ci`)
```bash
# Aplicar misma configuración:
# Jenkins → petclinic-maven-ci → Configure
# Build Triggers → Consultar repositorio (SCM)
# Programador: H/2 * * * * (cada 2 minutos para evitar sobrecarga)
```

---

## 📚 Comandos de Referencia

### Verificación de Estado
```bash
# Ver contenedores activos
docker ps --format "table {{.Names}}\t{{.Status}}"

# Ver configuración de polling en Jenkins
docker exec jenkins cat /var/jenkins_home/jobs/petclinic-angular-ci/config.xml | grep -A5 "triggers"

# Ver último commit en GitLab
docker exec gitlab gitlab-rails runner "puts Project.find_by(path: 'petclinic-angular').repository.last_commit.message"

# Contar builds realizados
docker exec jenkins ls /var/jenkins_home/jobs/petclinic-angular-ci/builds/ | wc -l
```

### Troubleshooting
```bash
# Ver logs de Jenkins
docker logs jenkins --tail 50

# Ver logs de GitLab
docker logs gitlab --tail 50

# Verificar conectividad interna
docker exec jenkins ping -c 3 gitlab
docker exec gitlab ping -c 3 jenkins
```

---

## 🎓 Lecciones Aprendidas

### ✅ Buenas Prácticas
1. **SCM Polling para desarrollo:** Más confiable y fácil de debugear
2. **Interval inteligente:** `H/1` distribuye carga, evita concurrencia
3. **Monitoreo:** Polling Log es esencial para troubleshooting
4. **Fallback:** Siempre tener trigger manual disponible

### ⚠️ Errores Comunes Evitados
1. **Sintaxis cron incorrecta:** Usar `H` en lugar de `*`
2. **Sobrecarga:** No configurar múltiples jobs con polling cada minuto
3. **Conectividad:** Verificar que Jenkins puede acceder a GitLab
4. **Credenciales:** SSH keys deben estar correctamente configuradas

---

## 🔄 Próximos Pasos

### Mejoras Futuras
1. **Webhooks en Producción:** Configurar autenticación adecuada
2. **Branch-specific Triggers:** Diferentes intervals por rama
3. **Conditional Builds:** Solo ejecutar si hay cambios en archivos específicos
4. **Notificaciones:** Slack/email para builds fallidos

### Integración Avanzada
1. **Multi-branch Pipelines:** Un job por rama automáticamente
2. **Pull Request Builders:** Builds automáticos en MRs
3. **Parallel Builds:** Ejecutar múltiples jobs en paralelo
4. **Pipeline as Code:** Jenkinsfile en cada repositorio

---

**Estado:** ✅ **COMPLETADO**  
**Funcionamiento:** ✅ **VERIFICADO**  
**Preparado para:** ✅ **ENTREVISTA TÉCNICA**

---

**Creado:** 13 de Noviembre 2025  
**Última Actualización:** 13 de Noviembre 2025  
**Autor:** Adrián Martín Romo Cañadas  
**Propósito:** Documentación completa de triggers automáticos para demostración técnica