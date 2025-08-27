# 📱 Complete Setup Instructions - Obsidian LiveSync & MCP Integration

## 🎯 Quick Setup Links

### 🔄 LiveSync Setup URI (Production Ready)
**Use this setup URI for all your devices:**

```
obsidian://setuplivesync?settings=%257b26dc20a21e2cf4d23c87740100000076579ac6db4ff74f3043670c0f27dcefXrbfwYmfxdvU4hAiDDxnzutWCzPQBg9HY4mx4cBljL7GbRGCYCRLaMABAmassmOYJEA3wZFCeGXoSSX%2BUfr9tpQWuKCnS6ZopxkfpjZa6i2RibF1WGi6vF521DBhmWe2diMXI0HKZk0ibnQqWt7bYZ5prTlJJUXfdcCl%2FFbLQMYHM78f6EusPcnmDlX2CCDXPWcqib8%2Ba4k6qx9WjmgQiqgpL75j7A8q0EuLiQxWHoJxCTuQQBWyHnmRvDCoWGKbADM5zCjLvuYm51wxGiti%2B7gI%2BzPUd8qUaMOX%2FRg4Dg31c%2FXgvfVHSdFtXf4qKBbLeClUSOyYQvCh4Na7Un1fp1hA%2B3rmkX8mQHSDr1U%2FiA603agAiN%2B0eqt5bfjzDIEKpQBjqQPcuDyXgBANrlHKy%2FU76rxnDGl6jvBor6WwJJhRiPeSjmGaVwHeTXd4fN%2FUsM64UhFHPNeQLhC3%2BK39Q1xRTaPRtZM1rONXg4hDWXT3zvifBzzVOkbAiTtLGpkLVhPg6g3uIEBdFelz7ZPW5y6p49tQqwM%2FAWUsRiOY6ASWUjBgnZCMk3R%2Bb1eiAWRvCFipxSqmfBK5zx8NYNalJoMBlynf6tmbOL7FIo4wHSlXegiSbUMNTjpbX6Wci9%2BLGIOOKdYhN8K791GVruwA2L7DFThvDLouVf227gOKZoibN7QJGedwcIvihQIm0N2zj9kjgB9iP3MrxpPgiJ1P95mDKC0I6dKHsLfTeLu%2FGKyot6H9hatDdzsejw7ib%2BAV3NZwBjNrmiJ213TpGjG5XMrp5ZOjffcgjiKMElMv%2ByMTsmV%2BftS9qPyDG2RrIPt7e990bhr8FyblWGkBwm3UmYK7yRZJbDQqWO1iRsXPN5U6YezeLHgCfrxEmWH9eiFXs5gvyKw%3D
```

**Setup Passphrase:** `small-frog`

