#!/bin/bash
set -euo pipefail

echo "========================================="
echo " Gajae-Code WSL2 Setup Script"
echo " Target: google-antigravity + Claude"
echo "========================================="

# ── 1. System packages ──────────────────────────
echo ""
echo "[1/7] Installing system packages..."
sudo apt-get update -qq
sudo apt-get install -y -qq \
  build-essential \
  git \
  curl \
  tmux \
  unzip \
  ca-certificates \
  pkg-config \
  libssl-dev

# ── 2. Install Rust ─────────────────────────────
echo ""
echo "[2/7] Installing Rust..."
if command -v rustc &>/dev/null; then
  echo "Rust already installed: $(rustc --version)"
else
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
  echo "Rust installed: $(rustc --version)"
fi

# ── 3. Install Bun ──────────────────────────────
echo ""
echo "[3/7] Installing Bun..."
if command -v bun &>/dev/null; then
  BUN_VER=$(bun --version)
  echo "Bun already installed: $BUN_VER"
else
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  echo "Bun installed: $(bun --version)"
fi

# Ensure bun is on PATH for this session
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
source "$HOME/.cargo/env" 2>/dev/null || true

# ── 4. Clone gajae-code ─────────────────────────
echo ""
echo "[4/7] Setting up gajae-code..."
GJC_DIR="$HOME/gajae-code"
if [ -d "$GJC_DIR/.git" ]; then
  echo "Repository already exists at $GJC_DIR"
  cd "$GJC_DIR"
  git pull --ff-only || true
else
  git clone https://github.com/Yeachan-Heo/gajae-code.git "$GJC_DIR"
  cd "$GJC_DIR"
fi

# ── 5. Install dependencies ─────────────────────
echo ""
echo "[5/7] Installing Node dependencies..."
bun install

# ── 6. Build native addon ───────────────────────
echo ""
echo "[6/7] Building native Rust addon (this may take 5-10 minutes)..."
bun --cwd=packages/natives run build

# ── 7. Verify CLI ───────────────────────────────
echo ""
echo "[7/7] Verifying gjc CLI..."
GJC_VERSION=$(bun packages/coding-agent/src/cli.ts --version 2>&1)
echo "gjc version: $GJC_VERSION"

# ── 8. Setup shell aliases ──────────────────────
echo ""
echo "Setting up shell aliases..."
ALIAS_LINE='alias gjc="bun $HOME/gajae-code/packages/coding-agent/src/cli.ts"'
if ! grep -qF "alias gjc=" "$HOME/.bashrc" 2>/dev/null; then
  echo "" >> "$HOME/.bashrc"
  echo "# Gajae-Code CLI" >> "$HOME/.bashrc"
  echo "$ALIAS_LINE" >> "$HOME/.bashrc"
  echo "Added gjc alias to ~/.bashrc"
else
  echo "gjc alias already exists in ~/.bashrc"
fi

echo ""
echo "========================================="
echo " Setup Complete!"
echo "========================================="
echo ""
echo " To use gajae-code:"
echo "   1. Open a new terminal or run: source ~/.bashrc"
echo "   2. Start gjc:  gjc --model google-antigravity/gemini-3-pro-high"
echo "   3. Login:       /login google-antigravity"
echo "   4. Use Claude:  /model claude-sonnet-4-6"
echo ""
echo " To use with tmux (full features):"
echo "   tmux new -s gjc"
echo "   gjc --tmux --model google-antigravity/gemini-3-pro-high"
echo ""
echo "========================================="
