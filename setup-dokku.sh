#!/bin/bash
# Script de configuración para ejecutar EN EL SERVIDOR DOKKU
# Copia y pega estos comandos directamente en el servidor

dokku apps:create evo 2>/dev/null || echo "✓ App existe"
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres 2>/dev/null || echo "✓ Plugin instalado"
dokku postgres:create evo 2>/dev/null || echo "✓ PostgreSQL existe"
dokku postgres:link evo evo 2>/dev/null || echo "✓ PostgreSQL vinculado"

# Ejecutar script de inicialización de base de datos
echo "Ejecutando script de inicialización..."
dokku postgres:connect evo << 'EOF'
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'evo_app_user') THEN
        CREATE USER evo_app_user WITH PASSWORD 'jA54%B@rF7$pQs2*Lx8#mZvN9!wY3&tD';
    END IF;
END
$$;

DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'service_db') THEN
        CREATE DATABASE service_db;
    END IF;
END
$$;

GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
EOF

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

dokku ports:set evo http:80:8080
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances

echo ""
echo "✅ Configuración completa. Ahora ejecuta: git push dokku master"
echo "🔑 API Key: $(dokku config:get evo AUTHENTICATION_API_KEY)"
