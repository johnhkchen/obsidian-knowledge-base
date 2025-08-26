#!/bin/bash
# Disk Space Monitoring for CouchDB and System
# Created: 2025-08-26

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/logs/disk-usage.log"

mkdir -p "${PROJECT_DIR}/logs"

# Thresholds
WARNING_THRESHOLD=80
CRITICAL_THRESHOLD=90

log_usage() {
    echo "$(date -Iseconds) $1" | tee -a "$LOG_FILE"
}

echo "=== Disk Space Monitor - $(date) ==="

# 1. System disk usage
system_usage=$(df -h "$PROJECT_DIR" | awk 'NR==2 {print $5}' | sed 's/%//')
system_available=$(df -h "$PROJECT_DIR" | awk 'NR==2 {print $4}')

log_usage "System disk usage: ${system_usage}% (${system_available} available)"

if [[ $system_usage -ge $CRITICAL_THRESHOLD ]]; then
    log_usage "CRITICAL: System disk usage at ${system_usage}%"
elif [[ $system_usage -ge $WARNING_THRESHOLD ]]; then
    log_usage "WARNING: System disk usage at ${system_usage}%"
fi

# 2. Docker volumes
if command -v docker &> /dev/null; then
    log_usage "Docker volume usage:"
    docker system df -v | grep -E "(couchdb|SIZE)" | while read -r line; do
        log_usage "  $line"
    done
fi

# 3. CouchDB database sizes
cd "$PROJECT_DIR"
if [[ -f .env ]]; then
    source .env
    if curl -s -f -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs > /dev/null 2>&1; then
        log_usage "CouchDB database sizes:"
        curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs | \
        jq -r '.[]' | while read -r db; do
            if [[ "$db" != _* ]]; then
                size=$(curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" "http://localhost:5984/${db}" | \
                       jq -r '.disk_size // 0' 2>/dev/null || echo "0")
                size_mb=$((size / 1048576))
                log_usage "  Database $db: ${size_mb}MB"
            fi
        done
    fi
fi

# 4. Backup directory usage
backup_dir="${PROJECT_DIR}/backups"
if [[ -d "$backup_dir" ]]; then
    backup_usage=$(du -sh "$backup_dir" | cut -f1)
    backup_count=$(find "$backup_dir" -name "*.tar.gz" | wc -l)
    log_usage "Backup directory: ${backup_usage} (${backup_count} files)"
fi

# 5. Log directory usage
log_dir="${PROJECT_DIR}/logs"
if [[ -d "$log_dir" ]]; then
    log_usage_size=$(du -sh "$log_dir" | cut -f1)
    log_usage "Log directory: ${log_usage_size}"
fi

# 6. Cleanup recommendations
if [[ $system_usage -ge $WARNING_THRESHOLD ]]; then
    log_usage "CLEANUP RECOMMENDATIONS:"
    log_usage "  - Run: docker system prune -f"
    log_usage "  - Clean old backups: find backups/ -name '*.tar.gz' -mtime +30 -delete"
    log_usage "  - Clean logs: find logs/ -name '*.log' -mtime +30 -delete"
    log_usage "  - Compact CouchDB databases via admin interface"
fi

log_usage "=== Disk monitoring completed ==="