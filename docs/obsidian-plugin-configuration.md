# Obsidian Plugin Configuration Guide

## Access Information

### Web Interface Access
- **Direct URL**: http://localhost:3000
- **Via Nginx Proxy**: http://localhost:3880/obsidian/
- **External (Tailscale)**: https://nuc-01-debian.emerald-wage.ts.net:3880/obsidian/

## Plugin Configuration Steps

### 1. Initial Obsidian Setup
1. Access Obsidian at: https://nuc-01-debian.emerald-wage.ts.net:3880/obsidian/
2. Open existing vault from `/obsidian/vault` (mapped to `./knowledge`)
3. Complete initial vault setup if prompted

### 2. obsidian-local-rest-api Plugin Installation
1. Open Settings → Community Plugins
2. Turn on Community Plugins if disabled
3. Browse Community Plugins
4. Search for "Local REST API"
5. Install the plugin by coddingtonbear
6. Enable the plugin

#### Plugin Configuration
1. Open Settings → Local REST API
2. Set API port: `27124` (default)
3. Enable HTTPS: `Yes` (for security)
4. Generate/set API key (save securely)
5. Test API connectivity

### 3. LiveSync Plugin Installation  
1. In Community Plugins, search for "LiveSync"
2. Install "Livesync" by vrtmrz
3. Enable the plugin

#### LiveSync Configuration
1. Open Settings → Livesync
2. Configure CouchDB connection:
   - **Database URI**: `http://localhost:5984/obsidian`
   - **Username**: `obsidian_admin`
   - **Password**: `Rjm/gUGa04cFTrE7SzLL5v/6w5MTaWah2Ck5tboySMU=`
   - **Database Name**: `obsidian`
3. Test connection and initialize database
4. Enable real-time sync

## Network Integration

### Nginx Proxy Routes
- `/obsidian/` → Obsidian web interface (port 3000)
- `/api/` → REST API endpoint (port 27124, HTTPS)
- `/` → CouchDB (port 5984) - **unchanged**

### CORS Configuration
All existing CORS headers remain active:
- `Access-Control-Allow-Origin: *`
- `Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS`
- `Access-Control-Allow-Headers: Authorization, Content-Type, X-Requested-With`
- `Access-Control-Allow-Credentials: true`

### API Testing
Once configured, test REST API:
```bash
# Test API health (replace YOUR_API_KEY)
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  https://nuc-01-debian.emerald-wage.ts.net:3880/api/
```

## Validation Checklist

### Plugin Installation
- [ ] obsidian-local-rest-api plugin installed and enabled
- [ ] LiveSync plugin installed and enabled
- [ ] Both plugins configured correctly

### Network Access
- [ ] Obsidian accessible via https://nuc-01-debian.emerald-wage.ts.net:3880/obsidian/
- [ ] CouchDB still accessible via existing URL
- [ ] REST API accessible via /api/ path (after configuration)

### Sync Functionality
- [ ] LiveSync connects to existing CouchDB
- [ ] Changes sync between instances
- [ ] Mobile access remains functional

### Integration Testing
- [ ] All existing services operational
- [ ] No port conflicts
- [ ] CORS headers working for all endpoints
- [ ] Backup and monitoring scripts unaffected

## Security Notes

1. **API Key Security**: Store REST API key securely, never commit to repository
2. **HTTPS Only**: REST API should only be accessed via HTTPS through nginx
3. **Network Isolation**: Container accessible only via nginx proxy
4. **Tailscale Protection**: External access protected by VPN

## Troubleshooting

### Plugin Issues
- Check plugin logs in Developer Console
- Verify vault permissions in container
- Restart Obsidian container if needed: `docker compose restart obsidian`

### Network Issues
- Test direct container access: `curl http://localhost:3000`
- Verify nginx configuration: `nginx -t`
- Check container logs: `docker compose logs obsidian`

### Sync Issues
- Verify CouchDB connectivity from container
- Check LiveSync plugin settings
- Test database permissions

## Maintenance

### Updates
```bash
# Update Obsidian container
docker compose pull obsidian
docker compose up -d obsidian

# Check health
docker compose ps
```

### Backups
- Plugin configurations stored in `obsidian_config` volume
- Include volume in existing backup procedures
- Document API keys in secure password manager