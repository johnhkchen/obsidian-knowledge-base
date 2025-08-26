#!/bin/bash
# CouchDB Restore Script for Obsidian Knowledge Base
# Created: 2025-08-26

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="${PROJECT_DIR}/backups/couchdb"

# Load environment variables
if [[ -f "${PROJECT_DIR}/.env" ]]; then
    source "${PROJECT_DIR}/.env"
else
    echo "Error: .env file not found in ${PROJECT_DIR}"
    exit 1
fi

# Function to show usage
show_usage() {
    echo "Usage: $0 [BACKUP_FILE]"
    echo ""
    echo "Examples:"
    echo "  $0 couchdb_backup_20250826_120000.tar.gz"
    echo "  $0 latest  # Uses the most recent backup"
    echo ""
    echo "Available backups:"
    ls -lt "${BACKUP_DIR}"/couchdb_backup_*.tar.gz 2>/dev/null | head -5 || echo "  No backups found"
}

# Parse arguments
if [[ $# -eq 0 ]]; then
    show_usage
    exit 1
fi

BACKUP_FILE="$1"

# Handle 'latest' option
if [[ "$BACKUP_FILE" == "latest" ]]; then
    BACKUP_FILE=$(ls -t "${BACKUP_DIR}"/couchdb_backup_*.tar.gz 2>/dev/null | head -1 || true)
    if [[ -z "$BACKUP_FILE" ]]; then
        echo "Error: No backup files found in ${BACKUP_DIR}"
        exit 1
    fi
    echo "Using latest backup: $(basename "$BACKUP_FILE")"
fi

# Ensure backup file path is absolute
if [[ ! "$BACKUP_FILE" == /* ]]; then
    BACKUP_FILE="${BACKUP_DIR}/${BACKUP_FILE}"
fi

# Verify backup file exists
if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "Error: Backup file not found: $BACKUP_FILE"
    show_usage
    exit 1
fi

echo "Starting CouchDB restore from: $BACKUP_FILE"

# Warning prompt
echo ""
echo "WARNING: This will REPLACE all current CouchDB data!"
echo "Current containers will be stopped and data will be overwritten."
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled"
    exit 0
fi

# Stop CouchDB container
echo "Stopping CouchDB container..."
cd "${PROJECT_DIR}"
docker compose stop couchdb

# Create temporary extraction directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Extract backup
echo "Extracting backup..."
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"
BACKUP_NAME=$(basename "$BACKUP_FILE" .tar.gz)

# Verify backup structure
if [[ ! -d "$TEMP_DIR/$BACKUP_NAME" ]]; then
    echo "Error: Invalid backup structure"
    exit 1
fi

# Show backup info
if [[ -f "$TEMP_DIR/$BACKUP_NAME/backup_info.json" ]]; then
    echo "Backup info:"
    cat "$TEMP_DIR/$BACKUP_NAME/backup_info.json" | jq .
fi

# Method 1: Restore volumes (filesystem level)
echo "Restoring CouchDB volumes..."

# Remove existing volumes
docker volume rm obsidian-knowledge-base_couchdb_data 2>/dev/null || true
docker volume rm obsidian-knowledge-base_couchdb_config 2>/dev/null || true

# Create new volumes
docker volume create obsidian-knowledge-base_couchdb_data
docker volume create obsidian-knowledge-base_couchdb_config

# Restore data
if [[ -d "$TEMP_DIR/$BACKUP_NAME/data" ]]; then
    docker run --rm \
        -v obsidian-knowledge-base_couchdb_data:/target \
        -v "$TEMP_DIR/$BACKUP_NAME/data":/source:ro \
        alpine:latest \
        sh -c "cp -rp /source/* /target/ 2>/dev/null || true"
    echo "Data volume restored"
fi

# Restore config
if [[ -d "$TEMP_DIR/$BACKUP_NAME/config" ]]; then
    docker run --rm \
        -v obsidian-knowledge-base_couchdb_config:/target \
        -v "$TEMP_DIR/$BACKUP_NAME/config":/source:ro \
        alpine:latest \
        sh -c "cp -rp /source/* /target/ 2>/dev/null || true"
    echo "Config volume restored"
fi

# Start CouchDB container
echo "Starting CouchDB container..."
docker compose up -d couchdb

# Wait for CouchDB to be ready
echo "Waiting for CouchDB to start..."
for i in {1..30}; do
    if curl -s -f http://localhost:5984 > /dev/null 2>&1; then
        echo "CouchDB is ready"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Method 2: Restore databases (if dumps exist)
if [[ -d "$TEMP_DIR/$BACKUP_NAME/dumps" ]]; then
    echo "Restoring database dumps..."
    
    # Wait a bit more for CouchDB to be fully ready
    sleep 5
    
    # Check if we can authenticate
    if curl -s -f -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" http://localhost:5984/_all_dbs > /dev/null 2>&1; then
        # Restore each database dump
        for dump_file in "$TEMP_DIR/$BACKUP_NAME/dumps"/*.json; do
            if [[ -f "$dump_file" ]]; then
                db_name=$(basename "$dump_file" .json)
                if [[ "$db_name" != "_all_dbs" ]]; then
                    echo "Restoring database: $db_name"
                    
                    # Create database
                    curl -s -X PUT -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" \
                        "http://localhost:5984/$db_name" || true
                    
                    # Restore documents
                    jq -r '.rows[] | select(.doc) | .doc' "$dump_file" | \
                    while IFS= read -r doc; do
                        # Remove _rev field for restore
                        doc_cleaned=$(echo "$doc" | jq 'del(._rev)')
                        doc_id=$(echo "$doc_cleaned" | jq -r '._id')
                        
                        # Upload document
                        curl -s -X PUT \
                            -u "${COUCHDB_USER}:${COUCHDB_PASSWORD}" \
                            -H "Content-Type: application/json" \
                            -d "$doc_cleaned" \
                            "http://localhost:5984/$db_name/$doc_id" > /dev/null || true
                    done
                fi
            fi
        done
        echo "Database dumps restored"
    else
        echo "Warning: Could not authenticate with CouchDB for database restore"
    fi
fi

echo ""
echo "Restore completed successfully!"
echo "CouchDB should now be running with restored data"
echo ""
echo "Verify the restore:"
echo "  docker compose ps"
echo "  curl http://localhost:5984"