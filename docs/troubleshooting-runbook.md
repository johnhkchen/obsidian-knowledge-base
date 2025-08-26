# Troubleshooting Runbook - Obsidian Knowledge Base

## Quick Diagnostic Commands

```bash
# System health check
./scripts/health-check.sh

# Container status
docker compose ps

# CouchDB connectivity
curl -s http://localhost:5984/_up

# Performance metrics
./scripts/performance-monitor.sh

# Tailscale status
tailscale status
```

---

## Service Issues

### CouchDB Not Responding
**Symptoms**: Connection timeouts, "Service Unavailable" errors

**Diagnosis**:
```bash
docker compose logs couchdb --tail 50
docker compose ps
```

**Solutions**:
1. **Restart Container**:
   ```bash
   docker compose restart couchdb
   ```

2. **Check Credentials**:
   ```bash
   source .env
   echo "User: $COUCHDB_USER"  # Should not be empty
   ```

3. **Volume Permissions**:
   ```bash
   docker volume inspect obsidian-knowledge-base_couchdb_data
   ```

4. **Port Conflicts**:
   ```bash
   netstat -tulpn | grep 5984
   ```

### Container Won't Start
**Symptoms**: Container exits immediately, "Unhealthy" status

**Diagnosis**:
```bash
docker compose logs couchdb
docker events --filter container=obsidian-couchdb
```

**Solutions**:
1. **Check Docker Resources**:
   ```bash
   docker system df
   docker system prune -f  # If disk space low
   ```

2. **Recreate Container**:
   ```bash
   docker compose down
   docker compose up -d
   ```

3. **Reset Volumes** (DESTRUCTIVE):
   ```bash
   docker compose down -v
   # Restore from backup if needed
   ./scripts/restore-couchdb.sh latest
   ```

---

## Sync Issues

### LiveSync Connection Failed
**Symptoms**: Red status in Obsidian, "Connection refused"

**Diagnosis**:
1. **Check Server**:
   ```bash
   curl -s http://localhost:5984
   ```

2. **Test from Mobile** (use actual Tailscale IP):
   ```bash
   curl -s http://100.68.79.63:5984
   ```

**Solutions**:
1. **Verify Tailscale**:
   ```bash
   tailscale status
   # Ensure device is connected
   ```

2. **Check Firewall**:
   ```bash
   sudo ufw status  # If using ufw
   ```

3. **Test Credentials**:
   ```bash
   source .env
   curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" http://localhost:5984/_all_dbs
   ```

### Sync Very Slow
**Symptoms**: Long delays, timeouts during sync

**Diagnosis**:
```bash
# Check performance
./scripts/performance-monitor.sh

# Check network latency
ping 100.68.79.63  # Replace with server IP

# Check database size
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" http://localhost:5984/obsidiandb
```

**Solutions**:
1. **Optimize Settings** (Mobile):
   - Increase sync interval to 60+ seconds
   - Enable "Sync only when WiFi"
   - Reduce "Maximum document size"

2. **Database Maintenance**:
   ```bash
   # Compact database (CouchDB admin console)
   curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
        http://localhost:5984/obsidiandb/_compact
   ```

### Sync Conflicts
**Symptoms**: Multiple versions of same note, conflict notifications

**Solutions**:
1. **Enable Conflict Resolution** (Obsidian LiveSync settings):
   - Set to "Merge" for collaborative editing
   - Use "Overwrite" only if certain

2. **Manual Resolution**:
   - Check for files ending in `_conflict_`
   - Merge content manually
   - Delete conflict files after resolution

---

## Network Issues

### Mobile Can't Connect
**Symptoms**: Works on desktop, fails on mobile

**Diagnosis**:
1. **Test Tailscale** (on mobile):
   - Open Tailscale app
   - Verify connected status
   - Test ping to server

2. **Check IP Address**:
   ```bash
   tailscale status  # Note the server IP
   ```

**Solutions**:
1. **Update Mobile Configuration**:
   - Use `http://[TAILSCALE_IP]:5984`
   - NOT `localhost:5984`

2. **Restart Tailscale**:
   - Disable/enable in mobile app
   - May need to reauthenticate

3. **Check Mobile Network**:
   - Test both WiFi and cellular
   - Some corporate networks block VPN

### Performance Degradation
**Symptoms**: Slow response times, timeouts

