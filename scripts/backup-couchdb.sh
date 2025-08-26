#!/bin/bash
# CouchDB Backup Script for Obsidian Knowledge Base
# Created: 2025-08-26

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups/couchdb"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="couchdb_backup_${TIMESTAMP}"

# Load environment variables
if [[ -f "${PROJECT_DIR}/.env" ]]; then
    source "${PROJECT_DIR}/.env"
else
    echo "Error: .env file not found in ${PROJECT_DIR}"
    exit 1
fi

# Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

echo "Starting CouchDB backup at $(date)"
echo "Backup directory: ${BACKUP_DIR}/${BACKUP_NAME}"

# Method 1: Volume-based backup (filesystem level)
echo "Creating volume-based backup..."
docker run --rm \
    -v obsidian-knowledge-base_couchdb_data:/source:ro \
    -v obsidian-knowledge-base_couchdb_config:/config:ro \
    -v "${BACKUP_DIR}:/backup" \
    --user "$(id -u):$(id -g)" \
    alpine:latest \
    sh -c "
        mkdir -p /backup/${BACKUP_NAME}/data
        mkdir -p /backup/${BACKUP_NAME}/config
        cp -rp /source/* /backup/${BACKUP_NAME}/data/ 2>/dev/null || true
        cp -rp /config/* /backup/${BACKUP_NAME}/config/ 2>/dev/null || true
        echo 'Volume backup completed'
    "

# Method 2: Database-level backup (if CouchDB is accessible)
echo "Attempting database-level backup..."
if curl -s -f -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs > /dev/null 2>&1; then
    echo "CouchDB is accessible, creating database dumps..."
    
    # Get all databases
    DATABASES=$(curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs)
    
    # Create database dumps directory
    mkdir -p "${BACKUP_DIR}/${BACKUP_NAME}/dumps"
    
    # Save database list
    echo "${DATABASES}" > "${BACKUP_DIR}/${BACKUP_NAME}/dumps/_all_dbs.json"
    
    # Backup each database (excluding system databases)
    echo "${DATABASES}" | jq -r '.[]' | grep -v '^_' | while read -r db; do
        if [[ -n "$db" ]]; then
            echo "Backing up database: $db"
            curl -s -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" \
                "http://localhost:5984/${db}/_all_docs?include_docs=true" \
                > "${BACKUP_DIR}/${BACKUP_NAME}/dumps/${db}.json"
        fi
    done
    
    echo "Database dumps completed"
else
    echo "Warning: CouchDB not accessible for database-level backup"
    echo "Only volume-based backup was performed"
fi

# Create backup metadata
cat > "${BACKUP_DIR}/${BACKUP_NAME}/backup_info.json" << EOF
{
    "timestamp": "${TIMESTAMP}",
    "date": "$(date -Iseconds)",
    "backup_type": "full",
    "couchdb_version": "3.5.0",
    "methods": ["volume", "database_dump"],
    "size_bytes": $(du -sb "${BACKUP_DIR}/${BACKUP_NAME}" | cut -f1),
    "files_count": $(find "${BACKUP_DIR}/${BACKUP_NAME}" -type f | wc -l)
}
EOF

# Compress backup
echo "Compressing backup..."
cd "${BACKUP_DIR}"
tar -czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

# Cleanup old backups (keep last 7 days)
echo "Cleaning up old backups (keeping last 7 days)..."
find "${BACKUP_DIR}" -name "couchdb_backup_*.tar.gz" -mtime +7 -delete

FINAL_SIZE=$(du -sh "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" | cut -f1)
echo "Backup completed successfully!"
echo "File: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "Size: ${FINAL_SIZE}"
echo "Completed at: $(date)"