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
LOCAL_PREFS_FILE="$SCRIPT_DIR/USER_PREFERENCES.md"

# Global paths
GLOBAL_ROOT="$HOME/.opencode"
GLOBAL_AGENTS_DIR="$GLOBAL_ROOT/agents"
GLOBAL_COMMANDS_DIR="$GLOBAL_ROOT/commands"
GLOBAL_SKILLS_DIR="$GLOBAL_ROOT/skills"
GLOBAL_INSTRUCTIONS_DIR="$GLOBAL_ROOT/instructions"
GLOBAL_PREFS_FILE="$GLOBAL_ROOT/USER_PREFERENCES.md"
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

    # Copy and then patch ALL local project paths to global paths
    # Use direct string replacement for known relative patterns
    sed "s|/Users/.*/AGENTS.md|$GLOBAL_ROOT/AGENTS.md|g" "$LOCAL_CONFIG_FILE" | \
      sed "s|\.opencode/agents-archive/|$GLOBAL_ROOT/agents-archive/|g" | \
      sed "s|\.opencode/agents/|$GLOBAL_AGENTS_DIR/|g" | \
      sed "s|{file:commands/|{file:$GLOBAL_COMMANDS_DIR/|g" | \
      sed "s|\"library/|\"$GLOBAL_ROOT/library/|g" > "$GLOBAL_CONFIG_FILE"
    
    # Cleanup any accidentally doubled paths from previous runs
    sed -i '' "s|/Users/himanshusao//Users/himanshusao|/Users/himanshusao|g" "$GLOBAL_CONFIG_FILE"
    
    echo -e "${GREEN}✓ Config synced and patched to $GLOBAL_CONFIG_FILE${NC}"
    echo ""
}

# --- Function: Optimize Skills (Mega-Trim) ---
optimize_skills() {
    GLOBAL_LIBRARY_DIR="$GLOBAL_ROOT/library"
    mkdir -p "$GLOBAL_LIBRARY_DIR"
    
    echo -e "${BLUE}🎯 Optimizing Skills (Mega-Trim)...${NC}"
    
    # Move all folders to Library
    if [ -d "$GLOBAL_SKILLS_DIR" ] && [ "$(ls -A "$GLOBAL_SKILLS_DIR" 2>/dev/null)" ]; then
        mv "$GLOBAL_SKILLS_DIR"/* "$GLOBAL_LIBRARY_DIR/" 2>/dev/null || true
    fi

    # Restore the GLOBAL CORE (Essentials for every agent)
    CORE_SKILLS=(
      "agent-sort"
      "architecture-decision-records"
      "coding-standards"
      "configure-ecc"
      "documentation-lookup"
      "git-workflow"
      "product-lifecycle"
      "strategic-compact"
      "tdd-workflow"
      "verification-loop"
    )

    for skill in "${CORE_SKILLS[@]}"; do
      if [ -d "$GLOBAL_LIBRARY_DIR/$skill" ]; then
        cp -r "$GLOBAL_LIBRARY_DIR/$skill" "$GLOBAL_SKILLS_DIR/"
        echo -e "   ${GREEN}✓ Restored Core:${NC} $skill"
      fi
    done
    
    echo -e "${GREEN}✓ Global skills optimized. 170+ specialized skills moved to Library.${NC}"
    echo ""
}

# Agents: Only chat.md goes to auto-load. All others go to agents-archive.
# This prevents OpenCode from injecting 40 agent manuals (~30K tokens) into every prompt.
echo -e "${BLUE}🔄 Syncing Agents (selective)...${NC}"
AGENTS_ARCHIVE="$GLOBAL_ROOT/agents-archive"
mkdir -p "$AGENTS_ARCHIVE"
mkdir -p "$GLOBAL_AGENTS_DIR"

# Copy chat.md to auto-load (the only agent that should be auto-loaded)
if [ -f "$LOCAL_AGENTS_DIR/chat.md" ]; then
    cp "$LOCAL_AGENTS_DIR/chat.md" "$GLOBAL_AGENTS_DIR/chat.md"
    echo -e "   ${GREEN}✅ Auto-load: chat.md${NC}"
fi

# Archive all other agents to the library
for agent_file in "$LOCAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if [ "$filename" != "chat.md" ] && [ "$filename" != "README.md" ]; then
        cp "$agent_file" "$AGENTS_ARCHIVE/"
        echo -e "   ${BLUE}📦 Archived: $filename${NC}"
    fi
done

# Remove any stale agents from auto-load (except chat.md)
for agent_file in "$GLOBAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if [ "$filename" != "chat.md" ]; then
        rm -f "$agent_file"
    fi
done
echo -e "${GREEN}✓ Agents synced. Only chat.md in auto-load.${NC}"
echo ""

sync_dir "$LOCAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_DIR" "Commands"


# Skills go DIRECTLY to Library (never to auto-load)
# This prevents OpenCode from injecting 33,000 tokens into every prompt
echo -e "${BLUE}🔄 Syncing Skills to Library (not auto-load)...${NC}"
GLOBAL_LIBRARY_DIR="$GLOBAL_ROOT/library"
mkdir -p "$GLOBAL_LIBRARY_DIR"
if [ -d "$LOCAL_SKILLS_DIR" ]; then
    rsync -av --delete --exclude 'README.md' "$LOCAL_SKILLS_DIR/" "$GLOBAL_LIBRARY_DIR/" | grep -v 'sending incremental file list' | grep -v './' | grep -v 'total size is' || true
    echo -e "${GREEN}✓ Skills synced to Library: $GLOBAL_LIBRARY_DIR${NC}"
fi

# Ensure auto-load skills directory is EMPTY
rm -rf "$GLOBAL_SKILLS_DIR"/*  2>/dev/null || true
echo -e "${GREEN}✓ Auto-load skills directory cleared (zero bloat).${NC}"
echo ""

sync_dir "$LOCAL_INSTRUCTIONS_DIR" "$GLOBAL_INSTRUCTIONS_DIR" "Instructions"

# Sync Preferences
if [ -f "$LOCAL_PREFS_FILE" ]; then
    echo -e "${BLUE}🔄 Syncing Preferences...${NC}"
    cp "$LOCAL_PREFS_FILE" "$GLOBAL_PREFS_FILE"
    echo -e "${GREEN}✓ Preferences synced to $GLOBAL_PREFS_FILE${NC}"
    echo ""
fi

sync_config

# Sync Global Source of Truth (AGENTS.md)
LOCAL_AGENTS_DOC="$PROJECT_ROOT/AGENTS.md"
GLOBAL_AGENTS_DOC="$GLOBAL_ROOT/AGENTS.md"
if [ -f "$LOCAL_AGENTS_DOC" ]; then
    echo -e "${BLUE}🔄 Syncing Team Source of Truth (AGENTS.md)...${NC}"
    cp "$LOCAL_AGENTS_DOC" "$GLOBAL_AGENTS_DOC"
    echo -e "${GREEN}✓ Global Source of Truth updated: $GLOBAL_AGENTS_DOC${NC}"
    echo ""
fi

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
echo -e "  ${BLUE}Source of Truth:${NC} $GLOBAL_ROOT/AGENTS.md"
echo -e "  ${BLUE}Backup:${NC}       $BACKUP_ROOT"
echo ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Test with: ${YELLOW}opencode agent list${NC}"
echo -e "  2. Use agents: ${YELLOW}@project-manager help me plan...${NC}"
echo ""
