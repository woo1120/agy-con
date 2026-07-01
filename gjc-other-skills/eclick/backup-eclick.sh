#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date +%Y%m%d-%H%M%S)"
DEST="${1:-/mnt/d/etc/eclick-backup/$STAMP}"
mkdir -p "$DEST/.gjc/agent/skills" "$DEST/.gjc/agent/commands" "$DEST/.gjc"

if [ -d "$HOME/.gjc/agent/skills/eclick" ]; then
  cp -a "$HOME/.gjc/agent/skills/eclick" "$DEST/.gjc/agent/skills/eclick"
fi
if [ -f "$HOME/.gjc/agent/commands/eclick.md" ]; then
  cp "$HOME/.gjc/agent/commands/eclick.md" "$DEST/.gjc/agent/commands/eclick.md"
fi
if [ -d "$HOME/.gjc/eclick" ]; then
  cp -a "$HOME/.gjc/eclick" "$DEST/.gjc/eclick"
fi
if [ -f "$HOME/.gitconfig" ]; then
  cp "$HOME/.gitconfig" "$DEST/.gitconfig"
fi
if [ -d "$HOME/.ssh" ]; then
  mkdir -p "$DEST/.ssh"
  cp -a "$HOME/.ssh/." "$DEST/.ssh/"
fi

printf 'Backup written to: %s\n' "$DEST"
