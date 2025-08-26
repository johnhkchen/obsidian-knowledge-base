# Sync Frequency & Battery Life Optimization

## Overview
This document provides guidance for optimizing LiveSync frequency settings to balance real-time synchronization with mobile device battery life.

## Default vs Optimized Settings

### Default Settings (Real-time)
```
Sync Interval: 1000ms (1 second)
Background Sync: Always active
Battery Impact: High
Use Case: Active collaborative editing
```

### Optimized Settings (Battery-friendly)
```
Sync Interval: 60000ms (60 seconds)
Background Sync: Limited
Battery Impact: Low
Use Case: Personal note-taking
```

## Recommended Configurations

### Heavy Users (Active Collaboration)
```
Periodic sync interval: 5000ms (5 seconds)
Batch sync timeout: 10000ms
Use background fetch: Enabled
Sync on device start: Enabled
Battery impact: Medium
```

### Regular Users (Personal Notes)
```
Periodic sync interval: 30000ms (30 seconds)
Batch sync timeout: 30000ms
Use background fetch: Enabled
Sync only when WiFi: Optional
Battery impact: Low
```

### Light Users (Occasional Access)
```
Periodic sync interval: 300000ms (5 minutes)
Batch sync timeout: 60000ms
Use background fetch: Limited
Sync only when WiFi: Recommended
Battery impact: Minimal
```

## Platform-Specific Optimization

### iOS Optimization
- **Background App Refresh**: Enable for sync to work
- **Low Power Mode**: Automatically reduces sync frequency
- **Screen Off**: iOS limits background activity
- **Recommended**: 60-second intervals

### Android Optimization
- **Battery Optimization**: Exempt Obsidian from optimization
- **Doze Mode**: May affect background sync
- **Data Saver**: Can block background sync
- **Recommended**: 60-120 second intervals

## Monitoring Battery Impact

### iOS Monitoring
```
Settings → Battery → Show Activity
Look for Obsidian usage patterns
Monitor background vs screen-on usage
```

### Android Monitoring
```
Settings → Battery → App Usage
Check Obsidian power consumption
Monitor background activity
```

## Dynamic Adjustment Strategies

### WiFi vs Cellular
```javascript
// Pseudo-configuration
if (network.type === "WiFi") {
    syncInterval = 30000; // 30 seconds
} else {
    syncInterval = 120000; // 2 minutes
}
```

### Time-Based Adjustment
```javascript
// Active hours: faster sync
// Night/weekend: slower sync
const currentHour = new Date().getHours();
if (currentHour >= 9 && currentHour <= 17) {
    syncInterval = 30000; // Work hours
} else {
    syncInterval = 300000; // Off hours
}
```

## Battery Life Estimates

### Typical Impact (per hour)
- **Real-time (1s)**: 8-15% battery
- **Fast (5s)**: 3-6% battery  
- **Normal (30s)**: 1-2% battery
- **Slow (5min)**: <1% battery

*Estimates vary by device, network, and vault size*

## Advanced Configuration

### LiveSync Plugin Settings
```json
{
  "periodicReplication": true,
  "periodicReplicationInterval": 60000,
  "syncOnSave": true,
  "syncOnFileOpen": false,
  "batchSave": true,
  "batchSaveMinimumDelay": 5000,
  "batchSaveMaximumDelay": 30000
}
```

### Network-Aware Settings
- **Strong Signal**: Reduce intervals
- **Weak Signal**: Increase intervals, batch operations
- **Roaming**: Disable or minimal sync
- **WiFi Only**: Skip cellular sync entirely

## Troubleshooting Battery Issues

### High Battery Usage
1. **Check Sync Intervals**: Reduce frequency
2. **Monitor Conflicts**: Frequent conflicts increase sync
3. **Large Files**: Move to separate folder
4. **Background Limits**: Ensure proper OS settings

### Sync Delays
1. **Increase Frequency**: If battery allows
2. **Manual Sync**: Use pull-to-refresh
3. **Notification Triggers**: Sync on app open
4. **Network Detection**: Sync when WiFi connects

## Best Practices

### Setup Phase
1. Start with conservative settings (60s intervals)
2. Monitor battery usage for 1 week
3. Adjust based on usage patterns
4. Test on all devices

### Ongoing Maintenance
1. Review settings monthly
2. Adjust for travel/roaming
3. Monitor OS updates impact
4. Update based on usage changes

### Team Collaboration
- Coordinate sync settings across team
- Consider "work hours" vs "personal time" settings
- Use shared documentation for team settings
- Regular review of team sync performance

## Quick Settings Reference

### Maximum Battery Life
```
Sync Interval: 300000ms (5 minutes)
Background Sync: Disabled
WiFi Only: Enabled
Manual Sync: Primary method
```

### Balanced Performance
```
Sync Interval: 60000ms (1 minute)
Background Sync: Limited
WiFi Only: Optional
Auto-sync: Enabled
```

### Maximum Collaboration
```
Sync Interval: 5000ms (5 seconds)
Background Sync: Always
WiFi Only: Disabled
Real-time: Near real-time
```

---

**Configuration Date**: ___________  
**Device Type**: ___________  
**Usage Pattern**: ___________  
**Next Review**: ___________