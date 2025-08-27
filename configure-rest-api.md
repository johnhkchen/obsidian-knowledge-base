# REST API Plugin Configuration (Non-Destructive)

## ⚠️ IMPORTANT: LiveSync is already working - DO NOT modify LiveSync settings!

## Current Status Check
- Access: https://nuc-01-debian.emerald-wage.ts.net:3880/obsidian/
- LiveSync: ✅ WORKING (iOS + Windows clients syncing)
- REST API: ❌ NEEDS CONFIGURATION

## Step-by-Step Configuration

### Step 1: Access Obsidian Web Interface
1. Open: https://nuc-01-debian.emerald-wage.ts.net:3880/obsidian/
2. **DO NOT** change any existing vault settings
3. **DO NOT** modify any LiveSync configurations

### Step 2: Install REST API Plugin ONLY
1. Go to Settings (⚙️) → Community Plugins  
2. **If Community Plugins are already enabled**: Skip to step 4
3. **If Community Plugins are disabled**: Enable them carefully
4. Click "Browse" community plugins
5. Search for: "Local REST API"
6. Find plugin by "coddingtonbear"
7. Click "Install"
8. Click "Enable" 

### Step 3: Configure REST API Plugin
1. Go to Settings → Local REST API (should appear in left sidebar)
2. Configure:
   - **Port**: 27124 (default, matches nginx configuration)
   - **Enable HTTPS**: Yes (for security)
   - **API Key**: Generate new key (save it securely)
   - **Enable CORS**: Yes (if available)

### Step 4: Test REST API
1. Copy the generated API key
2. Test from command line:
```bash
# Replace YOUR_API_KEY with actual key
curl -k -H "Authorization: Bearer YOUR_API_KEY" \
  https://nuc-01-debian.emerald-wage.ts.net:3880/api/
```

## What NOT to Touch
- ❌ Any LiveSync plugin settings
- ❌ Vault settings
- ❌ Existing sync configurations  
- ❌ Any database connections

## Expected Results
- ✅ REST API accessible at `/api/` endpoint
- ✅ LiveSync continues working normally
- ✅ Both plugins coexist without conflicts

## Validation
After configuration:
1. REST API responds to curl requests
2. iOS/Windows clients continue syncing normally
3. No error messages in plugin consoles
4. Web interface remains accessible

## API Key Security
- Save API key in secure password manager
- Do NOT commit to repository
- Use only via HTTPS through nginx proxy