**Diagnosis**:
```bash
# System resources
top -bn1 | head -20

# Disk usage
df -h
docker system df

# Network test
ping -c 5 100.68.79.63
```

**Solutions**:
1. **Resource Cleanup**:
   ```bash
   docker system prune -f
   # Clean old backups if disk full
   find backups/couchdb/ -name "*.tar.gz" -mtime +30 -delete
   ```

2. **Container Resources** (edit docker-compose.yml):
   ```yaml
   services:
     couchdb:
       deploy:
         resources:
           limits:
             memory: 1G
           reservations:
             memory: 512M
   ```

---

## Data Issues

### Missing Notes/Data
**Symptoms**: Notes disappeared, database seems empty

**Immediate Actions**:
1. **Don't Panic**: Stop all sync immediately
2. **Check Local Files**: Verify files exist in vault folder
3. **Check Database**:
   ```bash
   curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
        http://localhost:5984/obsidiandb/_all_docs
   ```

**Recovery Steps**:
1. **Restore from Backup**:
   ```bash
   ./scripts/restore-couchdb.sh latest
   ```

2. **Re-sync from Local**:
   - Disable sync on all devices
   - Choose "Copy setup to remote" on device with most recent data
   - Re-enable sync on other devices

### Database Corruption
**Symptoms**: CouchDB errors, inconsistent data

**Recovery**:
1. **Immediate Backup**:
   ```bash
   ./scripts/backup-couchdb.sh
   ```

2. **Database Repair**:
   ```bash
   curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
        http://localhost:5984/obsidiandb/_compact
   ```

3. **Full Reset** (if corruption severe):
   ```bash
   # Backup local files first!
   docker compose down -v
   # Restore clean state and re-sync
   ```

---

## Authentication Issues

### Invalid Credentials
**Symptoms**: 401 Unauthorized errors

**Diagnosis**:
```bash
source .env
echo "Testing: $COUCHDB_USER"
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" http://localhost:5984/_session
```

**Solutions**:
1. **Reset CouchDB Admin**:
   ```bash
   docker compose exec couchdb curl -X PUT \
     http://localhost:5984/_node/_local/_config/admins/$COUCHDB_USER \
     -d "\"$COUCHDB_PASSWORD\""
   ```

2. **Update .env File**:
   - Verify credentials match across all devices
   - No special characters causing encoding issues

### Encryption/Passphrase Issues
**Symptoms**: "Decryption failed" errors

**Solutions**:
1. **Verify Passphrase**:
   - Must be identical across all devices
   - Copy from SYNC_CREDENTIALS.md exactly

2. **Reset Encryption**:
   - Disable E2E on all devices
   - Re-enable with same passphrase
   - Full re-sync may be needed

---

## Monitoring & Alerts

### Health Check Failures
**Check Alert Logs**:
```bash
tail -f logs/alerts.log
tail -f logs/health-check.log
```

**Common Alert Resolutions**:
- **Disk Space**: Clean up old backups, Docker images
- **Service Down**: Restart containers, check resources
- **Backup Age**: Run manual backup, check cron jobs

### Performance Monitoring
**View Metrics**:
```bash
tail -20 logs/performance.log
jq '.' logs/metrics.json | tail -20
```

**Performance Optimization**:
- Monitor CPU/memory usage patterns
- Adjust sync frequency based on usage
- Consider nginx caching for heavy loads

---

## Emergency Procedures

### Complete System Recovery
1. **Assess Damage**: What's working/broken?
2. **Secure Backups**: Identify latest good backup
3. **Document Issue**: Note symptoms and timeline
4. **Restore Service**: Follow backup-restore-procedures.md
5. **Verify Function**: Test sync on all devices
6. **Post-Mortem**: Document root cause and prevention

### Data Loss Prevention
- **Daily Backups**: Verify backup script runs
- **Multiple Copies**: Local + cloud backup strategy
- **Version Control**: Consider git backup of vault
- **Test Restores**: Monthly restore verification

---

## Escalation Contacts

**Self-Service Resources**:
- Health check: `./scripts/health-check.sh`
- Performance: `./scripts/performance-monitor.sh`
- Documentation: `docs/` directory

**When to Escalate**:
- Data loss or corruption
- Security breach suspected
- Multiple failed recovery attempts
- Infrastructure changes needed

---

**Emergency Contact**: System Administrator  
**Documentation Version**: 1.0  
**Last Updated**: 2025-08-26  
**Next Review**: 2025-11-26