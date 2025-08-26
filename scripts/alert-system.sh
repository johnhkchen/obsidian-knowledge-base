#!/bin/bash
# Alert System for Obsidian Knowledge Base Services
# Created: 2025-08-26

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ALERT_LOG="${PROJECT_DIR}/logs/alerts.log"
STATE_FILE="${PROJECT_DIR}/logs/alert-state.json"

# Ensure log directory exists
mkdir -p "${PROJECT_DIR}/logs"

# Alert thresholds
DISK_SPACE_WARNING=80
DISK_SPACE_CRITICAL=90
BACKUP_AGE_WARNING=48  # hours
BACKUP_AGE_CRITICAL=72 # hours

# Function to log alerts
log_alert() {
    local severity=$1
    local message=$2
    local timestamp=$(date -Iseconds)
    
    echo "${timestamp} [${severity}] ${message}" >> "$ALERT_LOG"
    
    # Also output to stdout for monitoring systems
    echo "[${severity}] ${message}"
}

# Function to send notification (placeholder for future integration)
send_notification() {
    local severity=$1
    local message=$2
    local service=$3
    
    # For now, just log. Future implementations could include:
    # - Email notifications
    # - Slack/Discord webhooks
    # - System notifications
    # - Integration with monitoring systems (Prometheus, etc.)
    
    log_alert "$severity" "${service}: ${message}"
}

# Function to load previous state
load_previous_state() {
    if [[ -f "$STATE_FILE" ]]; then
        cat "$STATE_FILE"
    else
        echo "{}"
    fi
}

# Function to save current state
save_current_state() {
    local state=$1
    echo "$state" > "$STATE_FILE"
}

# Function to check if we should alert (avoid spam)
should_alert() {
    local service=$1
    local issue=$2
    local current_state=$(load_previous_state)
    
    # Check if this issue was already alerted recently
    local last_alert=$(echo "$current_state" | jq -r ".\"${service}_${issue}\" // \"never\"" 2>/dev/null || echo "never")
    local current_time=$(date +%s)
    
    if [[ "$last_alert" != "never" ]]; then
        local time_since_alert=$(( current_time - last_alert ))
        # Re-alert after 4 hours (14400 seconds)
        if [[ $time_since_alert -lt 14400 ]]; then
            return 1  # Don't alert
        fi
    fi
    
    return 0  # Alert
}

# Function to record alert
record_alert() {
    local service=$1
    local issue=$2
    local current_state=$(load_previous_state)
    local current_time=$(date +%s)
    
    # Update state with current alert time
    local new_state=$(echo "$current_state" | jq --arg key "${service}_${issue}" --arg time "$current_time" '. + {($key): ($time | tonumber)}' 2>/dev/null || echo "{\"${service}_${issue}\": $current_time}")
    save_current_state "$new_state"
}

echo "Running alert checks at $(date)"

# 1. Check CouchDB Health
if ! curl -s -f http://localhost:5984/_up > /dev/null 2>&1; then
    if should_alert "couchdb" "down"; then
        send_notification "CRITICAL" "CouchDB is not responding" "couchdb"
        record_alert "couchdb" "down"
    fi
fi

# 2. Check Container Health
if command -v docker &> /dev/null; then
    cd "$PROJECT_DIR"
    containers=$(docker compose ps 2>/dev/null || echo "")
    
    if [[ -n "$containers" ]]; then
        echo "$containers" | tail -n +2 | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                name=$(echo "$line" | awk '{print $1}')
                
                if [[ "$line" != *"Up"* ]]; then
                    if should_alert "container" "$name"; then
                        send_notification "CRITICAL" "Container $name is not running" "docker"
                        record_alert "container" "$name"
                    fi
                elif [[ "$line" == *"unhealthy"* ]]; then
                    if should_alert "container" "${name}_unhealthy"; then
                        send_notification "WARNING" "Container $name is unhealthy" "docker"
                        record_alert "container" "${name}_unhealthy"
                    fi
                fi
            fi
        done
    fi
fi

# 3. Check Disk Space
disk_usage=$(df -h "$PROJECT_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ $disk_usage -ge $DISK_SPACE_CRITICAL ]]; then
    if should_alert "disk" "critical"; then
        send_notification "CRITICAL" "Disk usage is ${disk_usage}% (critical threshold: ${DISK_SPACE_CRITICAL}%)" "disk"
        record_alert "disk" "critical"
    fi
elif [[ $disk_usage -ge $DISK_SPACE_WARNING ]]; then
    if should_alert "disk" "warning"; then
        send_notification "WARNING" "Disk usage is ${disk_usage}% (warning threshold: ${DISK_SPACE_WARNING}%)" "disk"
        record_alert "disk" "warning"
    fi
fi

# 4. Check Backup Age
backup_dir="${PROJECT_DIR}/backups/couchdb"
if [[ -d "$backup_dir" ]]; then
    latest_backup=$(ls -t "${backup_dir}"/couchdb_backup_*.tar.gz 2>/dev/null | head -1 || echo "")
    if [[ -n "$latest_backup" ]]; then
        backup_age=$(stat -c %Y "$latest_backup")
        current_time=$(date +%s)
        age_hours=$(( (current_time - backup_age) / 3600 ))
        
        if [[ $age_hours -ge $BACKUP_AGE_CRITICAL ]]; then
            if should_alert "backup" "critical"; then
                send_notification "CRITICAL" "Latest backup is ${age_hours} hours old (critical threshold: ${BACKUP_AGE_CRITICAL}h)" "backup"
                record_alert "backup" "critical"
            fi
        elif [[ $age_hours -ge $BACKUP_AGE_WARNING ]]; then
            if should_alert "backup" "warning"; then
                send_notification "WARNING" "Latest backup is ${age_hours} hours old (warning threshold: ${BACKUP_AGE_WARNING}h)" "backup"
                record_alert "backup" "warning"
            fi
        fi
    else
        if should_alert "backup" "missing"; then
            send_notification "CRITICAL" "No backup files found in ${backup_dir}" "backup"
            record_alert "backup" "missing"
        fi
    fi
fi

# 5. Check Tailscale Status
if command -v tailscale &> /dev/null; then
    if ! tailscale status &> /dev/null; then
        if should_alert "tailscale" "disconnected"; then
            send_notification "WARNING" "Tailscale is not connected" "tailscale"
            record_alert "tailscale" "disconnected"
        fi
    fi
fi

echo "Alert check completed at $(date)"