### 🌐 Web Interface Access
**Direct browser access:** [https://obsidian.b28.dev/obsidian/](https://obsidian.b28.dev/obsidian/)

---

## 🏗️ Architecture Overview

### ✅ Complete Working Stack
```
📱 Clients → 🌐 obsidian.b28.dev → 🔒 Let's Encrypt SSL → 
    📦 Caddy Proxy → 🗄️ CouchDB + 📝 Obsidian App
```

### 🔐 Security Model
- **Domain:** `obsidian.b28.dev` (public DNS, private IP)
- **Target IP:** `100.68.79.63` (Tailscale private network)
- **SSL Certificate:** Valid Let's Encrypt certificate (auto-renewed)
- **Access:** Only Tailscale network devices can connect

---

## 📋 Setup Instructions by Device Type

### 🖥️ Desktop/Laptop Obsidian
1. **Install LiveSync Plugin** from Community Plugins
2. **Click the setup URI** above (or copy/paste into browser)
3. **Enter passphrase:** `small-frog`
4. **Verify connection** - should sync immediately

### 📱 Mobile Obsidian (iOS/Android)
1. **Install Obsidian** from App Store/Play Store
2. **Install LiveSync Plugin** from Community Plugins
3. **Tap the setup URI link** above
4. **Enter passphrase:** `small-frog`
5. **Allow sync** - may take a few minutes for initial sync

### 🌐 Web Browser Access
- **URL:** [https://obsidian.b28.dev/obsidian/](https://obsidian.b28.dev/obsidian/)
- **Works on:** Any device on Tailscale network
- **Features:** Full Obsidian interface in browser

---

## 🔧 Technical Details

### 🚀 Service Endpoints
- **LiveSync Database:** `https://obsidian.b28.dev/`
- **Web Interface:** `https://obsidian.b28.dev/obsidian/`
- **REST API (MCP):** `https://obsidian.b28.dev/api/`
- **Database Name:** `obsidian`

### 🛠️ Infrastructure Components
- **Reverse Proxy:** Caddy (automatic HTTPS with Let's Encrypt)
- **Database:** CouchDB 3.5.0 (persistent sync backend)
- **Application:** LinuxServer Obsidian container
- **MCP Integration:** Semantic MCP server for Claude Code
- **Network:** Private Tailscale network (`emerald-wage.ts.net`)

### 🔄 Container Stack
```yaml
obsidian-caddy:    # Reverse proxy with SSL termination
obsidian-couchdb:  # Database backend for sync
obsidian-app:      # Main Obsidian application
```

---

## 🧪 Verification Steps

### ✅ Test LiveSync Connection
1. Create a test note on one device
2. Verify it appears on other devices within 30 seconds
3. Check for sync conflicts (should be minimal)

### ✅ Test Web Interface
1. Open [https://obsidian.b28.dev/obsidian/](https://obsidian.b28.dev/obsidian/)
2. Verify vault contents match other devices
3. Test creating/editing notes via web

### ✅ Test MCP Integration (Claude Code)
1. Run `claude mcp list` - should show "obsidian: ✓ Connected"
2. Test vault operations via Claude Code
3. Verify changes sync to all devices

---

## 🚨 Troubleshooting

### 🔧 Common Issues

#### "Certificate Authority Invalid" Error
- **Cause:** Device not on Tailscale network
- **Solution:** Connect to Tailscale, then retry

#### "Connection Refused" Error  
- **Cause:** Service temporarily unavailable
- **Solution:** Wait 30 seconds and retry

#### Sync Not Working
- **Check:** Device is on Tailscale network
- **Check:** LiveSync plugin is enabled and configured
- **Reset:** Delete local database and re-setup if needed

### 📞 Getting Help
- **View logs:** Docker container logs on host server
- **Test connectivity:** `curl https://obsidian.b28.dev/`
- **MCP status:** `claude mcp list` on host

---

## 📈 Performance & Monitoring

### ✅ Expected Performance
- **Initial sync:** 1-5 minutes (depending on vault size)
- **Real-time sync:** 5-30 seconds for changes
- **Web interface load:** 2-5 seconds
- **MCP operations:** Sub-second response times

### 📊 Health Indicators
- **SSL Certificate:** Auto-renewed (expires Nov 25, 2025)
- **Database status:** Monitor CouchDB health checks
- **Sync status:** Check LiveSync plugin status

---

## 🎯 Success Metrics

This setup provides:

- ✅ **Universal Access:** Same setup works on all devices
- ✅ **Valid SSL:** No browser certificate warnings
- ✅ **Private Network:** Tailscale-only access
- ✅ **Real-time Sync:** Changes propagate within seconds
- ✅ **Claude Integration:** Full MCP functionality
- ✅ **Web Access:** Browser-based editing capability
- ✅ **Auto-renewal:** SSL certificates managed automatically

---

*Document created: 2025-08-27*  
*Architecture: Tailscale + Caddy + CouchDB + Obsidian + MCP*  
*Status: Production Ready ✅*

---

## 🔧 CORRECTED Setup URI (Fixed Database Endpoint)

**⚠️ IMPORTANT UPDATE:** The original setup URI had the wrong endpoint. Use this corrected version:

### 🔄 LiveSync Setup URI (CORRECTED - Use This One!)
```
obsidian://setuplivesync?settings=%259faea1fc0be8aa1f245f4af40100000005ec75593f1ca8c1bdbc5736762bcea2Zj67uogErWxeqrKEBn9NxfjPgBR6jljVIDYgS2Cj75slBQ%2Fw%2Bsg7pe7aAufeO3BUINARHz23XdKsSVa3cn98Zzwymfc7ai8ml%2FA3zl0FAabE20s4dlGPoNcs%2Fp3tawmC3z85up1YdzJyLW53%2BczaXrFruRvaLQiK7QDIyJA%2FfsGsS%2FWxGndMZSYmoa12baKUNDAxqmmvHgxJi9lLDdLf6xOhafW1c5AaLXj1WxQT0H8qBkxWMmE28LuedvQ%2FZIlRVvbKtEbGQW3w1F2jgi9dGj96bZGXvzD6EBzyKfz4%2Fxhp5wPIEp5b7gzCPHRdz29IxzkncihWQ7aGeHOhPblTHmnltCSmvSz1xvh2u%2BiGM81y%2FYWCdMUVrL1Tiq27MQaG5VWMwwhh%2Be5HLxeU%2FKi63rLdN%2BEZH3%2FramRcyUCkRg3Fjl%2Fs%2BBJ0BQ%2FQVLZA3gGcmSMWhP7dnrMyrSsVjUBsNk%2BDsuytYmTf3lPATNhMziLh%2Bkdu59mnr4jCkwzLiKpyMfZyIhuZIUltxzgT2JkRWFpjs1cAw5FvsYcDiKk39EDr4O5vcGyaSXmHBOzG1UBWohYyCySnJEUbq2GAqSLIjpmRsVdLF%2Bu2Scg9I%2FoXi2eg3Cn2HHlSieCwfS1kA53zqPbxZdYL%2FgPLgLzZVXWZgHLJLVlnyPYBnEayLWVOv5lsUmeJisaZkOBSb0FdLm2Z3H022NOe%2Bgd0GHW6jUBeSiQbWYaR0gtpbhfitp0fpBDm99W9bZr2sALrMQVBn8TQWi%2BVuCiAoemSfEN4%2FILKyPrUqjOos8bK1fquhRoR45AyKPrFrN%2BGJYGhnZWH6Zl9yZ0dU%2FRdS02WOOuzUwXbmZD%2BNBczFEX%2Ft4oUD%2FWWdRAB25S4im4KYxtNrhTC9Wm8YdaURkw%3D
```

**Setup Passphrase:** `summer-dawn`

**Key Fix:** This URI connects to `https://obsidian.b28.dev/` (the CouchDB database) instead of the `/obsidian/` web interface path.

---

## 🔄 What Changed
- **Old URI:** Pointed to web interface path (wrong)
- **New URI:** Points to database root (correct)
- **Result:** LiveSync should now connect successfully without 404 errors