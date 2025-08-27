# Obsidian REST API Configuration

## ✅ Configuration Complete

### API Details
- **Endpoint**: `https://localhost:3880/api/` (via nginx proxy)
- **Port**: 27124 (HTTPS)
- **Certificate**: `obsidian-rest-api.crt` (extracted from container, stored locally)
- **API Key**: [STORED SECURELY - NOT IN REPOSITORY]
- **Binding**: 0.0.0.0 (allows external connections)

### Security Notes
⚠️ **IMPORTANT**: API keys and certificates are NOT committed to the repository
- API key stored in `OBSIDIAN_API_CONFIG.md` (gitignored)
- SSL certificate stored as `obsidian-rest-api.crt` (gitignored)
- Both files must be secured separately and not shared publicly

### Test Commands Template
```bash
# Health check
curl -k -H "Authorization: Bearer YOUR_API_KEY_HERE" \
  https://localhost:3880/api/

# List vault contents  
curl -k -H "Authorization: Bearer YOUR_API_KEY_HERE" \
  https://localhost:3880/api/vault/
```

### Plugin Status
- ✅ obsidian-local-rest-api: Installed, configured, working
- ✅ LiveSync: Already working (iOS + Windows clients syncing)
- ✅ Both plugins coexist without conflicts

### For Claude Code MCP Integration
The Obsidian server is ready for MCP integration. Contact administrator for:
- API key (not stored in repository)
- SSL certificate location
- Connection details