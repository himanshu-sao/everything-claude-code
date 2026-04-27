#!/bin/bash
# OpenCode Agent Configuration Verification Script

echo "🔍 OpenCode Agent Configuration Verification"
echo "=============================================="
echo ""

# Check directory structure
echo "📁 Directory Structure:"
if [ -d ".opencode/agents" ]; then
    echo "  ✅ .opencode/agents/ exists (correct)"
else
    echo "  ❌ .opencode/agents/ missing"
    exit 1
fi

if [ -d ".opencode/agent" ]; then
    echo "  ⚠️  .opencode/agent/ still exists (should be removed)"
fi

echo ""

# Count agent files
echo "📊 Agent Files:"
agent_count=$(ls -1 .opencode/agents/*.md 2>/dev/null | grep -v README.md | wc -l | tr -d ' ')
echo "  Found: $agent_count agent markdown files"
echo ""

# Validate JSON
echo "🔧 JSON Configuration:"
if jq empty .opencode/opencode.json 2>/dev/null; then
    echo "  ✅ opencode.json is valid JSON"
    
    # Count agents in JSON
    json_agents=$(jq -r '.agent | keys | length' .opencode/opencode.json)
    echo "  Agents in JSON: $json_agents (should be 1 - just 'build')"
    
    if [ "$json_agents" -eq 1 ]; then
        echo "  ✅ Correct - only primary agent in JSON"
    else
        echo "  ⚠️  Expected 1 agent in JSON, found $json_agents"
    fi
else
    echo "  ❌ opencode.json is invalid"
    exit 1
fi

echo ""

# Check markdown format
echo "📝 Markdown File Format:"
invalid_count=0
for file in .opencode/agents/*.md; do
    if [ "$(basename "$file")" = "README.md" ]; then
        continue
    fi
    
    if ! head -20 "$file" | grep -q "^name:"; then
        echo "  ❌ Missing 'name:' in $file"
        ((invalid_count++))
    fi
    
    if ! head -20 "$file" | grep -q "^mode:"; then
        echo "  ❌ Missing 'mode:' in $file"
        ((invalid_count++))
    fi
done

if [ $invalid_count -eq 0 ]; then
    echo "  ✅ All agent files have required frontmatter"
else
    echo "  ⚠️  Found $invalid_count issues"
fi

echo ""

# Summary
echo "📋 Summary:"
echo "  Total agents: $agent_count (markdown) + $json_agents (JSON) = $((agent_count + json_agents))"
echo ""

if [ $invalid_count -eq 0 ] && [ "$json_agents" -eq 1 ]; then
    echo "✅ Configuration is correct!"
    echo ""
    echo "Next steps:"
    echo "  1. Test with: opencode agents list"
    echo "  2. Try invoking an agent: @planner"
    echo "  3. Check agent discovery works"
else
    echo "⚠️  Some issues found - review above"
fi

# Made with Bob
