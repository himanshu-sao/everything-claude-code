#!/bin/bash
echo "🔄 Updating all OpenCode MCP servers to latest versions..."

npx --yes bob-pr-reviewer@latest --help > /dev/null
npx --yes @upstash/context7-mcp@latest --help > /dev/null
npx --yes @modelcontextprotocol/server-github@latest --help > /dev/null
npx --yes @modelcontextprotocol/server-memory@latest --help > /dev/null
npx --yes @playwright/mcp@latest --help > /dev/null
npx --yes @modelcontextprotocol/server-sequential-thinking@latest --help > /dev/null
npx --yes token-optimizer-mcp@latest --help > /dev/null

echo "✅ All MCPs updated in your local cache. Your next sessions will be instant!"
