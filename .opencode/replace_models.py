import os
import glob

# Mappings
replacements = {
    "ollama/mistral:7b": "ollama/llama3.2:3b",
    "ollama/deepseek-coder-v2:32b": "ollama/codestral:latest",
    "ollama/deepseek-coder-v2": "ollama/codestral:latest"
}

# Process agents
agents_dir = ".opencode/agents"
for filepath in glob.glob(os.path.join(agents_dir, "*.md")):
    with open(filepath, "r") as f:
        content = f.read()
    
    modified = False
    for old, new in replacements.items():
        if old in content:
            content = content.replace(old, new)
            modified = True
            
    if modified:
        with open(filepath, "w") as f:
            f.write(content)
        print(f"Updated {filepath}")

# Process opencode.json
config_path = ".opencode/opencode.json"
with open(config_path, "r") as f:
    config_content = f.read()

if "ollama/deepseek-coder:1.3b" in config_content:
    config_content = config_content.replace("ollama/deepseek-coder:1.3b", "ollama/llama3.2:3b")
    with open(config_path, "w") as f:
        f.write(config_content)
    print(f"Updated {config_path}")

print("Replacement complete.")
