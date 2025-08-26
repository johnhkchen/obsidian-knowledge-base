#!/bin/bash
# Performance Monitoring Script for Obsidian Knowledge Base
# Created: 2025-08-26

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="${PROJECT_DIR}/logs/performance.log"
METRICS_FILE="${PROJECT_DIR}/logs/metrics.json"

# Load environment variables
if [[ -f "${PROJECT_DIR}/.env" ]]; then
    source "${PROJECT_DIR}/.env"
fi

# Ensure log directory exists
mkdir -p "${PROJECT_DIR}/logs"

# Function to log metrics
log_metrics() {
    local timestamp=$(date -Iseconds)
    local metric_name=$1
    local metric_value=$2
    local unit=${3:-""}
    
    echo "${timestamp} ${metric_name}: ${metric_value} ${unit}" >> "$LOG_FILE"
}

# Function to save JSON metrics
save_json_metrics() {
    local metrics=$1
    local timestamp=$(date -Iseconds)
    
    # Create metrics object with timestamp
    local metrics_with_timestamp=$(echo "$metrics" | jq --arg ts "$timestamp" '. + {timestamp: $ts}')
    
    # Append to metrics file
    echo "$metrics_with_timestamp" >> "$METRICS_FILE"
}

echo "=== Performance Monitor Report - $(date) ===" | tee -a "$LOG_FILE"

# Initialize metrics object
metrics="{}"

# 1. CouchDB Performance Metrics
echo "Checking CouchDB performance..."

if curl -s -f http://localhost:5984/_up > /dev/null 2>&1; then
    # Test response time
    couchdb_response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:5984/)
    log_metrics "couchdb_response_time" "$couchdb_response_time" "seconds"
    metrics=$(echo "$metrics" | jq --arg val "$couchdb_response_time" '.couchdb_response_time = ($val | tonumber)')
    
    # Get CouchDB stats if authentication works
    if [[ -n "${COUCHDB_USER:-}" ]] && [[ -n "${COUCHDB_PASSWORD:-}" ]]; then
        if curl -s -f -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs > /dev/null 2>&1; then
            # Database count
            db_count=$(curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs | jq 'length' 2>/dev/null || echo "0")
            log_metrics "couchdb_database_count" "$db_count" "databases"
            metrics=$(echo "$metrics" | jq --arg val "$db_count" '.couchdb_database_count = ($val | tonumber)')
            
            # Server stats (if available)
            server_stats=$(curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_node/_local/_stats 2>/dev/null || echo "{}")
            if [[ "$server_stats" != "{}" ]]; then
                # Extract useful metrics
                open_databases=$(echo "$server_stats" | jq '.couchdb.open_databases.value // 0' 2>/dev/null || echo "0")
                open_os_files=$(echo "$server_stats" | jq '.couchdb.open_os_files.value // 0' 2>/dev/null || echo "0")
                
                log_metrics "couchdb_open_databases" "$open_databases" "count"
                log_metrics "couchdb_open_files" "$open_os_files" "count"
                
                metrics=$(echo "$metrics" | jq --arg val1 "$open_databases" --arg val2 "$open_os_files" '.couchdb_open_databases = ($val1 | tonumber) | .couchdb_open_files = ($val2 | tonumber)')
            fi
        fi
    fi
else
    log_metrics "couchdb_status" "down" ""
    metrics=$(echo "$metrics" | jq '.couchdb_status = "down"')
fi

# 2. System Performance Metrics
echo "Checking system performance..."

# CPU usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | sed 's/%us,//' || echo "0")
log_metrics "cpu_usage" "$cpu_usage" "percent"
metrics=$(echo "$metrics" | jq --arg val "$cpu_usage" '.cpu_usage = ($val | tonumber)')

# Memory usage
memory_info=$(free -m)
total_memory=$(echo "$memory_info" | awk 'NR==2{print $2}')
used_memory=$(echo "$memory_info" | awk 'NR==2{print $3}')
memory_usage_percent=$(( (used_memory * 100) / total_memory ))

log_metrics "memory_usage" "$memory_usage_percent" "percent"
log_metrics "memory_used_mb" "$used_memory" "MB"
log_metrics "memory_total_mb" "$total_memory" "MB"

metrics=$(echo "$metrics" | jq --arg val1 "$memory_usage_percent" --arg val2 "$used_memory" --arg val3 "$total_memory" '.memory_usage_percent = ($val1 | tonumber) | .memory_used_mb = ($val2 | tonumber) | .memory_total_mb = ($val3 | tonumber)')

