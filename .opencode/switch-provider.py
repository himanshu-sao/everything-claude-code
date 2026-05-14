import json
import os
import sys
import glob

# Configuration
CONFIG_PATH = ".opencode/opencode.json"
PROFILES_PATH = ".opencode/profiles.json"
AGENTS_DIR = ".opencode/agents"

# Tier Assignments
TIER_MAPPING = {
    "developer": "power",
    "architect": "balanced",
    "project-manager": "balanced",
    "chat": "fast",
    "tech-lead": "fast",
    "pipeline-orchestrator": "balanced"
}

def load_profiles():
    with open(PROFILES_PATH, 'r') as f:
        return json.load(f)

def update_json_config(profile_name, profile_data):
    with open(CONFIG_PATH, 'r') as f:
        config = json.load(f)

    # Update root models
    config["model"] = profile_data["model"]
    config["small_model"] = profile_data["small_model"]

    # Update specific agents in JSON
    if "agent" in config:
        for agent_name, tier in TIER_MAPPING.items():
            if agent_name in config["agent"]:
                config["agent"][agent_name]["model"] = profile_data["tiers"][tier]

    with open(CONFIG_PATH, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Updated {CONFIG_PATH} with profile: {profile_name}")

def update_agent_files(profile_data):
    count = 0
    for filepath in glob.glob(os.path.join(AGENTS_DIR, "*.md")):
        agent_name = os.path.basename(filepath).replace(".md", "")
        
        # Determine tier
        tier = TIER_MAPPING.get(agent_name, "fast") # Default to fast for unknown agents
        new_model = profile_data["tiers"][tier]

        with open(filepath, 'r') as f:
            lines = f.readlines()

        modified = False
        new_lines = []
        for line in lines:
            if line.startswith("model: "):
                new_lines.append(f"model: {new_model}\n")
                modified = True
            else:
                new_lines.append(line)

        if modified:
            with open(filepath, 'w') as f:
                f.writelines(new_lines)
            count += 1
            # print(f"  - Updated {agent_name} -> {new_model}")

    print(f"✅ Updated {count} agent markdown files in {AGENTS_DIR}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 switch-provider.py [nvidia|ollama-local]")
        sys.exit(1)

    target = sys.argv[1].lower()
    profiles = load_profiles()

    if target not in profiles:
        print(f"Error: Profile '{target}' not found in profiles.json")
        sys.exit(1)

    profile_data = profiles[target]
    print(f"🔄 Switching to {profile_data['name']}...")

    update_json_config(target, profile_data)
    update_agent_files(profile_data)
    
    print(f"\n✨ Switch complete! Run '.opencode/sync-agents-global.sh' to apply changes globally.")

if __name__ == "__main__":
    main()
