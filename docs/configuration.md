# Configuration

This document provides detailed information about configuring Evolution API on Dokku.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Database Configuration](#database-configuration)
- [Authentication Configuration](#authentication-configuration)
- [Storage Configuration](#storage-configuration)
- [Domain and Port Configuration](#domain-and-port-configuration)
- [Advanced Configuration](#advanced-configuration)

## Environment Variables

### Required Variables

These variables are **required** for Evolution API to function:

| Variable | Description | Example |
|----------|-------------|---------|
| `DATABASE_CONNECTION_URI` | PostgreSQL connection string | `postgresql://user:pass@host:5432/db` |
| `SERVER_URL` | Public URL of your Evolution API instance | `https://evo.example.com` |
| `AUTHENTICATION_API_KEY` | Global API key for authentication | `oXZkh4B2FETGL31VeOzl6gqsdav9wmC0` |

**Set required variables:**
```bash
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
dokku config:set evo SERVER_URL="https://evo.example.com"
dokku config:set evo AUTHENTICATION_API_KEY="your-secure-api-key"
```

### Optional Variables

Customize Evolution API behavior with these optional variables:

#### Database Options

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_SAVE_DATA_INSTANCE` | Save instance data | `true` |
| `DATABASE_SAVE_DATA_NEW_MESSAGE` | Save new messages | `true` |
| `DATABASE_SAVE_MESSAGE_UPDATE` | Save message updates | `true` |
| `DATABASE_SAVE_DATA_CONTACTS` | Save contact information | `true` |
| `DATABASE_SAVE_DATA_CHATS` | Save chat information | `true` |
| `DATABASE_SAVE_DATA_HISTORIC` | Save message history | `true` |
| `DATABASE_SAVE_DATA_LABELS` | Save message labels | `false` |

**Example - Minimize database usage:**
```bash
dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=false
dokku config:set evo DATABASE_SAVE_DATA_LABELS=false
dokku config:set evo DATABASE_SAVE_MESSAGE_UPDATE=false
```

#### Cache Options (Redis)

| Variable | Description | Default |
|----------|-------------|---------|
| `CACHE_REDIS_ENABLED` | Enable Redis caching | `false` |
| `CACHE_REDIS_URI` | Redis connection URI | - |
| `CACHE_REDIS_PREFIX_KEY` | Redis key prefix | `evo` |

**Example - Enable Redis:**
```bash
dokku config:set evo CACHE_REDIS_ENABLED=true
dokku config:set evo CACHE_REDIS_URI="$(dokku config:get evo REDIS_URL)"
```

#### Webhook Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `WEBHOOK_GLOBAL_ENABLED` | Enable global webhook | `false` |
| `WEBHOOK_GLOBAL_URL` | Global webhook URL | - |
| `WEBHOOK_GLOBAL_WEBHOOK_BY_EVENTS` | Filter events | `false` |

**Example - Configure webhook:**
```bash
dokku config:set evo WEBHOOK_GLOBAL_ENABLED=true
dokku config:set evo WEBHOOK_GLOBAL_URL="https://your-webhook.com/endpoint"
```

#### WebSocket Configuration

| Variable | Description | Default |
|----------|-------------|---------|
| `WEBSOCKET_ENABLED` | Enable WebSocket | `false` |
| `WEBSOCKET_GLOBAL_EVENTS` | Enable global events | `false` |

**Example - Enable WebSocket:**
```bash
dokku config:set evo WEBSOCKET_ENABLED=true
dokku config:set evo WEBSOCKET_GLOBAL_EVENTS=true
```

#### Authentication Options

| Variable | Description | Default |
|----------|-------------|---------|
| `AUTHENTICATION_TYPE` | Authentication type (`apikey` or `jwt`) | `apikey` |
| `AUTHENTICATION_JWT_EXPIRIN_IN` | JWT expiration time (seconds) | `3600` |
| `AUTHENTICATION_JWT_SECRET` | JWT secret key | - |

#### Instance Management

| Variable | Description | Default |
|----------|-------------|---------|
| `DEL_INSTANCE` | Auto-delete inactive instances (days) | `false` |
| `CLEAN_STORE_CLEANING_INTERVAL` | Storage cleanup interval (seconds) | `7200` |
| `CLEAN_STORE_MESSAGES` | Clean old messages | `true` |
| `CLEAN_STORE_MESSAGE_UP_TO` | Keep messages for (days) | `15` |
| `CLEAN_STORE_CHATS` | Clean old chats | `true` |
| `CLEAN_STORE_CONTACTS` | Clean old contacts | `true` |

#### Language and Logging

| Variable | Description | Default |
|----------|-------------|---------|
| `LOG_LEVEL` | Logging level | `ERROR` |
| `LOG_COLOR` | Colorize logs | `true` |
| `LANGUAGE` | API language | `en` |

**Available log levels**: `ERROR`, `WARN`, `INFO`, `DEBUG`, `VERBOSE`

## Database Configuration

### View Current Configuration

```bash
dokku config evo | grep DATABASE
```

### PostgreSQL Information

```bash
# View PostgreSQL service info
dokku postgres:info evo

# Check database size
dokku postgres:connect evo -c "SELECT pg_size_pretty(pg_database_size('evo'));"
```

### Backup and Restore

**Create backup:**
```bash
# Linux/macOS
dokku postgres:backup evo backup-$(date +%Y%m%d)

# Windows (PowerShell)
$date = Get-Date -Format "yyyyMMdd"
ssh your-server "postgres:backup evo backup-$date"
```

**List backups:**
```bash
dokku postgres:backup-list evo
```

**Restore from backup:**
```bash
dokku postgres:backup-restore evo backup-name
```

**Export database:**
```bash
dokku postgres:export evo > evolution-backup.sql
```

**Import database:**
```bash
dokku postgres:import evo < evolution-backup.sql
```

## Authentication Configuration

### Generate Secure API Key

**Linux/macOS:**
```bash
API_KEY=$(openssl rand -hex 16)
dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"
echo "Your API Key: $API_KEY"
```

**Windows (PowerShell):**
```powershell
$API_KEY = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
ssh your-server "config:set evo AUTHENTICATION_API_KEY=$API_KEY"
Write-Host "Your API Key: $API_KEY"
```

### View Current API Key

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

### Change API Key

```bash
dokku config:set evo AUTHENTICATION_API_KEY="new-secure-api-key"
```

### Use JWT Authentication

```bash
dokku config:set evo AUTHENTICATION_TYPE="jwt"
dokku config:set evo AUTHENTICATION_JWT_SECRET="your-jwt-secret"
dokku config:set evo AUTHENTICATION_JWT_EXPIRIN_IN="86400"  # 24 hours
```

## Storage Configuration

### View Storage Configuration

```bash
dokku storage:report evo
```

### Mount Additional Storage

```bash
# Mount media storage
dokku storage:mount evo /var/lib/dokku/data/storage/evo-media:/evolution/media

# Mount logs
dokku storage:mount evo /var/lib/dokku/data/storage/evo-logs:/evolution/logs
```

### Unmount Storage

```bash
dokku storage:unmount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### Check Storage Usage

```bash
# Check disk usage
du -sh /var/lib/dokku/data/storage/evo

# Detailed breakdown
du -h --max-depth=1 /var/lib/dokku/data/storage/evo
```

## Domain and Port Configuration

### Configure Domain

**Set primary domain:**
```bash
dokku domains:set evo evo.example.com
```

**Add additional domains:**
```bash
dokku domains:add evo www.evo.example.com
dokku domains:add evo api.example.com
```

**Remove domain:**
```bash
dokku domains:remove evo www.evo.example.com
```

**List domains:**
```bash
dokku domains:report evo
```

### Configure Ports

**Set HTTP port:**
```bash
dokku ports:set evo http:80:8080
```

**Add HTTPS port:**
```bash
dokku ports:add evo https:443:8080
```

**Remove port:**
```bash
dokku ports:remove evo http:80:8080
```

**List ports:**
```bash
dokku ports:report evo
```

### SSL/TLS Configuration

**Enable Let's Encrypt:**
```bash
dokku letsencrypt:set evo email your@email.com
dokku letsencrypt:enable evo
```

**Renew certificate manually:**
```bash
dokku letsencrypt:renew evo
```

**Auto-renew setup:**
```bash
dokku letsencrypt:cron-job --add
```

**View certificate info:**
```bash
dokku letsencrypt:list
```

## Advanced Configuration

### Resource Limits

**Set memory and CPU limits:**
```bash
dokku resource:limit evo --memory 512m --cpu 1
```

**Remove limits:**
```bash
dokku resource:limit-clear evo --process-type web
```

**View current limits:**
```bash
dokku resource:report evo
```

### Health Checks

Evolution API includes built-in health checks. View status:

```bash
dokku checks:report evo
```

**Disable health checks** (not recommended):
```bash
dokku checks:disable evo
```

**Re-enable health checks:**
```bash
dokku checks:enable evo
```

### Proxy Configuration

**Disable proxy** (if using external reverse proxy):
```bash
dokku proxy:disable evo
```

**Re-enable proxy:**
```bash
dokku proxy:enable evo
```

**Set proxy type:**
```bash
dokku proxy:set evo nginx  # or 'caddy'
```

### Network Configuration

**Create custom network:**
```bash
dokku network:create custom-network
```

**Attach application to network:**
```bash
dokku network:set evo attach-post-create custom-network
```

**Detach from network:**
```bash
dokku network:set evo detach-post-create custom-network
```

### Scheduled Tasks (Cron)

**Set up cron jobs:**
```bash
# Create a cron script
dokku enter evo web
echo '0 2 * * * /app/cleanup.sh' | crontab -
```

### Environment Groups

**Create environment group:**
```bash
# Useful for managing multiple instances
dokku config:set --no-restart evo-prod ENV=production
dokku config:set --no-restart evo-dev ENV=development
```

### View All Configuration

```bash
# View all environment variables
dokku config evo

# Export configuration
dokku config:export evo > evo-config.env

# Import configuration
dokku config:bundle evo < evo-config.env
```

## Configuration Best Practices

### Security

1. **Use strong API keys** (minimum 32 characters)
2. **Enable HTTPS** with Let's Encrypt
3. **Rotate API keys** periodically
4. **Use environment variables** for sensitive data
5. **Disable unnecessary features** to reduce attack surface

### Performance

1. **Enable Redis** for 50+ users
2. **Disable message history** if not needed
3. **Set appropriate resource limits**
4. **Monitor and adjust** based on usage

### Reliability

1. **Set up automated backups**
2. **Enable health checks**
3. **Configure log retention**
4. **Monitor disk usage**
5. **Use persistent storage**

### Development vs Production

**Development:**
```bash
dokku config:set evo LOG_LEVEL=DEBUG
dokku config:set evo DEL_INSTANCE=1  # Delete after 1 day
```

**Production:**
```bash
dokku config:set evo LOG_LEVEL=ERROR
dokku config:set evo DEL_INSTANCE=false
dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=true
```

## Next Steps

- [Performance & Optimization](performance.md) - Optimize your deployment
- [Useful Commands](useful-commands.md) - Common management tasks
- [System Requirements](system-requirements.md) - Hardware recommendations

## References

- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Dokku Configuration](https://dokku.com/docs/configuration/)
- [PostgreSQL Plugin](https://github.com/dokku/dokku-postgres)
