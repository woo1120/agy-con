#!/bin/bash
set -euo pipefail

export PATH="/home/gjc/bin:/home/gjc/.bun/bin:/home/gjc/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

cd /home/gjc/gajae-code

echo "=== gjc update (git) ==="
echo "Current: $(bun packages/coding-agent/src/cli.ts --version)"
echo ""

echo "[1/4] Fetching latest..."
git fetch origin main

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
  echo "Already up to date."
  exit 0
fi

echo "[2/4] Pulling changes..."
# Stash build artifacts that may conflict
git stash --include-untracked -q 2>/dev/null || true
git pull origin main --ff-only
git stash drop -q 2>/dev/null || true

echo "[3/4] Installing dependencies..."
bun install

echo "[4/4] Building native addon..."
bun --cwd=packages/natives run build

echo ""
echo "Updated: $(bun packages/coding-agent/src/cli.ts --version)"
echo "=== Done ==="
