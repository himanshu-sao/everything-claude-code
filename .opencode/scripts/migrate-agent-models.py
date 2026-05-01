import os
import re

agents_dir = '/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/agents'

coding_agents = [
    'developer.md', 'ui-engineer.md', 'python-agent.md', 'java-agent.md', 
    'go-agent.md', 'cpp-agent.md', 'rust-agent.md', 'maintainer.md', 
    'ecosystem-optimizer.md', 'build-resolver.md', 'refactor-cleaner.md'
]

# Reasoning/Leadership agents
reasoning_agents = [
    'architect.md', 'project-manager.md', 'tech-lead.md', 'agent-supervisor.md',
    'dispatcher.md', 'qa-engineer.md', 'security-reviewer.md', 'code-reviewer.md',
    'chat.md'
]

for filename in os.listdir(agents_dir):
    if not filename.endswith('.md') or filename == 'README.md':
        continue
    
    path = os.path.join(agents_dir, filename)
    with open(path, 'r') as f:
        content = f.read()
    
    # Check if we should switch to Codestral
    if filename in coding_agents:
        new_content = re.sub(r'model: ollama/.*', 'model: ollama/codestral:latest', content)
        if new_content != content:
            with open(path, 'w') as f:
                f.write(new_content)
            print(f"✅ Updated {filename} to codestral:latest")
    elif filename in reasoning_agents:
         new_content = re.sub(r'model: ollama/.*', 'model: ollama/gemma4:e4b', content)
         if new_content != content:
            with open(path, 'w') as f:
                f.write(new_content)
            print(f"✅ Updated {filename} to gemma4:e4b")

print("Migration complete.")
