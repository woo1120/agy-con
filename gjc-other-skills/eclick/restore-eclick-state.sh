#!/usr/bin/env bash
set -euo pipefail

SRC="${1:?Usage: restore-eclick-state.sh /mnt/d/etc/eclick-backup/<stamp>}"
mkdir -p "$HOME/.gjc/agent/skills" "$HOME/.gjc/agent/commands" "$HOME/.gjc"

if [ -d "$SRC/.gjc/agent/skills/eclick" ]; then
  cp -a "$SRC/.gjc/agent/skills/eclick" "$HOME/.gjc/agent/skills/eclick"
fi
if [ -f "$SRC/.gjc/agent/commands/eclick.md" ]; then
  cp "$SRC/.gjc/agent/commands/eclick.md" "$HOME/.gjc/agent/commands/eclick.md"
fi
if [ -d "$SRC/.gjc/eclick" ]; then
  cp -a "$SRC/.gjc/eclick" "$HOME/.gjc/eclick"
fi
if [ -f "$SRC/.gitconfig" ]; then
  cp "$SRC/.gitconfig" "$HOME/.gitconfig"
fi
if [ -d "$SRC/.ssh" ]; then
  mkdir -p "$HOME/.ssh"
  cp -a "$SRC/.ssh/." "$HOME/.ssh/"
  chmod 700 "$HOME/.ssh" || true
  chmod 600 "$HOME/.ssh"/* 2>/dev/null || true
fi

bash "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install.sh"
printf 'Restored eClick state from: %s\n' "$SRC"
