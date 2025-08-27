`my-little-soda` adds a simple routing and priority system to GitHub issues, so you can use them as a task management layer for CLI coding agents.

## How It Works

The basic loop:

```bash
# launch claude code, give the initial prompt, causes AI agent to run
my-little-soda pop
# ticket is assigned and agent works on the ticket, then calls
my-little-soda bottle
# prompt the agent to finish landing their work and clean up
/clear
```

You can repeat this dev cycle repeatedly to process and merge GitHub issues that are in the repo.

## Setup

```bash
# my-little-soda uses `gh` to do most of the work
gh auth login
# fresh repos: run the `init` command to set up labels, credentials
my-little-soda init
# Create issues on your GitHub repo and they'll be available for agentic completion if they have the `route:ready` label!
```
