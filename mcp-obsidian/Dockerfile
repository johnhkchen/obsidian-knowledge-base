# Use Python 3.11+ as required by mcp-obsidian
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install uv for faster dependency management
RUN pip install uv

# Copy the entire project
COPY . .

# Install dependencies using uv
RUN uv sync --frozen

# Set environment variables defaults (can be overridden via docker-compose)
ENV OBSIDIAN_HOST=obsidian-app
ENV OBSIDIAN_PORT=27124
ENV OBSIDIAN_PROTOCOL=https
ENV OBSIDIAN_API_KEY=""

# Copy SSL certificate for Obsidian API if available
# The server.py will handle SSL verification via the verify_ssl parameter

# The entry point will be the mcp-obsidian command
CMD ["uv", "run", "mcp-obsidian"]