# MCP Obsidian Server Configuration

## Overview
The MCP (Model Context Protocol) server for Obsidian has been successfully configured to integrate with the containerized Obsidian setup. This allows external clients like Claude Code to interact with the Obsidian vault via the Local REST API.

## Configuration Details

### MCP Server Container
- **Image**: Custom built from `mcp-obsidian` by MarkusPfundstein
- **Container Name**: `obsidian-mcp-server`
- **Connection**: Direct HTTPS connection to Obsidian container
- **Port**: 27124 (Obsidian Local REST API port)
- **SSL Verification**: Disabled for container-to-container communication

### Environment Variables
```
OBSIDIAN_HOST=obsidian-app
OBSIDIAN_PORT=27124
OBSIDIAN_PROTOCOL=https
OBSIDIAN_API_KEY=ea2999ae90a3b62469e45ed5d5b2c60243263c6ffd2f36785b304307f0125056
```

### Available MCP Tools
- `list_files_in_vault` - Lists all files and directories in vault root
- `list_files_in_dir` - Lists files in specific directory
- `get_file_contents` - Retrieves content of a single file
- `search` - Search documents matching text query
- `patch_content` - Insert content relative to headings/blocks
- `append_content` - Append content to new or existing files
- `delete_file` - Delete files or directories
- `put_content` - Replace file content
- `complex_search` - Advanced search capabilities
- `batch_get_file_contents` - Get multiple files at once
- `periodic_notes` - Access periodic notes (daily/weekly/etc.)
- `recent_changes` - Get recently modified files

## Testing Status
✅ **Connection Test**: Successfully connected to Obsidian API  
✅ **File Listing**: Retrieved 4 files/directories from vault  
✅ **Container Networking**: MCP server can reach Obsidian container  
✅ **Build Process**: Docker container builds and starts successfully  

## Usage

### For External Claude Code Clients
The MCP server runs over stdio and can be used by external clients:

```bash
docker compose run --rm mcp-obsidian
```

### Integration with Claude Code
Add to your Claude Code MCP configuration:

```json
{
  "mcpServers": {
    "obsidian": {
      "command": "docker",
      "args": [
        "compose", 
        "-f", "/path/to/obsidian-knowledge-base/docker-compose.yml",
        "run", "--rm", "mcp-obsidian"
      ]
    }
  }
}
```

## Architecture
```
Claude Code Client
       ↓ (stdio/MCP protocol)
MCP Server Container
       ↓ (HTTPS API calls)
Obsidian Container (Local REST API)
       ↓ (file operations)
Vault Files (/obsidian/vault)
```

## Security Notes
- API key is currently stored in docker-compose.yml
- SSL verification disabled for container-to-container communication
- Access restricted to Docker internal network
- External access only via nginx proxy with proper authentication

## Dependencies
- Obsidian container with Local REST API plugin enabled
- Docker Compose networking for container communication
- Python 3.11+ runtime in MCP server container
- uv package manager for Python dependencies

## Status: ✅ READY FOR PRODUCTION
The MCP server is fully configured and ready for integration with Claude Code clients.