# Installation Guide

This guide provides complete step-by-step instructions for deploying Evolution API on Dokku.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Step 1: Create the Application](#step-1-create-the-application)
- [Step 2: Configure PostgreSQL](#step-2-configure-postgresql)
- [Step 3: Configure Persistent Storage](#step-3-configure-persistent-storage)
- [Step 4: Configure Domain and Ports](#step-4-configure-domain-and-ports)
- [Step 5: Deploy the Application](#step-5-deploy-the-application)
- [Step 6: Enable SSL (Optional)](#step-6-enable-ssl-optional)
- [Completion](#completion)

## Prerequisites

Before proceeding, ensure you have:

- A server with [Dokku installed](https://dokku.com/docs/getting-started/installation/)
- SSH access to your Dokku server
- The [PostgreSQL plugin](https://github.com/dokku/dokku-postgres) installed on Dokku
- (Optional) The [Let's Encrypt plugin](https://github.com/dokku/dokku-letsencrypt) for SSL certificates
- A domain pointing to your server (optional, but recommended)

## Step 1: Create the Application

Connect to your Dokku server via SSH and create the `evo` application:

```bash
dokku apps:create evo
```

This creates a new application named `evo` on your Dokku server.

## Step 2: Configure PostgreSQL

### Install, Create and Link PostgreSQL

1. **Install the PostgreSQL plugin** (skip if already installed):

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres
   ```

2. **Create the PostgreSQL service:**

   ```bash
   dokku postgres:create evo
   ```

3. **Link PostgreSQL to the application:**

   ```bash
   dokku postgres:link evo evo
   ```

### Configure Connection URI and SERVER_URL

Evolution API requires both `DATABASE_CONNECTION_URI` and `SERVER_URL`:

```bash
# Set DATABASE_CONNECTION_URI
dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"

# Set SERVER_URL (REQUIRED - replace with your actual domain)
dokku config:set evo SERVER_URL="https://evo.example.com"
```

> **Important**: Replace `evo.example.com` with your actual domain.

### Generate Authentication API Key

Evolution API requires a global API Key for all requests. Generate one securely:

**On Linux/macOS:**
```bash
# Generate a random secure 32-character API Key
API_KEY=$(openssl rand -hex 16)
dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"

# Save the API Key for later use
echo "Your API Key: $API_KEY"

# Verify it was configured correctly
dokku config:get evo AUTHENTICATION_API_KEY
```

**On Windows (PowerShell):**
```powershell
# Generate a random secure 32-character API Key
$API_KEY = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_})
ssh your-server "config:set evo AUTHENTICATION_API_KEY=$API_KEY"

# Save the API Key for later use
Write-Host "Your API Key: $API_KEY"

# Verify it was configured correctly
ssh your-server "config:get evo AUTHENTICATION_API_KEY"
```

> **Important**: Save this API Key in a secure location. You'll need it for all API requests.

### Create Additional User and Database (Optional)

If you need an additional user and database for the application, run the following commands **one by one**:

1. **Create the `evo_app_user` user:**

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

2. **Create the `service_db` database:**

   ```bash
   dokku postgres:connect evo << 'EOF'
   CREATE DATABASE service_db;
   EOF
   ```

3. **Grant privileges:**

   ```bash
   dokku postgres:connect evo << 'EOF'
   GRANT ALL PRIVILEGES ON DATABASE service_db TO evo_app_user;
   EOF
   ```

> **Note**: These commands are optional. The application works correctly with the main database automatically created by the PostgreSQL plugin.

## Step 3: Configure Persistent Storage

To persist WhatsApp instances between restarts, create and mount a directory:

```bash
# Ensure the storage directory exists
dokku storage:ensure-directory evo

# Mount the storage directory to the application
dokku storage:mount evo /var/lib/dokku/data/storage/evo:/evolution/instances
```

This ensures that all WhatsApp sessions, media, and data are preserved across application restarts and deployments.

## Step 4: Configure Domain and Ports

### Set the Domain

Configure the domain for your application:

```bash
dokku domains:set evo evo.example.com
```

> Replace `evo.example.com` with your actual domain.

### Map Ports

Map the internal port `8080` (Evolution API default) to external port `80`:

```bash
dokku ports:set evo http:80:8080
```

## Step 5: Deploy the Application

You can deploy the application using one of the following methods:

### Option 1: Deploy with `dokku git:sync` (Recommended)

If you have SSH access to the Dokku server, you can deploy directly from the official repository:

```bash
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

This will download the code, build, and deploy automatically.

> **Note**: This command must be run from the Dokku server via SSH.

### Option 2: Clone and Manual Push

If you prefer to work locally (works on **Windows, macOS, and Linux**):

1. **Clone the repository:**

   ```bash
   git clone https://github.com/carrilloapps/evolution-api-on-dokku.git
   cd evolution-api-on-dokku
   ```

2. **Add your Dokku server as a remote:**

   **Linux/macOS/Windows (Git Bash):**
   ```bash
   git remote add dokku dokku@your-server.com:evo
   ```

   **Windows (PowerShell/CMD):**
   ```powershell
   git remote add dokku dokku@your-server.com:evo
   ```

3. **Push to Dokku:**

   ```bash
   git push dokku master
   ```

Choose the method that best suits your workflow.

## Step 6: Enable SSL (Optional)

Secure your application with an SSL certificate from Let's Encrypt:

1. **Add the HTTPS port:**

   ```bash
   dokku ports:add evo https:443:8080
   ```

2. **Install the Let's Encrypt plugin** (skip if already installed):

   ```bash
   dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git
   ```

3. **Configure the contact email:**

   ```bash
   dokku letsencrypt:set evo email you@example.com
   ```

4. **Enable Let's Encrypt:**

   ```bash
   dokku letsencrypt:enable evo
   ```

5. **Configure automatic renewal:**

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
  -H "apikey: YOUR_API_KEY"
```

**Example:**
```bash
curl -X GET https://evo.example.com \
  -H "apikey: oXZkh4B2FETGL31VeOzl6gqsdav9wmC0"
```

You should receive a successful response from Evolution API.

## Next Steps

- Review [System Requirements](system-requirements.md) to optimize resources
- Check [Configuration](configuration.md) for advanced settings
- Read [Performance & Optimization](performance.md) for scaling tips
- See [Useful Commands](useful-commands.md) for management tasks

## Troubleshooting

### Application won't start

Check the logs:
```bash
dokku logs evo -t
```

### Database connection issues

Verify the database URL:
```bash
dokku config:get evo DATABASE_CONNECTION_URI
```

### Port conflicts

Check current port mappings:
```bash
dokku ports:report evo
```

For more help, visit the [Evolution API documentation](https://doc.evolution-api.com/).
