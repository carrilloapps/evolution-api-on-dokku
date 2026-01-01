# System Requirements

This document outlines the hardware and software requirements for deploying Evolution API on Dokku.

## Table of Contents

- [Software Requirements](#software-requirements)
- [Hardware Requirements](#hardware-requirements)
- [Network Requirements](#network-requirements)
- [Recommendations by Team Size](#recommendations-by-team-size)
- [Resource Adjustment](#resource-adjustment)

## Software Requirements

### Required

- **Dokku**: Version 0.30.0 or higher
  - Installation guide: [Dokku Getting Started](https://dokku.com/docs/getting-started/installation/)
- **PostgreSQL Plugin**: Latest version
  - Installation: `dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres`
- **Docker**: Version 20.10+ (automatically installed with Dokku)
- **Git**: Any recent version

### Optional

- **Let's Encrypt Plugin**: For SSL/TLS certificates
  - Installation: `dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git`
- **Redis Plugin**: For caching and improved performance (50+ users)
  - Installation: `dokku plugin:install https://github.com/dokku/dokku-redis.git redis`

## Hardware Requirements

### Minimum Requirements (1-10 users)

Perfect for testing, personal use, or very small teams.

| Resource | Specification |
|----------|--------------|
| **CPU** | 0.3 cores (30% of 1 vCPU) |
| **RAM** | 256MB |
| **Storage** | 2GB |
| **Network** | 10Mbps |

**Estimated Costs**: 
- VPS: $2-5/month (e.g., DigitalOcean, Vultr, Linode basic droplet)
- Cloud: $5-10/month (e.g., AWS t4g.micro with spot instances)

### Recommended for Small Teams (10-50 users)

Suitable for small businesses or growing teams with moderate usage.

| Resource | Specification |
|----------|--------------|
| **CPU** | 1 core |
| **RAM** | 512MB |
| **Storage** | 5GB |
| **Network** | 50Mbps |

**Estimated Costs**: 
- VPS: $5-10/month
- Cloud: $10-20/month

**Recommended Configuration:**
```bash
dokku resource:limit evo --memory 512m --cpu 1
```

### Recommended for Medium Teams (50-200 users)

For medium-sized teams with regular WhatsApp activity.

| Resource | Specification |
|----------|--------------|
| **CPU** | 2 cores |
| **RAM** | 1GB |
| **Storage** | 10GB |
| **Network** | 100Mbps |

**Estimated Costs**: 
- VPS: $10-20/month
- Cloud: $20-40/month

**Recommended Configuration:**
```bash
dokku resource:limit evo --memory 1024m --cpu 2
```

**Additional Recommendations:**
- Enable Redis caching for improved performance
- Set up regular database backups
- Monitor resource usage weekly

### High-Volume Deployments (200+ users)

For large organizations, call centers, or high-traffic deployments.

| Resource | Specification |
|----------|--------------|
| **CPU** | 4+ cores |
| **RAM** | 2GB+ |
| **Storage** | 20GB+ |
| **Network** | 200Mbps+ |

**Estimated Costs**: 
- VPS: $20-50/month
- Cloud: $40-100/month

**Recommended Configuration:**
```bash
dokku resource:limit evo --memory 2048m --cpu 4
```

**Additional Recommendations:**
- **Redis caching** (required for performance)
- **Database optimization** (disable unnecessary data logging)
- **Load balancing** (consider horizontal scaling)
- **Monitoring** (set up alerts for CPU/RAM usage)
- **CDN** (for media files if handling high volume)
- **Regular backups** (automated daily backups)

## Network Requirements

### Bandwidth Considerations

Evolution API's network usage depends on message volume and media handling:

| Usage Pattern | Estimated Bandwidth |
|---------------|---------------------|
| Text-only messages | 1-5Mbps |
| Text + occasional media | 10-50Mbps |
| Heavy media (images/videos) | 100-200Mbps+ |

### Port Requirements

The following ports must be accessible:

| Port | Protocol | Purpose |
|------|----------|---------|
| 80 | HTTP | Web traffic (optional, redirects to HTTPS) |
| 443 | HTTPS | Secure web traffic (recommended) |
| 8080 | HTTP | Evolution API internal port (mapped by Dokku) |

## Recommendations by Team Size

### 1-10 Users (Minimal)

```bash
# Default configuration (already set)
dokku resource:limit evo --memory 256m --cpu 0.5
```

**Best for**: 
- Personal projects
- Testing/development
- Small side projects

**Considerations**:
- May experience slowdowns with heavy media
- Not suitable for production with multiple users
- Perfect for cost-conscious deployments

### 10-50 Users (Small Team)

```bash
dokku resource:limit evo --memory 512m --cpu 1
```

**Best for**: 
- Small businesses
- Startups
- Growing teams

**Considerations**:
- Handles moderate message volume
- Can process media files efficiently
- Good balance of cost and performance

### 50-200 Users (Medium Team)

```bash
# Increase resources
dokku resource:limit evo --memory 1024m --cpu 2

# Enable Redis caching
dokku redis:create evo
dokku redis:link evo evo
dokku config:set evo CACHE_REDIS_ENABLED=true
dokku config:set evo CACHE_REDIS_URI="$(dokku config:get evo REDIS_URL)"
```

**Best for**: 
- Medium-sized companies
- Active customer support teams
- Marketing departments

**Considerations**:
- Redis significantly improves performance
- Monitor database size regularly
- Set up automated backups

### 200+ Users (High Volume)

```bash
# Maximum resources
dokku resource:limit evo --memory 2048m --cpu 4

# Enable Redis caching (required)
dokku redis:create evo
dokku redis:link evo evo
dokku config:set evo CACHE_REDIS_ENABLED=true
dokku config:set evo CACHE_REDIS_URI="$(dokku config:get evo REDIS_URL)"

# Optimize database
dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=false
dokku config:set evo DATABASE_SAVE_DATA_LABELS=false
```

**Best for**: 
- Large enterprises
- Call centers
- High-traffic applications

**Considerations**:
- Consider horizontal scaling (multiple instances)
- Implement load balancing
- Set up advanced monitoring
- Use CDN for media files
- Daily automated backups are critical

## Resource Adjustment

### Check Current Resources

**Linux/macOS:**
```bash
# View resource limits
dokku resource:report evo

# Monitor real-time usage
dokku ps:report evo
```

**Windows (PowerShell):**
```powershell
ssh your-server "resource:report evo"
ssh your-server "ps:report evo"
```

### Adjust Resources Dynamically

You can adjust resources at any time without data loss:

```bash
# Increase RAM and CPU
dokku resource:limit evo --memory 1024m --cpu 2

# Restart the application to apply changes
dokku ps:restart evo
```

### Monitor Resource Usage

Set up regular monitoring to ensure your deployment stays healthy:

```bash
# Check memory usage
dokku ps:report evo | grep -i memory

# Check CPU usage
dokku ps:report evo | grep -i cpu

# View logs for performance issues
dokku logs evo -t
```

## Cloud Provider Recommendations

### Budget-Friendly Options

1. **DigitalOcean Droplets**
   - $6/month for 1GB RAM, 1 vCPU (perfect for small teams)
   - $12/month for 2GB RAM, 1 vCPU (medium teams)

2. **Vultr Cloud Compute**
   - Similar pricing to DigitalOcean
   - Multiple datacenter locations

3. **Linode**
   - Competitive pricing
   - Excellent documentation

### Enterprise Options

1. **AWS (Amazon Web Services)**
   - t4g.micro or t3.small for small teams
   - t4g.medium for medium teams
   - Consider spot instances for 70% cost savings

2. **Google Cloud Platform**
   - e2-micro or e2-small
   - Good for integration with other Google services

3. **Microsoft Azure**
   - B1s or B1ms
   - Excellent for Windows-based organizations

## Storage Considerations

### Database Storage

PostgreSQL database size grows based on:
- Number of WhatsApp instances
- Message history (if enabled)
- Contact information
- Webhook logs

**Estimated database growth**:
- 10 instances: ~100-500MB
- 50 instances: ~500MB-2GB
- 200+ instances: 2-10GB+

### Media Storage

WhatsApp media files are stored in `/evolution/instances`:
- Images: ~100KB-5MB each
- Videos: ~1-50MB each
- Documents: varies

**Estimated media storage needs**:
- Low usage: 1-2GB
- Medium usage: 5-10GB
- High usage: 20-50GB+

### Storage Optimization Tips

1. **Disable message history** if not needed:
   ```bash
   dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=false
   ```

2. **Regular cleanup** of old media files:
   ```bash
   dokku enter evo web
   find /evolution/instances -type f -mtime +30 -delete
   ```

3. **Monitor storage usage**:
   ```bash
   dokku storage:report evo
   ```

## Next Steps

- [Installation Guide](installation.md) - Deploy Evolution API
- [Configuration](configuration.md) - Configure environment variables
- [Performance & Optimization](performance.md) - Optimize your deployment
- [Useful Commands](useful-commands.md) - Manage your application
