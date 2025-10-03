# 🏗️ Levantar Jenkins

## 📋 Prerrequisitos

- **Instalar Docker Desktop en Windows** (no dentro del WSL)
  - WSL2 no arranca systemd por defecto
  - El socket de Docker queda invisible para Windows

## ✅ Verificar instalación

```bash
docker run hello-world
```

## 🚀 Pasos de instalación

### 1. Crear volumen para datos persistentes

```bash
docker volume create jenkins_data
```

### 2. Levantar contenedor Jenkins

```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v jenkins_data:/var/jenkins_home \
  jenkins/jenkins:lts
```

**Explicación de parámetros:**
- `-d` → Ejecuta en segundo plano (daemon mode)
- `--name jenkins` → Nombre del contenedor
- `-p 8080:8080` → Mapea puerto web de Jenkins
- `-p 50000:50000` → Puerto para comunicación master-nodos
- `-v jenkins_data:/var/jenkins_home` → Volumen persistente para datos
- `jenkins/jenkins:lts` → Imagen oficial LTS (Long-Term Support)ker

### 3. Obtener contraseña inicial

```bash
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### 4. Configurar Jenkins

- Abrir **http://localhost:8080** en navegador
- Introducir contraseña inicial
- Instalar plugins recomendados
- Crear usuario administrador

