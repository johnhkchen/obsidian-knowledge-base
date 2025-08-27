# System Maintenance Runbook

## Overview

This runbook provides systematic maintenance procedures for the Obsidian LiveSync infrastructure. Follow these procedures to ensure system reliability, security, and performance.

## Daily Maintenance (Automated)

### Automated Health Checks
The system runs automated health checks via scheduled scripts:

```bash
# Health check script runs every 15 minutes
# Located at: ./scripts/health-check.sh
# Logs to: ./logs/health-check.log

# Manual health check
./scripts/health-check.sh
```

### Automated Backups
Daily backups are created automatically:

```bash
# Backup script runs daily at 2 AM
# Located at: ./scripts/backup-couchdb.sh
# Backups stored in: ./backups/couchdb/

# Manual backup
./scripts/backup-couchdb.sh
```

### Performance Monitoring
System metrics are collected continuously:

```bash
# Performance monitoring runs every 5 minutes
# Located at: ./scripts/performance-monitor.sh
# Metrics stored in: ./logs/performance.log

# Manual performance check
./scripts/performance-monitor.sh
```

## Weekly Maintenance Tasks

### 1. System Health Review

**Review Health Check Logs:**
```bash
# Check for any recent failures
grep -i "error\|fail\|warn" logs/health-check.log | tail -20

# Check service uptime
docker compose ps
docker stats --no-stream obsidian-couchdb obsidian-nginx
```

**Verify Backup Integrity:**
```bash
# List recent backups
ls -la backups/couchdb/ | tail -10

# Test backup integrity (weekly)
./scripts/restore-couchdb.sh --verify latest
```

### 2. Performance Analysis

**Review Performance Trends:**
```bash
# Analyze performance logs
tail -100 logs/performance.log | grep -E "cpu|memory|disk"

# Check database size growth
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE" | \
  jq '.sizes.file' | numfmt --to=iec
```

**Network Performance:**
```bash
# Check Tailscale connectivity
tailscale status | grep -E "active|idle"

# Test sync performance from different devices
# (Manual test - create note, time sync completion)
```

### 3. Security Review

**Check Access Logs:**
```bash
# Review nginx access logs for unusual patterns
tail -100 /tmp/nginx_access.log | grep -v "200 OK" | tail -20

# Check CouchDB access patterns
docker compose logs obsidian-couchdb | grep -E "GET|POST|PUT" | tail -20
```

**Credential Verification:**
```bash
# Verify environment variables are still valid
source .env
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/_session" | jq '.userCtx'
```

## Monthly Maintenance Tasks

### 1. Database Maintenance

**Database Compaction:**
```bash
# Compact main database
curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/_compact"

# Monitor compaction progress
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE" | \
  jq '.compact_running'

# Wait for completion, then verify size reduction
```

**View Compaction:**
```bash
# Compact view indexes
curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/_compact/_design/livesync"
```

### 2. System Updates

**Container Updates:**
```bash
# Pull latest container images
docker compose pull

# Update containers (during maintenance window)
docker compose up -d

# Verify all services started correctly
docker compose ps
./scripts/health-check.sh
```

**SSL Certificate Renewal:**
```bash
# Check certificate expiration
openssl x509 -in ssl/ssl-cert.crt -noout -dates

# If approaching expiration, regenerate:
# openssl req -x509 -newkey rsa:4096 -keyout ssl/ssl-cert.key \
#   -out ssl/ssl-cert.crt -sha256 -days 365 -nodes \
#   -subj "/CN=YOUR_TAILSCALE_HOSTNAME"

# Restart nginx after certificate update
docker compose restart obsidian-nginx
```

### 3. Backup Management

**Backup Cleanup:**
```bash
# Remove backups older than 90 days
find backups/couchdb/ -name "*.tar.gz" -mtime +90 -delete

# Verify sufficient backup retention
ls -la backups/couchdb/ | wc -l  # Should have 30+ recent backups
```

**Backup Verification:**
```bash
# Monthly backup restore test (use test environment)
# ./scripts/restore-couchdb.sh --test-environment latest
```

## Quarterly Maintenance Tasks

### 1. Security Audit

**Credential Rotation:**
```bash
# Generate new CouchDB credentials
NEW_PASSWORD=$(openssl rand -base64 32)

# Update CouchDB admin password
curl -X PUT "http://localhost:5984/_node/_local/_config/admins/$COUCHDB_USER" \
  -d "\"$NEW_PASSWORD\""

# Update .env file with new password
# Update all devices with new credentials
```

