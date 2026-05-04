import json
import sys
import os
import re

def patch_config(config_path, global_root, global_agents_dir, global_commands_dir, global_instructions_dir):
    if not os.path.exists(config_path):
        print(f"Error: {config_path} not found")
        return

    with open(config_path, 'r') as f:
        # Load as string first to do regex replacements on paths
        content = f.read()

    # Regex to catch both relative and absolute paths to .opencode
    # Matches: "/Users/.../.opencode/agents/" or ".opencode/agents/" or "agents/"
    content = re.sub(r'\"(?:[^"]*/)?(?:\.opencode/)?agents/([^"]*)\"', f'"{global_agents_dir}/\\1"', content)
    content = re.sub(r'\"(?:[^"]*/)?(?:\.opencode/)?agents-archive/([^"]*)\"', f'"{global_root}/agents-archive/\\1"', content)
    content = re.sub(r'\"(?:[^"]*/)?(?:\.opencode/)?AGENTS.md\"', f'"{global_root}/AGENTS.md"', content)
    content = re.sub(r'\{file:(?:[^}]*/)?(?:\.opencode/)?commands/([^}]*)\}', f'{{file:{global_commands_dir}/\\1}}', content)
    
    # Patch instructions paths
    content = re.sub(r'\"(?:[^"]*/)?(?:\.opencode/)?instructions/([^"]*)\"', f'"{global_instructions_dir}/\\1"', content)

    # Parse back to JSON to do structural fixes
    config = json.loads(content)
    
    # Grant tools to all agents if not present
    default_tools = {
        'read': True,
        'write': True,
        'edit': True,
        'bash': True,
        'task': True
    }
    
    for agent_name, agent_data in config.get('agent', {}).items():
        if 'tools' not in agent_data:
            agent_data['tools'] = default_tools
            
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)

if __name__ == "__main__":
    if len(sys.argv) > 5:
        patch_config(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5])
    else:
        print("Usage: python3 patch-config.py <path> <global_root> <global_agents_dir> <global_commands_dir> <global_instructions_dir>")
