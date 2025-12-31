#!/bin/bash
# Ejecutar ANTES del primer deploy
# Este script debe ejecutarse EN EL SERVIDOR DOKKU

set -e

APP_NAME="evo"

echo "🚀 Configuración previa al deploy de $APP_NAME"
echo ""

# Crear la app
echo "📦 Creando app Dokku..."
dokku apps:create $APP_NAME 2>/dev/null || echo "App ya existe"

# Instalar plugin de PostgreSQL
echo ""
echo "🔌 Instalando plugin de PostgreSQL..."
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres 2>/dev/null || echo "Plugin ya instalado"

# Crear servicio PostgreSQL
echo ""
echo "🗄️  Creando servicio PostgreSQL..."
dokku postgres:create $APP_NAME 2>/dev/null || echo "Servicio PostgreSQL ya existe"

# Vincular PostgreSQL a la app
echo ""
echo "🔗 Vinculando PostgreSQL a la app..."
dokku postgres:link $APP_NAME $APP_NAME 2>/dev/null || echo "PostgreSQL ya está vinculado"

echo ""
echo "1️⃣ Configurando variables de entorno básicas..."
dokku config:set --no-restart $APP_NAME \
  AUTHENTICATION_API_KEY="$(openssl rand -hex 16)" \
  CONFIG_SESSION_PHONE_VERSION="2.3000.1031543708" \
  CONFIG_SESSION_PHONE_CLIENT="carrilloapps" \
  CONFIG_SESSION_PHONE_NAME="Chrome" \
  DATABASE_ENABLED="true" \
  DATABASE_PROVIDER="postgresql" \
  DATABASE_CONNECTION_CLIENT_NAME="evolution_exchange" \
  DATABASE_SAVE_DATA_INSTANCE="true" \
  DATABASE_SAVE_DATA_NEW_MESSAGE="true" \
  DATABASE_SAVE_MESSAGE_UPDATE="true" \
  DATABASE_SAVE_DATA_CONTACTS="true" \
  DATABASE_SAVE_DATA_CHATS="true" \
  DATABASE_SAVE_DATA_LABELS="true" \
  DATABASE_SAVE_DATA_HISTORIC="true" \
  CACHE_LOCAL_ENABLED="true"

# Obtener DATABASE_URL y configurar DATABASE_CONNECTION_URI
echo ""
echo "⚙️  Configurando DATABASE_CONNECTION_URI..."
DB_URL=$(dokku config:get $APP_NAME DATABASE_URL)
if [ ! -z "$DB_URL" ]; then
  dokku config:set --no-restart $APP_NAME DATABASE_CONNECTION_URI="$DB_URL"
  echo "DATABASE_CONNECTION_URI configurado correctamente"
else
  echo "⚠️  WARNING: DATABASE_URL no encontrado. Asegúrate de que postgres:link se ejecutó correctamente."
fi

echo ""
echo "2️⃣ Configurando mapeo de puertos..."
dokku ports:set $APP_NAME http:80:8080

echo ""
echo "3️⃣ Configurando almacenamiento persistente..."
dokku storage:ensure-directory $APP_NAME
dokku storage:mount $APP_NAME /var/lib/dokku/data/storage/$APP_NAME:/evolution/instances

echo ""
echo "✅ Configuración completada!"
echo ""
echo "🔑 Tu API key: $(dokku config:get $APP_NAME AUTHENTICATION_API_KEY)"
echo ""
echo "📝 Próximo paso:"
echo "   Desde tu máquina local ejecuta: git push dokku master"
echo ""
echo "📊 Comandos útiles:"
echo "   - Ver logs: dokku logs $APP_NAME -t"
echo "   - Ver config: dokku config $APP_NAME"
echo "   - Info PostgreSQL: dokku postgres:info $APP_NAME"
echo ""
