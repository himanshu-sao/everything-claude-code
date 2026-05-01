import json
import os

config_path = '/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/opencode.json'
with open(config_path, 'r') as f:
    config = json.load(f)

# The "Lean & Mean" Trio
LOGIC_MODEL = "ollama/gemma4:e4b"      # Orchestration & Strategy
CODING_MODEL = "ollama/deepseek-coder-v2" # Implementation & Review
SPEED_MODEL = "ollama/llama3.2:3b"      # Triage & Docs

# Global defaults
config['model'] = LOGIC_MODEL
config['small_model'] = SPEED_MODEL

# Define model groups
logic_agents = [
    "tech-lead", "architect", "project-manager", "ba-agent", 
    "research-dispatcher", "system-auditor", "api-architect"
]

coding_agents = [
    "developer", "python-agent", "java-agent", "go-agent", 
    "ui-engineer", "code-reviewer", "tdd-guide", "build", 
    "build-error-resolver", "e2e-runner", "refactor-cleaner", 
    "database-reviewer", "security-reviewer"
]

speed_agents = [
    "chat", "dispatcher", "data-dispatcher", "infra-dispatcher", 
    "excel-dispatcher", "doc-updater", "analyzer-agent", 
    "ecosystem-optimizer", "deployment-agent"
]

for agent_name, agent_data in config.get('agent', {}).items():
    if agent_name in logic_agents:
        agent_data['model'] = LOGIC_MODEL
    elif agent_name in coding_agents:
        agent_data['model'] = CODING_MODEL
    elif agent_name in speed_agents:
        agent_data['model'] = SPEED_MODEL
    else:
        # Fallback to speed model for unknown agents to save memory
        agent_data['model'] = SPEED_MODEL

with open(config_path, 'w') as f:
    json.dump(config, f, indent=2)

print(f"✓ Ecosystem consolidated into 3 models: {LOGIC_MODEL}, {CODING_MODEL}, {SPEED_MODEL}")