**Access Review:**
```bash
# Review all Tailscale devices
tailscale status --json | jq '.Peer[] | {name: .HostName, active: .Active}'

# Remove unused/old devices from Tailscale admin console
```

### 2. Performance Optimization

**Database Optimization:**
```bash
# Analyze database performance
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/_utils/#database/$LIVESYNC_DATABASE/_all_docs"

# Check for fragmentation and unused indexes
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE" | \
  jq '.sizes'
```

**System Resource Review:**
```bash
# Check disk usage trends
df -h | grep -E "/|docker"

# Review memory usage patterns
docker stats --no-stream | grep obsidian

# Analyze CPU usage during peak sync times
```

### 3. Disaster Recovery Testing

**Backup Restore Testing:**
```bash
# Full disaster recovery test (use test environment)
# 1. Stop all services
# 2. Remove all data
# 3. Restore from backup
# 4. Verify full functionality
```

**Documentation Updates:**
```bash
# Update runbooks with any new procedures
# Update contact information
# Review and update recovery procedures
# Test all documented procedures
```

## Emergency Maintenance Procedures

### Service Outage Response

**Immediate Actions:**
```bash
# Check service status
docker compose ps
./scripts/health-check.sh

# Check system resources
df -h
free -h
docker system df
```

**Service Recovery:**
```bash
# Restart specific service
docker compose restart obsidian-couchdb
# OR restart all services
docker compose down && docker compose up -d

# Verify recovery
./scripts/health-check.sh
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" http://localhost:5984/_up
```

### Data Corruption Response

**Assessment:**
```bash
# Check database integrity
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/_all_docs?limit=1"

# Check container logs for errors
docker compose logs obsidian-couchdb --tail 100
```

**Recovery:**
```bash
# Stop services immediately
docker compose down

# Restore from most recent backup
./scripts/restore-couchdb.sh latest

# Restart services
docker compose up -d

# Verify data integrity
./scripts/health-check.sh
```

## Maintenance Windows

### Planned Maintenance

**Preparation:**
1. Announce maintenance window to users
2. Create full system backup
3. Test recovery procedures
4. Prepare rollback plan

**During Maintenance:**
1. Monitor all changes carefully
2. Test each change before proceeding to next
3. Keep detailed log of all actions
4. Have rollback procedures ready

**Post-Maintenance:**
1. Verify all services functional
2. Test sync from all devices
3. Monitor for 24 hours after changes
4. Document any issues or improvements

### Emergency Maintenance

**When Required:**
- Security vulnerability discovered
- Critical service failure
- Data corruption detected
- Infrastructure failure

**Response Procedure:**
1. Assess severity and impact
2. Create immediate backup if possible
3. Implement fix with minimal downtime
4. Verify system integrity
5. Monitor for 48 hours post-fix
6. Document incident and resolution

## Monitoring and Alerting

### Health Monitoring

**Automated Checks:**
- Service availability every 15 minutes
- Backup completion daily
- Disk space monitoring every hour
- Certificate expiration monthly

**Alert Thresholds:**
- Service down > 5 minutes
- Backup failed for 2+ days
- Disk space > 85% full
- Certificate expires < 30 days

### Performance Monitoring

**Key Metrics:**
- Response time to sync requests
- Database size growth rate
- CPU/memory usage patterns
- Network connectivity stability

**Alert Conditions:**
- Sync response time > 30 seconds
- Database growth > 10GB/month
- CPU usage > 80% for 1+ hour
- Network connectivity < 95% uptime

## Documentation Maintenance

### Runbook Updates

**Monthly Review:**
- Verify all procedures work as documented
- Update version numbers and paths
- Add new procedures discovered during maintenance
- Remove obsolete procedures

**Change Control:**
- Document all procedure changes
- Test changes before implementing
- Update training materials
- Communicate changes to administrators

## Contact Information

**System Administrator:** [Contact Info]
**Backup Administrator:** [Contact Info]  
**Emergency Contact:** [Contact Info]
**Escalation Path:** [Defined escalation procedure]

---

**Maintenance Schedule:**
- **Daily:** Automated (health checks, backups, monitoring)
- **Weekly:** Manual review and verification (30 minutes)
- **Monthly:** Database maintenance and updates (2 hours)
- **Quarterly:** Security audit and optimization (4 hours)
- **Emergency:** As needed (immediate response)

**Last Updated:** 2025-08-27  
**Next Review:** 2025-11-27