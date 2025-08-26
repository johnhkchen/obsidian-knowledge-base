# Mobile App Compatibility Notes

## Supported Platforms

### iOS (iPhone/iPad)
- **Minimum Version**: iOS 14.0+
- **Obsidian Version**: 1.4.16+
- **LiveSync Version**: 0.25.10+
- **Status**: ✅ Fully Supported

### Android
- **Minimum Version**: Android 7.0 (API 24)+
- **Obsidian Version**: 1.4.16+
- **LiveSync Version**: 0.25.10+
- **Status**: ✅ Fully Supported

## Battery Life Optimization

### Recommended Settings
- **Sync Interval**: 60 seconds (instead of real-time)
- **Background Sync**: Enabled but limited
- **Sync Only on WiFi**: Consider for large vaults
- **Live Preview**: Disable if performance issues

### Battery-Friendly Configuration
```
LiveSync Settings → Advanced:
- Periodic sync interval: 60000ms
- Batch sync timeout: 30000ms
- Use background fetch: Enabled
- Sync only when WiFi: Optional
```

## Network Considerations

### Tailscale on Mobile
- **iOS**: Works well, minimal battery impact
- **Android**: May need battery optimization exemption
- **Corporate Networks**: Some may block VPN traffic
- **Cellular**: Works but monitor data usage

### Connection Stability
- Use server Tailscale IP, not localhost
- Configure longer timeouts for mobile networks
- Enable connection retry with backoff

## Platform-Specific Issues

### iOS Specific
- **Background Refresh**: Enable for Obsidian in Settings
- **Low Power Mode**: Disables background sync
- **App Store Version**: Always use latest version
- **File Access**: No special permissions needed

### Android Specific
- **Battery Optimization**: Exempt Obsidian from battery optimization
- **Background App Limits**: Disable for Obsidian
- **Data Saver**: May interfere with sync
- **Custom ROMs**: May have additional restrictions

## Performance Guidelines

### Large Vaults (>100MB)
- Initial sync may take several minutes
- Use WiFi for initial setup
- Consider file size limits
- Monitor storage space

### Sync Conflict Handling
- Mobile devices more prone to conflicts
- Use "Merge" mode for better compatibility
- Resolve conflicts promptly
- Avoid editing same note simultaneously

## Testing Matrix

### Verified Configurations
| Device | OS | Obsidian | LiveSync | Status |
|--------|----|-----------|---------| -------|
| iPhone 14 | iOS 17.1 | 1.4.16 | 0.25.10 | ✅ Working |
| iPad Air | iOS 16.7 | 1.4.16 | 0.25.10 | ✅ Working |
| Samsung Galaxy | Android 13 | 1.4.16 | 0.25.10 | ✅ Working |
| Google Pixel | Android 14 | 1.4.16 | 0.25.10 | ✅ Working |

### Known Issues
- None currently identified
- Monitor plugin updates for compatibility

---

**Last Updated**: 2025-08-26  
**Next Review**: 2026-02-26