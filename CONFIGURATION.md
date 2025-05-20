# Configuration Guide

This document explains how to configure the Evolution API system and all its components.

## Environment Variables

The system is configured through environment variables in the `docker-compose.yml` file. These variables allow you to customize the behavior of each service.

### Evolution API Configuration

#### Authentication
```yaml
# API Authentication
- AUTHENTICATION_API_KEY=${AUTHENTICATION_API_KEY:-c4b46XpQs2Lw7tF9hM5jN8aD3}
```

#### Database Configuration
```yaml
# Database Configuration
- DATABASE_ENABLED=${DATABASE_ENABLED:-true}
- DATABASE_PROVIDER=${DATABASE_PROVIDER:-postgresql}
- DATABASE_CONNECTION_URI=postgresql://${POSTGRES_USER:-db_admin_xk72r}:${SERVICE_PASSWORD_POSTGRES:-service_password}@postgres:5432/${POSTGRES_DB:-evolution_database}
- DATABASE_CONNECTION_CLIENT_NAME=${DATABASE_CONNECTION_CLIENT_NAME:-evolution_exchange}
```

#### Data Persistence
```yaml
# Data Persistence
- DATABASE_SAVE_DATA_INSTANCE=${DATABASE_SAVE_DATA_INSTANCE:-true}
- DATABASE_SAVE_DATA_NEW_MESSAGE=${DATABASE_SAVE_DATA_NEW_MESSAGE:-true}
- DATABASE_SAVE_MESSAGE_UPDATE=${DATABASE_SAVE_MESSAGE_UPDATE:-true}
- DATABASE_SAVE_DATA_CONTACTS=${DATABASE_SAVE_DATA_CONTACTS:-true}
- DATABASE_SAVE_DATA_CHATS=${DATABASE_SAVE_DATA_CHATS:-true}
- DATABASE_SAVE_DATA_LABELS=${DATABASE_SAVE_DATA_LABELS:-true}
- DATABASE_SAVE_DATA_HISTORIC=${DATABASE_SAVE_DATA_HISTORIC:-true}
```

#### Redis Configuration
```yaml
# Redis Configuration
- CACHE_REDIS_ENABLED=${CACHE_REDIS_ENABLED:-true}
- CACHE_REDIS_URI=redis://redis:6379/6
- CACHE_REDIS_PREFIX_KEY=${CACHE_REDIS_PREFIX_KEY:-evolution}
- CACHE_REDIS_SAVE_INSTANCES=${CACHE_REDIS_SAVE_INSTANCES:-false}
- CACHE_LOCAL_ENABLED=${CACHE_LOCAL_ENABLED:-false}
```

#### RabbitMQ Configuration
```yaml
# RabbitMQ Configuration
- RABBITMQ_ENABLED=${RABBITMQ_ENABLED:-true}
- RABBITMQ_GLOBAL_ENABLED=${RABBITMQ_GLOBAL_ENABLED:-false}
- RABBITMQ_URI=amqp://${RABBITMQ_DEFAULT_USER:-guest}:${SERVICE_PASSWORD_RABBITMQ:-guest}@rabbitmq:5672
- RABBITMQ_EXCHANGE_NAME=${RABBITMQ_EXCHANGE_NAME:-evolution_exchange}
```

#### RabbitMQ Events
```yaml
# RabbitMQ Events
- RABBITMQ_EVENTS_APPLICATION_STARTUP=${RABBITMQ_EVENTS_APPLICATION_STARTUP:-false}
- RABBITMQ_EVENTS_QRCODE_UPDATED=${RABBITMQ_EVENTS_QRCODE_UPDATED:-true}
- RABBITMQ_EVENTS_MESSAGES_SET=${RABBITMQ_EVENTS_MESSAGES_SET:-true}
- RABBITMQ_EVENTS_MESSAGES_UPSERT=${RABBITMQ_EVENTS_MESSAGES_UPSERT:-true}
- RABBITMQ_EVENTS_MESSAGES_UPDATE=${RABBITMQ_EVENTS_MESSAGES_UPDATE:-true}
- RABBITMQ_EVENTS_MESSAGES_DELETE=${RABBITMQ_EVENTS_MESSAGES_DELETE:-true}
- RABBITMQ_EVENTS_SEND_MESSAGE=${RABBITMQ_EVENTS_SEND_MESSAGE:-true}
- RABBITMQ_EVENTS_CONTACTS_SET=${RABBITMQ_EVENTS_CONTACTS_SET:-true}
- RABBITMQ_EVENTS_CONTACTS_UPSERT=${RABBITMQ_EVENTS_CONTACTS_UPSERT:-true}
- RABBITMQ_EVENTS_CONTACTS_UPDATE=${RABBITMQ_EVENTS_CONTACTS_UPDATE:-true}
- RABBITMQ_EVENTS_PRESENCE_UPDATE=${RABBITMQ_EVENTS_PRESENCE_UPDATE:-true}
- RABBITMQ_EVENTS_CHATS_SET=${RABBITMQ_EVENTS_CHATS_SET:-true}
- RABBITMQ_EVENTS_CHATS_UPSERT=${RABBITMQ_EVENTS_CHATS_UPSERT:-true}
- RABBITMQ_EVENTS_CHATS_UPDATE=${RABBITMQ_EVENTS_CHATS_UPDATE:-true}
- RABBITMQ_EVENTS_CHATS_DELETE=${RABBITMQ_EVENTS_CHATS_DELETE:-true}
- RABBITMQ_EVENTS_GROUPS_UPSERT=${RABBITMQ_EVENTS_GROUPS_UPSERT:-true}
- RABBITMQ_EVENTS_GROUPS_UPDATE=${RABBITMQ_EVENTS_GROUPS_UPDATE:-true}
- RABBITMQ_EVENTS_GROUP_PARTICIPANTS_UPDATE=${RABBITMQ_EVENTS_GROUP_PARTICIPANTS_UPDATE:-true}
- RABBITMQ_EVENTS_CONNECTION_UPDATE=${RABBITMQ_EVENTS_CONNECTION_UPDATE:-true}
- RABBITMQ_EVENTS_CALL=${RABBITMQ_EVENTS_CALL:-true}
```

