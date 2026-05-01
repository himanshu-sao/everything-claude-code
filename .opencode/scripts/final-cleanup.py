import json
import os

config_path = '/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/opencode.json'
with open(config_path, 'r') as f:
    config = json.load(f)

default_tools = {
    'read': True,
    'write': True,
    'edit': True,
    'bash': True,
    'task': True
}

# 1. Global instructions
config['instructions'] = ['/Users/himanshusao/.opencode/AGENTS.md']

# 2. Iterate through every agent
for agent_name, agent_data in config.get('agent', {}).items():
    # Grant tools universallly
    agent_data['tools'] = default_tools
    
    # Fix instruction paths
    new_instr = []
    for instr in agent_data.get('instructions', []):
        if 'AGENTS.md' in instr:
            new_instr.append('/Users/himanshusao/.opencode/AGENTS.md')
        elif instr.endswith('.md'):
            # Standardize agent instructions to the global agents dir
            base = os.path.basename(instr)
            new_instr.append(f'/Users/himanshusao/.opencode/agents/{base}')
        else:
            new_instr.append(instr)
    agent_data['instructions'] = new_instr

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)
