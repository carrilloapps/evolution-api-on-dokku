#!/bin/bash

# Evolution API - Dokku Setup Script
# This script configures the Dokku app and PostgreSQL service

set -e

APP_NAME="${1:-evo}"
POSTGRES_SERVICE="${APP_NAME}-postgres"

echo "🚀 Setting up Dokku app: $APP_NAME"

# Create the app if it doesn't exist
echo "📦 Creating Dokku app..."
dokku apps:create "$APP_NAME" 2>/dev/null || echo "App already exists"

# Install postgres plugin if not installed
echo "🔌 Checking PostgreSQL plugin..."
dokku plugin:list | grep postgres || sudo dokku plugin:install https://github.com/dokku/dokku-postgres.git

# Create PostgreSQL service
echo "🗄️  Creating PostgreSQL service..."
dokku postgres:create "$POSTGRES_SERVICE" --image-version 16 2>/dev/null || echo "PostgreSQL service already exists"

# Link PostgreSQL to the app
echo "🔗 Linking PostgreSQL to app..."
dokku postgres:link "$POSTGRES_SERVICE" "$APP_NAME"

# Set port mapping (internal 8080 -> external PORT assigned by Dokku)
echo "🔧 Configuring ports..."
dokku ports:set "$APP_NAME" http:80:8080

# Set environment variables
echo "⚙️  Setting environment variables..."
dokku config:set "$APP_NAME" \
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

# Create persistent storage for instances
echo "💾 Setting up persistent storage..."
dokku storage:ensure-directory "$APP_NAME"
dokku storage:mount "$APP_NAME" /var/lib/dokku/data/storage/"$APP_NAME":/evolution/instances

# Get the DATABASE_URL and format it correctly
DB_URL=$(dokku config:get "$APP_NAME" DATABASE_URL)
if [ ! -z "$DB_URL" ]; then
  dokku config:set "$APP_NAME" DATABASE_CONNECTION_URI="$DB_URL"
fi

echo ""
echo "✅ Setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Add git remote: git remote add dokku dokku@your-host:$APP_NAME"
echo "   2. Push to deploy: git push dokku master"
echo ""
echo "🔑 Your API key: $(dokku config:get $APP_NAME AUTHENTICATION_API_KEY)"
echo ""
echo "📊 Useful commands:"
echo "   - View logs: dokku logs $APP_NAME -t"
echo "   - View config: dokku config $APP_NAME"
echo "   - Restart app: dokku ps:restart $APP_NAME"
echo "   - PostgreSQL info: dokku postgres:info $POSTGRES_SERVICE"
echo ""
