# Secure Mobile Device Setup Guide

## Overview

This guide provides secure setup procedures for accessing your Obsidian vault from mobile devices using environment-based configuration. All sensitive information is referenced from secure configuration files rather than embedded in documentation.

## Prerequisites

- Server setup complete with environment variables configured
- Tailscale VPN network established
- Mobile device capable of running Obsidian app
- Access to secure credentials from your `.env` configuration

## Security-First Setup Process

### 1. Network Security Setup

#### Install Tailscale VPN

**iOS (iPhone/iPad):**
1. Install **Tailscale** from the App Store
2. Sign in with your Tailscale account
3. Complete authentication flow
4. Verify "Connected" status in app

**Android:**
1. Install **Tailscale** from Google Play Store
2. Sign in with your Tailscale account
3. Complete authentication flow
4. Verify "Connected" status in app

#### Network Verification

Test network connectivity before proceeding:
- Open mobile browser
- Navigate to your server's Tailscale address (from your environment)
- Should reach login prompt (don't enter credentials yet)

### 2. Obsidian Mobile Installation

**iOS:**
1. Install **Obsidian** from the App Store
2. Skip initial vault creation

**Android:**
1. Install **Obsidian** from Google Play Store
2. Skip initial vault creation

### 3. LiveSync Plugin Configuration

#### Enable Community Plugins
1. Open Settings → Community plugins
2. Disable "Safe mode" if prompted
3. Access plugin browser

#### Install LiveSync Plugin
1. Search for "Self-hosted LiveSync"
2. Install plugin by vrtmrz
3. Enable the plugin

#### Secure Configuration

**Important:** Use your environment variables for all sensitive values.

Configure Remote Database Settings:
- **Database URI**: Use your configured HTTPS endpoint from environment
- **Username**: Use value from `COUCHDB_USER` environment variable
- **Password**: Use value from `COUCHDB_PASSWORD` environment variable
- **Database Name**: Use value from `LIVESYNC_DATABASE` environment variable

Configure End-to-End Encryption:
- **Enable E2E Encryption**: Yes
- **Passphrase**: Use value from `LIVESYNC_PASSPHRASE` environment variable

#### Connection Testing
1. Test connection in LiveSync settings
2. Should show "Connected successfully"
3. If failed, verify Tailscale connectivity first

### 4. Initial Vault Synchronization

#### Download Existing Vault
1. In LiveSync settings, choose "Fetch from remote"
2. Wait for initial synchronization to complete
3. Verify your notes appear in mobile app

#### Sync Configuration
- **Enable LiveSync**: Yes
- **Sync on Save**: Recommended
- **Sync on Start**: Recommended
- **Sync Interval**: 30-60 seconds (battery optimization)

## Mobile-Specific Security Settings

### Battery Optimization
Configure sync settings for mobile efficiency:
- **Sync only on WiFi**: Recommended for cellular data savings
- **Periodic sync interval**: 60+ seconds to preserve battery
- **Sync on app focus**: Enable for manual control
- **Background sync**: Disable if battery life is priority

### Network Security
- **VPN requirement**: Always use Tailscale for server access
- **Public WiFi protection**: Tailscale encrypts all traffic
- **Cellular fallback**: Sync will work over cellular through VPN

### Data Protection
- **Local encryption**: Enable device screen lock/biometrics
- **App-level security**: Use Obsidian's built-in vault encryption if needed
- **Backup consideration**: Mobile vault is synced copy, not primary storage

## Verification Procedures

### 1. Network Connectivity Test
Before configuring sync, verify:
```bash
# From desktop, check mobile device appears:
tailscale status
# Mobile device should show as "active"
```

### 2. Cross-Device Sync Test
1. Create test note on desktop
2. Wait 30-60 seconds
3. Check mobile app - note should appear
4. Edit note on mobile
5. Verify changes sync back to desktop

### 3. Security Verification
- All connections use HTTPS through Tailscale VPN
- No public internet exposure of database
- Credentials never stored in plain text in mobile app
- End-to-end encryption active for all synced data

## Troubleshooting Guide

### Connection Issues

**"Connection Failed" Errors:**
1. Verify Tailscale connection status on mobile
2. Test server URL in mobile browser first
3. Check if desktop shows mobile device as "active"
4. Restart Tailscale app if needed

**Authentication Failures:**
1. Verify credentials match environment variables exactly
2. Check for copy/paste errors with special characters
3. Test credentials from desktop to confirm validity

### Sync Problems

**Changes Not Syncing:**
1. Check LiveSync status shows "Connected" on both devices
2. Verify same database name configured on all devices
3. Check sync intervals aren't too long
4. Try manual sync in LiveSync settings

**Slow Performance:**
1. Increase sync interval to reduce battery usage
2. Enable "WiFi only" sync if cellular is slow
3. Check server performance during sync times

### Network Issues

**Mobile Not Visible in Tailscale:**
1. Sign out and back in to Tailscale mobile app
2. Check internet connectivity on mobile device
3. Verify Tailscale account permissions
4. Restart Tailscale app completely

**SSL/Certificate Warnings:**
1. Ensure using HTTPS URL (not HTTP)
2. Clear mobile browser cache
3. Verify Tailscale machine name is correct
4. Try accessing server URL directly in mobile browser

## Advanced Mobile Configuration

### Multi-Vault Support
If using multiple vaults:
1. Create separate database for each vault
2. Configure different credentials per vault
3. Use vault-specific passphrases for E2E encryption
4. Test each vault sync independently

### Offline Usage
Configure for limited connectivity:
1. Enable offline mode in Obsidian
2. Set longer sync intervals when offline
3. Use manual sync when connection available
4. Keep local copies of critical notes

### Performance Optimization
For optimal mobile performance:
1. Limit vault size (large files affect mobile performance)
2. Use selective sync if available in future plugin versions
3. Regular database maintenance on server
4. Monitor mobile data usage patterns

## Security Best Practices

### Credential Management
- Never screenshot or write down credentials
- Use mobile password managers for secure storage
- Rotate credentials periodically across all devices
- Remove access for lost/stolen devices immediately

### Network Security
- Always connect through Tailscale VPN
- Never use public WiFi without VPN protection
- Monitor Tailscale device list regularly
- Enable device approval for additional security

### Data Protection
- Enable device lock screen with biometrics
- Use Obsidian vault passwords if storing sensitive notes
- Regular backups include mobile configuration
- Document recovery procedures for lost devices

## Device Management

### Adding New Mobile Devices
1. Install and authenticate Tailscale first
2. Verify network connectivity to server
3. Install Obsidian with same configuration
4. Test sync with non-critical data first
5. Monitor sync performance and adjust settings

### Removing Mobile Devices
1. Disable LiveSync on device before removal
2. Remove device from Tailscale network
3. Clear any cached credentials
4. Update documentation to reflect change

### Device Recovery
If mobile device is lost or stolen:
1. Remove from Tailscale network immediately
2. Rotate CouchDB credentials if compromised
3. Monitor server logs for unauthorized access
4. Update all other devices with new credentials

## Support and Resources

- **Server Configuration**: Check `.env` file for current settings
- **Network Diagnostics**: Use `tailscale status` on desktop
- **Sync Monitoring**: Check LiveSync plugin status on all devices
- **Security Issues**: Review server logs and access patterns

---

**Security Note**: This guide avoids embedding credentials and relies on secure environment-based configuration. Always verify your environment variables are properly configured before mobile setup.