### PostgreSQL Configuration

```yaml
environment:
  - POSTGRES_USER=${POSTGRES_USER:-db_admin_xk72r}
  - POSTGRES_PASSWORD=${SERVICE_PASSWORD_POSTGRES:-service_password}
  - POSTGRES_DB=${POSTGRES_DB:-evolution_database}
```

### RabbitMQ Configuration

```yaml
environment:
  - RABBITMQ_DEFAULT_USER=${RABBITMQ_DEFAULT_USER:-guest}
  - RABBITMQ_DEFAULT_PASS=${SERVICE_PASSWORD_RABBITMQ:-guest}
```

## Creating a .env File

For better security and easier configuration, you can create a `.env` file in the project root with your custom settings. This file will be automatically loaded by Docker Compose.

Example `.env` file:

```env
# API Authentication
AUTHENTICATION_API_KEY=your_secure_api_key_here

# PostgreSQL Configuration
POSTGRES_USER=your_db_user
SERVICE_PASSWORD_POSTGRES=your_secure_postgres_password
POSTGRES_DB=your_database_name

# RabbitMQ Configuration
RABBITMQ_DEFAULT_USER=your_rabbitmq_user
SERVICE_PASSWORD_RABBITMQ=your_secure_rabbitmq_password
```

## Port Configuration

You can change the exposed ports in the `docker-compose.yml` file under the `ports` section of each service:

```yaml
ports:
  - "2559:8080"  # Evolution API (host:container)
  - "5432:5432"  # PostgreSQL
  - "6379:6379"  # Redis
  - "5672:5672"  # RabbitMQ AMQP
  - "15672:15672"  # RabbitMQ Management UI
```

## Volume Configuration

The system uses Docker volumes for data persistence:

```yaml
volumes:
  postgres_data:
  evolution_instances:
```

These volumes ensure your data is preserved between container restarts.

## Database Initialization

The `init-db.sql` script is mounted in the PostgreSQL container and automatically executed when the container is first started. It creates:

- A user `evo_app_user` with a secure password
- A database `service_db`
- Appropriate privileges

This initialization only happens once, when the `postgres_data` volume is empty.

## Advanced Configuration

### Customizing Redis Caching

For optimal performance, you can adjust the Redis caching configuration:

```yaml
# Enable Redis caching
- CACHE_REDIS_ENABLED=true
# Disable local caching
- CACHE_LOCAL_ENABLED=false
# Set instance caching (can improve performance but increases memory usage)
- CACHE_REDIS_SAVE_INSTANCES=true
```

### RabbitMQ Event Filtering

You can selectively enable or disable specific events to reduce message load:

```yaml
# Disable high-frequency events
- RABBITMQ_EVENTS_PRESENCE_UPDATE=false
# Enable only critical events
- RABBITMQ_EVENTS_CONNECTION_UPDATE=true
- RABBITMQ_EVENTS_QRCODE_UPDATED=true
```

### TLS/SSL Configuration

For production use, it's recommended to configure TLS/SSL. This requires additional setup with a reverse proxy like Nginx or Traefik.

Example Nginx configuration:

```nginx
server {
    listen 443 ssl;
    server_name api.yourdomain.com;

    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;

    location / {
        proxy_pass http://localhost:2559;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

## Production Recommendations

For production deployments, consider the following:

1. **Use Strong Passwords**: Generate strong, unique passwords for all services
2. **Secure API Key**: Change the default API key to a strong, random value
3. **External Network**: Use an external Docker network for better isolation
4. **Resource Limits**: Set container resource limits to prevent resource exhaustion
5. **Backup Strategy**: Implement regular backups of the PostgreSQL database and Evolution instances
6. **Monitoring**: Add monitoring and alerting for all services

## Troubleshooting

If you encounter configuration issues, check:

1. **Logs**: `docker compose logs service_name`
2. **Environment Variables**: Ensure all variables are correctly set
3. **Volume Permissions**: Check if volume permissions are correct
4. **Network Connectivity**: Verify that containers can communicate with each other
