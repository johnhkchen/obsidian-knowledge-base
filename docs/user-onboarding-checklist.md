# User Onboarding Checklist - Obsidian Knowledge Base

## Overview
This checklist guides new users through setting up Obsidian with the CouchDB sync infrastructure for seamless note synchronization across devices.

---

## Pre-requisites
- [ ] Tailscale account and client installed on all devices
- [ ] Obsidian desktop app installed
- [ ] Mobile devices available for testing (iOS/Android)

---

## Phase 1: Desktop Setup (5-10 minutes)

### 1.1 Obsidian Desktop Configuration
- [ ] **Download Obsidian**: Get the latest version from [obsidian.md](https://obsidian.md)
- [ ] **Install Obsidian**: Follow platform-specific installation instructions
- [ ] **Open Vault**: Navigate to the knowledge base directory
- [ ] **Verify Vault**: Confirm you can see the folder structure (knowledge/, docs/, templates/)

### 1.2 LiveSync Plugin Setup
- [ ] **Access Community Plugins**: Settings → Community plugins → Browse
- [ ] **Search for LiveSync**: Find "Self-hosted LiveSync" plugin
- [ ] **Install Plugin**: Click Install → Enable
- [ ] **Configure Plugin**: Go to Settings → LiveSync

### 1.3 LiveSync Configuration
Use these settings:

**Connection Settings:**
- [ ] **URI**: `http://localhost:5984` (or Tailscale IP if remote)
- [ ] **Username**: See SYNC_CREDENTIALS.md
- [ ] **Password**: See SYNC_CREDENTIALS.md  
- [ ] **Database**: `obsidiandb`

**Encryption Settings:**
- [ ] **Enable E2E Encryption**: Check this box
- [ ] **Passphrase**: Copy from SYNC_CREDENTIALS.md
- [ ] **Verify Passphrase**: Double-check accuracy

**Initial Setup:**
- [ ] **Test Connection**: Click "Check connectivity"
- [ ] **Setup Database**: Click "Check and fix database configuration"
- [ ] **Initial Sync**: Choose "Copy setup to remote" if first device

### 1.4 Verification
- [ ] **Connection Status**: Green checkmark in LiveSync settings
- [ ] **Create Test Note**: Add a test note and verify it syncs
- [ ] **Check Sync History**: View sync log for successful operations

---

## Phase 2: Mobile Setup (10-15 minutes per device)

### 2.1 Network Access Setup
- [ ] **Install Tailscale**: Download from app store
- [ ] **Authenticate Tailscale**: Log in with your account
- [ ] **Verify Connection**: Confirm you can reach the server IP

### 2.2 Mobile Obsidian Setup
- [ ] **Install Obsidian**: Download from App Store/Play Store
- [ ] **Skip Local Vault**: Don't create a new vault
- [ ] **Access Community Plugins**: Enable community plugins
- [ ] **Install LiveSync**: Search and install "Self-hosted LiveSync"

### 2.3 Mobile LiveSync Configuration
**Important**: Use the Tailscale IP, not localhost

**Connection Settings:**
- [ ] **URI**: `http://[TAILSCALE_IP]:5984` (replace with actual IP)
- [ ] **Username**: Same as desktop setup
- [ ] **Password**: Same as desktop setup
- [ ] **Database**: `obsidiandb`

**Encryption Settings:**
- [ ] **Enable E2E Encryption**: Must match desktop setting
- [ ] **Passphrase**: Copy exact same passphrase from SYNC_CREDENTIALS.md

**Sync Settings:**
- [ ] **Sync Direction**: Choose "Replicate from remote"
- [ ] **Initial Download**: Wait for complete sync

### 2.4 Mobile Verification
- [ ] **Test Sync**: Modify a note and verify it appears on desktop
- [ ] **Create Mobile Note**: Add note from mobile, check desktop sync
- [ ] **Check Battery Settings**: Configure sync frequency for battery life

---

## Phase 3: Optimization & Best Practices (5 minutes)

### 3.1 Sync Settings Optimization
For better battery life on mobile:
- [ ] **Sync Interval**: Set to 30-60 seconds instead of real-time
- [ ] **Background Sync**: Enable but limit frequency
- [ ] **WiFi Only**: Consider enabling for large files

### 3.2 Security Verification
- [ ] **HTTPS**: Confirm using secure connection if available
- [ ] **Firewall**: Verify only authorized devices can access
- [ ] **Backup**: Confirm automatic backups are running

### 3.3 Performance Optimization
- [ ] **Large Files**: Move large attachments to separate folder
- [ ] **Sync Exclusions**: Configure .obsidian/workspace.json exclusion
- [ ] **Conflict Resolution**: Understand merge vs overwrite behavior

---

## Phase 4: Testing & Validation (10 minutes)

### 4.1 Multi-Device Sync Test
- [ ] **Create Note on Desktop**: Add new note with content
- [ ] **Verify on Mobile**: Wait for sync, confirm note appears
- [ ] **Edit on Mobile**: Modify content on mobile device
- [ ] **Verify on Desktop**: Confirm changes sync back

### 4.2 Conflict Resolution Test
- [ ] **Disconnect Mobile**: Turn off WiFi/data temporarily
- [ ] **Edit Same Note**: Modify same note on both devices
- [ ] **Reconnect Mobile**: Enable network and observe conflict handling
- [ ] **Resolve Conflicts**: Understand conflict resolution options

### 4.3 Offline Capability Test
- [ ] **Work Offline**: Create/edit notes without network
- [ ] **Verify Local Storage**: Confirm notes saved locally
- [ ] **Reconnect & Sync**: Test sync when connection restored

---

## Troubleshooting Quick Reference

### Common Issues:
- **Connection Failed**: Check Tailscale connection and server IP
- **Sync Not Working**: Verify credentials match exactly
- **Conflicts**: Use "Merge" option for collaborative editing
- **Battery Drain**: Increase sync interval on mobile

### Support Resources:
- LiveSync Documentation: Check plugin settings help
- Server Status: Run `./scripts/health-check.sh`
- Logs: Check Obsidian Developer Console for sync errors

---

## Success Criteria Checklist

### ✅ **Setup Complete When:**
- [ ] All devices show green sync status
- [ ] Notes sync bidirectionally within 1-2 minutes
- [ ] Encryption is working (E2E enabled)
- [ ] Mobile battery usage is acceptable
- [ ] Offline editing works properly
- [ ] Conflict resolution is understood

### 📱 **Mobile Specific:**
- [ ] Tailscale connected and stable
- [ ] Background sync functioning
- [ ] App doesn't crash or freeze
- [ ] Sync works on both WiFi and cellular

### 🔧 **Performance Optimized:**
- [ ] Sync frequency set appropriately
- [ ] Large files handled correctly
- [ ] No significant battery drain
- [ ] Responsive UI during sync

---

## Post-Setup Recommendations

### Daily Use:
- Monitor sync status occasionally
- Keep Tailscale connected on mobile
- Use descriptive commit messages if enabled
- Regular backup verification

### Weekly Maintenance:
- Check for LiveSync plugin updates
- Review sync performance
- Clean up conflict files if any
- Verify backup integrity

### Monthly Review:
- Update Obsidian and plugins
- Review security settings
- Check server performance
- Update access credentials if needed

---

**Setup Date**: ___________  
**Devices Configured**: ___________  
**Next Review**: ___________  

*For technical support or issues, refer to the troubleshooting runbook or system administrator.*