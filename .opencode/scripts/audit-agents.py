import os
import yaml

agents_dir = '/Users/himanshusao/Work/src/extra/himanshu-sao/everything-claude-code/.opencode/agents'

for filename in os.listdir(agents_dir):
    if not filename.endswith('.md') or filename == 'README.md':
        continue
    
    path = os.path.join(agents_dir, filename)
    with open(path, 'r') as f:
        content = f.read()
    
    if content.startswith('---'):
        try:
            # Check if it has the required fields
            parts = content.split('---', 2)
            if len(parts) >= 3:
                frontmatter = yaml.safe_load(parts[1])
                required = ['name', 'mode', 'model']
                missing = [r for r in required if r not in frontmatter]
                if not missing:
                    print(f"✅ {filename} is valid")
                    continue
                else:
                    print(f"⚠️  {filename} missing {missing}")
            else:
                 print(f"❌ {filename} has malformed frontmatter")
        except Exception as e:
            print(f"❌ {filename} error parsing frontmatter: {e}")
    else:
        print(f"❌ {filename} missing frontmatter")
