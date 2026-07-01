#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$HOME/.gjc/agent/skills/eclick"
COMMAND_DIR="$HOME/.gjc/agent/commands"

mkdir -p "$SKILL_DIR" "$COMMAND_DIR"
cp "$SCRIPT_DIR/SKILL.md" "$SKILL_DIR/SKILL.md"
cp "$SCRIPT_DIR/README.md" "$SKILL_DIR/README.md"
cp "$SCRIPT_DIR/eclick.command.md" "$COMMAND_DIR/eclick.md"

printf 'Installed eClick skill:\n'
printf '  %s\n' "$SKILL_DIR/SKILL.md"
printf '  %s\n' "$SKILL_DIR/README.md"
printf 'Installed slash shortcut:\n'
printf '  %s\n' "$COMMAND_DIR/eclick.md"
printf '\nRestart GJC, then use: /eclick\n'
