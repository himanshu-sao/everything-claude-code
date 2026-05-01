#!/bin/bash
# OpenCode Nexus Verification & Comparison
# Validates local config and compares with global ~/.opencode/

GLOBAL_ROOT="$HOME/.opencode"
LOCAL_ROOT=".opencode"

echo "🔍 Nexus System Verification"
echo "=============================================="

# 1. Compare Files with Global
echo "📊 Global Comparison:"
FILES_TO_CHECK=("opencode.json" "agents/chat.md" "agents/tech-lead.md" "AGENTS.md")

for file in "${FILES_TO_CHECK[@]}"; do
    if [[ "$file" == "AGENTS.md" ]]; then
        LOCAL_PATH="$file"
        GLOBAL_PATH="$GLOBAL_ROOT/$file"
    elif [[ "$file" == "opencode.json" ]]; then
        LOCAL_PATH="$LOCAL_ROOT/$file"
        GLOBAL_PATH="$HOME/.config/opencode/opencode.json"
    else
        LOCAL_PATH="$LOCAL_ROOT/$file"
        GLOBAL_PATH="$GLOBAL_ROOT/agents/${file#agents/}"
    fi

    if [ -f "$GLOBAL_PATH" ]; then
        if diff -q "$LOCAL_PATH" "$GLOBAL_PATH" >/dev/null; then
            echo "  ✅ $file: Matches Global"
        else
            echo "  ⚠️  $file: DIVERTED (Local differs from Global)"
        fi
    else
        echo "  ❌ $file: Missing from Global"
    fi
done

echo ""

# 2. Validate Local JSON
echo "🔧 JSON Configuration:"
if jq empty "$LOCAL_ROOT/opencode.json" 2>/dev/null; then
    json_agents=$(jq -r '.agent | keys | length' "$LOCAL_ROOT/opencode.json")
    echo "  ✅ opencode.json is valid (Agents: $json_agents)"
else
    echo "  ❌ opencode.json is INVALID"
fi

echo ""

# 3. Mode/Model Check
echo "🛡️  Nexus Guard Check:"
for file in "$LOCAL_ROOT"/agents/*.md; do
    [ -e "$file" ] || continue
    name=$(basename "$file")
    if head -n 5 "$file" | grep -q "mode: primary" && [[ "$name" != "chat.md" ]]; then
        echo "  ⚠️  WARNING: $name is set to 'primary'. Only 'chat' should be primary."
    fi
done

echo ""
echo "✅ Verification complete. Run '.opencode/sync-agents-global.sh' to sync diversions."
