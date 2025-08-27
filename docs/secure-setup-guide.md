# Secure LiveSync Setup Guide

## Overview

This guide provides secure setup procedures for Obsidian LiveSync without embedded credentials. All sensitive information should be stored in environment variables or secure configuration files.

## Prerequisites

- Docker and Docker Compose installed
- SSL certificates configured
- Tailscale or equivalent VPN for secure access
- `.env` file configured with all required credentials

## Initial Setup Process

### 1. Environment Configuration

Copy the example environment file and configure with your credentials:

```bash
cp .env.example .env
```

Configure the following variables in your `.env` file:

```bash
# CouchDB Configuration
COUCHDB_USER=your_admin_username
COUCHDB_PASSWORD=your_secure_password_here

# LiveSync Configuration  
LIVESYNC_PASSPHRASE=your_secure_passphrase_here
LIVESYNC_DATABASE=your_database_name

# System Configuration
PUID=1000
PGID=1000
TZ=Your/Timezone

# Obsidian MCP Configuration (if using)
OBSIDIAN_API_KEY=your_api_key_here
```

### 2. SSL Certificate Setup

Ensure SSL certificates are properly configured:

```bash
# Verify certificates exist
ls -la ssl/
# Should show:
# - ssl-cert.crt
# - ssl-cert.key
```

### 3. Container Deployment

Deploy the services using Docker Compose:

```bash
# Start all services
docker compose up -d

# Verify all containers are running
docker compose ps
```

### 4. Database Initialization

Create and configure your LiveSync database:

```bash
# Generate setup URI with environment variables
./generate-setup-uri.sh
```

This script will output a secure setup URI using your configured credentials.

## Obsidian Plugin Configuration

### Desktop Setup

1. Install the LiveSync Community Plugin
2. Use the generated setup URI from step 4 above
3. Verify connection and synchronization

### Mobile Setup

1. Install Obsidian mobile app
2. Install LiveSync plugin
3. Configure manually with these settings:
   - **URI**: Your configured HTTPS endpoint
   - **Username**: Value from `COUCHDB_USER` environment variable
   - **Password**: Value from `COUCHDB_PASSWORD` environment variable  
   - **Database**: Value from `LIVESYNC_DATABASE` environment variable
   - **Passphrase**: Value from `LIVESYNC_PASSPHRASE` environment variable

## Security Best Practices

### Environment Variables

- Never commit `.env` files to version control
- Use strong, randomly generated passwords
- Rotate credentials periodically
- Restrict access to the `.env` file: `chmod 600 .env`

### Network Security

- Use VPN (Tailscale recommended) for external access
- Configure proper firewall rules
- Use SSL/TLS for all connections
- Regularly update SSL certificates

### Access Control

- Use unique credentials for each user/device
- Implement proper user management in CouchDB
- Monitor access logs for suspicious activity
- Set up alerts for failed authentication attempts

## Verification Steps

### 1. Service Health Check

```bash
# Check all services are running
./scripts/health-check.sh

# View service logs
docker compose logs obsidian-couchdb
docker compose logs obsidian-nginx
```

### 2. Connection Test

```bash
# Test CouchDB connectivity
curl -k https://your-server-ip:3880/_up

# Test with authentication
curl -k -u $COUCHDB_USER:$COUCHDB_PASSWORD https://your-server-ip:3880/_all_dbs
```

### 3. Sync Verification

- Create a test note on one device
- Verify it appears on other devices
- Check sync status in plugin settings

## Troubleshooting

Common issues and solutions are documented in the [Troubleshooting Guide](troubleshooting-guide.md).

## Maintenance

- Regular backups: Use `./scripts/backup-couchdb.sh`
- Monitor disk space: `./scripts/disk-space-monitor.sh`
- Health monitoring: `./scripts/health-check.sh`
- Update containers: `docker compose pull && docker compose up -d`

## Support

For additional support, see:
- [Mobile Setup Guide](mobile-setup-guide.md)
- [Troubleshooting Guide](troubleshooting-guide.md)
- [Maintenance Runbook](maintenance-runbook.md)

---

**Security Note**: This setup guide follows security best practices by avoiding embedded credentials and using environment variables for sensitive configuration.