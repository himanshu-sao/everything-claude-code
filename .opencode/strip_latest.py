import os
import glob

# Mappings to fix codestral model names
replacements = {
    "ollama/codestral:latest": "ollama/codestral"
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

modified_config = False
for old, new in replacements.items():
    if old in config_content:
        config_content = config_content.replace(old, new)
        modified_config = True

if modified_config:
    with open(config_path, "w") as f:
        f.write(config_content)
    print(f"Updated {config_path}")

print("Replacement of codestral:latest -> codestral complete.")
