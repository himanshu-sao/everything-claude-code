import os
import re

agents_dir = '.opencode/agents'
if os.path.exists(agents_dir):
    for filename in os.listdir(agents_dir):
        if filename.endswith('.md'):
            filepath = os.path.join(agents_dir, filename)
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Remove model: ... from frontmatter
            new_content = re.sub(r'\nmodel: [^\n]+\n', '\n', content)
            
            if new_content != content:
                with open(filepath, 'w') as f:
                    f.write(new_content)
                print(f"Stripped model from {filename}")
else:
    print(f"Directory {agents_dir} not found")
