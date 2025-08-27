# HKDF Decryption Error Troubleshooting Guide

## Overview

HKDF (HMAC-based Key Derivation Function) decryption errors occur when there are encryption version conflicts or passphrase mismatches in LiveSync. This guide provides systematic troubleshooting steps for resolving these issues.

## Common HKDF Error Symptoms

- "HKDF decryption failed" error messages in Obsidian
- "Invalid encryption version" warnings
- Sync failures with cryptographic errors
- Documents showing as encrypted but unreadable
- New devices unable to decrypt existing data

## Root Causes

### 1. Passphrase Mismatches
- Different passphrases used across devices
- Passphrase entered incorrectly during setup
- Copy/paste errors with whitespace or encoding issues

### 2. Encryption Version Conflicts
- Mixed encryption versions between devices
- Database contains data from different encryption implementations
- Plugin version differences between devices

### 3. Database Migration Issues
- Legacy encrypted data from previous setups
- Incomplete migration between encryption methods
- Corrupted encryption headers in database

## Diagnostic Steps

### 1. Verify Current Setup

Check your environment configuration:
```bash
source .env
echo "Current database: $LIVESYNC_DATABASE"
echo "Passphrase configured: $(echo $LIVESYNC_PASSPHRASE | head -c 10)..."
```

### 2. Check Device Consistency

On each device, verify:
- Same database name is configured
- Identical passphrase (character-for-character)
- Same plugin version installed
- Same encryption settings enabled

### 3. Database Analysis

Check for mixed encryption versions:
```bash
# Connect to CouchDB admin interface
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/_all_docs?limit=5"

# Look for documents with different encryption headers
```

## Resolution Strategies

### Strategy 1: Passphrase Synchronization (Low Risk)

**When to use**: When devices have slightly different passphrases

1. **Stop sync on all devices**:
   - Disable LiveSync on all connected devices
   - Wait for all pending operations to complete

2. **Verify master passphrase**:
   ```bash
   # Check your stored passphrase
   echo "Master passphrase: $LIVESYNC_PASSPHRASE"
   ```

3. **Update all devices**:
   - Copy passphrase exactly from your `.env` file
   - Paste into LiveSync settings on each device
   - Verify no extra spaces or characters

4. **Re-enable sync gradually**:
   - Start with one device (desktop recommended)
   - Verify successful sync before adding next device
   - Add mobile devices last

### Strategy 2: Clean Database Migration (Medium Risk)

**When to use**: When database contains mixed encryption versions

1. **Create backup**:
   ```bash
   ./scripts/backup-couchdb.sh
   # Save current database before changes
   ```

2. **Export unencrypted data**:
   - On device with most recent data
   - Disable end-to-end encryption temporarily
   - Let sync complete to create unencrypted copy

3. **Create new database**:
   ```bash
   # Update database name in .env
   LIVESYNC_DATABASE=obsidian_clean_$(date +%Y%m%d)
   ```

4. **Fresh sync setup**:
   - Configure new database on primary device
   - Enable encryption with verified passphrase
   - Add other devices using same settings

### Strategy 3: Device-by-Device Reset (High Success Rate)

**When to use**: When other strategies fail

1. **Identify primary device**:
   - Choose device with most recent/complete data
   - Ensure local vault files are intact
   - This device becomes the "source of truth"

2. **Reset other devices**:
   - Uninstall LiveSync plugin on secondary devices
   - Clear any cached data
   - Reinstall plugin with fresh configuration

3. **Gradual re-connection**:
   - Connect devices one at a time
   - Use "Copy to remote" from primary device
   - Let full sync complete before adding next device

## Advanced Troubleshooting

### Encryption Header Analysis

For technical diagnosis, examine document encryption headers:

```bash
# Get a sample encrypted document
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/[document_id]" | \
  jq '.data' | head -c 100

# Look for encryption version indicators
# Different headers indicate version conflicts
```

### Database Compaction

Clean up fragmented or corrupted encryption data:

```bash
# Compact database to remove old revisions
curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE/_compact"

# Monitor compaction progress
curl -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
  "http://localhost:5984/$LIVESYNC_DATABASE" | jq '.compact_running'
```

### Plugin Version Alignment

Ensure all devices use compatible plugin versions:

1. **Check current versions**:
   - Desktop: Settings → Community Plugins → LiveSync
   - Mobile: Settings → Community Plugins → Self-hosted LiveSync

2. **Update to latest**:
   - Update all devices to same version
   - Restart Obsidian after updates
   - Re-test sync after version alignment

## Prevention Strategies

### Secure Passphrase Management

1. **Generate strong passphrases**:
   ```bash
   # Generate secure passphrase
   openssl rand -base64 32
   ```

2. **Store securely**:
   - Use password managers
   - Document in secure location
   - Never embed in configuration files

3. **Version control**:
   - Track passphrase changes
   - Document when/why changed
   - Ensure all devices updated together

### Database Hygiene

1. **Regular maintenance**:
   ```bash
   # Weekly database compaction
   curl -X POST -u "$COUCHDB_USER:$COUCHDB_PASSWORD" \
     "http://localhost:5984/$LIVESYNC_DATABASE/_compact"
   ```

2. **Monitor encryption consistency**:
   - Regular sync testing across devices
   - Check for error patterns
   - Document any encryption issues

3. **Backup strategy**:
   - Daily automated backups
   - Test restore procedures monthly
   - Keep unencrypted backup option available

### Device Management

1. **Standardized setup**:
   - Use same plugin version across devices
   - Document exact configuration steps
   - Test new devices in isolation first

2. **Change management**:
   - Plan encryption changes carefully
   - Update all devices simultaneously
   - Verify sync before completing changes

## Recovery Procedures

### Emergency Data Recovery

If HKDF errors cause complete sync failure:

1. **Secure local data**:
   ```bash
   # Backup local vault immediately
   tar -czf vault_emergency_backup_$(date +%Y%m%d_%H%M).tar.gz knowledge/
   ```

2. **Disable sync everywhere**:
   - Stop all sync operations
   - Prevent further data corruption

3. **Assess data integrity**:
   - Compare device contents
   - Identify most complete dataset
   - Document what's missing/different

4. **Choose recovery path**:
   - Strategy 2 (Clean Migration) for mixed encryption
   - Strategy 3 (Device Reset) for widespread issues
   - Professional assistance if data loss risk is high

### Post-Recovery Verification

After resolving HKDF issues:

1. **Sync testing**:
   - Create test notes on each device
   - Verify bidirectional sync
   - Test file attachments if used

2. **Performance monitoring**:
   - Monitor sync speed/reliability
   - Check for recurring errors
   - Document any remaining issues

3. **Documentation update**:
   - Record what caused the issue
   - Document successful resolution steps
   - Update prevention procedures

## Support Resources

- **LiveSync Plugin**: [Community forum](https://forum.obsidian.md)
- **CouchDB**: [Official documentation](https://docs.couchdb.org)
- **System logs**: `docker compose logs obsidian-couchdb`
- **Backup procedures**: [backup-restore-procedures.md](backup-restore-procedures.md)

---

**Warning**: HKDF decryption issues can result in data loss if not handled carefully. Always create backups before attempting resolution strategies.