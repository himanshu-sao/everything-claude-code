import json
import sys
import os

def empower(config_path):
    if not os.path.exists(config_path):
        print(f"Error: {config_path} not found")
        return

    with open(config_path, 'r') as f:
        config = json.load(f)

    default_tools = {
        'read': True,
        'write': True,
        'edit': True,
        'bash': True,
        'task': True
    }

    print(f"Empowering agents in {config_path}...")
    
    # 1. Patch the global instructions
    config['instructions'] = ['/Users/himanshusao/.opencode/AGENTS.md']

    # 2. Patch every agent
    for agent_name, agent_data in config.get('agent', {}).items():
        # Grant tools
        agent_data['tools'] = default_tools
        
        # Standardize instructions
        new_instr = []
        for instr in agent_data.get('instructions', []):
            if 'AGENTS.md' in instr:
                new_instr.append('/Users/himanshusao/.opencode/AGENTS.md')
            else:
                new_instr.append(instr)
        agent_data['instructions'] = new_instr

    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✓ All agents empowered with full toolkits.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        empower(sys.argv[1])
    else:
        print("Usage: python3 empower-agents.py <path_to_opencode.json>")
