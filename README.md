# Evolution API en Dokku

[![Evolution API](https://img.shields.io/badge/Evolution%20API-2.2.0-green.svg)](https://github.com/EvolutionAPI/evolution-api)
[![Dokku](https://img.shields.io/badge/Dokku-Compatible-blue.svg)](https://github.com/dokku/dokku)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.1-blue.svg)](https://www.postgresql.org/)

## Descripción

Esta guía explica cómo desplegar [Evolution API](https://evolution-api.com/), una API REST completa para WhatsApp, en un servidor [Dokku](http://dokku.viewdocs.io/dokku/). Dokku es un PaaS ligero que simplifica el despliegue y gestión de aplicaciones usando Docker.

## Requisitos Previos

Antes de continuar, asegúrate de tener:

- Un servidor con [Dokku instalado](http://dokku.viewdocs.io/dokku/getting-started/installation/)
- El [plugin de PostgreSQL](https://github.com/dokku/dokku-postgres) instalado en Dokku
- (Opcional) El [plugin de Let's Encrypt](https://github.com/dokku/dokku-letsencrypt) para certificados SSL
- Dominio apuntando a tu servidor (opcional)

## Instrucciones de Instalación

### 1. Crear la Aplicación

Conéctate a tu servidor Dokku y crea la app `evo`:

```bash
dokku apps:create evo
```

### 2. Configurar PostgreSQL

#### Instalar, Crear y Vincular PostgreSQL

1. Instalar el plugin de PostgreSQL:

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
   ```

2. Crear el servicio PostgreSQL:

   ```bash
   dokku postgres:create evo
   ```

3. Vincular PostgreSQL a la aplicación:

   ```bash
   dokku postgres:link evo evo
   ```

#### Configurar la URI de Conexión

Evolution API requiere `DATABASE_CONNECTION_URI` además de `DATABASE_URL`:

```bash
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
```

#### Generar API Key de Autenticación

Evolution API requiere una API Key global para todas las peticiones. Genera una de forma segura:

**En Linux/macOS:**
```bash
# Genera una API Key aleatoria y segura de 32 caracteres
API_KEY=$(openssl rand -hex 16)
dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"

# Verifica que se configuró correctamente
dokku config:get evo AUTHENTICATION_API_KEY
```

**En Windows (PowerShell):**
```powershell
# Genera una API Key aleatoria y segura de 32 caracteres
$API_KEY = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
ssh tu-servidor "config:set evo AUTHENTICATION_API_KEY=$API_KEY"

# Verifica que se configuró correctamente
ssh tu-servidor "config:get evo AUTHENTICATION_API_KEY"
```

> **Importante**: Guarda esta API Key en un lugar seguro. La necesitarás para todas las peticiones a la API.

#### Crear Usuario y Base de Datos Adicional (Opcional)

Si necesitas un usuario y base de datos adicional para la aplicación, ejecuta los siguientes comandos **uno por uno**:

1. Crear el usuario `evo_app_user`:

   ```bash
   dokku postgres:connect evo << 'EOF'
   DO $$
   BEGIN
       IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'evo_app_user') THEN
           CREATE USER evo_app_user WITH PASSWORD 'jA54%B@rF7$pQs2*Lx8#mZvN9!wY3&tD';
       END IF;
   END
   $$;
   EOF
   ```

2. Crear la base de datos `service_db`:

   ```bash
   dokku postgres:connect evo << 'EOF'
   CREATE DATABASE service_db;
   EOF
   ```

3. Otorgar privilegios:

   ```bash
   dokku postgres:connect evo << 'EOF'
   GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
   EOF
   ```

> **Nota**: Estos comandos son opcionales. La aplicación funciona correctamente con la base de datos principal creada automáticamente por el plugin de PostgreSQL.

### 3. Configurar Almacenamiento Persistente

Para persistir las instancias de WhatsApp entre reinicios, crea y monta un directorio:

```bash
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### 4. Configurar Dominio y Puertos

Configura el dominio para tu aplicación:

```bash
dokku domains:set evo evo.example.com
```

Mapea el puerto interno `8080` al puerto externo `80`:

```bash
dokku ports:set evo http:80:8080
```

### 5. Desplegar la Aplicación

Puedes desplegar la aplicación usando uno de los siguientes métodos:

#### Opción 1: Despliegue con `dokku git:sync`

Si tienes acceso SSH al servidor Dokku, puedes desplegar directamente desde el repositorio oficial:

```bash
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

Esto descargará el código, construirá y desplegará automáticamente.

> **Nota**: Este comando debe ejecutarse desde el servidor Dokku via SSH.

#### Opción 2: Clonar y Push Manual

Si prefieres trabajar localmente (funciona en **Windows, macOS y Linux**):

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/carrilloapps/evolution-api-on-dokku.git
   cd evolution-api-on-dokku
   ```

2. Agregar tu servidor Dokku como remoto:

   **Linux/macOS/Windows (Git Bash):**
   ```bash
   git remote add dokku dokku@tu-servidor.com:evo
   ```

   **Windows (PowerShell/CMD):**
   ```powershell
   git remote add dokku dokku@tu-servidor.com:evo
   ```

3. Hacer push a Dokku:

   ```bash
   git push dokku master
   ```

Elige el método que mejor se adapte a tu flujo de trabajo.

### 6. Habilitar SSL (Opcional)

Asegura tu aplicación con un certificado SSL de Let's Encrypt:

1. Agregar el puerto HTTPS:

   ```bash
   dokku ports:add evo https:443:8080
   ```

2. Instalar el plugin de Let's Encrypt:

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
   ```

3. Configurar el email de contacto:

   ```bash
   dokku letsencrypt:set evo email tu@example.com
   ```

4. Habilitar Let's Encrypt:

   ```bash
   dokku letsencrypt:enable evo
   ```

5. Configurar renovación automática:

   ```bash
   dokku letsencrypt:cron-job --add
   ```

## Finalización

¡Felicidades! Tu instancia de Evolution API está funcionando. Puedes acceder en:

- **HTTP**: `http://evo.example.com`
- **HTTPS**: `https://evo.example.com` (si configuraste SSL)

### Obtener tu API Key

Obtén la API Key que generaste durante la instalación:

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

**Resultado de ejemplo:**
```
oXZkh4B2FETGL31VeOzl6gqsdav9wmC0
```

### Cambiar la API Key

Si deseas cambiar la API Key por una personalizada:

```bash
dokku config:set evo AUTHENTICATION_API_KEY="tu-nueva-api-key-super-segura"
```

### Probar la API

Prueba que la API esté funcionando correctamente:

```bash
# Reemplaza TU_API_KEY con la que obtuviste
curl -X GET https://evo.example.com \
  -H "apikey: oXZkh4B2FETGL31VeOzl6gqsdav9wmC0"
```

Deberías recibir una respuesta exitosa de Evolution API.

## Comandos Útiles

### Logs y Monitoreo

```bash
# Ver logs en tiempo real
dokku logs evo -t

# Ver configuración
dokku config evo
```

### Gestión de PostgreSQL

**Linux/macOS:**
```bash
# Información de PostgreSQL
dokku postgres:info evo

# Conectar a PostgreSQL
dokku postgres:connect evo

# Backup
dokku postgres:backup evo backup-$(date +%Y%m%d)
```

**Windows (PowerShell):**
```powershell
# Información de PostgreSQL
ssh tu-servidor "postgres:info evo"

# Conectar a PostgreSQL
ssh tu-servidor "postgres:connect evo"

# Backup
$fecha = Get-Date -Format "yyyyMMdd"
ssh tu-servidor "postgres:backup evo backup-$fecha"
```

### Actualizaciones

Para actualizar la aplicación:

```bash
git pull origin master
git push dokku master
```

Dokku ejecutará automáticamente las migraciones de Prisma y los health checks.

## Características

- ✅ Solo PostgreSQL (sin Redis/Cache)
- ✅ Migraciones automáticas de Prisma
- ✅ Health checks configurados
- ✅ Almacenamiento persistente
- ✅ Variables de entorno pre-configuradas

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Acknowledgments

- [Evolution API](https://github.com/EvolutionAPI/evolution-api) - The amazing WhatsApp API
- [Dokku](https://dokku.com/) - Docker-powered PaaS
- [PostgreSQL](https://www.postgresql.org/) - Powerful open source database

## Additional Documentation

For more information about Evolution API, visit the [official documentation](https://doc.evolution-api.com/).

### Changelog

This deployment uses Evolution API v2.2.0 which includes stable and tested features.

> **Note**: Newer versions of Evolution API are available but may require additional configuration or testing. This deployment uses v2.2.0 for maximum stability.

For complete changelog and latest releases, visit [Evolution API Releases](https://github.com/EvolutionAPI/evolution-api/releases).
