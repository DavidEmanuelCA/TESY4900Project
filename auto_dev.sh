#!/bin/bash

# Start ssh-agent if not already running
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
fi

# List private keys in ~/.ssh
echo "Available SSH keys:"
keys=($(find ~/.ssh -maxdepth 1 -type f -name "id_*" ! -name "*.pub"))
for i in "${!keys[@]}"; do
    echo "$((i+1))) ${keys[$i]}"
done

# Ask the user to choose a key
read -p "Choose the SSH key to use (number): " choice

# Check if the selection is valid
if [[ "$choice" -ge 1 && "$choice" -le ${#keys[@]} ]]; then
    selected_key="${keys[$((choice-1))]}"
    ssh-add "$selected_key"
    echo "✅ Added key: $selected_key"
else
    echo "❌ Invalid selection."
    exit 1
fi

# Optional: Launch Godot (comment out if not desired)
# godot4 .

echo "✔ SSH agent ready and project environment initialized."

