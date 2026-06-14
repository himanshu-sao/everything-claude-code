#!/bin/bash
# OpenCode Agent Configuration Verification Script
set -euo pipefail

# Acquire verification lock (if flock is available)
VERIFY_LOCK="$HOME/.config/opencode/verify.lock"
exec 200>"$VERIFY_LOCK"
if command -v flock >/dev/null 2>&1; then
  flock -n 200 || { echo "Failed to acquire verify lock" >&2; exit 1; }
fi

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

# Check scripts directory
echo "📜 Scripts:"
EXPECTED_SCRIPTS=("add_task.sh" "update_task.sh" "read_task.sh" "heartbeat.sh" "monitor_tasks.sh" "start_monitor.sh" "stop_monitor.sh")
scripts_ok=0
for script in "${EXPECTED_SCRIPTS[@]}"; do
    if [ -f ".opencode/scripts/$script" ]; then
        if [ -x ".opencode/scripts/$script" ]; then
            echo "  ✅ $script (executable)"
        else
            echo "  ⚠️  $script (not executable)"
            ((scripts_ok++))
        fi
    else
        echo "  ❌ $script missing"
        ((scripts_ok++))
    fi
done
if [ $scripts_ok -eq 0 ]; then
    echo "  ✅ All scripts present and executable"
fi

echo ""

# Check global sync status
echo "🌐 Global Sync (${HOME}/.config/opencode):"
if [ -d "$HOME/.config/opencode/scripts" ]; then
    global_scripts=$(ls -1 "$HOME/.config/opencode/scripts/"*.sh 2>/dev/null | wc -l | tr -d ' ')
    echo "  ✅ Global scripts: $global_scripts files"
else
    echo "  ⚠️  Global scripts directory missing (run sync-agents-global.sh)"
fi
if [ -f "$HOME/.config/opencode/agents/dummy-agent.md" ]; then
    echo "  ✅ Global dummy-agent.md present"
else
    echo "  ⚠️  Global dummy-agent.md missing (run sync-agents-global.sh)"
fi

echo ""

# Summary
echo "📋 Summary:"
echo "  Agent files: $agent_count | JSON agents: $json_agents | Scripts: $(( ${#EXPECTED_SCRIPTS[@]} - scripts_ok ))/${#EXPECTED_SCRIPTS[@]}"
if [ -d "$HOME/.config/opencode/scripts" ]; then
    global_scripts=$(ls -1 "$HOME/.config/opencode/scripts/"*.sh 2>/dev/null | wc -l | tr -d ' ')
    echo "  Global sync: scripts ($global_scripts), dummy-agent: $([ -f "$HOME/.config/opencode/agents/dummy-agent.md" ] && echo 'yes' || echo 'no')"
fi
echo ""

if [ $invalid_count -eq 0 ] && [ "$json_agents" -eq 1 ] && [ $scripts_ok -eq 0 ]; then
    echo "✅ Configuration is correct!"
    echo ""
    echo "Next steps:"
    echo "  1. Run sync-agents-global.sh to sync to global"
    echo "  2. Test with: opencode agents list"
    echo "  3. Try invoking an agent: @planner"
else
    echo "⚠️  Some issues found - review above"
fi

# Made with Bob
