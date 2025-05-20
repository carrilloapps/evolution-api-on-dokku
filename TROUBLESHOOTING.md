# Troubleshooting Guide

This document provides solutions for common issues you might encounter when using Evolution API.

## Table of Contents

- [Database Connection Issues](#database-connection-issues)
- [RabbitMQ Connection Issues](#rabbitmq-connection-issues)
- [API Authentication Problems](#api-authentication-problems)
- [WhatsApp Connection Problems](#whatsapp-connection-problems)
- [Docker-related Issues](#docker-related-issues)
- [Performance Issues](#performance-issues)

## Database Connection Issues

### Error: "database does not exist"

**Problem:**
```
FATAL: database "db_admin_xk72r" does not exist
```

**Solution:**
This occurs when the PostgreSQL healthcheck tries to connect to a non-existent database. The healthcheck should specify the database name:

1. Edit the `docker-compose.yml` file to update the healthcheck command:
   ```yaml
   healthcheck:
     test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-db_admin_xk72r} -d ${POSTGRES_DB:-evolution_database}"]
     interval: 10s
     timeout: 5s
     retries: 3
   ```

2. Restart the containers:
   ```bash
   docker compose down
   docker compose up -d
   ```

### Error: "role does not exist"

**Problem:**
```
FATAL: role "evo_app_user" does not exist
```

**Solution:**
This can happen if the initialization script didn't run correctly.

1. Check if the initialization script was properly mounted:
   ```bash
   docker compose exec postgres ls -la /docker-entrypoint-initdb.d/
   ```

2. If the problem persists, you may need to recreate the volume:
   ```bash
   docker compose down -v
   docker compose up -d
   ```

## RabbitMQ Connection Issues

### Error: "ECONNREFUSED"

**Problem:**
```
Error: connect ECONNREFUSED 172.19.0.4:5672
```

**Solution:**
This occurs when the Evolution API tries to connect to RabbitMQ before it's fully started.

1. Update the dependencies in `docker-compose.yml` to wait for services to be healthy:
   ```yaml
   depends_on:
     postgres:
       condition: service_healthy
     redis:
       condition: service_healthy
     rabbitmq:
       condition: service_healthy
   ```

2. Improve the RabbitMQ healthcheck:
   ```yaml
   healthcheck:
     test: ["CMD", "rabbitmq-diagnostics", "-q", "ping"]
     interval: 10s
     timeout: 5s
     retries: 5
     start_period: 30s
   ```

3. Restart the services:
   ```bash
   docker compose down
   docker compose up -d
   ```

### Error: "Authentication failed"

**Problem:**
```
Error: ACCESS_REFUSED - Login was refused using authentication mechanism PLAIN
```

**Solution:**
This occurs when the provided RabbitMQ credentials are incorrect.

1. Verify the RabbitMQ credentials in your environment variables
2. Check that the same credentials are used in the connection string
3. If needed, reset the RabbitMQ password:
   ```bash
   docker compose exec rabbitmq rabbitmqctl change_password ${RABBITMQ_DEFAULT_USER:-guest} ${SERVICE_PASSWORD_RABBITMQ:-guest}
   ```

## API Authentication Problems

### Error: "Unauthorized"

**Problem:**
```
{"error":true,"message":"Unauthorized"}
```

**Solution:**
This occurs when the API key is incorrect or missing.

1. Verify the API key being used in requests matches the one in the environment variables
2. Check the `AUTHENTICATION_API_KEY` environment variable in `docker-compose.yml`
3. Ensure you're including the API key in the header of every request:
   ```
   -H "apikey: your_api_key_here"
   ```

## WhatsApp Connection Problems

### Error: "Unable to generate QR code"

**Problem:**
```
{"error":true,"message":"Unable to generate QR code"}
```

**Solution:**
This can happen for several reasons:

1. Check if the instance exists:
   ```bash
   curl -i -H "apikey: your_api_key_here" http://localhost:2559/instance/fetchInstances
   ```

2. Try recreating the instance:
   ```bash
   curl -i -X DELETE -H "apikey: your_api_key_here" http://localhost:2559/instance/delete/your_instance_name
   curl -i -X POST -H "Content-Type: application/json" -H "apikey: your_api_key_here" -d '{"instanceName":"your_instance_name"}' http://localhost:2559/instance/create
   ```

3. Check the logs for more details:
   ```bash
   docker compose logs evolution-api
   ```

## Docker-related Issues

### Error: "Port is already allocated"

**Problem:**
```
Error starting userland proxy: listen tcp 0.0.0.0:2559: bind: address already in use
```

**Solution:**
This happens when another application is using one of the required ports.

1. Find which process is using the port:
   ```bash
   netstat -ano | findstr :2559
   ```

2. Stop the process or change the port mapping in `docker-compose.yml`

3. Restart the services:
   ```bash
   docker compose down
   docker compose up -d
   ```

## Performance Issues

### Slow Response Times

**Problem:** The API is responding slowly or timing out.

**Solution:**
1. Check system resources:
   ```bash
   docker stats
   ```

2. Increase resource allocation to containers if needed

3. Optimize Redis caching:
   ```yaml
   environment:
     - CACHE_REDIS_ENABLED=true
     - CACHE_LOCAL_ENABLED=false
   ```

4. Consider scaling the services horizontally with Docker Swarm or Kubernetes

---

If you encounter an issue not covered in this guide, please check the logs for more details:

```bash
docker compose logs
```

For more specific logging:

```bash
docker compose logs evolution-api
docker compose logs postgres
docker compose logs redis
docker compose logs rabbitmq
```
