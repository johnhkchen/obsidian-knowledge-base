# Claude Code Integration Guide

This document contains learnings, best practices, and configuration guidance for Claude Code integration with this project.

## MCP (Model Context Protocol) Integration

### Current Setup ✅ Optimal
- **MCP Server**: `obsidian-semantic-mcp` (npm package)  
- **Architecture**: Plugin-based via Obsidian Local REST API
- **Status**: Production-ready and validated
- **Performance**: Excellent (low latency, high reliability)

### Setup Instructions
1. **Install Obsidian Local REST API Plugin**
   - Open Obsidian → Settings → Community plugins → Browse
   - Search "Local REST API" and install/enable
   - Generate API key in plugin settings

2. **Configure Claude Code MCP**
   ```json
   {
     "mcpServers": {
       "obsidian": {
         "command": "npx",
         "args": ["-y", "obsidian-semantic-mcp"],
         "env": {
           "OBSIDIAN_API_KEY": "your-api-key-here",
           "OBSIDIAN_API_URL": "http://127.0.0.1:27124",
           "OBSIDIAN_VAULT_NAME": "your-vault-name"
         }
       }
     }
   }
   ```

3. **Verify Connection**
   ```bash
   claude mcp list
   # Should show: obsidian: npx obsidian-semantic-mcp - ✓ Connected
   ```

### Architecture Decision
**Chosen**: Plugin-based MCP via npm package  
**Rejected**: Docker sidecar approach (architectural incompatibility)  
**Reason**: Superior performance, reliability, and simpler setup

## Documentation Strategy

### Documentation Placement Principles ✅ Analyzed
- **Public (`/docs/`, root)**: User guides, setup instructions, troubleshooting
- **Private (`/knowledge/`)**: Strategic planning, research, advanced operations
- **Security**: No credentials in public docs, user-critical info publicly accessible

### Key Violations Identified
- **High Priority**: User-facing security guides in private vault (blocks user access)
- **Medium Priority**: Owner research in public docs (wrong audience)

### Migration Needed
- Move `knowledge/docs/secure-setup-guide.md` → `docs/secure-setup-guide.md`
- Move `knowledge/docs/secure-mobile-setup-guide.md` → `docs/secure-mobile-setup-guide.md`  
- Move owner research from `docs/` to `knowledge/`

## Development Workflow

### My Little Soda Integration ✅ Working
- **Task Management**: GitHub Issues → Agent branches → Review → Merge
- **Workflow**: `my-little-soda pop` → work → `my-little-soda bottle`
- **Branch Naming**: `agent001/{issue-number}-{description}`

### Best Practices
- Use TodoWrite tool for complex multi-step tasks
- Complete work in focused sessions (15-60 minutes per issue)
- Always test and verify changes before bottling
- Create public summaries for research/analysis work

## Security and Infrastructure

### Database Security ✅ Analysis Complete
- **Current State**: CouchDB with encrypted sync working properly  
- **Issues Identified**: Credential management, database cleanup needs
- **Status**: Implementation ready pending mission control review
- **Priority**: Medium (system working, improvements available)

### Infrastructure Status
- **CouchDB**: ✅ Running and healthy
- **Nginx HTTPS Proxy**: ✅ Operational on port 3880
- **Tailscale VPN**: ✅ Connected (`nuc-01-debian.emerald-wage.ts.net`)
- **Mobile Access**: ✅ Ready via secure endpoint
- **MCP Integration**: ✅ Connected via plugin architecture

## Troubleshooting

### MCP Connection Issues
- **"Connection Failed"**: Check Obsidian REST API plugin enabled
- **"API Key Invalid"**: Regenerate key in plugin settings
- **"Vault Not Found"**: Verify vault name matches exactly
- **"npx Command Not Found"**: Install Node.js

### Common Workflow Issues
- **Agent appears busy**: Check `my-little-soda status`, may need to close issue
- **Branch conflicts**: Switch to main, then checkout work branch
- **Missing commits**: Ensure changes committed before `my-little-soda bottle`

## Project Evolution

### Completed Major Work
- **MCP Integration**: Comprehensive research and setup validation (Issue #26)
- **Documentation Analysis**: Placement strategy and violation identification (Issue #30) 
- **Security Analysis**: Database hardening planning (Issue #29)
- **Infrastructure Setup**: Complete CouchDB + Obsidian sync deployment

### Remaining Work Items
- **Documentation Migration**: Implement placement strategy recommendations
- **Database Security**: Execute planned hardening (pending mission control)
- **Setup Guide Updates**: Incorporate research findings into user documentation

## Configuration Files

### Key Files
- **`.mcp.json`**: MCP server configuration for Claude Code
- **`docker-compose.yml`**: Infrastructure service definitions
- **`.env`**: Environment variables (gitignored, use `.env.example`)
- **`knowledge/`**: Private documentation vault (gitignored)
- **`docs/`**: Public documentation and setup guides

### Important Notes
- **Never commit credentials** - use environment variables
- **Keep public docs accessible** - users need setup guides without vault access
- **Maintain documentation sync** - update both public and private docs as needed

---

**Last Updated**: 2025-08-27  
**Version**: 1.0  
**Status**: Production-ready with documented improvement paths

*This document captures learnings from Issues #26, #29, #30 and provides guidance for future Claude Code integration work.*