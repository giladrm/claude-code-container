#!/bin/bash

# Bootstrap script to install run-claude-docker.sh
# Usage: curl -fsSL https://raw.githubusercontent.com/giladrm/claude-code-container/main/install-claude-docker.sh | bash

set -e  # Exit on error

# Configuration
SCRIPT_URL="https://raw.githubusercontent.com/giladrm/claude-code-container/main/run-claude-docker.sh"
INSTALL_PATH="$HOME/bin/run-claude-docker.sh"

echo "Installing run-claude-docker.sh to $INSTALL_PATH..."

# Create bin directory if it doesn't exist
mkdir -p "$HOME/bin"

# Add to PATH if not already there
UPDATE_PATH=false
for rc_file in ~/.bashrc ~/.zshrc; do
  if [ -f "$rc_file" ] && ! grep -q 'PATH=.*~/bin' "$rc_file"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "$rc_file"
    UPDATE_PATH=true
  fi
done

if [ "$UPDATE_PATH" = true ]; then
  echo "Added ~/bin to your PATH in shell configuration files"
fi

# Download the script
echo "Downloading script from $SCRIPT_URL..."
curl -fsSL "$SCRIPT_URL" -o "$INSTALL_PATH"

# Make executable
chmod +x "$INSTALL_PATH"

# Verify installation
if [ -x "$INSTALL_PATH" ]; then
  echo "Installation complete!"
  echo "You can now run the script with: run-claude-docker.sh"
  echo "Please restart your terminal or run 'source ~/.bashrc' (or 'source ~/.zshrc') to update PATH."
  echo ""
  echo "Note: If you're using a different shell, make sure to add $HOME/bin to your PATH."
else
  echo "Installation failed!"
  exit 1
fi