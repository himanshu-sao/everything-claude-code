#!/bin/bash
# OpenCode Global Agent Sync Script
# Syncs local agents to global ~/.opencode/agents/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_AGENTS_DIR="$SCRIPT_DIR/agents"
GLOBAL_AGENTS_DIR="$HOME/.opencode/agents"
BACKUP_DIR="$HOME/.opencode/agents.backup.$(date +%Y%m%d_%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OpenCode Global Agent Sync                  ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo ""

# Check if local agents directory exists
if [ ! -d "$LOCAL_AGENTS_DIR" ]; then
    echo -e "${RED}✗ Error: Local agents directory not found: $LOCAL_AGENTS_DIR${NC}"
    exit 1
fi

# Count local agents (excluding README)
LOCAL_COUNT=$(find "$LOCAL_AGENTS_DIR" -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
echo -e "${BLUE}📁 Local agents directory:${NC} $LOCAL_AGENTS_DIR"
echo -e "${BLUE}📊 Local agents found:${NC} $LOCAL_COUNT"
echo ""

# Create global directory if it doesn't exist
if [ ! -d "$GLOBAL_AGENTS_DIR" ]; then
    echo -e "${YELLOW}📂 Creating global agents directory...${NC}"
    mkdir -p "$GLOBAL_AGENTS_DIR"
    echo -e "${GREEN}✓ Created: $GLOBAL_AGENTS_DIR${NC}"
else
    echo -e "${GREEN}✓ Global agents directory exists:${NC} $GLOBAL_AGENTS_DIR"
    
    # Count existing global agents
    if [ "$(ls -A $GLOBAL_AGENTS_DIR/*.md 2>/dev/null)" ]; then
        GLOBAL_COUNT=$(find "$GLOBAL_AGENTS_DIR" -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
        echo -e "${BLUE}📊 Existing global agents:${NC} $GLOBAL_COUNT"
        
        # Create backup
        echo -e "${YELLOW}💾 Creating backup...${NC}"
        mkdir -p "$BACKUP_DIR"
        cp -r "$GLOBAL_AGENTS_DIR"/*.md "$BACKUP_DIR/" 2>/dev/null || true
        echo -e "${GREEN}✓ Backup created:${NC} $BACKUP_DIR"
    fi
fi

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}🔄 Syncing agents...${NC}"
echo ""

# Sync agents
SYNCED=0
SKIPPED=0
UPDATED=0

for agent_file in "$LOCAL_AGENTS_DIR"/*.md; do
    # Skip README
    if [ "$(basename "$agent_file")" = "README.md" ]; then
        continue
    fi
    
    agent_name=$(basename "$agent_file")
    target_file="$GLOBAL_AGENTS_DIR/$agent_name"
    
    # Check if agent already exists globally
    if [ -f "$target_file" ]; then
        # Compare files
        if cmp -s "$agent_file" "$target_file"; then
            echo -e "${BLUE}⊙${NC} $agent_name ${BLUE}(unchanged)${NC}"
            ((SKIPPED++))
        else
            # Files differ - update
            cp "$agent_file" "$target_file"
            echo -e "${YELLOW}↻${NC} $agent_name ${YELLOW}(updated)${NC}"
            ((UPDATED++))
        fi
    else
        # New agent
        cp "$agent_file" "$target_file"
        echo -e "${GREEN}✓${NC} $agent_name ${GREEN}(new)${NC}"
        ((SYNCED++))
    fi
done

echo ""
echo -e "${BLUE}════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Sync complete!${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  ${GREEN}New agents:${NC}       $SYNCED"
echo -e "  ${YELLOW}Updated agents:${NC}   $UPDATED"
echo -e "  ${BLUE}Unchanged agents:${NC} $SKIPPED"
echo -e "  ${BLUE}Total synced:${NC}     $((SYNCED + UPDATED + SKIPPED))"
echo ""

# Create/update global README
GLOBAL_README="$GLOBAL_AGENTS_DIR/README.md"
cat > "$GLOBAL_README" << 'EOF'
# Global OpenCode Agents

This directory contains globally available OpenCode agents that can be used across all projects.

## Location
`~/.opencode/agents/`

## Usage

These agents are automatically discovered by OpenCode in any project:

```bash
# List all agents (including global)
opencode agent list

# Use a global agent
@planner help me plan a feature
@code-reviewer review my code
```

## Syncing from Projects

To sync agents from a project to this global directory:

```bash
cd /path/to/your/project
.opencode/sync-agents-global.sh
```

## Agent Priority

When an agent exists in both locations:
1. **Project-level** (`.opencode/agents/`) - Takes precedence
2. **Global-level** (`~/.opencode/agents/`) - Used as fallback

## Managing Global Agents

### Add a new global agent
Create a new `.md` file in this directory with proper frontmatter.

### Remove a global agent
Delete the `.md` file from this directory.

### Update a global agent
Edit the `.md` file directly, or sync from a project.

## Backup

Backups are automatically created in `~/.opencode/agents.backup.TIMESTAMP/` when syncing.

---

**Last synced:** $(date)
**Total agents:** $(find "$GLOBAL_AGENTS_DIR" -name "*.md" ! -name "README.md" | wc -l | tr -d ' ')
EOF

echo -e "${GREEN}✓ Global README updated${NC}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
    echo -e "${BLUE}💾 Backup location:${NC} $BACKUP_DIR"
fi

echo -e "${BLUE}🌍 Global agents directory:${NC} $GLOBAL_AGENTS_DIR"
echo ""
echo -e "${GREEN}✓ All agents are now available globally!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Test with: ${YELLOW}opencode agent list${NC}"
echo -e "  2. Use agents: ${YELLOW}@planner help me plan...${NC}"
echo -e "  3. View global agents: ${YELLOW}ls -la ~/.opencode/agents/${NC}"
echo ""

# Made with Bob
