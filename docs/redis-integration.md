# Redis Integration Guide (Optional)

This document provides instructions for integrating Redis caching into your Evolution API deployment. **Redis is NOT required** for basic operation and should only be added when needed for performance optimization with larger teams (50+ users).

## Table of Contents

- [When to Use Redis](#when-to-use-redis)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Verification](#verification)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Removal](#removal)

## When to Use Redis

Consider adding Redis when:

- **Team size exceeds 50 users**
- **Message volume exceeds 2000 messages/day**
- **Response times are consistently above 200ms**
- **Database queries are causing bottlenecks**
- **Multiple instances need session sharing**

### Do NOT Use Redis If:

- ❌ Team has less than 50 users
- ❌ Message volume is under 2000 messages/day
- ❌ Current performance is satisfactory
- ❌ Want to minimize infrastructure complexity
- ❌ Want to reduce resource costs

> **Important**: Evolution API works perfectly without Redis. The default PostgreSQL-only setup is optimized for most use cases (1-50 users).

## Prerequisites

Before installing Redis:

1. **Verify current performance** is insufficient
2. **Monitor resource usage** to ensure Redis is needed
3. **Ensure Dokku Redis plugin** is available
4. **Plan for additional resource allocation** (Redis needs ~128MB RAM minimum)

## Installation

### Step 1: Install Dokku Redis Plugin

**Linux/macOS:**
```bash
dokku plugin:install https://github.com/dokku/dokku-redis.git redis
```

**Windows (PowerShell - Remote):**
```powershell
ssh your-server "dokku plugin:install https://github.com/dokku/dokku-redis.git redis"
```

### Step 2: Create Redis Instance

**Create Redis service:**
```bash
dokku redis:create evo
```

**Expected Output:**
```
-----> Starting container
       Waiting for container to be ready
-----> Creating container database
-----> Redis container created: evo
```

### Step 3: Link Redis to Application

**Link Redis to Evolution API:**
```bash
dokku redis:link evo evo
```

This will automatically set the `REDIS_URL` environment variable.

**Verify link:**
```bash
dokku redis:info evo
```

## Configuration

### Step 1: Enable Redis in Evolution API

**Set environment variables:**
```bash
dokku config:set evo CACHE_REDIS_ENABLED=true
dokku config:set evo CACHE_REDIS_URI="$(dokku config:get evo REDIS_URL)"
```

**Optional - Set custom prefix:**
```bash
dokku config:set evo CACHE_REDIS_PREFIX_KEY="evolution"
```

### Step 2: Configure Redis Settings

**Optimize Redis for your workload:**
```bash
# For small teams (50-100 users)
dokku redis:set evo maxmemory 128mb
dokku redis:set evo maxmemory-policy allkeys-lru

# For medium teams (100-200 users)
dokku redis:set evo maxmemory 256mb
dokku redis:set evo maxmemory-policy allkeys-lru

# For large teams (200+ users)
dokku redis:set evo maxmemory 512mb
dokku redis:set evo maxmemory-policy allkeys-lru
```

### Step 3: Restart Application

**Restart to apply changes:**
```bash
dokku ps:restart evo
```

## Verification

### Check Redis Connection

**Connect to Redis CLI:**
```bash
dokku redis:connect evo
```

**Test Redis commands:**
```redis
# Inside Redis CLI
PING
# Expected: PONG

INFO stats
# Should show connection info

KEYS evolution:*
# Shows cached keys (if any)

exit
```

### Verify Application Logs

**Check Evolution API logs:**
```bash
dokku logs evo --tail 100
```

**Look for Redis connection messages:**
```
[INFO] Redis cache enabled
[INFO] Connected to Redis at redis://...
```

### Monitor Performance Improvement

**Before Redis:**
```bash
# Check response time
curl -w "@curl-format.txt" -o /dev/null -s "https://your-domain.com/health"
```

Create `curl-format.txt`:
```
time_total: %{time_total}s\n
```

**After Redis** (should show faster response times):
```bash
curl -w "@curl-format.txt" -o /dev/null -s "https://your-domain.com/health"
```

## Monitoring

### Monitor Redis Performance

**Check Redis stats:**
```bash
dokku redis:info evo
```

**View Redis logs:**
```bash
dokku redis:logs evo
```

**Monitor memory usage:**
```bash
dokku redis:connect evo
# Inside Redis CLI
INFO memory
```

### Monitor Application Performance

**Check API response times:**
```bash
# Create monitoring script
cat > /root/monitor-redis.sh << 'EOF'
#!/bin/bash
echo "=== Redis Stats ==="
dokku redis:info evo | grep -E "used_memory|connected_clients|total_commands"

echo -e "\n=== Evolution API Response Time ==="
curl -w "Response time: %{time_total}s\n" -o /dev/null -s "https://your-domain.com/health"
EOF

chmod +x /root/monitor-redis.sh
```

**Run monitoring:**
```bash
/root/monitor-redis.sh
```

### Set Up Redis Backups

**Create backup:**
```bash
dokku redis:backup evo backup-$(date +%Y%m%d-%H%M%S)
```

**Schedule automated backups** (daily at 2 AM):
```bash
# Create backup script
cat > /root/backup-redis.sh << 'EOF'
#!/bin/bash
BACKUP_NAME="redis-backup-$(date +%Y%m%d-%H%M%S)"
dokku redis:backup evo $BACKUP_NAME
dokku redis:backup-list evo | head -n 20
EOF

chmod +x /root/backup-redis.sh

# Add to crontab
echo "0 2 * * * /root/backup-redis.sh" | crontab -
```

**List backups:**
```bash
dokku redis:backup-list evo
```

**Restore from backup:**
```bash
dokku redis:backup-restore evo backup-name
```

## Troubleshooting

### Redis Connection Issues

**Problem**: Application can't connect to Redis

**Solution**:
```bash
# Check Redis is running
dokku redis:info evo

# Verify link
dokku redis:links evo

# Check environment variable
dokku config:get evo REDIS_URL

# Restart services
dokku redis:restart evo
dokku ps:restart evo
```

### High Memory Usage

**Problem**: Redis consuming too much memory

**Solution**:
```bash
# Check current memory usage
dokku redis:connect evo
# Inside Redis CLI: INFO memory

# Reduce max memory
dokku redis:set evo maxmemory 128mb

# Clear cache if needed
dokku redis:connect evo
# Inside Redis CLI: FLUSHALL
```

### Performance Not Improving

**Problem**: No performance improvement after Redis installation

**Possible causes**:
- Redis not actually needed (workload too small)
- Incorrect configuration
- Database is the bottleneck, not cache

**Solution**:
```bash
# Profile the application
dokku logs evo --tail 1000 | grep -E "slow|timeout|error"

# Check if Redis is being used
dokku redis:connect evo
# Inside Redis CLI: INFO stats
# Look for "total_commands_processed"

# If Redis shows low usage, consider removing it
```

### Connection Timeout

**Problem**: Redis connection timeout errors

**Solution**:
```bash
# Increase timeout
dokku config:set evo CACHE_REDIS_CONNECT_TIMEOUT=10000

# Check Redis service health
dokku redis:restart evo
dokku redis:logs evo
```

## Removal

If you decide Redis is not needed, you can safely remove it:

### Step 1: Disable Redis in Application

```bash
dokku config:unset evo CACHE_REDIS_ENABLED
dokku config:unset evo CACHE_REDIS_URI
dokku config:unset evo CACHE_REDIS_PREFIX_KEY
```

### Step 2: Restart Application

```bash
dokku ps:restart evo
```

### Step 3: Unlink and Destroy Redis

**Unlink Redis from application:**
```bash
dokku redis:unlink evo evo
```

**Destroy Redis instance:**
```bash
dokku redis:destroy evo
```

**Confirm deletion** when prompted.

### Step 4: (Optional) Remove Redis Plugin

If you don't need Redis for any other apps:

```bash
dokku plugin:uninstall redis
```

## Performance Comparison

### With Redis (50+ users)

**Advantages:**
- ✅ Faster API response times (50-100ms improvement)
- ✅ Reduced database load
- ✅ Better handling of concurrent requests
- ✅ Session data caching

**Trade-offs:**
- ❌ Additional 128-512MB RAM usage
- ❌ More complex infrastructure
- ❌ Additional monitoring required
- ❌ Higher maintenance overhead

### Without Redis (1-50 users)

**Advantages:**
- ✅ Simpler infrastructure
- ✅ Lower resource usage (256MB total)
- ✅ Easier to maintain
- ✅ Lower costs
- ✅ Fewer failure points

**Trade-offs:**
- ❌ Slightly slower response times (acceptable for small teams)
- ❌ Database does more work (still fine for small workloads)

## Best Practices

1. **Start without Redis** - Only add when performance metrics indicate need
2. **Monitor before and after** - Measure actual performance improvement
3. **Set memory limits** - Prevent Redis from consuming too much RAM
4. **Regular backups** - Schedule automated Redis backups
5. **Monitor cache hit ratio** - Ensure Redis is actually being used effectively
6. **Set expiration policies** - Prevent stale data accumulation
7. **Use appropriate eviction policy** - `allkeys-lru` is recommended for most cases

## Additional Resources

- [Redis Documentation](https://redis.io/docs/)
- [Dokku Redis Plugin](https://github.com/dokku/dokku-redis)
- [Evolution API Documentation](https://doc.evolution-api.com/)
- [Performance Optimization Guide](performance.md)

## Summary

Redis is a powerful caching solution that can significantly improve Evolution API performance **for larger teams (50+ users)**. However, it adds complexity and resource overhead that is unnecessary for smaller deployments.

**Key Takeaways:**
- ✅ Evolution API works perfectly without Redis for teams under 50 users
- ✅ Only add Redis when performance metrics indicate a clear need
- ✅ Monitor performance before and after Redis installation
- ✅ Redis can be safely added or removed at any time
- ✅ Default PostgreSQL-only setup is optimized for most use cases

---

**Next Steps:**
- [Performance Optimization](performance.md) - Additional optimization techniques
- [Configuration Guide](configuration.md) - Complete environment variable reference
- [Useful Commands](useful-commands.md) - Redis management commands
