#!/bin/bash
# OpenCode Global Environment Sync Script
# Syncs local agents, skills, and configuration to global ~/.opencode/ directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source paths
LOCAL_AGENTS_DIR="$SCRIPT_DIR/agents"
LOCAL_COMMANDS_DIR="$SCRIPT_DIR/commands"
LOCAL_SKILLS_DIR="$WORKSPACE_ROOT/skills"
LOCAL_INSTRUCTIONS_DIR="$WORKSPACE_ROOT/instructions"
LOCAL_CONFIG_FILE="$SCRIPT_DIR/opencode.json"

# Global paths
GLOBAL_ROOT="$HOME/.opencode"
GLOBAL_AGENTS_DIR="$GLOBAL_ROOT/agents"
GLOBAL_COMMANDS_DIR="$GLOBAL_ROOT/commands"
GLOBAL_SKILLS_DIR="$GLOBAL_ROOT/skills"
GLOBAL_INSTRUCTIONS_DIR="$GLOBAL_ROOT/instructions"
GLOBAL_CONFIG_DIR="$HOME/.config/opencode"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.json"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$GLOBAL_ROOT/backups/backup_$TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   OpenCode Global Environment Sync           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo ""

# Create directories
mkdir -p "$GLOBAL_AGENTS_DIR"
mkdir -p "$GLOBAL_COMMANDS_DIR"
mkdir -p "$GLOBAL_SKILLS_DIR"
mkdir -p "$GLOBAL_INSTRUCTIONS_DIR"
mkdir -p "$GLOBAL_CONFIG_DIR"
mkdir -p "$BACKUP_ROOT"

# --- Function: Sync Directory ---
sync_dir() {
    local src="$1"
    local dest="$2"
    local name="$3"
    
    if [ ! -d "$src" ]; then
        echo -e "${YELLOW}⚠️  Skip: $name directory not found at $src${NC}"
        return
    fi

    echo -e "${BLUE}🔄 Syncing $name...${NC}"
    
    # Backup existing
    if [ -d "$dest" ] && [ "$(ls -A "$dest" 2>/dev/null)" ]; then
        mkdir -p "$BACKUP_ROOT/$name"
        cp -r "$dest"/* "$BACKUP_ROOT/$name/" 2>/dev/null || true
    fi

    # Sync
    rsync -av --delete --exclude 'README.md' "$src/" "$dest/" | grep -v 'sending incremental file list' | grep -v './' | grep -v 'total size is' || true
    echo -e "${GREEN}✓ $name synced to $dest${NC}"
    echo ""
}

# --- Function: Sync Config & Patch Paths ---
sync_config() {
    if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
        echo -e "${RED}✗ Error: Local config not found: $LOCAL_CONFIG_FILE${NC}"
        return
    fi

    echo -e "${BLUE}🔄 Syncing Configuration...${NC}"
    
    if [ -f "$GLOBAL_CONFIG_FILE" ]; then
        cp "$GLOBAL_CONFIG_FILE" "$BACKUP_ROOT/opencode.json.bak"
        echo -e "${YELLOW}💾 Backup of global config created: $BACKUP_ROOT/opencode.json.bak${NC}"
    fi

    # Copy and then patch relative command paths to absolute global paths
    # This ensures commands work in any directory
    cat "$LOCAL_CONFIG_FILE" | sed "s|{file:commands/|{file:$GLOBAL_COMMANDS_DIR/|g" > "$GLOBAL_CONFIG_FILE"
    
    echo -e "${GREEN}✓ Config synced and patched to $GLOBAL_CONFIG_FILE${NC}"
    echo ""
}

# Execute Syncs
sync_dir "$LOCAL_AGENTS_DIR" "$GLOBAL_AGENTS_DIR" "Agents"
sync_dir "$LOCAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_DIR" "Commands"
sync_dir "$LOCAL_SKILLS_DIR" "$GLOBAL_SKILLS_DIR" "Skills"
sync_dir "$LOCAL_INSTRUCTIONS_DIR" "$GLOBAL_INSTRUCTIONS_DIR" "Instructions"
sync_config

# Create/update global README
GLOBAL_README="$GLOBAL_ROOT/README.md"
cat > "$GLOBAL_README" << EOF
# Global OpenCode Environment

This directory contains globally available OpenCode agents, skills, commands, and instructions.

## Location
\`$GLOBAL_ROOT/\`

## Usage
These resources are automatically discovered by OpenCode in any project.

## Syncing
To update your global environment from a project:
\`\`\`bash
cd /path/to/project
.opencode/sync-agents-global.sh
\`\`\`

## Backup
Backups are created in \`$GLOBAL_ROOT/backups/\` before each sync.

---
**Last synced:** $(date)
EOF

echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✓ Global Environment Sync Complete!          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  ${BLUE}Agents:${NC}       $GLOBAL_AGENTS_DIR"
echo -e "  ${BLUE}Commands:${NC}     $GLOBAL_COMMAND_DIR"
echo -e "  ${BLUE}Skills:${NC}       $GLOBAL_SKILLS_DIR"
echo -e "  ${BLUE}Config:${NC}       $GLOBAL_CONFIG_FILE"
echo -e "  ${BLUE}Backup:${NC}       $BACKUP_ROOT"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Test with: ${YELLOW}opencode agent list${NC}"
echo -e "  2. Use agents: ${YELLOW}@planner help me plan...${NC}"
echo ""
