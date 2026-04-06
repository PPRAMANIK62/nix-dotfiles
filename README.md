# nix-dotfiles

Declarative macOS setup for Apple Silicon using nix-darwin + home-manager + nix-homebrew. One command bootstraps a fresh Mac from zero to fully configured.

## What's included

**System (nix-darwin)**
- macOS defaults — dock autohide, dark mode, key repeat, trackpad tap-to-click, Finder path bar
- Touch ID for sudo
- Nix store optimization

**GUI apps (Homebrew)**
- Ghostty, OBS, Docker, Zed
- Helium (Mac App Store)
- Iosevka Nerd Font Mono

**Shell**
- zsh with autosuggestions, syntax highlighting, completions
- fzf + zoxide integrations
- Aliases for eza, bat, tmux, nix, git, and more

**CLI tools**
- eza, yazi, bat, ripgrep, fd, btop, htop, fastfetch
- gh, lazygit, delta, tmux
- bun, Node 22

**Editor / terminal configs**
- Ghostty — TokyoNight theme, Iosevka font, background blur
- Vim — TokyoNight, fzf, LSP, lightline (git-cloned plugins, no plugin manager)
- Zed — settings + keymap
- tmux — Tokyo Night status bar, vim-style navigation, Ctrl-a prefix
- lazygit — Tokyo Night theme, delta pager

**Git**
- User config + GPG signing by default

---

## Fresh Mac setup

```bash
curl -fsSL https://raw.githubusercontent.com/PPRAMANIK62/nix-dotfiles/master/bootstrap.sh | bash
```

This will:
1. Install Nix (Determinate Systems installer)
2. Install Homebrew
3. Clone this repo to `~/.dotfiles`
4. Run `darwin-rebuild switch --flake .#macbook`

---

## After bootstrap

```bash
# 1. Import and trust your GPG key
gpg --import your-private-key.gpg
gpg --edit-key C5C35170013BB4E5
# In gpg shell: trust → 5 → y → quit

# 2. Authenticate GitHub CLI
gh auth login

# 3. Add secrets (never committed)
echo 'export OPENROUTER_API_KEY=your-key' >> ~/.zshrc.local

# 4. Install Claude Code
npm install -g @anthropic-ai/claude-code

# 5. Restart terminal
```

---

## Applying changes

After editing any `.nix` file:

```bash
darwin-rebuild switch --flake ~/.dotfiles#macbook
# or use the alias:
uu
```

---

## Structure

```
.
├── flake.nix                  # inputs + darwinConfiguration entry point
├── bootstrap.sh               # first-time installer
├── hosts/macbook/
│   ├── default.nix            # macOS system defaults, Touch ID, system packages
│   └── homebrew.nix           # Homebrew casks, taps, mas apps
└── home/
    ├── default.nix            # home-manager entry, imports all modules
    ├── shell.nix              # zsh, plugins, aliases, fzf, zoxide
    ├── packages.nix           # CLI tools and dev toolchains
    ├── git.nix                # git user config + GPG signing
    └── programs/
        ├── ghostty.nix        # Ghostty terminal config
        ├── vim.nix            # Vim config (options, keybinds, plugins, colors)
        ├── zed.nix            # Zed settings.json + keymap.json
        ├── tmux.nix           # tmux config
        └── lazygit.nix        # lazygit config
```

---

## Key aliases

| Alias | Command |
|-------|---------|
| `uu` | `darwin-rebuild switch --flake ~/.dotfiles#macbook` |
| `ns` | `nix search nixpkgs` |
| `v` | `vim` |
| `ls` | `eza` (with icons) |
| `la` | `eza -la` |
| `lt` | `eza --tree` |
| `lf` | `yazi` |
| `cat` | `bat -p` |
| `ff` | `fastfetch` |
| `ta` | `tmux attach` |
| `tn` | `tmux new-session` |
| `gs` | `git status` |
| `ga` | `git add .` |
| `gc` | `git commit -m` |
