import os

# Mappings for specific agents to use appropriate models
agent_model_mapping = {
    # Coding and Reviewing -> codestral:latest
    "code-reviewer.md": "ollama/codestral:latest",
    "security-reviewer.md": "ollama/codestral:latest",
    "database-reviewer.md": "ollama/codestral:latest",
    "python-agent.md": "ollama/codestral:latest",
    "java-agent.md": "ollama/codestral:latest",
    "go-agent.md": "ollama/codestral:latest",
    "test-agent.md": "ollama/codestral:latest",
    
    # Analytical / Architectural -> gemma4:e4b
    "api-architect.md": "ollama/gemma4:e4b",
    "quality-gate.md": "ollama/gemma4:e4b",
    "analyzer-agent.md": "ollama/gemma4:e4b",
    "story-writer.md": "ollama/gemma4:e4b"
}

agents_dir = ".opencode/agents"

for filename, target_model in agent_model_mapping.items():
    filepath = os.path.join(agents_dir, filename)
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            content = f.read()
        
        # Replace the incorrectly assigned llama3.2:3b model with the target model
        if "ollama/llama3.2:3b" in content:
            new_content = content.replace("ollama/llama3.2:3b", target_model)
            with open(filepath, "w") as f:
                f.write(new_content)
            print(f"Fixed {filename} -> {target_model}")
        else:
            print(f"Skipped {filename} (llama3.2:3b not found)")
    else:
        print(f"File not found: {filename}")

print("Correction complete.")
