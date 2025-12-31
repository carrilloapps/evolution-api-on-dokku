# Evolution API on Dokku

[![Evolution API](https://img.shields.io/badge/Evolution%20API-2.3.7-green.svg)](https://github.com/EvolutionAPI/evolution-api)
[![Dokku](https://img.shields.io/badge/Dokku-Compatible-blue.svg)](https://github.com/dokku/dokku)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.1-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Description

This guide explains how to deploy [Evolution API](https://evolution-api.com/), a complete REST API for WhatsApp, on a [Dokku](http://dokku.viewdocs.io/dokku/) server. Dokku is a lightweight PaaS that simplifies application deployment and management using Docker.

## Prerequisites

Before proceeding, ensure you have:

- A server with [Dokku installed](http://dokku.viewdocs.io/dokku/getting-started/installation/)
- The [PostgreSQL plugin](https://github.com/dokku/dokku-postgres) installed on Dokku
- (Optional) The [Let's Encrypt plugin](https://github.com/dokku/dokku-letsencrypt) for SSL certificates
- Domain pointing to your server (optional)

## Installation Instructions

### 1. Create the Application

Connect to your Dokku server and create the `evo` app:

```bash
dokku apps:create evo
```

### 2. Configure PostgreSQL

#### Install, Create and Link PostgreSQL

1. Install the PostgreSQL plugin:

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
   ```

2. Create the PostgreSQL service:

   ```bash
   dokku postgres:create evo
   ```

3. Link PostgreSQL to the application:

   ```bash
   dokku postgres:link evo evo
   ```

#### Configure Connection URI

Evolution API requires `DATABASE_CONNECTION_URI` in addition to `DATABASE_URL`:

```bash
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
```

#### Generate Authentication API Key

Evolution API requires a global API Key for all requests. Generate one securely:

**On Linux/macOS:**
```bash
# Generate a random secure 32-character API Key
API_KEY=$(openssl rand -hex 16)
dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"

# Verify it was configured correctly
dokku config:get evo AUTHENTICATION_API_KEY
```

**On Windows (PowerShell):**
```powershell
# Generate a random secure 32-character API Key
$API_KEY = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
ssh your-server "config:set evo AUTHENTICATION_API_KEY=$API_KEY"

# Verify it was configured correctly
ssh your-server "config:get evo AUTHENTICATION_API_KEY"
```

> **Important**: Save this API Key in a secure location. You'll need it for all API requests.

#### Create Additional User and Database (Optional)

If you need an additional user and database for the application, run the following commands **one by one**:

1. Create the `evo_app_user` user:

   ```bash
   dokku postgres:connect evo << 'EOF'
   DO $$
   BEGIN
       IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'evo_app_user') THEN
           CREATE USER evo_app_user WITH PASSWORD 'jA54%B@rF7$pQs2*Lx8#mZvN9!wY3&tD';
       END IF;
   END
   $$;
   EOF
   ```

2. Create the `service_db` database:

   ```bash
   dokku postgres:connect evo << 'EOF'
   CREATE DATABASE service_db;
   EOF
   ```

3. Grant privileges:

   ```bash
   dokku postgres:connect evo << 'EOF'
   GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
   EOF
   ```

> **Note**: These commands are optional. The application works correctly with the main database automatically created by the PostgreSQL plugin.

### 3. Configure Persistent Storage

To persist WhatsApp instances between restarts, create and mount a directory:

```bash
dokku storage:ensure-directory evo
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

### 4. Configure Domain and Ports

Configure the domain for your application:

```bash
dokku domains:set evo evo.example.com
```

Map internal port `8080` to external port `80`:

```bash
dokku ports:set evo http:80:8080
```

### 5. Deploy the Application

You can deploy the application using one of the following methods:

#### Option 1: Deploy with `dokku git:sync`

If you have SSH access to the Dokku server, you can deploy directly from the official repository:

```bash
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

This will download the code, build, and deploy automatically.

> **Note**: This command must be run from the Dokku server via SSH.

#### Option 2: Clone and Manual Push

If you prefer to work locally (works on **Windows, macOS, and Linux**):

1. Clone the repository:

   ```bash
   git clone https://github.com/carrilloapps/evolution-api-on-dokku.git
   cd evolution-api-on-dokku
   ```

2. Add your Dokku server as a remote:

   **Linux/macOS/Windows (Git Bash):**
   ```bash
   git remote add dokku dokku@your-server.com:evo
   ```

   **Windows (PowerShell/CMD):**
   ```powershell
   git remote add dokku dokku@your-server.com:evo
   ```

3. Push to Dokku:

   ```bash
   git push dokku master
   ```

Choose the method that best suits your workflow.

### 6. Enable SSL (Optional)

Secure your application with an SSL certificate from Let's Encrypt:

1. Add the HTTPS port:

   ```bash
   dokku ports:add evo https:443:8080
   ```

2. Install the Let's Encrypt plugin:

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
   ```

3. Configure the contact email:

   ```bash
   dokku letsencrypt:set evo email you@example.com
   ```

4. Enable Let's Encrypt:

   ```bash
   dokku letsencrypt:enable evo
   ```

5. Configure automatic renewal:

   ```bash
   dokku letsencrypt:cron-job --add
   ```

## Completion

Congratulations! Your Evolution API instance is up and running. You can access it at:

- **HTTP**: `http://evo.example.com`
- **HTTPS**: `https://evo.example.com` (if you configured SSL)

### Get Your API Key

Retrieve the API Key you generated during installation:

```bash
dokku config:get evo AUTHENTICATION_API_KEY
```

**Example output:**
```
oXZkh4B2FETGL31VeOzl6gqsdav9wmC0
```

### Change the API Key

If you want to change the API Key to a custom one:

```bash
dokku config:set evo AUTHENTICATION_API_KEY="your-new-super-secure-api-key"
```

### Test the API

Test that the API is working correctly:

```bash
# Replace YOUR_API_KEY with the one you obtained
curl -X GET https://evo.example.com \
  -H "apikey: oXZkh4B2FETGL31VeOzl6gqsdav9wmC0"
```

You should receive a successful response from Evolution API.

## Useful Commands

### Logging and Monitoring

```bash
# View logs in real-time
dokku logs evo -t

# View configuration
dokku config evo
```

### PostgreSQL Management

**Linux/macOS:**
```bash
# PostgreSQL information
dokku postgres:info evo

# Connect to PostgreSQL
dokku postgres:connect evo

# Backup
dokku postgres:backup evo backup-$(date +%Y%m%d)
```

**Windows (PowerShell):**
```powershell
# PostgreSQL information
ssh your-server "postgres:info evo"

# Connect to PostgreSQL
ssh your-server "postgres:connect evo"

# Backup
$date = Get-Date -Format "yyyyMMdd"
ssh your-server "postgres:backup evo backup-$date"
```

### Updates

To update the application:

```bash
git pull origin master
git push dokku master
```

Dokku will automatically run Prisma migrations and health checks.

## Features

- ✅ PostgreSQL only (no Redis/Cache)
- ✅ Automatic Prisma migrations
- ✅ Configured health checks
- ✅ Persistent storage
- ✅ Pre-configured environment variables
- ✅ Resource limits (0.6 CPU, 512MB RAM)

## Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details on how to get started.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Acknowledgments

- [Evolution API](https://github.com/EvolutionAPI/evolution-api) - The amazing WhatsApp API
- [Dokku](https://dokku.com/) - Docker-powered PaaS
- [PostgreSQL](https://www.postgresql.org/) - Powerful open source database

## Additional Documentation

For more information about Evolution API, visit the [official documentation](https://doc.evolution-api.com/).

### Changelog

This deployment uses Evolution API v2.3.7 which includes:

- ✅ **WhatsApp Business Meta Templates** - Create, update and delete WhatsApp Business templates
- ✅ **Enhanced Webhook Events** - Track message sync progress with `isLatest` and progress percentage
- ✅ **N8N Integration** - Support for quoted messages in chatbot integration
- ✅ **WebSocket Improvements** - Wildcard host support for flexible connections
- ✅ **Pix Payment Support** - Handle interactive Pix button messages
- ✅ **Baileys Fixes** - Resolved authentication and reconnection issues
- ✅ **Chatwoot Enhancements** - Improved contact management and message handling
- ✅ **Proxy Support** - Fixed compatibility with Node.js 18+ and Undici
- ✅ **Database Optimizations** - Better contact and chat deduplication

For complete changelog, visit [Evolution API v2.3.7 Release](https://github.com/EvolutionAPI/evolution-api/releases/tag/v2.3.7).
