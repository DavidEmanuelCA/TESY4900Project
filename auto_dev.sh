#!/bin/bash

# Start ssh-agent and export its variables to a temp file
eval "$(ssh-agent -s)" >/dev/null

# Export agent environment
export SSH_AUTH_SOCK
export SSH_AGENT_PID

# List available keys
echo "Available SSH keys:"
key_paths=($(find ~/.ssh -maxdepth 1 -type f -name "id_*" ! -name "*.pub"))
for i in "${!key_paths[@]}"; do
  echo "$((i+1))) ${key_paths[$i]}"
done

# User chooses one
read -p "Choose the SSH key to use (number): " choice
chosen_key=${key_paths[$((choice-1))]}

# Add key
if ssh-add "$chosen_key"; then
  echo "✅ Added key: $chosen_key"
  echo "✔ Ready to use Git with SSH!"
else
  echo "❌ Failed to add SSH key."
  exit 1
fi

# Optional: run a new shell with agent environment to allow using Git
echo "💡 Opening a subshell with SSH agent active. Type 'exit' when done."
$SHELL

