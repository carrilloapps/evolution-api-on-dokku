# Performance & Optimization

This document provides tips and best practices for optimizing Evolution API performance on Dokku.

## Table of Contents

- [Performance Overview](#performance-overview)
- [Resource Optimization](#resource-optimization)
- [Database Optimization](#database-optimization)
- [Caching with Redis](#caching-with-redis)
- [Storage Optimization](#storage-optimization)
- [Network Optimization](#network-optimization)
- [Monitoring and Alerting](#monitoring-and-alerting)
- [Scaling Strategies](#scaling-strategies)

## Performance Overview

### Performance by Team Size

| Team Size | Expected Performance | Configuration |
|-----------|---------------------|---------------|
| 1-10 users | 100-500 msg/day | Minimal (256MB RAM, 0.5 CPU) |
| 10-50 users | 500-2000 msg/day | Small (512MB RAM, 1 CPU) |
| 50-200 users | 2000-10000 msg/day | Medium (1GB RAM, 2 CPU) + Redis |
| 200+ users | 10000+ msg/day | High (2GB+ RAM, 4+ CPU) + Redis + Optimizations |

### Key Performance Indicators (KPIs)

Monitor these metrics to ensure optimal performance:

- **Response Time**: < 100ms for API calls
- **CPU Usage**: < 70% average
- **RAM Usage**: < 80% of allocated
- **Database Size**: Monitor growth rate
- **Disk I/O**: < 50% of available
- **Network Latency**: < 50ms

## Resource Optimization

### Adjust Resources Based on Usage

**Check current usage:**
```bash
# View current resource usage
dokku ps:report evo

# Monitor in real-time
docker stats $(dokku ps:inspect evo | jq -r '.[].ID')
```

**Windows (PowerShell):**
```powershell
ssh your-server "ps:report evo"
```

### Resource Allocation Guidelines

**For 1-10 users (default):**
```bash
dokku resource:limit evo --memory 256m --cpu 0.5
```

**For 10-50 users:**
```bash
dokku resource:limit evo --memory 512m --cpu 1
```

**For 50-200 users:**
```bash
dokku resource:limit evo --memory 1024m --cpu 2
```

**For 200+ users:**
```bash
dokku resource:limit evo --memory 2048m --cpu 4
```

### Optimize Container Settings

**Increase swap memory** (if needed):
```bash
# On the host server
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' >> /etc/fstab
```

## Database Optimization

### Disable Unnecessary Data Logging

**For high-volume deployments**, disable unnecessary data logging:

```bash
# Disable message history (saves ~70% database space)
dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=false

# Disable message updates (saves ~20% database space)
dokku config:set evo DATABASE_SAVE_MESSAGE_UPDATE=false

# Disable label tracking (saves ~5% database space)
dokku config:set evo DATABASE_SAVE_DATA_LABELS=false
```

**Recommended for production:**
```bash
# Keep essential data only
dokku config:set evo DATABASE_SAVE_DATA_INSTANCE=true
dokku config:set evo DATABASE_SAVE_DATA_NEW_MESSAGE=true
dokku config:set evo DATABASE_SAVE_DATA_CONTACTS=true
dokku config:set evo DATABASE_SAVE_DATA_CHATS=true
dokku config:set evo DATABASE_SAVE_DATA_HISTORIC=false
dokku config:set evo DATABASE_SAVE_MESSAGE_UPDATE=false
dokku config:set evo DATABASE_SAVE_DATA_LABELS=false
```

### Database Maintenance

**Regular vacuum** (optimize database):
```bash
# Weekly maintenance
dokku postgres:connect evo -c "VACUUM ANALYZE;"

# Full vacuum (requires more time, but better results)
dokku postgres:connect evo -c "VACUUM FULL;"
```

**Automated vacuum script** (`/root/vacuum-evolution.sh`):
```bash
#!/bin/bash
echo "Starting database vacuum at $(date)"
dokku postgres:connect evo -c "VACUUM ANALYZE;" >> /var/log/evolution-vacuum.log 2>&1
echo "Vacuum completed at $(date)"
```

Add to cron (run weekly on Sunday at 3 AM):
```bash
chmod +x /root/vacuum-evolution.sh
echo "0 3 * * 0 /root/vacuum-evolution.sh" | crontab -
```

### Clean Old Data

**Manually clean old data:**
```bash
# Clean messages older than 30 days
dokku postgres:connect evo << EOF
DELETE FROM "Message" WHERE "datetime" < NOW() - INTERVAL '30 days';
EOF

# Clean old sessions
dokku postgres:connect evo << EOF
DELETE FROM "Session" WHERE "updatedAt" < NOW() - INTERVAL '90 days';
EOF
```

**Automated cleanup script** (`/root/cleanup-evolution-db.sh`):
```bash
#!/bin/bash
echo "Starting database cleanup at $(date)"
dokku postgres:connect evo << EOF
DELETE FROM "Message" WHERE "datetime" < NOW() - INTERVAL '30 days';
DELETE FROM "Session" WHERE "updatedAt" < NOW() - INTERVAL '90 days';
VACUUM ANALYZE;
EOF
echo "Cleanup completed at $(date)"
```

Add to cron (run monthly on the 1st at 2 AM):
```bash
chmod +x /root/cleanup-evolution-db.sh
echo "0 2 1 * * /root/cleanup-evolution-db.sh" | crontab -
```

### Index Optimization

**Check for missing indexes:**
```bash
dokku postgres:connect evo -c "
SELECT schemaname, tablename, attname, n_distinct, correlation 
FROM pg_stats 
WHERE schemaname = 'public' 
ORDER BY n_distinct DESC LIMIT 20;"
```

## Caching with Redis

### Enable Redis for Better Performance

**For 50+ users**, Redis is highly recommended:

```bash
# Install Redis plugin (if not installed)
dokku plugin:install https://github.com/dokku/dokku-redis.git redis

# Create Redis instance
dokku redis:create evo

# Link to application
dokku redis:link evo evo

# Enable Redis cache
dokku config:set evo CACHE_REDIS_ENABLED=true
dokku config:set evo CACHE_REDIS_URI="$(dokku config:get evo REDIS_URL)"

# Restart application
dokku ps:restart evo
```

### Redis Configuration

**Set Redis key prefix:**
```bash
dokku config:set evo CACHE_REDIS_PREFIX_KEY="evo"
```

**Check Redis usage:**
```bash
dokku redis:info evo
```

**Monitor Redis:**
```bash
dokku redis:connect evo
> INFO memory
> DBSIZE
> INFO stats
```

### Redis Best Practices

1. **Monitor memory usage** - Redis should not exceed 80% of allocated memory
2. **Set expiration times** for cached data
3. **Use appropriate data structures** (hashes, lists, sets)
4. **Regular backups** - `dokku redis:backup evo backup-$(date +%Y%m%d)`

## Storage Optimization

### Clean Old Media Files

**Manual cleanup:**
```bash
# Enter container
dokku enter evo web

# Find files older than 30 days
find /evolution/instances -type f -mtime +30

# Delete files older than 30 days
find /evolution/instances -type f -mtime +30 -delete

# Check storage usage
du -sh /evolution/instances
```

**Automated cleanup script** (`/root/cleanup-evolution-media.sh`):
```bash
#!/bin/bash
echo "Starting media cleanup at $(date)"
dokku enter evo web bash -c "find /evolution/instances -type f -mtime +30 -delete"
echo "Media cleanup completed at $(date)"
du -sh /var/lib/dokku/data/storage/evo
```

Add to cron (run weekly on Saturday at 4 AM):
```bash
chmod +x /root/cleanup-evolution-media.sh
echo "0 4 * * 6 /root/cleanup-evolution-media.sh" | crontab -
```

### Monitor Storage Usage

**Check storage usage:**
```bash
# Total storage
du -sh /var/lib/dokku/data/storage/evo

# Breakdown by folder
du -h --max-depth=1 /var/lib/dokku/data/storage/evo | sort -h

# Check available space
df -h /var/lib/dokku/data/storage
```

**Set up storage alerts:**
```bash
# Create alert script
cat > /root/check-storage.sh << 'EOF'
#!/bin/bash
USAGE=$(df /var/lib/dokku/data/storage | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $USAGE -gt 80 ]; then
    echo "WARNING: Storage usage is at ${USAGE}%" | mail -s "Evolution API Storage Alert" you@example.com
fi
EOF

chmod +x /root/check-storage.sh
echo "0 */6 * * * /root/check-storage.sh" | crontab -
```

### Compress Old Files

**Compress old media:**
```bash
dokku enter evo web bash -c "
find /evolution/instances -type f -name '*.jpg' -mtime +7 -exec mogrify -quality 80 {} \;
find /evolution/instances -type f -name '*.png' -mtime +7 -exec mogrify -quality 80 {} \;
"
```

## Network Optimization

### Enable HTTP/2

HTTP/2 improves performance for multiple concurrent requests:

```bash
# Ensure HTTPS is enabled first
dokku letsencrypt:enable evo

# HTTP/2 is automatically enabled with HTTPS on modern Dokku/nginx
```

### Configure CDN (Optional)

For high-volume media delivery, consider using a CDN:

1. **CloudFlare** (free tier available)
2. **Amazon CloudFront**
3. **Fastly**

**Benefits:**
- Faster media delivery
- Reduced server load
- Better global performance

### Optimize Network Settings

**Increase nginx buffer size** (if needed):

Create `/home/dokku/evo/nginx.conf.d/buffers.conf`:
```nginx
client_body_buffer_size 16k;
client_max_body_size 50m;
```

Reload nginx:
```bash
dokku nginx:build-config evo
dokku ps:restart evo
```

## Monitoring and Alerting

### Set Up Monitoring

**Install monitoring tools:**
```bash
# Install htop for interactive process monitoring
apt-get install htop

# Install netdata for comprehensive monitoring
bash <(curl -Ss https://my-netdata.io/kickstart.sh)
```

**Access monitoring:**
- Netdata: `http://your-server:19999`
- htop: `htop` (in terminal)

### Application Monitoring

**Monitor logs:**
```bash
# Real-time logs
dokku logs evo -t

# Save logs to file
dokku logs evo > /var/log/evolution-$(date +%Y%m%d).log
```

**Set up log rotation:**

Create `/etc/logrotate.d/evolution`:
```
/var/log/evolution-*.log {
    weekly
    rotate 4
    compress
    delaycompress
    missingok
    notifempty
}
```

### Performance Monitoring Script

Create `/root/monitor-evolution.sh`:
```bash
#!/bin/bash
echo "=== Evolution API Performance Report ==="
echo "Date: $(date)"
echo ""

echo "=== Resource Usage ==="
dokku ps:report evo | grep -E "memory|cpu"
echo ""

echo "=== Database Size ==="
dokku postgres:connect evo -c "SELECT pg_size_pretty(pg_database_size('evo'));"
echo ""

echo "=== Storage Usage ==="
du -sh /var/lib/dokku/data/storage/evo
echo ""

echo "=== Disk Space ==="
df -h /var/lib/dokku/data/storage | grep -v "Filesystem"
echo ""

echo "=== Application Status ==="
curl -s -I https://evo.example.com | head -1
echo ""
```

Make executable and run daily:
```bash
chmod +x /root/monitor-evolution.sh
echo "0 8 * * * /root/monitor-evolution.sh | mail -s 'Evolution API Daily Report' you@example.com" | crontab -
```

### Alert Configuration

**CPU Alert:**
```bash
cat > /root/check-cpu.sh << 'EOF'
#!/bin/bash
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//')
if (( $(echo "$CPU > 80" | bc -l) )); then
    echo "CPU usage is high: ${CPU}%" | mail -s "Evolution API CPU Alert" you@example.com
fi
EOF

chmod +x /root/check-cpu.sh
echo "*/15 * * * * /root/check-cpu.sh" | crontab -
```

**Memory Alert:**
```bash
cat > /root/check-memory.sh << 'EOF'
#!/bin/bash
MEM=$(free | grep Mem | awk '{print ($3/$2) * 100}')
if (( $(echo "$MEM > 80" | bc -l) )); then
    echo "Memory usage is high: ${MEM}%" | mail -s "Evolution API Memory Alert" you@example.com
fi
EOF

chmod +x /root/check-memory.sh
echo "*/15 * * * * /root/check-memory.sh" | crontab -
```

## Scaling Strategies

### Vertical Scaling

**Increase resources** as needed:

```bash
# Start with minimal
dokku resource:limit evo --memory 256m --cpu 0.5

# Scale up as user base grows
dokku resource:limit evo --memory 512m --cpu 1   # 10-50 users
dokku resource:limit evo --memory 1024m --cpu 2  # 50-200 users
dokku resource:limit evo --memory 2048m --cpu 4  # 200+ users
```

### Horizontal Scaling

**Scale to multiple instances:**

```bash
# Scale to 2 instances
dokku ps:scale evo web=2

# Scale to 4 instances (for high volume)
dokku ps:scale evo web=4
```

**Requirements for horizontal scaling:**
- Redis for shared caching
- PostgreSQL for shared database
- Load balancer (nginx automatically configured by Dokku)

**Check current scaling:**
```bash
dokku ps:report evo | grep -i scale
```

### Load Balancing

Dokku automatically load balances between multiple instances using nginx.

**Verify load balancing:**
```bash
# Check nginx configuration
dokku nginx:show-config evo

# Monitor instance distribution
watch -n 1 'docker stats --no-stream | grep evo'
```

## Performance Benchmarking

### Test API Performance

**Simple test:**
```bash
# Test response time
time curl -H "apikey: YOUR_API_KEY" https://evo.example.com
```

**Load testing with Apache Bench:**
```bash
# Install Apache Bench
apt-get install apache2-utils

# Test with 100 concurrent requests
ab -n 1000 -c 100 -H "apikey: YOUR_API_KEY" https://evo.example.com/
```

**Advanced load testing with wrk:**
```bash
# Install wrk
apt-get install wrk

# Test with 10 threads, 100 connections for 30 seconds
wrk -t10 -c100 -d30s -H "apikey: YOUR_API_KEY" https://evo.example.com/
```

## Best Practices Summary

### Essential Optimizations (All Deployments)

1. ✅ Set appropriate resource limits based on team size
2. ✅ Enable automatic backups
3. ✅ Configure persistent storage
4. ✅ Enable HTTPS with Let's Encrypt
5. ✅ Monitor logs regularly

### Recommended Optimizations (50+ Users)

6. ✅ Enable Redis caching
7. ✅ Disable unnecessary database logging
8. ✅ Set up automated database vacuum
9. ✅ Implement storage cleanup
10. ✅ Configure monitoring and alerts

### Advanced Optimizations (200+ Users)

11. ✅ Horizontal scaling (multiple instances)
12. ✅ Database connection pooling
13. ✅ CDN for media delivery
14. ✅ Separate media storage server
15. ✅ Advanced monitoring with Netdata or Prometheus
16. ✅ Load balancing with multiple servers

## Troubleshooting Performance Issues

### Slow Response Times

**Check:**
1. CPU usage: `dokku ps:report evo`
2. RAM usage: `free -h`
3. Database size: `dokku postgres:connect evo -c "SELECT pg_size_pretty(pg_database_size('evo'));"`
4. Disk I/O: `iostat -x 1`

**Solutions:**
- Increase resources
- Enable Redis
- Optimize database queries
- Clean old data

### High CPU Usage

**Check:**
1. Number of active instances
2. Message processing volume
3. Database queries

**Solutions:**
- Scale horizontally
- Enable Redis caching
- Optimize database indexes
- Disable unnecessary features

### High Memory Usage

**Check:**
1. Memory leaks in logs
2. Number of connections
3. Cache size

**Solutions:**
- Increase RAM allocation
- Restart application regularly
- Limit number of instances
- Enable Redis to offload memory

### Database Performance Issues

**Check:**
1. Database size
2. Number of connections
3. Query performance

**Solutions:**
- Run VACUUM ANALYZE
- Clean old data
- Disable unnecessary logging
- Add database indexes

## Next Steps

- [Useful Commands](useful-commands.md) - Management commands reference
- [Configuration](configuration.md) - Advanced configuration options
- [System Requirements](system-requirements.md) - Hardware recommendations

## References

- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Dokku Scaling Guide](https://dokku.com/docs/deployment/scaling/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Redis Best Practices](https://redis.io/topics/optimization)
