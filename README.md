# Evolution API - Dokku

Evolution API v2.2.0 desplegado en Dokku con PostgreSQL.

## 🚀 Deploy Automático

### 1. Configuración Mínima en el Servidor:

```bash
# Crear app y PostgreSQL
dokku apps:create evo
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
dokku postgres:create evo
dokku postgres:link evo evo

# Configurar puertos y almacenamiento
dokku ports:set evo http:80:8080
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### 2. Deploy desde tu Máquina:

```bash
git push dokku master
```

**¡Eso es todo!** El resto se configura automáticamente:
- ✅ Variables de entorno con valores por defecto
- ✅ DATABASE_CONNECTION_URI desde DATABASE_URL
- ✅ Health checks configurados
- ✅ API key generado automáticamente

### 3. (Opcional) Inicializar usuarios adicionales de DB:

```bash
dokku postgres:connect evo << 'EOF'
CREATE USER evo_app_user WITH PASSWORD 'tu_password_seguro';
CREATE DATABASE service_db OWNER evo_app_user;
GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
EOF
```

## 📊 Comandos Útiles

```bash
# Ver logs
dokku logs evo -t

# Ver configuración (incluyendo API key generado)
dokku config evo

# Reiniciar
dokku ps:restart evo

# PostgreSQL
dokku postgres:info evo
dokku postgres:backup evo backup-$(date +%Y%m%d)

# SSL
dokku letsencrypt:enable evo
```

## 🔐 Obtener API Key

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

## 🌐 Desarrollo Local

```bash
cp .env.example .env
docker-compose up -d
```
