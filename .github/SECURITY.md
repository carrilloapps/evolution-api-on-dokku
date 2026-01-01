# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the deployment configuration. Evolution API security issues should be reported to the [Evolution API project](https://github.com/EvolutionAPI/evolution-api).

| Version | Supported          |
| ------- | ------------------ |
| Latest  | :white_check_mark: |
| < Latest | :x:                |

## Reporting a Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

If you discover a security vulnerability in this deployment configuration, please send an email to the maintainer. You can find the contact information in the [FUNDING.yml](.github/FUNDING.yml) file or GitHub profile.

Please include the following information:

- **Description**: A clear description of the vulnerability
- **Impact**: How the vulnerability could be exploited
- **Steps to Reproduce**: Detailed steps to reproduce the vulnerability
- **Environment**: Version information (Dokku, Evolution API, OS, etc.)
- **Potential Fix**: If you have a suggested fix, please include it

### What to Expect

- **Acknowledgment**: We will acknowledge receipt of your vulnerability report within 48 hours
- **Investigation**: We will investigate and confirm the vulnerability
- **Resolution**: We will work on a fix and release it as soon as possible
- **Disclosure**: We will coordinate public disclosure with you after the fix is released

## Security Best Practices

When deploying Evolution API on Dokku, follow these security best practices:

### 1. Use Strong Authentication

```bash
# Generate strong API keys (minimum 32 characters)
API_KEY=$(openssl rand -hex 32)
dokku config:set evo AUTHENTICATION_API_KEY="$API_KEY"
```

### 2. Enable HTTPS

```bash
# Always use HTTPS in production
dokku letsencrypt:enable evo
dokku letsencrypt:cron-job --add
```

### 3. Secure Database Access

```bash
# Use strong database passwords
# Restrict database access to localhost
# Enable SSL/TLS for database connections
```

### 4. Regular Updates

```bash
# Keep Dokku updated
dokku version

# Keep PostgreSQL updated
dokku postgres:info evo

# Keep Evolution API updated
dokku git:sync --build evo https://github.com/carrilloapps/evolution-api-on-dokku.git
```

### 5. Limit Resource Access

```bash
# Set appropriate resource limits
dokku resource:limit evo --memory 512m --cpu 1

# Monitor resource usage
dokku ps:report evo
```

### 6. Secure Environment Variables

```bash
# Never commit secrets to version control
# Use environment variables for sensitive data
# Rotate API keys regularly
dokku config:set evo AUTHENTICATION_API_KEY="new-secure-key"
```

### 7. Enable Firewall

```bash
# Configure UFW or iptables
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 80/tcp  # HTTP
sudo ufw allow 443/tcp # HTTPS
sudo ufw enable
```

### 8. Regular Backups

```bash
# Backup database regularly
dokku postgres:backup evo backup-$(date +%Y%m%d)

# Store backups securely offsite
```

### 9. Monitor Logs

```bash
# Regularly review logs for suspicious activity
dokku logs evo -t

# Set up log monitoring and alerting
```

### 10. Restrict SSH Access

```bash
# Use SSH keys instead of passwords
# Disable root login
# Use non-standard SSH port
# Enable fail2ban
```

## Evolution API Security

For security issues specific to Evolution API:

- Visit the [Evolution API Security Policy](https://github.com/EvolutionAPI/evolution-api/security)
- Report issues to the Evolution API maintainers
- Keep Evolution API updated to the latest version

## Dokku Security

For security issues specific to Dokku:

- Visit the [Dokku Security Documentation](http://dokku.viewdocs.io/dokku/deployment/security/)
- Keep Dokku updated to the latest stable version
- Follow Dokku security best practices

## PostgreSQL Security

For PostgreSQL security:

- Use the latest PostgreSQL version
- Enable SSL/TLS connections
- Use strong passwords
- Regular security patches
- Follow [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/security.html)

## Compliance

This deployment can be configured to meet various compliance requirements:

- **GDPR**: Implement data retention policies, encryption, and access controls
- **HIPAA**: Enable encryption at rest and in transit, implement access logs
- **SOC 2**: Implement monitoring, logging, and access controls

Consult with your compliance team for specific requirements.

## Contact

For security concerns, please contact the maintainer through:

- Email: See GitHub profile or FUNDING.yml
- GitHub: Open a security advisory (preferred for critical issues)

## Acknowledgments

We appreciate the security research community's efforts in responsibly disclosing vulnerabilities. Contributors will be acknowledged in our security advisories (with their permission).

---

**Last Updated**: 2026-01-01
