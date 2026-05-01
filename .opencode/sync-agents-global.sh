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
PROJECT_ROOT="$WORKSPACE_ROOT"

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

printf "%b\n" "${BLUE}╔════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${BLUE}║   OpenCode Global Environment Sync           ║${NC}"
printf "%b\n" "${BLUE}╚════════════════════════════════════════════════╝${NC}"
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
        printf "%b\n" "${YELLOW}⚠️  Skip: $name directory not found at $src${NC}"
        return
    fi

    printf "%b\n" "${BLUE}🔄 Syncing $name...${NC}"
    
    # Backup existing
    if [ -d "$dest" ] && [ "$(ls -A "$dest" 2>/dev/null)" ]; then
        mkdir -p "$BACKUP_ROOT/$name"
        cp -r "$dest"/* "$BACKUP_ROOT/$name/" 2>/dev/null || true
    fi

    # Sync
    rsync -av --delete --exclude 'README.md' "$src/" "$dest/" | grep -v 'sending incremental file list' | grep -v './' | grep -v 'total size is' || true
    printf "%b\n" "${GREEN}✓ $name synced to $dest${NC}"
    echo ""
}

# --- Function: Sync Config & Patch Paths ---
sync_config() {
    if [ ! -f "$LOCAL_CONFIG_FILE" ]; then
        printf "%b\n" "${RED}✗ Error: Local config not found: $LOCAL_CONFIG_FILE${NC}"
        return
    fi

    printf "%b\n" "${BLUE}🔄 Syncing Configuration...${NC}"
    
    if [ -f "$GLOBAL_CONFIG_FILE" ]; then
        cp "$GLOBAL_CONFIG_FILE" "$BACKUP_ROOT/opencode.json.bak"
        printf "%b\n" "${YELLOW}💾 Backup of global config created: $BACKUP_ROOT/opencode.json.bak${NC}"
    fi

    # Use the new python patching script to avoid path-doubling and other regex bugs
    cp "$LOCAL_CONFIG_FILE" "$GLOBAL_CONFIG_FILE"
    python3 "$SCRIPT_DIR/scripts/patch-config.py" "$GLOBAL_CONFIG_FILE" "$GLOBAL_ROOT" "$GLOBAL_AGENTS_DIR" "$GLOBAL_COMMANDS_DIR"
    
    printf "%b\n" "${GREEN}✓ Config synced and patched to $GLOBAL_CONFIG_FILE${NC}"
    echo ""
}

# --- Function: Optimize Skills (Mega-Trim) ---
optimize_skills() {
    GLOBAL_LIBRARY_DIR="$GLOBAL_ROOT/library"
    mkdir -p "$GLOBAL_LIBRARY_DIR"
    
    printf "%b\n" "${BLUE}🎯 Optimizing Skills (Mega-Trim)...${NC}"
    
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
        printf "%b\n" "   ${GREEN}✓ Restored Core:${NC} $skill"
      fi
    done
    
    printf "%b\n" "${GREEN}✓ Global skills optimized. 170+ specialized skills moved to Library.${NC}"
    echo ""
}

# Agents: Define core fleet for auto-load. Others go to agents-archive.
# This keeps the system fast while maintaining the mission-critical orchestrators.
printf "%b\n" "${BLUE}🔄 Syncing Agents (selective)...${NC}"
AGENTS_ARCHIVE="$GLOBAL_ROOT/agents-archive"
mkdir -p "$AGENTS_ARCHIVE"
mkdir -p "$GLOBAL_AGENTS_DIR"

CORE_AGENTS=(
    "chat.md"
    "tech-lead.md"
    "project-manager.md"
    "architect.md"
    "developer.md"
    "qa-engineer.md"
    "tdd-guide.md"
)

is_core_agent() {
    local filename="$1"
    for core in "${CORE_AGENTS[@]}"; do
        [[ "$filename" == "$core" ]] && return 0
    done
    return 1
}

# Sync Local to Global (Active or Archive)
for agent_file in "$LOCAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if is_core_agent "$filename"; then
        cp "$agent_file" "$GLOBAL_AGENTS_DIR/$filename"
        printf "%b\n" "   ${GREEN}✅ Auto-load:${NC} $filename"
    elif [ "$filename" != "README.md" ]; then
        cp "$agent_file" "$AGENTS_ARCHIVE/"
        printf "%b\n" "   ${BLUE}📦 Archived:${NC} $filename"
    fi
done

# Remove any stale agents from auto-load that are NOT in the core fleet
for agent_file in "$GLOBAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if ! is_core_agent "$filename"; then
        rm -f "$agent_file"
    fi
done
printf "%b\n" "${GREEN}✓ Agents synced. Core fleet is active in auto-load.${NC}"
echo ""

sync_dir "$LOCAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_DIR" "Commands"


# Skills go DIRECTLY to Library (never to auto-load)
# This prevents OpenCode from injecting 33,000 tokens into every prompt
printf "%b\n" "${BLUE}🔄 Syncing Skills to Library (not auto-load)...${NC}"
GLOBAL_LIBRARY_DIR="$GLOBAL_ROOT/library"
mkdir -p "$GLOBAL_LIBRARY_DIR"
if [ -d "$LOCAL_SKILLS_DIR" ]; then
    rsync -av --delete --exclude 'README.md' "$LOCAL_SKILLS_DIR/" "$GLOBAL_LIBRARY_DIR/" | grep -v 'sending incremental file list' | grep -v './' | grep -v 'total size is' || true
    printf "%b\n" "${GREEN}✓ Skills synced to Library: $GLOBAL_LIBRARY_DIR${NC}"
fi

# Ensure auto-load skills directory is EMPTY
rm -rf "$GLOBAL_SKILLS_DIR"/*  2>/dev/null || true
printf "%b\n" "${GREEN}✓ Auto-load skills directory cleared (zero bloat).${NC}"
echo ""

sync_dir "$LOCAL_INSTRUCTIONS_DIR" "$GLOBAL_INSTRUCTIONS_DIR" "Instructions"

# Sync Preferences
if [ -f "$LOCAL_PREFS_FILE" ]; then
    printf "%b\n" "${BLUE}🔄 Syncing Preferences...${NC}"
    cp "$LOCAL_PREFS_FILE" "$GLOBAL_PREFS_FILE"
    printf "%b\n" "${GREEN}✓ Preferences synced to $GLOBAL_PREFS_FILE${NC}"
    echo ""
fi

sync_config

# Sync Global Source of Truth (AGENTS.md)
LOCAL_AGENTS_DOC="$PROJECT_ROOT/AGENTS.md"
GLOBAL_AGENTS_DOC="$GLOBAL_ROOT/AGENTS.md"
if [ -f "$LOCAL_AGENTS_DOC" ]; then
    printf "%b\n" "${BLUE}🔄 Syncing Team Source of Truth (AGENTS.md)...${NC}"
    cp "$LOCAL_AGENTS_DOC" "$GLOBAL_AGENTS_DOC"
    printf "%b\n" "${GREEN}✓ Global Source of Truth updated: $GLOBAL_AGENTS_DOC${NC}"
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

printf "%b\n" "${GREEN}╔════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${GREEN}║   ✓ Global Environment Sync Complete!          ║${NC}"
printf "%b\n" "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo ""
printf "%b\n" "${BLUE}📊 Summary:${NC}"
printf "%b\n" "  ${BLUE}Agents:${NC}       $GLOBAL_AGENTS_DIR"
printf "%b\n" "  ${BLUE}Commands:${NC}     $GLOBAL_COMMAND_DIR"
printf "%b\n" "  ${BLUE}Skills:${NC}       $GLOBAL_SKILLS_DIR"
printf "%b\n" "  ${BLUE}Config:${NC}       $GLOBAL_CONFIG_FILE"
printf "%b\n" "  ${BLUE}Source of Truth:${NC} $GLOBAL_ROOT/AGENTS.md"
printf "%b\n" "  ${BLUE}Backup:${NC}       $BACKUP_ROOT"
echo ""
printf "%b\n" "${GREEN}Next steps:${NC}"
printf "%b\n" "  1. Test with: ${YELLOW}opencode agent list${NC}"
printf "%b\n" "  2. Use agents: ${YELLOW}@project-manager help me plan...${NC}"
echo ""
