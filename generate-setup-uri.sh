#!/bin/bash
# Generate LiveSync Setup URI
# Based on your server configuration

# Load your current configuration
source .env

# Your server configuration
export hostname="http://100.68.79.63:5984"  # Your Tailscale IP
export database="obsidiandb"
export username="$COUCHDB_USER"
export password="$COUCHDB_PASSWORD"
export passphrase="zuBwiah5Ma1ogAAtBVACFzSeKbJhK7ru4LCleAQTiqk="  # Your E2EE passphrase

echo "Generating Setup URI with configuration:"
echo "- Hostname: $hostname"
echo "- Database: $database"
echo "- Username: $username"
echo "- E2EE Passphrase: [CONFIGURED]"
echo ""

# Generate using the official script
deno run -A https://raw.githubusercontent.com/vrtmrz/obsidian-livesync/main/utils/flyio/generate_setupuri.ts