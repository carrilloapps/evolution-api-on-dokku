# Useful Commands

This document provides a reference guide for common management tasks and commands for Evolution API on Dokku.

## Table of Contents

- [Application Management](#application-management)
- [Logging and Monitoring](#logging-and-monitoring)
- [Database Management](#database-management)
- [Storage Management](#storage-management)
- [Resource Management](#resource-management)
- [Updates and Deployment](#updates-and-deployment)
- [Troubleshooting](#troubleshooting)

## Application Management

### Application Status

```bash
# Check if application is running
dokku ps:report evo

# View application information
dokku apps:info evo

# List all applications
dokku apps:list
```

### Start, Stop, Restart

```bash
# Restart the application
dokku ps:restart evo

# Stop the application
dokku ps:stop evo

# Start the application
dokku ps:start evo

# Rebuild and restart
dokku ps:rebuild evo
```

### Scale Application

```bash
# Scale to multiple instances
dokku ps:scale evo web=2

# View current scaling
dokku ps:report evo | grep -i scale
```

### Enter Application Container

```bash
# Access container shell
dokku enter evo web

# Execute command in container
dokku enter evo web bash -c "ls -la /evolution/instances"
```

## Logging and Monitoring

### View Logs

```bash
# Real-time logs
dokku logs evo -t

# View last 100 lines
dokku logs evo -n 100

# View specific process logs
dokku logs evo web -t
```

**Windows (PowerShell):**
```powershell
ssh your-server "logs evo -t"
```

### Monitor Resource Usage

```bash
# View resource usage
dokku ps:report evo

# Monitor in real-time (requires docker stats)
docker stats $(dokku ps:inspect evo | jq -r '.[].ID')
```

### View Configuration

```bash
# View all environment variables
dokku config evo

# View specific variable
dokku config:get evo AUTHENTICATION_API_KEY

# Export configuration
dokku config:export evo > evo-config.env
```

## Database Management

### PostgreSQL Information

```bash
# View database information
dokku postgres:info evo

# Check database size
dokku postgres:connect evo -c "SELECT pg_size_pretty(pg_database_size('evo'));"

# List all databases
dokku postgres:list
```

### Connect to Database

```bash
# Connect to PostgreSQL console
dokku postgres:connect evo

# Execute SQL command
dokku postgres:connect evo -c "SELECT COUNT(*) FROM _prisma_migrations;"
```

**Windows (PowerShell):**
```powershell
ssh your-server "postgres:connect evo"
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

### Database Maintenance

```bash
# Vacuum database (optimize)
dokku postgres:connect evo -c "VACUUM ANALYZE;"

# Check database connections
dokku postgres:connect evo -c "SELECT COUNT(*) FROM pg_stat_activity;"

# View database statistics
dokku postgres:connect evo -c "SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;"
```

## Storage Management

### View Storage Information

```bash
# View storage configuration
dokku storage:report evo

# Check mounted volumes
dokku storage:list evo
```

### Check Storage Usage

```bash
# Check disk usage
du -sh /var/lib/dokku/data/storage/evo

# Detailed breakdown
du -h --max-depth=1 /var/lib/dokku/data/storage/evo

# Check available disk space
df -h /var/lib/dokku/data/storage
```

### Manage Storage

```bash
# Mount new storage
dokku storage:mount evo /var/lib/dokku/data/storage/evo-media:/evolution/media

# Unmount storage
dokku storage:unmount evo /var/lib/dokku/data/storage/evo:/evolution/instances

# Ensure directory exists
dokku storage:ensure-directory evo-backup
```

### Clean Old Files

```bash
# Enter container and clean old media
dokku enter evo web
find /evolution/instances -type f -mtime +30 -delete

# Clean old logs
find /evolution/logs -type f -mtime +7 -delete
```

## Resource Management

### View Resource Limits

```bash
# View current limits
dokku resource:report evo

# View detailed resource usage
dokku ps:report evo
```

**Windows (PowerShell):**
```powershell
ssh your-server "resource:report evo"
ssh your-server "ps:report evo"
```

### Set Resource Limits

**Minimal (1-10 users):**
```bash
dokku resource:limit evo --memory 256m --cpu 0.5
```

**Small team (10-50 users):**
```bash
dokku resource:limit evo --memory 512m --cpu 1
```

**Medium team (50-200 users):**
```bash
dokku resource:limit evo --memory 1024m --cpu 2
```

**High volume (200+ users):**
```bash
dokku resource:limit evo --memory 2048m --cpu 4
```

### Clear Resource Limits

```bash
dokku resource:limit-clear evo --process-type web
```

## Updates and Deployment

### Deploy Application

**From Git repository:**
```bash
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

**From local repository:**
```bash
git push dokku master
```

### Manual Update Process

```bash
# 1. Pull latest code (if using git sync)
dokku git:sync evo https://github.com/carrilloapps/evolution-api-on-dokku.git

# 2. Rebuild application
dokku ps:rebuild evo

# 3. Verify deployment
dokku logs evo -t
```

### Rollback Deployment

```bash
# View deployment history
dokku releases evo

# Rollback to previous version
dokku releases:rollback evo
```

### Zero-Downtime Deployment

```bash
# Enable zero-downtime checks
dokku checks:enable evo

# View check configuration
dokku checks:report evo
```

## Troubleshooting

### Check Application Health

```bash
# View health check status
dokku checks:report evo

# Test manually
curl -I https://evo.example.com
```

### Debug Connection Issues

```bash
# Check port mappings
dokku ports:report evo

# Check proxy configuration
dokku proxy:report evo

# Check domain configuration
dokku domains:report evo
```

### Fix Common Issues

**Application won't start:**
```bash
# Check logs
dokku logs evo -t

# Verify configuration
dokku config evo

# Rebuild application
dokku ps:rebuild evo
```

**Database connection issues:**
```bash
# Verify database link
dokku postgres:links evo

# Check database status
dokku postgres:info evo

# Test connection
dokku postgres:connect evo -c "SELECT 1;"
```

**Out of memory:**
```bash
# Check current usage
dokku ps:report evo | grep -i memory

# Increase memory limit
dokku resource:limit evo --memory 1024m

# Restart application
dokku ps:restart evo
```

**Storage full:**
```bash
# Check disk usage
df -h /var/lib/dokku/data/storage

# Clean old files
dokku enter evo web
find /evolution/instances -type f -mtime +30 -delete

# Optimize database
dokku postgres:connect evo -c "VACUUM FULL;"
```

### View System Information

```bash
# Dokku version
dokku version

# Docker version
docker --version

# System resources
free -h
df -h
top
```

## Domain and SSL Management

### Domain Commands

```bash
# List domains
dokku domains:report evo

# Add domain
dokku domains:add evo api.example.com

# Remove domain
dokku domains:remove evo api.example.com

# Clear all domains
dokku domains:clear evo
```

### SSL/TLS Commands

```bash
# Enable Let's Encrypt
dokku letsencrypt:enable evo

# Renew certificate
dokku letsencrypt:renew evo

# View certificate info
dokku letsencrypt:list

# Disable Let's Encrypt
dokku letsencrypt:disable evo

# Set email for Let's Encrypt
dokku letsencrypt:set evo email you@example.com
```

### Auto-Renewal

```bash
# Add cron job for auto-renewal
dokku letsencrypt:cron-job --add

# Remove cron job
dokku letsencrypt:cron-job --remove

# List cron jobs
dokku letsencrypt:cron-job --list
```

## Network Management

### View Network Information

```bash
# View network configuration
dokku network:report evo

# List Docker networks
docker network ls
```

### Create and Manage Networks

```bash
# Create network
dokku network:create custom-network

# Attach to network
dokku network:set evo attach-post-create custom-network

# Detach from network
dokku network:set evo detach-post-create custom-network
```

## Redis Management (Optional)

> **Note**: Redis is **NOT required** and NOT included by default. These commands are only for teams that have installed Redis (50+ users). See [Redis Integration Guide](redis-integration.md) for complete setup and configuration.

**If you have Redis installed:**

```bash
# Create Redis instance
dokku redis:create evo

# Link to application
dokku redis:link evo evo

# View Redis info
dokku redis:info evo

# Connect to Redis
dokku redis:connect evo

# Backup Redis
dokku redis:backup evo backup-$(date +%Y%m%d)

# List backups
dokku redis:backup-list evo

# Remove Redis (if no longer needed)
dokku redis:unlink evo evo
dokku redis:destroy evo
```

**For complete Redis documentation**, see [Redis Integration Guide](redis-integration.md).

## Automation Scripts

### Daily Backup Script

Create `/root/backup-evolution.sh`:
```bash
#!/bin/bash
DATE=$(date +%Y%m%d-%H%M%S)
dokku postgres:backup evo backup-$DATE
echo "Backup created: backup-$DATE"
```

Make executable and add to cron:
```bash
chmod +x /root/backup-evolution.sh
echo "0 2 * * * /root/backup-evolution.sh" | crontab -
```

### Health Check Script

Create `/root/check-evolution.sh`:
```bash
#!/bin/bash
if ! curl -f -s https://evo.example.com > /dev/null; then
    echo "Evolution API is down! Restarting..."
    dokku ps:restart evo
    echo "Restarted at $(date)" >> /var/log/evolution-restarts.log
fi
```

Make executable and add to cron (check every 5 minutes):
```bash
chmod +x /root/check-evolution.sh
echo "*/5 * * * * /root/check-evolution.sh" | crontab -
```

## Quick Reference

### Most Common Commands

```bash
# View logs
dokku logs evo -t

# Restart app
dokku ps:restart evo

# View config
dokku config evo

# Database backup
dokku postgres:backup evo backup-$(date +%Y%m%d)

# Check resources
dokku resource:report evo

# Update app
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

### Emergency Commands

```bash
# Application crashed
dokku ps:rebuild evo

# Out of memory
dokku resource:limit evo --memory 1024m
dokku ps:restart evo

# Database issues
dokku postgres:restart evo

# Full reset (CAUTION: DATA LOSS)
dokku ps:stop evo
dokku postgres:destroy evo --force
dokku postgres:create evo
dokku postgres:link evo evo
dokku ps:rebuild evo
```

## Next Steps

- [Performance & Optimization](performance.md) - Optimize your deployment
- [Configuration](configuration.md) - Advanced configuration options
- [System Requirements](system-requirements.md) - Hardware recommendations

## References

- [Dokku CLI Reference](https://dokku.com/docs/deployment/application-management/)
- [PostgreSQL Plugin](https://github.com/dokku/dokku-postgres)
- [Evolution API Documentation](https://doc.evolution-api.com/)
