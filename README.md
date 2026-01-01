# Evolution API on Dokku

[![Evolution API](https://img.shields.io/badge/Evolution%20API-2.3.7-green.svg)](https://github.com/EvolutionAPI/evolution-api)
[![Dokku](https://img.shields.io/badge/Dokku-Compatible-blue.svg)](https://github.com/dokku/dokku)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18.1-blue.svg)](https://www.postgresql.org/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Table of Contents

- [About](#about)
- [Prerequisites](#prerequisites)
- [Minimum Requirements](#minimum-requirements)
- [Quick Start](#quick-start)
- [Documentation](#documentation)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## About

This guide explains how to deploy [Evolution API](https://evolution-api.com/), a complete REST API for WhatsApp, on a [Dokku](https://dokku.com/docs/) server. Dokku is a lightweight PaaS that simplifies application deployment and management using Docker.

## Prerequisites

Before proceeding, ensure you have:

- A server with [Dokku installed](https://dokku.com/docs/getting-started/installation/)
- The [PostgreSQL plugin](https://github.com/dokku/dokku-postgres) installed on Dokku
- (Optional) The [Let's Encrypt plugin](https://github.com/dokku/dokku-letsencrypt) for SSL certificates
- Domain pointing to your server (optional)

## Minimum Requirements

For 1-10 users, you'll need:

- **CPU**: 0.3 cores
- **RAM**: 256MB
- **Storage**: 2GB
- **Network**: 10Mbps

> For detailed system requirements and recommendations for different team sizes, see [System Requirements](docs/system-requirements.md).

## Quick Start

1. **Create the application:**
   ```bash
   dokku apps:create evo
   ```

2. **Set up PostgreSQL:**
   ```bash
   dokku postgres:create evo
   dokku postgres:link evo evo
   dokku config:set evo DATABASE_CONNECTION_URI="$(dokku config:get evo DATABASE_URL)"
   ```

3. **Configure authentication:**
   ```bash
   API_KEY=$(openssl rand -hex 16)
   dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"
   dokku config:set evo SERVER_URL="https://your-domain.com"
   ```

4. **Deploy:**
   ```bash
   dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
   ```

> For complete installation instructions, see [Installation Guide](docs/installation.md).

## Documentation

- **[Installation Guide](docs/installation.md)** - Complete step-by-step installation process
- **[System Requirements](docs/system-requirements.md)** - Hardware and software requirements
- **[Configuration](docs/configuration.md)** - Environment variables and settings
- **[Performance & Optimization](docs/performance.md)** - Tips for scaling and optimization
- **[Redis Integration](docs/redis-integration.md)** - Optional Redis caching guide (for 50+ users)
- **[Useful Commands](docs/useful-commands.md)** - Common management commands
- **[Changelog](docs/changelog.md)** - Version history and updates

## Features

- ✅ **Minimal resource usage** (256MB RAM, 0.5 CPU by default)
- ✅ **PostgreSQL only** (no cache/Redis required - works perfectly for 1-50 users)
- ✅ **Automatic Prisma migrations**
- ✅ **Optimized health checks** (single instance)
- ✅ **Persistent storage**
- ✅ **Pre-configured environment variables**
- ✅ **Scalable** (easily adjust resources based on user load)
- 🔧 **Optional Redis integration** (only needed for 50+ users - see [Redis Integration Guide](docs/redis-integration.md))

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
- [Evolution API](https://doc.evolution-api.com/) - Official documentation for APP
