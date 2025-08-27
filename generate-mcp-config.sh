#!/bin/bash

# Load environment variables
source .env

# Generate .mcp.json from template with environment variables substituted
envsubst < .mcp.json.template > .mcp.json

echo "Generated .mcp.json with API key from environment variables"