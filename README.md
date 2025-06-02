# Evolution API - WhatsApp Integration System

**Version:** 2.2.3  
**Updated:** May 20, 2025

A comprehensive WhatsApp integration API solution with additional services for enhanced performance, scalability, and reliability.

![License](https://img.shields.io/badge/license-MIT-blue)
![Version](https://img.shields.io/badge/version-2.2.3-green)

## 🌟 Overview

Evolution API provides a robust interface for integrating WhatsApp functionality into your applications. This implementation includes PostgreSQL for data persistence, Redis for caching, and RabbitMQ for message queuing, creating a complete ecosystem for WhatsApp API integration.

> ⚠️ **How to solve the issue if you [can’t see the QR code](https://github.com/carrilloapps/evolution-api-coolify/issues/1)?**

## 📋 Table of Contents

- [Quick Start](#quick-start)
- [System Architecture](#system-architecture)
- [Services](#services)
- [Configuration](#configuration)
- [API Endpoints](#api-endpoints)
- [WebSocket Support](#websocket-support)
- [Data Persistence](#data-persistence)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)
- [Changelog](#changelog)

## ⚠️ IMPORTANT: Database Initialization

The `init-db.sql` file will be executed **automatically and only once** when the PostgreSQL container starts for the first time (when the data volume is empty). This file:

- Creates the `evo_app_user` user with a securely generated password
- Creates the `service_db` database
- Grants the necessary privileges

If you delete the `postgres_data` volume (using `docker-compose down -v`), the script will run again on the next startup. If you only restart the containers without removing volumes, the script will not run again.

## 🔍 Services

### Evolution API

The main service that provides the WhatsApp API:
- **Image**: `atendai/evolution-api:latest`
- **Port**: 2559 (mapped to internal 8080)
- **API Key**: Configurable via environment variables (default: `c4b46XpQs2Lw7tF9hM5jN8aD3`)

### PostgreSQL

Primary database for data storage:
- **Image**: `postgres:16-alpine`
- **Port**: 5432
- **Username**: `db_admin_xk72r` (configurable)
- **Database**: `evolution_database` (configurable)

### Secondary Database (automatically created)

Created by the initialization script:
- **Username**: `evo_app_user`
- **Database**: `service_db`

### Redis

Caching service for improved performance:
- **Image**: `redis:latest`
- **Port**: 6379

### RabbitMQ

Message broker for event handling:
- **Image**: `rabbitmq:3-management`
- **Ports**: 5672 (AMQP), 15672 (Management UI)
- **Default Username**: `guest` (configurable)

## 📊 Persistent Volumes

- `evolution_instances`: Stores WhatsApp instances
- `postgres_data`: Stores PostgreSQL data

## 🖥️ Useful Commands

### Check Service Status

```bash
docker compose ps
```

### View Service Logs

```bash
docker compose logs evolution-api
```

### Restart Service

```bash
docker compose restart evolution-api
```

### Stop Services

```bash
docker compose down
```

### Start Services

```bash
docker compose up -d
```

## 🚀 API Endpoints

### Check if API is Working

```bash
curl -i -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" http://localhost:2559/
```

### Get Active Instances

```bash
curl -i -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" http://localhost:2559/instance/fetchInstances
```

### Create a New Instance

```bash
curl -i -X POST \
  -H "Content-Type: application/json" \
  -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" \
  -d '{"instanceName":"my-instance"}' \
  http://localhost:2559/instance/create
```

### Connect an Instance (Generate QR Code)

```bash
curl -i -X POST \
  -H "Content-Type: application/json" \
  -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" \
  http://localhost:2559/instance/connect/my-instance
```

### Request QR Code for an Instance

```bash
curl -i -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" http://localhost:2559/instance/qrcode/my-instance
```

### Send Text Message

```bash
curl -i -X POST \
  -H "Content-Type: application/json" \
  -H "apikey: c4b46XpQs2Lw7tF9hM5jN8aD3" \
  -d '{
    "number": "12345678901",
    "textMessage": {
      "text": "Hello, this is a test message"
    }
  }' \
  http://localhost:2559/message/sendText/my-instance
```

### Complete API Documentation

For complete API documentation, see the [Evolution API Documentation](https://github.com/evolution-api/evolution-api) on GitHub.

## 🔄 Additional Features

### WebSocket
WebSocket is enabled for real-time communication:
- **WebSocket URL**: `ws://localhost:2559`
- **Available Events**: messages, connections, status, groups

### PostgreSQL
The PostgreSQL implementation provides:
- Persistent data storage
- Improved scalability and performance
- Advanced queries on WhatsApp data

### Redis
The Redis implementation provides:
- High-performance caching
- Better response times for frequent operations
- Efficient session management

### RabbitMQ
The RabbitMQ implementation allows:
- Publishing and subscribing to WhatsApp events
- Asynchronous message processing
- Load distribution between services
- Management interface available at: http://localhost:15672

## 🔒 Security Notes

- It's recommended to change the API key before using in production
- For production environments, configure CORS_ORIGIN appropriately instead of using "*"
- Change the default passwords for PostgreSQL, Redis, and RabbitMQ
- Consider using an external Docker network for improved security

## 🤝 Contributing

Please see our [CONTRIBUTING.md](CONTRIBUTING.md) file for information on how to contribute to this project.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## 📝 Changelog

For a detailed list of changes, see the [CHANGELOG.md](CHANGELOG.md) file.
