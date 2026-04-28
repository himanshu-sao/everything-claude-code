#!/bin/bash

# Define paths
GLOBAL_SKILLS="$HOME/.opencode/skills"
GLOBAL_LIBRARY="$HOME/.opencode/library"

echo "🔄 Initializing OpenCode Skill Optimization..."

# 1. Create the Library
mkdir -p "$GLOBAL_LIBRARY"

# 2. Move everything to Library
echo "📦 Moving all 184 skills to the Library..."
mv "$GLOBAL_SKILLS"/* "$GLOBAL_LIBRARY/" 2>/dev/null

# 3. Restore the GLOBAL CORE (Essentials for every agent)
echo "🎯 Restoring Global Core Skills..."
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
  if [ -d "$GLOBAL_LIBRARY/$skill" ]; then
    cp -r "$GLOBAL_LIBRARY/$skill" "$GLOBAL_SKILLS/"
    echo "   ✓ Restored: $skill"
  fi
done

echo "✅ Optimization Complete! Your global system prompt is now 90% lighter."
echo "🚀 Next step: Run the sync script to update your agents."
