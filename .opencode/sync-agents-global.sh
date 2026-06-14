#!/bin/bash
# OpenCode Global Environment Sync Script
# Syncs local agents, skills, and configuration to global ~/.opencode/ directory

set -euo pipefail

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
GLOBAL_ROOT="$HOME/.config/opencode"
GLOBAL_AGENTS_DIR="$GLOBAL_ROOT/agents"
GLOBAL_COMMANDS_DIR="$GLOBAL_ROOT/commands"
GLOBAL_SKILLS_DIR="$GLOBAL_ROOT/skills"
GLOBAL_INSTRUCTIONS_DIR="$GLOBAL_ROOT/instructions"
GLOBAL_PREFS_FILE="$GLOBAL_ROOT/USER_PREFERENCES.md"
GLOBAL_CONFIG_DIR="$HOME/.config/opencode"
GLOBAL_CONFIG_FILE="$GLOBAL_CONFIG_DIR/opencode.json"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_ROOT="$GLOBAL_ROOT/backups/backup_$TIMESTAMP"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Acquire global sync lock (if flock is available)
SYNC_LOCK="$HOME/.config/opencode/sync.lock"
exec 200>"$SYNC_LOCK"
if command -v flock >/dev/null 2>&1; then
  flock -n 200 || { echo "Failed to acquire sync lock" >&2; exit 1; }
fi

printf "%b\n" "${BLUE}╔════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${BLUE}║   OpenCode Global Environment Sync (Nuclear) ║${NC}"
printf "%b\n" "${BLUE}╚════════════════════════════════════════════════╝${NC}"

# Create directories
mkdir -p "$GLOBAL_AGENTS_DIR"
mkdir -p "$GLOBAL_COMMANDS_DIR"
mkdir -p "$GLOBAL_SKILLS_DIR"
mkdir -p "$GLOBAL_INSTRUCTIONS_DIR"
mkdir -p "$GLOBAL_CONFIG_DIR"
mkdir -p "$GLOBAL_ROOT/scripts"
mkdir -p "$BACKUP_ROOT"

# --- Function: Sync Directory ---
sync_dir() {
    local src="$1"
    local dest="$2"
    local name="$3"
    if [ ! -d "$src" ]; then return; fi
    printf "🔄 Syncing %s...\n" "$name"
    if [ -d "$dest" ] && [ "$(ls -A "$dest" 2>/dev/null)" ]; then
        mkdir -p "$BACKUP_ROOT/$name"
        cp -r "$dest"/* "$BACKUP_ROOT/$name/" 2>/dev/null || true
    fi
    rsync -av --delete --exclude 'README.md' "$src/" "$dest/" | grep -v 'sending incremental file list' | grep -v './' | grep -v 'total size is' || true
}

# --- Function: Sync Config ---
sync_config() {
    if [ ! -f "$LOCAL_CONFIG_FILE" ]; then return; fi
    printf "🔄 Syncing Configuration...\n"
    if [ -f "$GLOBAL_CONFIG_FILE" ]; then
        cp "$GLOBAL_CONFIG_FILE" "$BACKUP_ROOT/opencode.json.bak"
    fi
    cp "$LOCAL_CONFIG_FILE" "$GLOBAL_CONFIG_FILE"
    # Note: Using python patching if available, otherwise just copy.
    if [ -f "$SCRIPT_DIR/scripts/patch-config.py" ]; then
        python3 "$SCRIPT_DIR/scripts/patch-config.py" "$GLOBAL_CONFIG_FILE" "$GLOBAL_ROOT" "$GLOBAL_AGENTS_DIR" "$GLOBAL_COMMANDS_DIR" "$GLOBAL_INSTRUCTIONS_DIR"
    fi
    printf "${GREEN}✓ Config synced and patched.${NC}\n"
}

# --- Selective Agent Sync (The Nuclear Part) ---
printf "🔄 Syncing Agents (Flat Fleet Only)...\n"
AGENTS_ARCHIVE="$GLOBAL_ROOT/agents-archive"
mkdir -p "$AGENTS_ARCHIVE"

# CORE_AGENTS: Excludes orchestrators to prevent deadlocks.
# dummy-agent.md is included for integration testing.
CORE_AGENTS=(
    "chat.md"
    "project-manager.md"
    "architect.md"
    "tech-lead.md"
    "developer.md"
    "qa-engineer.md"
    "tdd-guide.md"
    "ui-engineer.md"
    "agent-supervisor.md"
    "dummy-agent.md"
)

is_core_agent() {
    local filename="$1"
    for core in "${CORE_AGENTS[@]}"; do
        [[ "$filename" == "$core" ]] && return 0
    done
    return 1
}

for agent_file in "$LOCAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if is_core_agent "$filename"; then
        cp "$agent_file" "$GLOBAL_AGENTS_DIR/$filename"
        printf "   ${GREEN}✅ Auto-load:${NC} %s\n" "$filename"
    elif [ "$filename" != "README.md" ] && [ "$filename" != "pipeline-orchestrator.md" ]; then
        cp "$agent_file" "$AGENTS_ARCHIVE/"
        printf "   ${BLUE}📦 Archived:${NC} %s\n" "$filename"
    fi
done

# Cleanup global dir of non-core agents
for agent_file in "$GLOBAL_AGENTS_DIR"/*.md; do
    filename=$(basename "$agent_file")
    if ! is_core_agent "$filename"; then rm -f "$agent_file"; fi
done

sync_dir "$LOCAL_COMMANDS_DIR" "$GLOBAL_COMMANDS_DIR" "Commands"

# Skills: Sync to Library (Mega-Trim)
GLOBAL_LIBRARY_DIR="$GLOBAL_ROOT/library"
mkdir -p "$GLOBAL_LIBRARY_DIR"
if [ -d "$LOCAL_SKILLS_DIR" ]; then
    rsync -av --delete --exclude 'README.md' "$LOCAL_SKILLS_DIR/" "$GLOBAL_LIBRARY_DIR/" | grep -v 'sending' || true
    printf "${GREEN}✓ Skills synced to Library.${NC}\n"
fi
rm -rf "$GLOBAL_SKILLS_DIR"/*  2>/dev/null || true

# Sync scripts
printf "🔄 Syncing Scripts...\n"
LOCAL_SCRIPTS_DIR="$SCRIPT_DIR/scripts"
if [ -d "$LOCAL_SCRIPTS_DIR" ]; then
    rsync -av --delete "$LOCAL_SCRIPTS_DIR/" "$GLOBAL_ROOT/scripts/" | grep -v 'sending' || true
    printf "${GREEN}✓ Scripts synced.${NC}\n"
fi

sync_dir "$LOCAL_INSTRUCTIONS_DIR" "$GLOBAL_INSTRUCTIONS_DIR" "Instructions"
sync_config

# Sync Source of Truth
if [ -f "$PROJECT_ROOT/AGENTS.md" ]; then
    cp "$PROJECT_ROOT/AGENTS.md" "$GLOBAL_ROOT/AGENTS.md"
fi

printf "\n%b\n" "${GREEN}╔════════════════════════════════════════════════╗${NC}"
printf "%b\n" "${GREEN}║   ✓ Golden Sync Complete (Full Logic Restored) ║${NC}"
printf "%b\n" "${GREEN}╚════════════════════════════════════════════════╝${NC}\n"
