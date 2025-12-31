# Evolution API - Dokku

Evolution API v2.2.0 desplegado en Dokku con PostgreSQL.

## 🚀 Deploy Rápido

### En el Servidor Dokku (ejecutar primero):

```bash
# Crear app y configurar PostgreSQL
dokku apps:create evo
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku postgres:create evo
dokku postgres:link evo evo

# Configurar variables de entorno
DB_URL=$(dokku config:get evo DATABASE_URL)
dokku config:set --no-restart evo \
  AUTHENTICATION_API_KEY="$(openssl rand -hex 32)" \
  DATABASE_ENABLED="true" \
  DATABASE_PROVIDER="postgresql" \
  DATABASE_CONNECTION_URI="$DB_URL" \
  DATABASE_CONNECTION_CLIENT_NAME="evolution_exchange" \
  DATABASE_SAVE_DATA_INSTANCE="true" \
  DATABASE_SAVE_DATA_NEW_MESSAGE="true" \
  DATABASE_SAVE_MESSAGE_UPDATE="true" \
  DATABASE_SAVE_DATA_CONTACTS="true" \
  DATABASE_SAVE_DATA_CHATS="true" \
  DATABASE_SAVE_DATA_LABELS="true" \
  DATABASE_SAVE_DATA_HISTORIC="true" \
  CACHE_LOCAL_ENABLED="true" \
  CONFIG_SESSION_PHONE_VERSION="2.3000.1031543708" \
  CONFIG_SESSION_PHONE_CLIENT="carrilloapps" \
  CONFIG_SESSION_PHONE_NAME="Chrome"

# Configurar puertos y almacenamiento
dokku ports:set evo http:80:8080
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### Desde tu Máquina Local:

```bash
git remote add dokku dokku@your-server:evo
git push dokku master
```

## 📊 Comandos Útiles

```bash
# Logs
dokku logs evo -t

# Reiniciar
dokku ps:restart evo

# Ver configuración
dokku config evo

# PostgreSQL
dokku postgres:info evo
dokku postgres:connect evo
dokku postgres:backup evo backup-$(date +%Y%m%d)

# SSL (Let's Encrypt)
dokku letsencrypt:enable evo
```

## 🔐 API Key

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

## 🌐 Desarrollo Local

```bash
cp .env.example .env
docker-compose up -d
```

## 📁 Estructura

- `Dockerfile` - Build de la imagen
- `CHECKS` - Health checks de Dokku
- `DOKKU_SCALE` - Configuración de procesos
- `.env.example` - Variables de entorno de ejemplo
- `docker-compose.yaml` - Setup local
- `init-db.sql` - Script inicial de PostgreSQL
