#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/PPRAMANIK62/dotfiles"
DOTFILES_DIR="$HOME/.dotfiles"

echo "==> [1/4] Installing Nix (Determinate Systems)..."
if ! command -v nix &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
        | sh -s -- install --no-confirm
    # Source nix into current shell
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
else
    echo "    Nix already installed, skipping."
fi

echo "==> [2/4] Installing Homebrew..."
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Add brew to PATH for Apple Silicon
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "    Homebrew already installed, skipping."
fi

echo "==> [3/4] Cloning dotfiles..."
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
    echo "    Dotfiles already cloned at $DOTFILES_DIR, pulling latest..."
    git -C "$DOTFILES_DIR" pull
fi

echo "==> [4/4] Running darwin-rebuild switch..."
cd "$DOTFILES_DIR"
nix run nix-darwin -- switch --flake .#macbook

echo ""
echo "Done! Post-setup checklist:"
echo "  1. Import GPG key:  gpg --import <your-key.gpg>"
echo "  2. Trust GPG key:   gpg --edit-key C5C35170013BB4E5  (then: trust → 5 → quit)"
echo "  3. Auth GitHub CLI: gh auth login"
echo "  4. Add API keys:    echo 'export OPENROUTER_API_KEY=...' >> ~/.zshrc.local"
echo "  5. Install Claude Code: npm install -g @anthropic-ai/claude-code"
echo "  6. Restart terminal"
