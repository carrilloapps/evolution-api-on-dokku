# Evolution API - Dokku Deployment

Production-ready Evolution API deployment for Dokku with PostgreSQL.

## 🚀 Quick Start (Dokku Server)

### Prerequisites

- Dokku installed and configured on your server
- SSH access to your Dokku server
- PostgreSQL plugin installed

### Automated Setup

Run the setup script on your **Dokku server**:

```bash
# Upload and run the setup script
scp dokku-setup.sh dokku@your-server:~
ssh dokku@your-server
chmod +x dokku-setup.sh
./dokku-setup.sh evo  # Replace 'evo' with your app name
```

### Manual Setup

If you prefer manual configuration:

```bash
# On your Dokku server
APP_NAME="evo"

# 1. Create the app
dokku apps:create $APP_NAME

# 2. Install PostgreSQL plugin (if not installed)
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres

# 3. Create PostgreSQL service (same name as app)
dokku postgres:create $APP_NAME

# 4. Link PostgreSQL to app
dokku postgres:link $APP_NAME $APP_NAME

# 5. Configure environment variables
dokku config:set --no-restart $APP_NAME \
  AUTHENTICATION_API_KEY="your_secure_api_key_here" \
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

# 6. Set DATABASE_CONNECTION_URI from DATABASE_URL
DB_URL=$(dokku config:get $APP_NAME DATABASE_URL)
dokku config:set --no-restart $APP_NAME DATABASE_CONNECTION_URI="$DB_URL"

# 7. Set port mapping
dokku ports:set $APP_NAME http:80:8080

# 8. Create persistent storage
dokku storage:ensure-directory $APP_NAME
dokku storage:mount $APP_NAME /var/lib/dokku/data/storage/$APP_NAME:/evolution/instances
```

## 📦 Deploy from Local

```bash
# Add Dokku remote (only once)
git remote add dokku dokku@your-server:evo

# Deploy
git add .
git commit -m "Deploy Evolution API to Dokku"
git push dokku master
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` and customize as needed. Key variables:

- `AUTHENTICATION_API_KEY`: API authentication key (generate a secure random string)
- `DATABASE_CONNECTION_URI`: Automatically set by Dokku postgres plugin
- `CONFIG_SESSION_PHONE_*`: WhatsApp session configuration

### Ports

- Internal: Application listens on port `8080`
- External: Dokku maps to port `80` (or `443` with SSL)

### Persistent Storage

The app stores WhatsApp instance data in `/evolution/instances`. This is automatically mounted to persistent storage in Dokku.

## 🏥 Health Checks

Dokku uses the `CHECKS` file to verify the app is running:

- Waits 5 seconds before first check
- Tries up to 6 times with 10-second timeout
- Checks if the root endpoint returns "Evolution API"

## 📊 Useful Commands

```bash
# View logs
dokku logs evo -t

# View configuration
dokku config evo

# Restart app
dokku ps:restart evo

# Scale app
dokku ps:scale evo web=1

# PostgreSQL info
dokku postgres:info evo

# PostgreSQL backup
dokku postgres:backup evo backup-$(date +%Y%m%d)

# PostgreSQL console
dokku postgres:connect evo

# PostgreSQL logs
dokku postgres:logs evo -t

# Enable SSL (Let's Encrypt)
dokku letsencrypt:enable evo
```

## 🔒 Security Recommendations

1. **Change default API key**: Generate a strong random key
   ```bash
   dokku config:set evo AUTHENTICATION_API_KEY="$(openssl rand -hex 32)"
   ```

2. **Enable SSL**: Use Let's Encrypt
   ```bash
   sudo dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
   dokku letsencrypt:set evo email your@email.com
   dokku letsencrypt:enable evo
   dokku letsencrypt:cron-job --add
   ```

3. **Restrict PostgreSQL access**: Already configured by default (internal only)

4. **Set up regular backups**:
   ```bash
   # Add to cron
   0 2 * * * dokku postgres:backup evo backup-$(date +\%Y\%m\%d)
   
   # Or use Dokku's automated backups
   dokku postgres:backup-schedule evo "0 2 * * *" backup-bucket
   ```

## 🐛 Troubleshooting

### Build fails with "Unable to select a buildpack"

✅ **Fixed**: This repo now includes a `Dockerfile`, so Dokku will use it automatically.

### App crashes after deployment

```bash
# Check logs
dokku logs evo -t

# Verify database connection
dokku config:get evo DATABASE_CONNECTION_URI

# Restart
dokku ps:restart evo
```

### PostgreSQL connection errors


# Verify link
dokku postgres:links evo

# Check DATABASE_URL is set
dokku config:get evo DATABASE_URL
dokku config:get evo DATABASE_CONNECTION_URI

# Re-link if necessary
dokku postgres:unlink evo evo
dokku postgres:link evo evo

# Set DATABASE_CONNECTION_URI from DATABASE_URL
DB_URL=$(dokku config:get evo DATABASE_URL)
dokku config:set evo DATABASE_CONNECTION_URI="$DB_URL"
# Re-link if necessary
dokku postgres:unlink evo-postgres evo
dokku postgres:link evo-postgres evo
```

### Port mapping issues

```bash
# Check current ports
dokku ports:list evo

# Reset port mapping
dokku ports:clear evo
dokku ports:set evo http:80:8080
```

## 📁 Project Structure

```
.
├── Dockerfile              # Container build instructions
├── CHECKS                  # Dokku health checks
├── DOKKU_SCALE            # Process scaling configuration
├── dokku-setup.sh         # Automated setup script
├── .env.example           # Environment variables template
├── docker-compose.yaml    # Local development setup
├── init-db.sql           # PostgreSQL initialization
└── README.md             # This file
```

## 🔄 Updates and Maintenance

```bash
# Update to latest version
git pull origin master
git push dokku master

# Rollback to previous version
dokku ps:rebuild evo <previous-release-id>

# View releases
dokku releases evo
```

## 🌐 Local Development

For local development with docker-compose:

```bash
# Copy environment file
cp .env.example .env

# Edit .env with your local settings
nano .env

# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

## 📚 Additional Resources

- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Dokku Documentation](https://dokku.com/docs/getting-started/installation/)
- [Dokku PostgreSQL Plugin](https://github.com/dokku/dokku-postgres)

## 📝 Notes

- **Database**: Dokku creates and manages PostgreSQL automatically via the postgres plugin
- **Storage**: WhatsApp instances are persisted to Dokku's storage directory
- **Scaling**: Default is 1 web process; adjust with `dokku ps:scale`
- **Backups**: Set up automated PostgreSQL backups using the postgres plugin

## 🆘 Support

For issues specific to:
- Evolution API: Check [Evolution API GitHub](https://github.com/EvolutionAPI/evolution-api)
- Dokku deployment: Check [Dokku Documentation](https://dokku.com/docs/)
- This setup: Create an issue in this repository