# Disk I/O
if command -v iostat &> /dev/null; then
    io_stats=$(iostat -x 1 1 | tail -n +4 | head -n 1)
    if [[ -n "$io_stats" ]]; then
        read_iops=$(echo "$io_stats" | awk '{print $4}' || echo "0")
        write_iops=$(echo "$io_stats" | awk '{print $5}' || echo "0")
        
        log_metrics "disk_read_iops" "$read_iops" "ops/sec"
        log_metrics "disk_write_iops" "$write_iops" "ops/sec"
        
        metrics=$(echo "$metrics" | jq --arg val1 "$read_iops" --arg val2 "$write_iops" '.disk_read_iops = ($val1 | tonumber) | .disk_write_iops = ($val2 | tonumber)')
    fi
fi

# 3. Docker Container Metrics
echo "Checking Docker container performance..."

if command -v docker &> /dev/null; then
    cd "$PROJECT_DIR"
    
    # Container resource usage
    container_stats=$(docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "")
    
    if [[ -n "$container_stats" ]]; then
        echo "$container_stats" | tail -n +2 | while read -r container cpu_perc mem_usage; do
            if [[ "$container" == *"couchdb"* ]]; then
                cpu_val=$(echo "$cpu_perc" | sed 's/%//')
                mem_val=$(echo "$mem_usage" | cut -d'/' -f1 | sed 's/MiB//')
                
                log_metrics "container_couchdb_cpu" "$cpu_val" "percent"
                log_metrics "container_couchdb_memory" "$mem_val" "MiB"
                
                metrics=$(echo "$metrics" | jq --arg val1 "$cpu_val" --arg val2 "$mem_val" '.container_couchdb_cpu = ($val1 | tonumber) | .container_couchdb_memory_mb = ($val2 | tonumber)')
            fi
        done
    fi
fi

# 4. Network Performance
echo "Checking network performance..."

# Test local connectivity
nginx_port=$(grep -o 'listen [0-9]*' nginx.conf 2>/dev/null | head -1 | cut -d' ' -f2 || echo "3880")
if curl -s -f http://localhost:${nginx_port} > /dev/null 2>&1; then
    nginx_response_time=$(curl -o /dev/null -s -w '%{time_total}' http://localhost:${nginx_port}/)
    log_metrics "nginx_response_time" "$nginx_response_time" "seconds"
    metrics=$(echo "$metrics" | jq --arg val "$nginx_response_time" '.nginx_response_time = ($val | tonumber)')
fi

# 5. Sync Performance Simulation
echo "Testing sync performance..."

if [[ -n "${COUCHDB_USER:-}" ]] && [[ -n "${COUCHDB_PASSWORD:-}" ]]; then
    # Create a test document and measure performance
    test_db="performance_test"
    test_doc='{"_id":"perf_test_'$(date +%s)'","type":"performance_test","timestamp":"'$(date -Iseconds)'","data":"test"}'
    
    # Create test database if it doesn't exist
    curl -s -X PUT -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" "http://localhost:5984/${test_db}" > /dev/null 2>&1 || true
    
    # Measure write performance
    write_start=$(date +%s.%3N)
    write_result=$(curl -s -X POST -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" -H "Content-Type: application/json" -d "$test_doc" "http://localhost:5984/${test_db}" || echo '{"error": "failed"}')
    write_end=$(date +%s.%3N)
    write_time=$(echo "$write_end - $write_start" | bc 2>/dev/null || echo "0")
    
    if [[ "$write_result" != *"error"* ]]; then
        log_metrics "couchdb_write_time" "$write_time" "seconds"
        metrics=$(echo "$metrics" | jq --arg val "$write_time" '.couchdb_write_time = ($val | tonumber)')
        
        # Measure read performance
        doc_id=$(echo "$write_result" | jq -r '.id' 2>/dev/null || echo "")
        if [[ -n "$doc_id" ]] && [[ "$doc_id" != "null" ]]; then
            read_start=$(date +%s.%3N)
            curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" "http://localhost:5984/${test_db}/${doc_id}" > /dev/null
            read_end=$(date +%s.%3N)
            read_time=$(echo "$read_end - $read_start" | bc 2>/dev/null || echo "0")
            
            log_metrics "couchdb_read_time" "$read_time" "seconds"
            metrics=$(echo "$metrics" | jq --arg val "$read_time" '.couchdb_read_time = ($val | tonumber)')
        fi
    fi
fi

# Save all metrics as JSON
save_json_metrics "$metrics"

echo "=== Performance monitoring completed ===" | tee -a "$LOG_FILE"

# Performance summary
echo ""
echo "Performance Summary:"
echo "- CouchDB Response Time: ${couchdb_response_time:-unknown}s"
echo "- CPU Usage: ${cpu_usage}%"
echo "- Memory Usage: ${memory_usage_percent}%"
echo "- Latest metrics saved to: $METRICS_FILE"