# Obsidian Knowledge Base

Personal knowledge management system with self-hosted CouchDB sync, orchestrated using my-little-soda multi-agent workflow.

## Overview

This repository serves as:
- **Obsidian Vault**: Personal knowledge management and note-taking system
- **Self-hosted Sync**: CouchDB backend for cross-device synchronization  
- **Development Orchestration**: Uses my-little-soda for task management and automation

## Quick Start

1. **Clone and Initialize**
   ```bash
   gh repo clone johnhkchen/obsidian-knowledge-base
   cd obsidian-knowledge-base
   # my-little-soda binary will be provided by release pipeline
   ./tools/my-little-soda init
   ```

2. **Set up Infrastructure**
   - Check GitHub Issues for current tasks
   - Use `./tools/my-little-soda pop` to claim next setup task
   - Follow `docs/obsidian-setup-checklist.md` for complete setup

## Architecture

- **CouchDB**: Self-hosted database for note synchronization
- **Obsidian**: Desktop and mobile clients with local storage
- **LiveSync Plugin**: Encrypted sync between devices and CouchDB
- **Reverse Proxy**: HTTPS termination for mobile compatibility
- **my-little-soda**: Multi-agent task orchestration

## Repository Structure

```
├── README.md                    # This file
├── docs/                        # Setup guides and documentation
│   └── obsidian-setup-checklist.md
├── knowledge/                   # Obsidian vault content
│   ├── projects/               # Project-specific notes
│   ├── tech/                   # Technical knowledge and findings
│   └── resources/              # Reference materials
├── templates/                  # Note templates for Obsidian
├── tools/                      # Development and maintenance tools
└── .obsidian/                  # Obsidian configuration (created by app)
```

## Workflow

1. **Issues as Tasks**: GitHub Issues drive all setup and maintenance work
2. **Agent Coordination**: my-little-soda assigns tasks to agents (branches)
3. **Automated Setup**: Infrastructure provisioning through orchestrated tasks
4. **Knowledge Capture**: Document learnings and processes in the vault

## Getting Started

The setup process is orchestrated through GitHub Issues and my-little-soda:

```bash
# Check current status
./tools/my-little-soda status

# See what work is available  
./tools/my-little-soda peek

# Claim and start working on next task
./tools/my-little-soda pop

# Complete work and create PR
./tools/my-little-soda bottle
```

## Documentation

- **Setup Guide**: `docs/obsidian-setup-checklist.md` - Complete CouchDB + Obsidian setup
- **Testing Report**: `knowledge/tech/my-little-soda-testing-report.md` - Tool evaluation findings
- **Architecture**: This README and documentation in `knowledge/tech/`

## Status

✅ **Setup Complete**  
Infrastructure deployed and ready for production use. Cross-device sync operational via secure Tailscale network.

### Current Configuration
- ✅ **CouchDB Database**: Running and healthy
- ✅ **Nginx HTTPS Proxy**: Operational on port 3880  
- ✅ **Tailscale VPN**: Connected (`nuc-01-debian.emerald-wage.ts.net`)
- ✅ **Mobile Access**: Ready via `https://nuc-01-debian.emerald-wage.ts.net:3880`
- ✅ **Documentation**: Complete setup and troubleshooting guides
- ✅ **MCP Integration**: Claude Code connected via `obsidian-semantic-mcp` plugin

### Quick Access
- **Desktop Setup**: Open this folder in Obsidian, configure LiveSync plugin
- **Mobile Setup**: Follow `docs/mobile-setup-guide.md`  
- **Admin Access**: CouchDB admin at `http://localhost:5984/_utils`
- **System Status**: See `docs/final-setup-status.md`