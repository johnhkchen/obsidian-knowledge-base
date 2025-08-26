# CouchDB Backup and Restore Procedures

## Overview
This document describes the backup and restore procedures for the Obsidian knowledge base CouchDB database.

## Backup Strategy

### Automated Backup Script
Location: `scripts/backup-couchdb.sh`

### Backup Methods Implemented

1. **Volume-based Backup** (Primary)
   - Creates filesystem-level copies of Docker volumes
   - Includes both data and configuration
   - Always functional regardless of CouchDB state

2. **Database-level Backup** (Secondary)
   - Exports database documents via CouchDB API
   - Requires CouchDB to be running and accessible
   - Provides logical backup of data

### Running Backups

#### Manual Backup
```bash
# Run backup script
./scripts/backup-couchdb.sh
```

#### Automated Backup Schedule (Recommended)
Create a cron job for daily backups at 2 AM:

```bash
# Edit crontab
crontab -e

# Add this line:
0 2 * * * cd /home/jchen/services/obsidian-knowledge-base && ./scripts/backup-couchdb.sh >> /var/log/couchdb-backup.log 2>&1
```

### Backup Storage
- **Location**: `backups/couchdb/`
- **Format**: Compressed tar.gz archives
- **Naming**: `couchdb_backup_YYYYMMDD_HHMMSS.tar.gz`
- **Retention**: 7 days (automatically cleaned)

### Backup Contents
Each backup includes:
- CouchDB data volume (database files)
- CouchDB config volume (configuration files)
- Database dumps (JSON format, if accessible)
- Backup metadata (timestamp, size, file count)

## Restore Procedures

### Restore Script
Location: `scripts/restore-couchdb.sh`

### Restore Options

#### Restore Latest Backup
```bash
./scripts/restore-couchdb.sh latest
```

#### Restore Specific Backup
```bash
# List available backups
ls -lt backups/couchdb/

# Restore specific backup
./scripts/restore-couchdb.sh couchdb_backup_20250826_151735.tar.gz
```

### Restore Process
1. **Warning prompt** - Confirms destructive operation
2. **Stop CouchDB** - Prevents data corruption
3. **Remove existing volumes** - Clears current data
4. **Create new volumes** - Fresh volume creation
5. **Restore data** - Copies backup data to volumes
6. **Restart CouchDB** - Starts service with restored data
7. **Wait for startup** - Ensures CouchDB is ready
8. **Restore databases** - Imports logical backups (if available)

### Verification After Restore
```bash
# Check container status
docker compose ps

# Test CouchDB API
curl http://localhost:5984

# Check databases (if credentials are working)
curl -u admin:password http://localhost:5984/_all_dbs
```

## Disaster Recovery

### Complete System Recovery
1. **Install Dependencies**
   - Docker and Docker Compose
   - Basic tools (curl, jq)

2. **Restore Repository**
   ```bash
   git clone <repository-url>
   cd obsidian-knowledge-base
   ```

3. **Restore Configuration**
   - Restore `.env` file with credentials
   - Verify `docker-compose.yml` configuration

4. **Restore Database**
   ```bash
   # Copy backup file to backups/couchdb/
   ./scripts/restore-couchdb.sh <backup-file>
   ```

5. **Verify Services**
   ```bash
   docker compose up -d
   docker compose ps
   ```

### Partial Recovery (Data Only)
If only database data is lost but configuration is intact:

```bash
# Stop service
docker compose stop couchdb

# Restore from backup
./scripts/restore-couchdb.sh latest

# Service will restart automatically
```

## Backup Monitoring

### Backup Status Check
```bash
# List recent backups
ls -lt backups/couchdb/ | head -5

# Check backup sizes
du -sh backups/couchdb/*.tar.gz

# Verify backup integrity
tar -tzf backups/couchdb/couchdb_backup_YYYYMMDD_HHMMSS.tar.gz
```

### Backup Health Monitoring
- Monitor backup directory size growth
- Verify daily backup creation
- Test restore procedure monthly
- Check backup log files for errors

## Security Considerations

### Backup Security
- Backups contain sensitive data and credentials
- Store in secure location with appropriate permissions
- Consider encryption for offsite storage
- Limit access to backup files

### Restore Security
- Verify backup integrity before restore
- Use secure channels for backup transfer
- Validate backup source and authenticity

## Troubleshooting

### Common Issues

#### Backup Script Permission Errors
- Ensure script is executable: `chmod +x scripts/backup-couchdb.sh`
- Check backup directory permissions
- Verify Docker access for current user

#### CouchDB Not Accessible During Backup
- Volume backup will still work
- Check CouchDB credentials in `.env`
- Verify container is running: `docker compose ps`

#### Restore Fails
- Check available disk space
- Verify backup file integrity
- Ensure Docker volumes can be removed
- Stop all dependent services

### Recovery from Failed Restore
If restore fails midway:
1. Stop CouchDB: `docker compose stop couchdb`
2. Remove partial volumes: `docker volume rm obsidian-knowledge-base_couchdb_*`
3. Retry restore with same backup file
4. If still failing, restore from older backup

## Testing and Validation

### Monthly Restore Test
1. Create test environment
2. Restore from recent backup
3. Verify data integrity
4. Test Obsidian sync functionality
5. Document any issues found

### Backup Validation
- Verify backup file can be extracted
- Check backup metadata for completeness
- Test small restore operations
- Monitor backup file sizes for anomalies

---

**Last Updated**: 2025-08-26  
**Next Review**: 2025-11-26  
**Owner**: System Administrator