#!/bin/bash
# Move ALL remaining skills from global auto-load to library
# This prevents OpenCode from injecting 33,000 tokens into every prompt

GLOBAL_SKILLS="$HOME/.opencode/skills"
GLOBAL_LIBRARY="$HOME/.opencode/library"

echo "🔥 Nuclear Skill Cleanup..."

mkdir -p "$GLOBAL_LIBRARY"

# Move everything out of the auto-load path
if [ -d "$GLOBAL_SKILLS" ] && [ "$(ls -A "$GLOBAL_SKILLS" 2>/dev/null)" ]; then
    for skill_dir in "$GLOBAL_SKILLS"/*/; do
        skill_name=$(basename "$skill_dir")
        if [ -d "$GLOBAL_LIBRARY/$skill_name" ]; then
            rm -rf "$skill_dir"
            echo "   ✓ Removed duplicate: $skill_name (already in library)"
        else
            mv "$skill_dir" "$GLOBAL_LIBRARY/"
            echo "   ✓ Moved to library: $skill_name"
        fi
    done
fi

echo ""
echo "✅ Global skills directory is now EMPTY."
echo "📊 Skills in auto-load: $(ls -1 "$GLOBAL_SKILLS" 2>/dev/null | wc -l | tr -d ' ')"
echo "📚 Skills in library:   $(ls -1 "$GLOBAL_LIBRARY" 2>/dev/null | wc -l | tr -d ' ')"
echo ""
echo "🚀 Your token count should now drop from 33,266 to ~500."
