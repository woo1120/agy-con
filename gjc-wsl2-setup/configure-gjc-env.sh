#!/bin/bash
set -euo pipefail

# Write gjc env file
cat > /home/gjc/.bashrc.gjc << 'EOFRC'
# === Gajae-Code Environment ===
# Exclude Windows PATH to prevent binary conflicts
export PATH="/home/gjc/.bun/bin:/home/gjc/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games"

# GJC alias
alias gjc='bun /home/gjc/gajae-code/packages/coding-agent/src/cli.ts'

# Default model: google-antigravity
export GJC_MODEL='google-antigravity/gemini-3-pro-high'
EOFRC

# Source it from .bashrc if not already
if ! grep -qF '.bashrc.gjc' /home/gjc/.bashrc 2>/dev/null; then
  echo '' >> /home/gjc/.bashrc
  echo '# Gajae-Code env' >> /home/gjc/.bashrc
  echo 'source /home/gjc/.bashrc.gjc' >> /home/gjc/.bashrc
fi

# Install wslu for wslview browser support
sudo apt-get install -y -qq wslu 2>/dev/null || true

# Verify tmux
tmux -V

echo "SETUP_COMPLETE"
