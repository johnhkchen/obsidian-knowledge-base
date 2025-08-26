# Tailscale + Nginx Proxy Setup Guide

## Overview
This guide sets up nginx + tailscale to provide secure HTTPS access to CouchDB for mobile device compatibility using Tailscale's built-in certificate management.

## Prerequisites
- CouchDB container running via docker-compose
- Tailscale account and device authentication
- Flox environment with nginx and tailscale installed

## Setup Steps

### 1. Deploy CouchDB Container
```bash
# Deploy CouchDB container
docker compose up -d

# Verify container is running
docker compose ps
```

### 2. Activate Flox Environment
```bash
# Activate the flox environment with nginx and tailscale
flox activate

# Verify tools are available
which nginx
which tailscale
which my-little-soda
```

### 3. Setup Tailscale
```bash
# Start and authenticate tailscale
sudo tailscale up

# Enable HTTPS certificates (this gives you automatic SSL)
sudo tailscale cert --domain your-tailscale-name.tailXXXX.ts.net

# Check your tailscale status and note your machine name
tailscale status
```

### 4. Configure Nginx
The nginx configuration is already provided in `nginx.conf`. Start nginx:

```bash
# Test the nginx configuration
nginx -t -c $PWD/nginx.conf

# Start nginx with the configuration
nginx -c $PWD/nginx.conf

# Verify nginx is running
ps aux | grep nginx
```

### 5. Test Access
```bash
# Test local nginx proxy
curl -I http://localhost:3880

# Test CouchDB access through proxy
curl -u obsidian_admin:secure_password_change_me http://localhost:3880

# From another device on your tailscale network:
# curl -I https://your-machine.tailXXXX.ts.net:3880
```

### 6. Configure Obsidian LiveSync
In Obsidian LiveSync plugin settings:
- Remote Database URI: `https://your-machine.tailXXXX.ts.net:3880`
- Username: `obsidian_admin` (or your CouchDB username)  
- Password: `secure_password_change_me` (or your CouchDB password)
- Database Name: `obsidiandb`

## Security Considerations

### Tailscale Security Benefits
- All traffic is encrypted end-to-end via WireGuard
- No need to expose ports to the public internet
- Automatic certificate management
- Device-level authentication and authorization
- Private mesh network between your devices

### Firewall Configuration
```bash
# Only allow tailscale and local access
# CouchDB and nginx only listen on localhost/tailscale interface
# No public port exposure needed

# Optional: Block direct CouchDB access
sudo ufw deny 5984/tcp
```

### CouchDB Security
- ✅ Change default admin credentials (recommended)
- ✅ Enable require_valid_user in CouchDB config
- ✅ Access only through Tailscale VPN
- ✅ No public internet exposure

## Troubleshooting

### Common Issues
1. **Tailscale Not Connecting:**
   - Run `sudo tailscale up` to authenticate
   - Check `tailscale status` for connection issues
   - Ensure tailscale daemon is running

2. **Nginx Not Starting:**
   - Test config: `nginx -t -c $PWD/nginx.conf`
   - Check if port 3880 is already in use: `lsof -i :3880`
   - Verify nginx binary is available: `which nginx`

3. **Mobile App Can't Connect:**
   - Install Tailscale on mobile device and authenticate
   - Ensure mobile device shows as connected: `tailscale status`
   - Test access via mobile browser first
   - Check CORS headers in nginx config

4. **CouchDB Connection Errors:**
   - Verify CouchDB container is running: `docker compose ps`
   - Test direct access: `curl localhost:5984`
   - Check nginx proxy: `curl localhost:3880`

### Verification Commands
```bash
# Check all services
docker compose logs couchdb
tailscale status
ps aux | grep nginx

# Test the full chain
curl -u obsidian_admin:secure_password_change_me http://localhost:3880/_all_dbs

# From other tailscale devices
curl -I https://your-machine.tailXXXX.ts.net:3880
```

## No DNS Setup Required
With Tailscale, you get:
- Automatic *.tailXXXX.ts.net domain for your machine
- Built-in SSL certificates
- No port forwarding or firewall configuration needed
- Works from anywhere with Tailscale installed

## Final Steps
1. Update Obsidian LiveSync settings on all devices
2. Test sync between desktop and mobile
3. Verify HTTPS access works from external networks
4. Document final configuration in main setup guide

## Status Verification
- [ ] Nginx Proxy Manager deployed and accessible
- [ ] SSL certificate issued successfully
- [ ] HTTPS access to CouchDB working
- [ ] Mobile device can connect via HTTPS
- [ ] Obsidian sync functional across devices