# HTTPS Reverse Proxy Setup Guide

## Overview
This guide sets up Nginx Proxy Manager to provide HTTPS access to CouchDB for mobile device compatibility.

## Prerequisites
- CouchDB container running via docker-compose
- Domain or subdomain pointing to your server
- Ports 80, 443, and 81 available

## Setup Steps

### 1. Deploy Containers
```bash
# Deploy both CouchDB and Nginx Proxy Manager
docker-compose up -d

# Verify both containers are running
docker-compose ps
```

### 2. Access Nginx Proxy Manager
1. Open browser to `http://your-server-ip:81`
2. Login with default credentials:
   - Email: `admin@example.com`
   - Password: `changeme`
3. **IMMEDIATELY** change default credentials on first login

### 3. Create SSL Proxy Host
1. Go to "Proxy Hosts" → "Add Proxy Host"
2. **Details Tab:**
   - Domain Names: `your-domain.com` or `subdomain.your-domain.com`
   - Scheme: `http`
   - Forward Hostname/IP: `couchdb` (Docker service name)
   - Forward Port: `5984`
   - ✅ Cache Assets
   - ✅ Block Common Exploits
   - ✅ Websockets Support

3. **SSL Tab:**
   - ✅ SSL Certificate
   - ✅ Force SSL
   - ✅ HTTP/2 Support
   - ✅ HSTS Enabled
   - Select "Request a new SSL Certificate"
   - ✅ Force SSL
   - Email: your-email@domain.com
   - ✅ I Agree to the Let's Encrypt Terms of Service

4. **Advanced Tab (Optional):**
   ```nginx
   # Add CORS headers for CouchDB
   add_header Access-Control-Allow-Origin *;
   add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
   add_header Access-Control-Allow-Headers "Authorization, Content-Type";
   
   # Handle OPTIONS requests
   if ($request_method = 'OPTIONS') {
       add_header Access-Control-Allow-Origin *;
       add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
       add_header Access-Control-Allow-Headers "Authorization, Content-Type";
       add_header Content-Length 0;
       add_header Content-Type text/plain;
       return 204;
   }
   ```

### 4. Test HTTPS Access
1. Visit `https://your-domain.com/_utils`
2. Should see CouchDB admin interface with valid SSL certificate
3. Test from mobile device to ensure accessibility

### 5. Configure Obsidian LiveSync
In Obsidian LiveSync plugin settings:
- Remote Database URI: `https://your-domain.com`
- Username: `obsidian_admin` (or your CouchDB username)
- Password: `secure_password_change_me` (or your CouchDB password)
- Database Name: `obsidiandb`

## Security Considerations

### Firewall Configuration
```bash
# Allow HTTP/HTTPS traffic
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Allow NPM admin interface (restrict to your IP if possible)
sudo ufw allow 81/tcp

# Block direct CouchDB access from outside (optional)
# sudo ufw deny 5984/tcp
```

### Strong SSL Configuration
- Let's Encrypt certificates auto-renew
- Force HTTPS redirects enabled
- HTTP/2 support for performance
- HSTS headers for security

### CouchDB Security
- Change default admin credentials
- Enable require_valid_user in CouchDB config
- Consider VPN access for additional security

## Troubleshooting

### Common Issues
1. **SSL Certificate Failed:**
   - Ensure domain points to your server IP
   - Check ports 80/443 are accessible from internet
   - Verify no other services using these ports

2. **Mobile App Can't Connect:**
   - Test HTTPS URL in mobile browser first
   - Ensure certificate is not self-signed
   - Check CORS headers are properly set

3. **CouchDB Connection Errors:**
   - Verify CouchDB container is running
   - Check internal Docker network connectivity
   - Test direct access to CouchDB on port 5984

### Verification Commands
```bash
# Check container logs
docker-compose logs nginx-proxy-manager
docker-compose logs couchdb

# Test SSL certificate
curl -I https://your-domain.com

# Test CouchDB API
curl -u username:password https://your-domain.com/_all_dbs
```

## DNS Setup Requirements

### For External Access
- A record: `your-domain.com` → `your-server-public-ip`
- Or CNAME: `subdomain.your-domain.com` → `your-domain.com`

### For Local Testing
Add to `/etc/hosts` (or equivalent):
```
your-server-local-ip    your-domain.com
```

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