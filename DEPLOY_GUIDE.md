# 🚀 Guía Rápida de Deploy - Evolution API en Dokku

## ⚠️ IMPORTANTE: Ejecutar PRIMERO en el servidor Dokku

### Opción A: Script Automatizado (Recomendado)

```bash
# 1. Subir el script al servidor
scp dokku-config-before-deploy.sh dokku@tu-servidor:~

# 2. Conectar al servidor
ssh dokku@tu-servidor

# 3. Ejecutar el script
chmod +x dokku-config-before-deploy.sh
./dokku-config-before-deploy.sh
```

### Opción B: Comandos Manuales

```bash
# Conectar al servidor Dokku
ssh dokku@tu-servidor

# Crear la app
dokku apps:create evo

# Instalar plugin de PostgreSQL
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres

# Crear servicio PostgreSQL (mismo nombre que la app)
dokku postgres:create evo

# Vincular PostgreSQL a la app
dokku postgres:link evo evo

# Configurar variables de entorno
dokku config:set --no-restart evo \
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
DB_URL=$(dokku config:get evo DATABASE_URL)
dokku config:set --no-restart evo DATABASE_CONNECTION_URI="$DB_URL"

# Configurar mapeo de puertos
dokku ports:set evo http:80:8080

# Configurar almacenamiento persistente
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

## ✅ Verificación de la Configuración

```bash
# Verificar que todo está configurado correctamente
dokku config evo

# Deberías ver:
# - DATABASE_URL (automático del plugin postgres)
# - DATABASE_CONNECTION_URI (debe ser igual a DATABASE_URL)
# - DATABASE_PROVIDER=postgresql
# - Todas las demás variables de entorno
```

## 🚢 Deploy desde tu Máquina Local

```bash
# Agregar remoto de Dokku (solo la primera vez)
git remote add dokku dokku@tu-servidor:evo

# Hacer deploy
git push dokku master
```

## 🔍 Monitoreo Post-Deploy

```bash
# Ver logs en tiempo real
dokku logs evo -t

# Ver estado de la app
dokku ps:report evo

# Ver estado de PostgreSQL
dokku postgres:info evo

# Ver configuración
dokku config evo

# Verificar puertos
dokku ports:list evo
```

## 🐛 Troubleshooting

### Error: "Database provider invalid"
```bash
# Verificar que DATABASE_PROVIDER está configurado
dokku config:get evo DATABASE_PROVIDER

# Si está vacío o incorrecto, configurarlo:
dokku config:set evo DATABASE_PROVIDER="postgresql"
```

### Error: "Could not connect to database"
```bash
# Verificar DATABASE_CONNECTION_URI
dokku config:get evo DATABASE_CONNECTION_URI

# Si está vacío, obtenerlo de DATABASE_URL
DB_URL=$(dokku config:get evo DATABASE_URL)
dokku config:set evo DATABASE_CONNECTION_URI="$DB_URL"
```

### Reiniciar la app después de cambios
```bash
dokku ps:restart evo
```

## 📝 Comandos Útiles

```bash
# Backup de PostgreSQL
dokku postgres:backup evo backup-$(date +%Y%m%d)

# Restaurar backup
dokku postgres:import evo < backup.sql

# Conectar a PostgreSQL
dokku postgres:connect evo

# Ver logs de PostgreSQL
dokku postgres:logs evo -t

# Escalar la app (múltiples instancias)
dokku ps:scale evo web=2

# Habilitar SSL con Let's Encrypt
dokku letsencrypt:enable evo
```

## 🔐 Obtener tu API Key

```bash
# Ver el API key generado
dokku config:get evo AUTHENTICATION_API_KEY
```

## 🎯 URL de la Aplicación

Después del deploy exitoso, tu aplicación estará disponible en:
- `http://evo.tu-dominio.com` (si configuraste el dominio)
- `http://tu-servidor-ip` (si no configuraste dominio)

Para usar la API, incluye el header:
```
apikey: TU_API_KEY_AQUI
```
