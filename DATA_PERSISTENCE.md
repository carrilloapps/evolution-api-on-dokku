# Data Persistence

This document explains how data is stored and persisted in the Evolution API system.

## Overview

The Evolution API system uses multiple mechanisms for data persistence:

1. **PostgreSQL**: Primary relational database for structured data
2. **Redis**: In-memory cache for improved performance
3. **Docker Volumes**: Persistent storage for WhatsApp instance data
4. **Secondary Database**: Additional database for service-specific data

## PostgreSQL Database

### Primary Database

The primary PostgreSQL database (`evolution_database` by default) stores:

- WhatsApp instance configurations
- Message history
- Contact information
- Chat records
- Group details
- Labels
- Media metadata

### Configuration

The database connection is configured through environment variables:

```yaml
- DATABASE_ENABLED=true
- DATABASE_PROVIDER=postgresql
- DATABASE_CONNECTION_URI=postgresql://db_admin_xk72r:service_password@postgres:5432/evolution_database
```

### Data Persistence Controls

You can control which data is saved to the database:

```yaml
- DATABASE_SAVE_DATA_INSTANCE=true    # Save instance configuration data
- DATABASE_SAVE_DATA_NEW_MESSAGE=true # Save new incoming messages
- DATABASE_SAVE_MESSAGE_UPDATE=true   # Save message updates (read receipts, etc.)
- DATABASE_SAVE_DATA_CONTACTS=true    # Save contact information
- DATABASE_SAVE_DATA_CHATS=true       # Save chat history
- DATABASE_SAVE_DATA_LABELS=true      # Save message labels
- DATABASE_SAVE_DATA_HISTORIC=true    # Save historic messages
```

### Secondary Database

The initialization script creates a secondary database (`service_db`) and user (`evo_app_user`):

```sql
CREATE USER evo_app_user WITH PASSWORD 'secure_password';
CREATE DATABASE service_db;
ALTER DATABASE service_db OWNER TO evo_app_user;
GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
```

This secondary database can be used for additional services or extensions.

## Redis Cache

Redis is used as a high-performance cache for:

- Session data
- Frequent queries
- Temporary data
- Optional instance data caching

### Configuration

The Redis connection is configured through environment variables:

```yaml
- CACHE_REDIS_ENABLED=true
- CACHE_REDIS_URI=redis://redis:6379/6
- CACHE_REDIS_PREFIX_KEY=evolution
- CACHE_REDIS_SAVE_INSTANCES=false
- CACHE_LOCAL_ENABLED=false
```

The `CACHE_REDIS_SAVE_INSTANCES` variable determines whether WhatsApp instances are cached in Redis. Enabling this can improve performance but increases memory usage.

## Docker Volumes

### PostgreSQL Data

The `postgres_data` volume persists the PostgreSQL database files:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
```

This ensures that database data survives container restarts and updates.

### WhatsApp Instance Data

The `evolution_instances` volume persists WhatsApp instance data:

```yaml
volumes:
  - evolution_instances:/evolution/instances
```

This includes:
- Session files
- Authentication data
- Media files
- Instance-specific configurations

## Initialization Script

The `init-db.sql` script is mounted in the PostgreSQL container and automatically executed when the container is first started:

```yaml
volumes:
  - type: bind
    source: ./init-db.sql
    target: /docker-entrypoint-initdb.d/init-db.sql
```

## RabbitMQ Events

RabbitMQ is used to capture and process various data events:

```yaml
- RABBITMQ_ENABLED=true
- RABBITMQ_URI=amqp://guest:guest@rabbitmq:5672
- RABBITMQ_EXCHANGE_NAME=evolution_exchange
```

These events can be used to:
- Sync data with external systems
- Create real-time updates
- Build event-driven architectures
- Implement custom data processing pipelines

## Backup and Recovery

### Database Backup

To backup the PostgreSQL database:

```bash
docker exec evolution_postgres pg_dump -U db_admin_xk72r evolution_database > backup.sql
```

### Instance Data Backup

To backup WhatsApp instance data:

```bash
docker run --rm -v evolution_instances:/data -v $(pwd):/backup alpine tar -czf /backup/instances.tar.gz -C /data .
```

### Restore Database

To restore the PostgreSQL database:

```bash
cat backup.sql | docker exec -i evolution_postgres psql -U db_admin_xk72r evolution_database
```

### Restore Instance Data

To restore WhatsApp instance data:

```bash
docker run --rm -v evolution_instances:/data -v $(pwd):/backup alpine sh -c "rm -rf /data/* && tar -xzf /backup/instances.tar.gz -C /data"
```

## Data Migration

When upgrading to a new version:

1. Backup your data following the procedures above
2. Update the container images
3. Restore your data if necessary

Most version updates are compatible with existing data, but it's always good practice to backup before upgrading.

## Data Security

### Encryption

The data is not encrypted at rest by default. For sensitive environments, consider:

1. Using encrypted volumes
2. Implementing database encryption
3. Setting up PostgreSQL with SSL

### Access Control

- PostgreSQL is configured with username/password authentication
- API access is protected by an API key
- Docker volumes restrict access to container users

## Best Practices

1. **Regular Backups**: Set up automated backups of both database and instance data
2. **Monitoring**: Monitor disk usage of volumes to avoid running out of space
3. **Secure Passwords**: Use strong, unique passwords for database users
4. **Version Control**: Document database schema changes if you modify the default schema
5. **Testing**: Regularly test your backup and restore procedures
