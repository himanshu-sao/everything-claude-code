#!/bin/bash
# Slim the global agents directory to ONLY the default agent (chat.md)
# Other agents are still registered in opencode.json and can be called on-demand

GLOBAL_AGENTS="$HOME/.opencode/agents"
GLOBAL_LIBRARY="$HOME/.opencode/library/agents-archive"

echo "🔧 Slimming Agents Directory..."

mkdir -p "$GLOBAL_LIBRARY"

# Keep ONLY chat.md in the agents directory
for agent_file in "$GLOBAL_AGENTS"/*.md; do
    filename=$(basename "$agent_file")
    if [ "$filename" = "chat.md" ]; then
        echo "   ✅ KEPT: $filename (default agent)"
    elif [ "$filename" = "README.md" ]; then
        rm -f "$agent_file"
        echo "   🗑️  Removed: $filename"
    else
        mv "$agent_file" "$GLOBAL_LIBRARY/"
        echo "   📦 Archived: $filename"
    fi
done

echo ""
echo "📊 Agents in auto-load: $(ls -1 "$GLOBAL_AGENTS"/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo "📚 Agents in archive:   $(ls -1 "$GLOBAL_LIBRARY"/*.md 2>/dev/null | wc -l | tr -d ' ')"
echo ""

# Show the size reduction
echo "📏 Agents directory size: $(du -sh "$GLOBAL_AGENTS" | cut -f1)"
echo "🚀 Should be ~4KB (just chat.md)"
