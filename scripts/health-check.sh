#!/bin/bash
# Health Check Script for Obsidian Knowledge Base Services
# Created: 2025-08-26

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/logs/health-check.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Ensure log directory exists
mkdir -p "${PROJECT_DIR}/logs"

# Function to log with timestamp
log() {
    echo "$(date -Iseconds) $1" | tee -a "$LOG_FILE"
}

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "OK")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "ERROR")
            echo -e "${RED}❌ $message${NC}"
            ;;
    esac
}

echo "======================================"
echo "Health Check Report - $(date)"
echo "======================================"

# Load environment variables
if [[ -f "${PROJECT_DIR}/.env" ]]; then
    source "${PROJECT_DIR}/.env"
else
    print_status "ERROR" ".env file not found"
    log "ERROR: .env file not found in ${PROJECT_DIR}"
fi

# Change to project directory
cd "$PROJECT_DIR"

# 1. Check Docker services
echo ""
echo "🐳 Docker Services Status"
echo "------------------------"

services_status=0

# Check if docker-compose is available
if command -v "docker" &> /dev/null && docker compose version &> /dev/null; then
    # Get container status using simple format
    containers=$(docker compose ps 2>/dev/null || echo "")
    
    if [[ -n "$containers" ]]; then
        # Parse table format output (skip header line)
        echo "$containers" | tail -n +2 | while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                name=$(echo "$line" | awk '{print $1}')
                status_info=$(echo "$line" | grep -o 'Up [^0-9]*' || echo "Down")
                
                if [[ "$status_info" == *"Up"* ]]; then
                    if [[ "$line" == *"unhealthy"* ]]; then
                        print_status "WARN" "Container $name: Running but unhealthy"
                        log "WARN: Container $name is running but unhealthy"
                    else
                        print_status "OK" "Container $name: Running"
                        log "INFO: Container $name is running"
                    fi
                else
                    print_status "ERROR" "Container $name: Not running"
                    log "ERROR: Container $name is not running"
                    services_status=1
                fi
            fi
        done
    else
        print_status "WARN" "No containers found"
        log "WARN: No containers found via docker compose"
    fi
else
    print_status "ERROR" "Docker or docker compose not available"
    log "ERROR: Docker or docker compose not available"
    services_status=1
fi

# 2. Check CouchDB Health
echo ""
echo "🗄️ CouchDB Health"
echo "----------------"

if curl -s -f http://localhost:5984/_up > /dev/null 2>&1; then
    print_status "OK" "CouchDB is responding"
    log "INFO: CouchDB health check passed"
    
    # Check if we can authenticate
    if [[ -n "${COUCHDB_USER:-}" ]] && [[ -n "${COUCHDB_PASSWORD:-}" ]]; then
        if curl -s -f -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs > /dev/null 2>&1; then
            print_status "OK" "CouchDB authentication working"
            log "INFO: CouchDB authentication successful"
        else
            print_status "WARN" "CouchDB authentication failed"
            log "WARN: CouchDB authentication failed"
        fi
    else
        print_status "WARN" "CouchDB credentials not configured"
        log "WARN: CouchDB credentials not found in environment"
    fi
else
    print_status "ERROR" "CouchDB is not responding"
    log "ERROR: CouchDB health check failed"
    services_status=1
fi

# 3. Check Nginx Proxy (if configured)
echo ""
echo "🌐 Nginx Proxy Health"
echo "--------------------"

if [[ -f "nginx.conf" ]]; then
    # Check if nginx is running on configured port
    nginx_port=$(grep -o 'listen [0-9]*' nginx.conf | head -1 | cut -d' ' -f2 || echo "3880")
    
    if curl -s -f http://localhost:${nginx_port} > /dev/null 2>&1; then
        print_status "OK" "Nginx proxy responding on port ${nginx_port}"
        log "INFO: Nginx proxy health check passed on port ${nginx_port}"
    else
        print_status "WARN" "Nginx proxy not responding on port ${nginx_port}"
        log "WARN: Nginx proxy not responding on port ${nginx_port}"
    fi
else
    print_status "WARN" "Nginx configuration not found"
    log "WARN: nginx.conf not found"
fi

# 4. Check Tailscale Status
echo ""
echo "🔗 Tailscale Network"
echo "------------------"

if command -v tailscale &> /dev/null; then
    if tailscale status &> /dev/null; then
        tailscale_ip=$(tailscale ip -4 2>/dev/null || echo "unknown")
        print_status "OK" "Tailscale connected (IP: ${tailscale_ip})"
        log "INFO: Tailscale is connected with IP ${tailscale_ip}"
    else
        print_status "ERROR" "Tailscale not connected"
        log "ERROR: Tailscale is not connected"
        services_status=1
    fi
else
    print_status "WARN" "Tailscale not installed"
    log "WARN: Tailscale command not available"
fi

# 5. Check Disk Space
echo ""
echo "💾 Disk Space Usage"
echo "------------------"

disk_usage=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [[ $disk_usage -lt 80 ]]; then
    print_status "OK" "Disk usage: ${disk_usage}%"
    log "INFO: Disk usage is ${disk_usage}%"
elif [[ $disk_usage -lt 90 ]]; then
    print_status "WARN" "Disk usage: ${disk_usage}%"
    log "WARN: Disk usage is ${disk_usage}% (warning threshold)"
else
    print_status "ERROR" "Disk usage: ${disk_usage}%"
    log "ERROR: Disk usage is ${disk_usage}% (critical threshold)"
    services_status=1
fi

# Check Docker volumes disk usage
if docker volume ls | grep -q couchdb; then
    couchdb_data_size=$(docker system df -v | grep couchdb_data | awk '{print $3}' || echo "unknown")
    print_status "OK" "CouchDB data volume size: ${couchdb_data_size}"
    log "INFO: CouchDB data volume size: ${couchdb_data_size}"
fi

# 6. Check Recent Backups
echo ""
echo "💾 Backup Status"
echo "---------------"

backup_dir="${PROJECT_DIR}/backups/couchdb"
if [[ -d "$backup_dir" ]]; then
    latest_backup=$(ls -t "${backup_dir}"/couchdb_backup_*.tar.gz 2>/dev/null | head -1 || echo "")
    if [[ -n "$latest_backup" ]]; then
        backup_age=$(stat -c %Y "$latest_backup")
        current_time=$(date +%s)
        age_hours=$(( (current_time - backup_age) / 3600 ))
        
        if [[ $age_hours -lt 48 ]]; then
            print_status "OK" "Latest backup: $(basename "$latest_backup") (${age_hours}h ago)"
            log "INFO: Latest backup is ${age_hours} hours old"
        else
            print_status "WARN" "Latest backup: $(basename "$latest_backup") (${age_hours}h ago)"
            log "WARN: Latest backup is ${age_hours} hours old (stale)"
        fi
    else
        print_status "WARN" "No backups found"
        log "WARN: No backup files found in ${backup_dir}"
    fi
else
    print_status "WARN" "Backup directory not found"
    log "WARN: Backup directory ${backup_dir} does not exist"
fi

# 7. Summary
echo ""
echo "📊 Summary"
echo "----------"

if [[ $services_status -eq 0 ]]; then
    print_status "OK" "All critical services are healthy"
    log "INFO: Health check completed successfully"
    exit 0
else
    print_status "ERROR" "Some services have issues"
    log "ERROR: Health check found issues"
    exit 1
fi