# Mobile Device Setup Guide

## Overview
Complete setup instructions for accessing your Obsidian vault sync via Tailscale network from mobile devices.

## Prerequisites
- Server setup complete (CouchDB + nginx proxy running)
- Tailscale account with admin access
- Mobile device with Obsidian app capability

## Mobile Device Setup Steps

### 1. Install Tailscale on Mobile Device

#### iOS (iPhone/iPad)
1. Download **Tailscale** from the App Store
2. Open the app and sign in with your account credentials
3. Follow the authentication flow
4. Verify connection in the app - should show "Connected"

#### Android
1. Download **Tailscale** from Google Play Store  
2. Open the app and sign in with your account credentials
3. Follow the authentication flow
4. Verify connection in the app - should show "Connected"

### 2. Install Obsidian Mobile App

#### iOS
1. Download **Obsidian** from the App Store
2. Open the app and skip vault creation (we'll sync from server)

#### Android  
1. Download **Obsidian** from Google Play Store
2. Open the app and skip vault creation (we'll sync from server)

### 3. Configure Obsidian LiveSync Plugin

1. **Enable Community Plugins**:
   - Go to Settings → Community plugins
   - Turn off "Safe mode" if prompted
   - Tap "Browse" to access community plugins

2. **Install LiveSync Plugin**:
   - Search for "LiveSync"
   - Install "Self-hosted LiveSync" by vrtmrz
   - Enable the plugin after installation

3. **Configure LiveSync Settings**:
   - Go to Settings → LiveSync
   - Set the following configuration:

   **Remote Database Settings:**
   - Remote Database URI: `https://nuc-01-debian.emerald-wage.ts.net:3880`
   - Username: `obsidian_admin`
   - Password: `secure_password_change_me`  
   - Database Name: `obsidiandb`

   **Sync Settings:**
   - Enable "LiveSync"
   - Enable "Sync on Save"
   - Enable "Sync on Start"
   - Set sync interval to desired frequency (e.g., every 10 seconds)

4. **Test Connection**:
   - Tap "Test Connection" in LiveSync settings
   - Should show "Connected successfully"
   - If connection fails, verify Tailscale is connected

5. **Initial Sync**:
   - Tap "Fetch Remote Database" to download existing vault
   - Wait for initial sync to complete
   - Verify your notes appear in the mobile app

## Verification Steps

### 1. Test Connectivity from Mobile Device
```bash
# In mobile browser (Safari/Chrome), navigate to:
https://nuc-01-debian.emerald-wage.ts.net:3880

# Should prompt for authentication
# Enter: obsidian_admin / secure_password_change_me
# Should show CouchDB welcome message
```

### 2. Test Cross-Device Sync
1. Create a test note on desktop Obsidian
2. Wait 10-30 seconds
3. Check mobile Obsidian - note should appear
4. Edit note on mobile device  
5. Check desktop - changes should sync back

### 3. Verify Network Connection
Check Tailscale status on all devices:
- Desktop: `tailscale status` should show mobile device as "active"  
- Mobile: Tailscale app should show "Connected"
- All devices should be on same 100.x.x.x network range

## Troubleshooting

### Common Issues

#### 1. "Connection Failed" in LiveSync
**Symptoms:** Can't connect to remote database
**Solutions:**
- Verify Tailscale is connected on mobile device
- Check server URL: `https://nuc-01-debian.emerald-wage.ts.net:3880`
- Test in mobile browser first
- Ensure mobile device shows as "active" in desktop `tailscale status`

#### 2. Mobile Device Not Visible in Tailscale Network
**Symptoms:** Device shows as "offline" in `tailscale status`
**Solutions:**
- Restart Tailscale app on mobile device
- Sign out and sign back in to Tailscale
- Check internet connectivity on mobile device
- Verify account permissions (admin can add devices)

#### 3. Sync Not Working Between Devices
**Symptoms:** Changes not appearing on other devices
**Solutions:**
- Check LiveSync status on both devices - should show "Connected"
- Verify same database name on all devices: `obsidiandb`
- Check sync settings - ensure "LiveSync" is enabled
- Try manual sync in LiveSync settings

#### 4. SSL/Certificate Errors
**Symptoms:** Browser shows security warnings
**Solutions:**
- Tailscale automatically handles SSL certificates
- Ensure using `https://` not `http://`
- Try clearing mobile browser cache
- Verify Tailscale machine name is correct

#### 5. Slow Sync Performance
**Symptoms:** Changes take long time to sync
**Solutions:**
- Reduce sync interval in LiveSync settings
- Check network connectivity quality
- Restart nginx proxy if needed: `nginx -s reload -c $PWD/nginx.conf`

### Diagnostic Commands (Desktop)
```bash
# Check all services status
tailscale status
docker compose ps
ps aux | grep nginx

# Test connectivity
curl -u obsidian_admin:secure_password_change_me http://localhost:3880
curl -I https://nuc-01-debian.emerald-wage.ts.net:3880

# Check logs
docker compose logs couchdb
tail -f /tmp/nginx_access.log
```

## Security Notes

### Tailscale Network Security
- All traffic encrypted end-to-end via WireGuard
- No public internet exposure required
- Device-level authentication and authorization
- Private mesh network between your devices

### CouchDB Security  
- Requires username/password authentication
- Access only through Tailscale VPN
- No direct public internet access
- Admin credentials should be changed from defaults

### Best Practices
- Regularly update Tailscale on all devices
- Use strong, unique passwords for CouchDB
- Monitor Tailscale device list for unauthorized access
- Enable device approval if needed for additional security

## Network Information

### Current Configuration
- **Server Machine**: nuc-01-debian.emerald-wage.ts.net
- **Tailscale Network**: emerald-wage.ts.net
- **CouchDB Access URL**: https://nuc-01-debian.emerald-wage.ts.net:3880
- **Database Name**: obsidiandb
- **Sync Protocol**: HTTPS over Tailscale VPN

### Device Requirements
- Tailscale app installed and authenticated
- Same Tailscale account across all devices
- Obsidian app with LiveSync community plugin
- Internet connectivity for initial Tailscale handshake

## Success Verification Checklist

- [ ] Tailscale installed and connected on mobile device
- [ ] Mobile device visible in desktop `tailscale status`
- [ ] Obsidian installed on mobile with LiveSync plugin
- [ ] LiveSync configured with correct server URL and credentials
- [ ] Test connection successful in LiveSync settings
- [ ] Initial vault sync completed to mobile device
- [ ] Cross-device sync tested (desktop → mobile → desktop)
- [ ] HTTPS access working from mobile browser
- [ ] No certificate warnings or connection errors

## Support
If issues persist:
1. Check Tailscale device connectivity via admin console
2. Verify CouchDB container health: `docker compose ps`
3. Review nginx proxy logs: `tail -f /tmp/nginx_access.log`
4. Test basic network connectivity between devices