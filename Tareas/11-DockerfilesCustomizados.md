# 🐳 Guía Completa: Dockerfiles Customizados

## 📋 **Índice**
1. [Introducción](#-introducción)
   - [Conceptos Fundamentales: Imagen vs Contenedor](#conceptos-fundamentales-imagen-vs-contenedor)
2. [Anatomía de un Dockerfile](#-anatomía-de-un-dockerfile)
3. [Instrucciones Principales](#-instrucciones-principales)
   - [CMD vs ENTRYPOINT](#9-cmd-vs-entrypoint)
4. [Optimización: Cache de Capas](#-optimización-cache-de-capas)
5. [Por qué usar Alpine Linux](#️-por-qué-usar-alpine-linux)
6. [Multi-Stage Builds](#️-multi-stage-builds)
7. [Mejores Prácticas](#-mejores-prácticas)
8. [Estrategias por Tipo de Aplicación](#-estrategias-por-tipo-de-aplicación)
9. [Dockerfile para Angular](#️-dockerfile-para-angular)
10. [Dockerfile para Java/Maven](#-dockerfile-para-javamaven)
11. [Optimización de Imágenes](#-optimización-de-imágenes)
12. [.dockerignore](#-dockerignore)
13. [Comandos Útiles](#️-comandos-útiles)
14. [Checklist de Validación](#-checklist-de-validación)
15. [Recursos Adicionales](#-recursos-adicionales)
13. [Próximos Pasos](#-próximos-pasos)

---

## 🎯 **Introducción**

### **¿Qué es un Dockerfile?**

Un **Dockerfile** es un archivo de texto que contiene **instrucciones** para construir una imagen Docker de forma automatizada.

```
Dockerfile → docker build → Docker Image → docker run → Container
```

### **¿Por qué crear Dockerfiles customizados?**

- ✅ **Reproducibilidad:** Mismo entorno en desarrollo, testing y producción
- ✅ **Automatización:** Build automático de imágenes
- ✅ **Optimización:** Imágenes más pequeñas y rápidas
- ✅ **Versionado:** Dockerfile en Git junto con el código
- ✅ **CI/CD:** Integración con Jenkins para builds automáticos

### **Flujo de trabajo con Dockerfiles**

```
1. Desarrollador → Escribe código + Dockerfile
2. Git push → GitLab
3. Jenkins → Detecta cambio (webhook)
4. Jenkins → docker build -t myapp:v1.0 .
5. Jenkins → docker push registry:5000/myapp:v1.0
6. Jenkins → kubectl apply deployment.yaml
7. Kubernetes → docker pull registry:5000/myapp:v1.0
8. Aplicación desplegada ✅
```

### **Conceptos Fundamentales: Imagen vs Contenedor**

Es crucial entender esta diferencia antes de crear Dockerfiles:

#### **Imagen Docker**
- 📦 **Plantilla inmutable** (read-only)
- Contiene: código, dependencias, sistema operativo base
- Se construye una vez con `docker build`
- Se almacena en registry
- **Analogía:** Como una **receta de cocina** o un **molde**

#### **Contenedor Docker**
- 🚀 **Instancia en ejecución** de una imagen (read-write)
- Se crea con `docker run`
- Puedes tener múltiples contenedores de la misma imagen
- **Analogía:** Como el **plato cocinado** o el **objeto creado con el molde**

**Ejemplo práctico:**
```bash
# Construir IMAGEN
docker build -t myapp:1.0 .

# Crear múltiples CONTENEDORES desde esa imagen
docker run -d --name app1 myapp:1.0
docker run -d --name app2 myapp:1.0
docker run -d --name app3 myapp:1.0
# Resultado: 1 imagen → 3 contenedores corriendo
```

| Aspecto | Imagen | Contenedor |
|---------|--------|------------|
| Estado | Inmutable | Mutable |
| Almacenamiento | Disco/registry | Memoria RAM |
| Cantidad | Una versión | Múltiples instancias |
| Comando | `docker build` | `docker run` |

---

## 📚 **Anatomía de un Dockerfile**

### **Estructura Básica**

```dockerfile
# Comentario: Imagen base
FROM ubuntu:22.04

# Metadata
LABEL maintainer="tu@email.com"
LABEL version="1.0"

# Variables de entorno
ENV APP_HOME=/app
ENV PORT=8080

# Crear directorios
RUN mkdir -p $APP_HOME

# Establecer directorio de trabajo
WORKDIR $APP_HOME

# Copiar archivos
COPY package.json .
COPY . .

# Instalar dependencias
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    npm install

# Exponer puerto
EXPOSE $PORT

# Usuario no-root (seguridad)
USER node

# Comando por defecto
CMD ["npm", "start"]
```

### **Flujo de ejecución**

```
1. FROM    → Selecciona imagen base
2. LABEL   → Agrega metadata
3. ENV     → Define variables
4. RUN     → Ejecuta comandos (instala cosas)
5. COPY    → Copia archivos del host
6. WORKDIR → Cambia directorio
7. EXPOSE  → Documenta puerto (informativo)
8. USER    → Cambia usuario
9. CMD     → Comando al iniciar contenedor
```

---

## 🔧 **Instrucciones Principales**

<details>
<summary>📚 <b>Referencia Completa de Instrucciones Dockerfile</b> (click para expandir)</summary>

### **1. FROM - Imagen Base**

Define la imagen base sobre la que construyes.

```dockerfile
# Imagen oficial de Node.js
FROM node:18-alpine

# Imagen oficial de Maven
FROM maven:3.9.9-eclipse-temurin-17

# Imagen oficial de Nginx
FROM nginx:alpine

# Imagen base mínima
FROM scratch
```

**Versiones recomendadas:**
- ✅ `alpine` → Más ligera (5-10MB base)
- ⚠️ `slim` → Ligera pero con más herramientas
- ❌ `latest` → Evitar en producción (inestable)

### **2. RUN - Ejecutar Comandos**

Ejecuta comandos durante el **build** de la imagen.

```dockerfile
# ❌ MAL: Múltiples capas
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git

# ✅ BIEN: Una sola capa
RUN apt-get update && \
    apt-get install -y \
        curl \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Cada `RUN` crea una nueva capa** → Combinar comandos reduce tamaño.

### **3. COPY vs ADD**

**COPY:** Copia archivos/directorios del host a la imagen.

```dockerfile
# Copiar un archivo
COPY package.json /app/

# Copiar directorio
COPY src/ /app/src/

# Copiar todo (excepto lo de .dockerignore)
COPY . /app/
```

**ADD:** Como COPY pero con funciones extra (auto-extrae tar, descarga URLs).

```dockerfile
# Descargar archivo
ADD https://example.com/file.tar.gz /tmp/

# Extraer tar automáticamente
ADD archive.tar.gz /app/
```

**Recomendación:** Usa `COPY` siempre que puedas (más explícito).

### **4. WORKDIR - Directorio de Trabajo**

Establece el directorio donde se ejecutan los comandos.

```dockerfile
# ❌ MAL
RUN cd /app
RUN npm install

# ✅ BIEN
WORKDIR /app
RUN npm install
```

### **5. ENV - Variables de Entorno**

Define variables de entorno disponibles en tiempo de **build** y **runtime**.

```dockerfile
ENV NODE_ENV=production
ENV PORT=8080
ENV APP_VERSION=1.0.0

# Usar variables
RUN echo "Building version $APP_VERSION"
```

### **6. ARG - Argumentos de Build**

Variables disponibles **solo durante el build**.

```dockerfile
ARG NODE_VERSION=18
FROM node:${NODE_VERSION}-alpine

ARG BUILD_DATE
LABEL build-date=$BUILD_DATE
```

Usar al construir:
```bash
docker build --build-arg NODE_VERSION=20 --build-arg BUILD_DATE=$(date) .
```

### **7. EXPOSE - Documentar Puerto**

**No abre puertos**, solo documenta qué puerto usa la aplicación.

```dockerfile
EXPOSE 8080
EXPOSE 3000
```

Para realmente exponer puerto:
```bash
docker run -p 8080:8080 myapp
```

### **8. USER - Cambiar Usuario**

Cambia el usuario que ejecuta comandos (seguridad).

```dockerfile
# ❌ MAL: Correr como root
FROM node:18-alpine
WORKDIR /app
COPY . .
CMD ["npm", "start"]

# ✅ BIEN: Correr como usuario no-root
FROM node:18-alpine
WORKDIR /app
COPY . .
RUN chown -R node:node /app
USER node
CMD ["npm", "start"]
```

### **9. CMD vs ENTRYPOINT**

Define qué comando ejecuta el contenedor al iniciarse.

#### **CMD - Comando por defecto (flexible)**

```dockerfile
CMD ["npm", "start"]
```

**Se puede sobrescribir fácilmente:**

```bash
docker run myapp              # Ejecuta: npm start
docker run myapp npm test     # Ejecuta: npm test (sobrescribe CMD)
docker run myapp sh           # Ejecuta: sh (sobrescribe CMD)
```

**Usa CMD cuando:**
- ✅ Quieres un comando por defecto pero flexible
- ✅ Es para desarrollo/testing
- ✅ Los usuarios pueden querer ejecutar otros comandos

#### **ENTRYPOINT - Comando fijo (rígido)**

```dockerfile
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]
```

**No se sobrescribe, solo se agregan argumentos:**

```bash
docker run myapp                    # Ejecuta: nginx -g daemon off;
docker run myapp -h                 # Ejecuta: nginx -h
docker run myapp -t                 # Ejecuta: nginx -t
```

**Usa ENTRYPOINT cuando:**
- ✅ El contenedor SIEMPRE debe ejecutar ese comando
- ✅ Es una aplicación de producción
- ✅ Quieres que se comporte como un ejecutable

#### **Combinación CMD + ENTRYPOINT (recomendado)**

```dockerfile
ENTRYPOINT ["java", "-jar"]
CMD ["app.jar"]
```

```bash
docker run myapp              # Ejecuta: java -jar app.jar
docker run myapp otro.jar     # Ejecuta: java -jar otro.jar (sobrescribe CMD)
```

| Aspecto | CMD | ENTRYPOINT |
|---------|-----|------------|
| **Propósito** | Comando por defecto | Comando principal fijo |
| **Sobrescribir** | Fácil | Difícil (--entrypoint) |
| **Uso típico** | Scripts, desarrollo | Aplicaciones, producción |
| **Flexibilidad** | Alta | Baja |

### **10. VOLUME - Volúmenes**

Declara puntos de montaje para persistencia.

```dockerfile
VOLUME /app/data
VOLUME /var/log/myapp
```

</details>

---

## 🚀 **Optimización: Cache de Capas**

### **¿Cómo funciona el cache?**

Docker construye imágenes en **capas**. Cada instrucción (`FROM`, `RUN`, `COPY`) crea una nueva capa.

**Si una capa no cambia, Docker la reutiliza (cache) → Builds más rápidos.**

### **Ejemplo sin optimizar (❌ Mal):**

```dockerfile
FROM node:18
WORKDIR /app
COPY . .                    # Copia TODO (cambia frecuentemente)
RUN npm install             # Se re-ejecuta cada vez que cambias código
CMD ["npm", "start"]
```

**Problema:** Cambias 1 línea de código → `npm install` se vuelve a ejecutar (¡5 minutos!)

### **Ejemplo optimizado (✅ Bien):**

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./       # Solo dependencias (cambian poco)
RUN npm install             # Se cachea si package.json no cambia
COPY . .                    # Código (cambia frecuentemente)
CMD ["npm", "start"]
```

**Beneficio:** Cambias código → `npm install` usa cache → Build en ¡1 segundo!

### **Visualización del cache:**

```
Build 1 (todo desde cero):
FROM node:18              ✅ Creada (300MB)
COPY package*.json        ✅ Creada (0.1MB)
RUN npm install           ✅ Creada (100MB) - 5 minutos
COPY . .                  ✅ Creada (50MB)
Total: 5 minutos

Build 2 (cambias código):
FROM node:18              ♻️ Cache
COPY package*.json        ♻️ Cache (igual)
RUN npm install           ♻️ Cache (omite npm install)
COPY . .                  ✅ Nueva (código cambió)
Total: 5 segundos
```

### **Reglas de oro:**
1. **Copiar dependencias primero** (cambian poco)
2. **Copiar código después** (cambia frecuentemente)
3. **Ordenar de menos cambiante a más cambiante**

---

## �️ **Por qué usar Alpine Linux**

### **¿Qué es Alpine?**

Distribución Linux **ultra minimalista** diseñada específicamente para contenedores.

### **Comparación de tamaños:**

| Imagen Base | Tamaño Base | Con Node.js |
|-------------|-------------|-------------|
| `ubuntu:22.04` | 77MB | ~1GB |
| `debian:bullseye` | 124MB | ~900MB |
| `alpine:3.18` | **5MB** | **175MB** |

**Reducción: 85% menos tamaño**

### **Ventajas de Alpine:**

✅ **Tamaño reducido:**
- Descargas 10x más rápidas
- Menos uso de disco y RAM
- Builds más rápidos

✅ **Seguridad:**
- Menos software = menos vulnerabilidades
- Menor superficie de ataque

✅ **Velocidad:**
- Inicios más rápidos
- Deploys más rápidos

### **Imágenes Alpine recomendadas:**

```dockerfile
FROM node:18-alpine        # Node.js
FROM python:3.11-alpine    # Python
FROM nginx:alpine          # Nginx
FROM eclipse-temurin:17-jre-alpine  # Java
```

### **¿Cuándo NO usar Alpine?**

- ⚠️ Software que requiere `glibc` específicamente (Alpine usa `musl`)
- ⚠️ Binarios propietarios que solo funcionan en Ubuntu/Debian
- ⚠️ Cuando necesitas herramientas de debugging avanzadas

**Recomendación:** Usa Alpine siempre que puedas. Solo usa Debian/Ubuntu si tienes problemas de compatibilidad.

---

## �🏗️ **Multi-Stage Builds**

### **¿Qué son y por qué usarlos?**

Usar **múltiples imágenes base** en un solo Dockerfile para separar el proceso de construcción y ejecución.

#### **Problema sin multi-stage:**

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install        # Instala TODO (dev + prod)
RUN npm run build
CMD ["npm", "start"]
```

**Resultado:** Imagen de **600MB** con:
- ❌ DevDependencies innecesarias (webpack, typescript)
- ❌ Código fuente sin compilar
- ❌ Herramientas de build que no se usan en producción

#### **Solución con multi-stage:**

```dockerfile
# Stage 1: Build (pesado)
FROM node:18 AS builder
RUN npm install && npm run build

# Stage 2: Production (ligero)
FROM node:18-alpine
COPY --from=builder /app/dist ./dist
RUN npm install --only=production
```

**Resultado:** Imagen de **150MB** (75% reducción)

**Beneficios:**
- ✅ Imagen final solo con lo necesario para ejecutar
- ✅ Más segura (menos software = menos vulnerabilidades)
- ✅ Descargas y deploys más rápidos

**Analogía:** Es como construir un mueble en un taller (Stage 1) y solo llevar el mueble terminado a casa (Stage 2), sin las herramientas.

### **Ejemplo completo: Aplicación Node.js**

```dockerfile
# ========== STAGE 1: Build ==========
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias (incluye devDependencies)
RUN npm ci

# Copiar código fuente
COPY . .

# Compilar aplicación (si usa TypeScript, webpack, etc.)
RUN npm run build

# ========== STAGE 2: Production ==========
FROM node:18-alpine

WORKDIR /app

# Copiar solo package.json
COPY package*.json ./

# Instalar SOLO dependencias de producción
RUN npm ci --only=production

# Copiar artefactos del stage anterior
COPY --from=builder /app/dist ./dist

# Usuario no-root
USER node

# Exponer puerto
EXPOSE 3000

# Comando de inicio
CMD ["node", "dist/index.js"]
```

**Ventajas:**
- ✅ Stage 1: 500MB (con devDependencies, compiladores)
- ✅ Stage 2: 150MB (solo runtime + producción)
- ✅ Imagen final: Solo 150MB

### **Ejemplo: Aplicación Java/Maven**

```dockerfile
# ========== STAGE 1: Build ==========
FROM maven:3.9.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copiar pom.xml primero (cache de dependencias)
COPY pom.xml .

# Descargar dependencias
RUN mvn dependency:go-offline

# Copiar código fuente
COPY src ./src

# Compilar y empaquetar
RUN mvn clean package -DskipTests

# ========== STAGE 2: Production ==========
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copiar solo el JAR del stage anterior
COPY --from=builder /app/target/*.jar app.jar

# Usuario no-root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Exponer puerto
EXPOSE 8080

# Comando de inicio
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**Ventajas:**
- ✅ Stage 1: 800MB (Maven + JDK + dependencias)
- ✅ Stage 2: 200MB (solo JRE + JAR)
- ✅ Imagen final: Solo 200MB

### **Ejemplo: Aplicación Angular**

```dockerfile
# ========== STAGE 1: Build ==========
FROM node:18-alpine AS builder

WORKDIR /app

# Copiar package.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Compilar para producción
RUN npm run build --prod

# ========== STAGE 2: Production ==========
FROM nginx:alpine

# Copiar archivos compilados
COPY --from=builder /app/dist/petclinic-angular /usr/share/nginx/html

# Copiar configuración de nginx (opcional)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto
EXPOSE 80

# Nginx se inicia automáticamente
CMD ["nginx", "-g", "daemon off;"]
```

**Ventajas:**
- ✅ Stage 1: 600MB (Node + dependencias + compilación)
- ✅ Stage 2: 50MB (Nginx + archivos estáticos)
- ✅ Imagen final: Solo 50MB

---

## ⚡ **Mejores Prácticas**

<details>
<summary>✨ <b>Top 8 Mejores Prácticas para Dockerfiles</b> (click para expandir)</summary>

### **1. Orden de las Capas (Cache)**

Docker cachea capas que no cambian → **Orden importa**.

```dockerfile
# ❌ MAL: Cachea poco
FROM node:18-alpine
WORKDIR /app
COPY . .                    # Copia TODO (cambia frecuentemente)
RUN npm install             # Se re-ejecuta cada vez

# ✅ BIEN: Aprovecha cache
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./       # Solo dependencias (cambian poco)
RUN npm ci                  # Se cachea si package.json no cambia
COPY . .                    # Copia código (cambia frecuentemente)
```

### **2. Usar .dockerignore**

Excluir archivos innecesarios del contexto de build.

```
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
.env
.vscode
coverage
dist
*.md
Dockerfile
.dockerignore
```

### **3. Minimizar Capas**

```dockerfile
# ❌ MAL: 5 capas
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# ✅ BIEN: 1 capa
RUN apt-get update && \
    apt-get install -y curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### **4. No incluir secretos**

```dockerfile
# ❌ MAL: Secretos en la imagen
ENV DB_PASSWORD=mysecret123
COPY .env .

# ✅ BIEN: Pasar en runtime
# docker run -e DB_PASSWORD=secret myapp
```

### **5. Usar imágenes oficiales y ligeras**

```dockerfile
# ❌ Pesada: 1GB
FROM ubuntu:22.04

# ✅ Ligera: 40MB
FROM node:18-alpine

# ✅ Más ligera: 5MB
FROM alpine:3.18
```

### **6. Usuario no-root**

```dockerfile
# ✅ Crear usuario
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

### **7. Health checks**

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

### **8. Labels para metadata**

```dockerfile
LABEL org.opencontainers.image.title="Petclinic Angular"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="adrianmrc94@example.com"
LABEL org.opencontainers.image.source="https://gitlab/adrianmrc94/petclinic-angular"
```

</details>

---

## 📋 **Estrategias por Tipo de Aplicación**

### **¿Qué va en cada Stage?**

#### **STAGE 1: Builder (Compilación)**

**Propósito:** Compilar/construir la aplicación

**Debe incluir:**
- ✅ Herramientas de build (Maven, npm, webpack)
- ✅ Compiladores (JDK, TypeScript, Babel)
- ✅ Dependencias de desarrollo
- ✅ Código fuente completo

**NO se incluye en la imagen final** (se descarta después del build)

#### **STAGE 2: Production (Runtime)**

**Propósito:** Ejecutar la aplicación en producción

**Debe incluir SOLO:**
- ✅ Runtime mínimo (JRE, nginx, node slim)
- ✅ Artefacto compilado (JAR, /dist)
- ✅ Dependencias de producción
- ✅ Archivos de configuración

**NO debe incluir:**
- ❌ Herramientas de build
- ❌ Código fuente
- ❌ DevDependencies
- ❌ Tests

### **Optimización: Angular vs Java**

| Aspecto | Angular | Java/Maven |
|---------|---------|------------|
| **Build** | `npm run build` | `mvn package` |
| **Artefacto** | Archivos HTML/CSS/JS | JAR ejecutable |
| **Runtime** | nginx (50MB) | JRE (200MB) |
| **Stage 1** | node:18-alpine | maven + JDK |
| **Stage 2** | nginx:alpine | JRE alpine |
| **Tamaño final** | ~50MB | ~200MB |
| **Puerto** | 80 | 8080 |

**Clave Angular:** No necesita Node en producción (solo nginx para servir archivos estáticos)

**Clave Java:** No necesita Maven ni JDK en producción (solo JRE para ejecutar JAR)

---

## �🅰️ **Dockerfile para Angular**

### **Dockerfile Completo para Petclinic Angular**

```dockerfile
# ========================================
# STAGE 1: Build Angular Application
# ========================================
FROM node:18-alpine AS builder

# Metadata
LABEL stage=builder
LABEL app=petclinic-angular

# Directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package.json package-lock.json ./

# Instalar dependencias
RUN npm ci --legacy-peer-deps

# Copiar código fuente
COPY . .

# Compilar aplicación para producción
RUN npm run build -- --configuration production

# ========================================
# STAGE 2: Serve with Nginx
# ========================================
FROM nginx:alpine

# Metadata
LABEL maintainer="adrianmrc94@example.com"
LABEL version="1.0.0"
LABEL description="Petclinic Angular Application"

# Copiar archivos compilados desde el stage anterior
COPY --from=builder /app/dist/petclinic-angular /usr/share/nginx/html

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Exponer puerto 80
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80 || exit 1

# Nginx inicia automáticamente
CMD ["nginx", "-g", "daemon off;"]
```

### **nginx.conf para Angular**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Habilitar gzip
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml+rss text/javascript;

    # Configuración para SPA (Single Page Application)
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache para archivos estáticos
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Desactivar cache para index.html
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }

    # Logs
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
}
```

### **.dockerignore para Angular**

```
# Dependencias
node_modules
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Directorio de salida
dist
dist-server

# IDE
.vscode
.idea
*.swp
*.swo
*~

# Testing
coverage
.nyc_output

# Git
.git
.gitignore

# Varios
.DS_Store
Thumbs.db
.env
.env.local
.env.production
*.md
Dockerfile
.dockerignore

# Angular específico
.angular
```

---

## ☕ **Dockerfile para Java/Maven**

### **Dockerfile Completo para Petclinic Maven**

```dockerfile
# ========================================
# STAGE 1: Build with Maven
# ========================================
FROM maven:3.9.9-eclipse-temurin-17 AS builder

# Metadata
LABEL stage=builder
LABEL app=petclinic-maven

# Directorio de trabajo
WORKDIR /app

# Copiar pom.xml primero (optimización de cache)
COPY pom.xml .

# Descargar dependencias (se cachea si pom.xml no cambia)
RUN mvn dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar y empaquetar (sin ejecutar tests)
RUN mvn clean package -DskipTests -B

# ========================================
# STAGE 2: Runtime with JRE
# ========================================
FROM eclipse-temurin:17-jre-alpine

# Metadata
LABEL maintainer="adrianmrc94@example.com"
LABEL version="1.0.0"
LABEL description="Spring PetClinic Application"

# Directorio de trabajo
WORKDIR /app

# Copiar JAR desde stage anterior
COPY --from=builder /app/target/*.jar app.jar

# Crear usuario no-root
RUN addgroup -S spring && adduser -S spring -G spring

# Cambiar permisos
RUN chown -R spring:spring /app

# Cambiar a usuario no-root
USER spring:spring

# Exponer puerto
EXPOSE 8080

# Variables de entorno (pueden sobrescribirse)
ENV JAVA_OPTS=""
ENV SPRING_PROFILES_ACTIVE=production

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:8080/actuator/health || exit 1

# Comando de inicio
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
```

### **.dockerignore para Maven**

```
# Maven
target
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties

# IDE
.idea
*.iws
*.iml
*.ipr
.vscode
.classpath
.project
.settings

# Logs
*.log

# Git
.git
.gitignore

# Varios
.DS_Store
Thumbs.db
.env
.env.local
.env.production
*.md
Dockerfile
.dockerignore

# Tests
coverage

# OS
Thumbs.db
desktop.ini
```

---

## 📊 **Optimización de Imágenes**

### **Comparación de Tamaños**

| Aplicación | Sin optimizar | Optimizada | Reducción |
|------------|---------------|------------|-----------|
| Angular | 600MB | 50MB | 92% |
| Java/Maven | 800MB | 200MB | 75% |
| Node.js | 500MB | 150MB | 70% |

### **Técnicas de Optimización**

#### **1. Multi-stage builds**
```dockerfile
# Build: 800MB
FROM maven:3.9.9-eclipse-temurin-17 AS builder
# ... build steps ...

# Runtime: 200MB
FROM eclipse-temurin:17-jre-alpine
COPY --from=builder /app/target/*.jar app.jar
```

#### **2. Usar Alpine**
```dockerfile
# Ubuntu: 77MB base
FROM ubuntu:22.04

# Alpine: 5MB base
FROM alpine:3.18
```

#### **3. Limpiar en mismo RUN**
```dockerfile
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

#### **4. Copiar solo necesario**
```dockerfile
# ❌ Copia TODO
COPY . .

# ✅ Copia selectivo
COPY package*.json ./
COPY src ./src
```

### **Herramientas de Análisis**

#### **dive - Explorar capas de imagen**
```bash
# Instalar dive
wget https://github.com/wagoodman/dive/releases/download/v0.10.0/dive_0.10.0_linux_amd64.deb
sudo dpkg -i dive_0.10.0_linux_amd64.deb

# Analizar imagen
dive registry:5000/petclinic-angular:latest
```

#### **docker history - Ver capas**
```bash
docker history registry:5000/petclinic-angular:latest
```

#### **docker images - Ver tamaños**
```bash
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
```

---

## 🚫 **.dockerignore**

### **¿Qué es?**

Archivo que especifica qué **NO** incluir en el contexto de build de Docker.

**Beneficios:**
- ✅ Builds más rápidos (menos archivos a copiar)
- ✅ Imágenes más pequeñas
- ✅ No incluir secretos accidentalmente

### **Sintaxis**

```
# Comentario

# Excluir archivos específicos
.env
secrets.txt

# Excluir directorios
node_modules
dist
coverage

# Excluir por extensión
*.log
*.tmp
*.swp

# Excluir todo excepto...
*
!src
!package.json
```

### **Ejemplo Completo**

```
# Dependencias
node_modules
bower_components

# Build artifacts
dist
build
target
*.jar
*.war

# Logs
*.log
logs

# Testing
coverage
.nyc_output
test-results

# IDEs
.vscode
.idea
*.swp
*.swo

# Git
.git
.gitignore
.gitattributes

# CI/CD
.github
.gitlab-ci.yml
Jenkinsfile

# Docker
Dockerfile
.dockerignore
docker-compose.yml

# Docs
*.md
docs

# Temporales
.DS_Store
Thumbs.db
*.tmp
*.bak

# Secrets
.env
.env.local
*.key
*.pem
```

---

## 🛠️ **Comandos Útiles**

### **Build**

```bash
# Build básico
docker build -t myapp:latest .

# Build con tag específico
docker build -t myapp:v1.0.0 .

# Build sin cache
docker build --no-cache -t myapp:latest .

# Build con argumentos
docker build --build-arg NODE_VERSION=18 -t myapp:latest .

# Build con target específico (multi-stage)
docker build --target builder -t myapp:builder .

# Ver progreso detallado
docker build --progress=plain -t myapp:latest .
```

### **Inspeccionar**

```bash
# Ver capas de la imagen
docker history myapp:latest

# Ver configuración completa
docker inspect myapp:latest

# Ver tamaño de la imagen
docker images myapp:latest

# Analizar con dive
dive myapp:latest
```

### **Test**

```bash
# Ejecutar contenedor
docker run --rm -p 8080:8080 myapp:latest

# Ejecutar con variables de entorno
docker run --rm -e NODE_ENV=production -p 8080:8080 myapp:latest

# Ejecutar en modo interactivo
docker run --rm -it myapp:latest sh

# Ver logs
docker logs -f <container_id>
```

### **Push a Registry**

```bash
# Tag para registry
docker tag myapp:latest registry:5000/myapp:latest

# Push
docker push registry:5000/myapp:latest

# Verificar en registry
curl http://registry:5000/v2/_catalog
curl http://registry:5000/v2/myapp/tags/list
```

---

## ✅ **Checklist de Validación**

Antes de considerar tu Dockerfile listo, verifica:

### **Funcionalidad**
- [ ] La imagen se construye sin errores
- [ ] El contenedor inicia correctamente
- [ ] La aplicación responde en el puerto esperado
- [ ] Los logs se ven correctamente

### **Optimización**
- [ ] Usa multi-stage builds
- [ ] Usa imagen base Alpine cuando sea posible
- [ ] Ordena COPY para aprovechar cache
- [ ] Combina comandos RUN
- [ ] Usa .dockerignore

### **Seguridad**
- [ ] No incluye secretos hardcodeados
- [ ] Corre como usuario no-root
- [ ] No expone puertos innecesarios
- [ ] Imagen base es de fuente confiable
- [ ] Dependencias están actualizadas

### **Mantenibilidad**
- [ ] Tiene labels con metadata
- [ ] Está comentado
- [ ] Usa variables de entorno
- [ ] Tiene health check
- [ ] Está versionado en Git

---

## 📖 **Recursos Adicionales**

### **Documentación Oficial**
- [Dockerfile reference](https://docs.docker.com/engine/reference/builder/)
- [Best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-stage builds](https://docs.docker.com/build/building/multi-stage/)

### **Herramientas**
- [dive](https://github.com/wagoodman/dive) - Explorar capas de imágenes
- [hadolint](https://github.com/hadolint/hadolint) - Linter para Dockerfiles
- [docker-slim](https://github.com/docker-slim/docker-slim) - Minimizar imágenes

### **Ejemplos**
- [Awesome Docker](https://github.com/veggiemonk/awesome-docker)
- [Docker Official Images](https://github.com/docker-library/official-images)

---

---

**Documentación creada:** Octubre 2025  
**Última actualización:** Octubre 2025  
**Versión:** 1.0
