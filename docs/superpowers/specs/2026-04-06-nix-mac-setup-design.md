# Nix Mac Setup — Design Spec

**Date:** 2026-04-06  
**Target:** Apple Silicon MacBook (aarch64-darwin)  
**Approach:** nix-darwin + home-manager + nix-homebrew  
**Goal:** Fully declarative, version-controlled dotfiles repo that bootstraps a new Mac from scratch with one command.

---

## Repository Structure

```
dotfiles/
├── flake.nix                  # entry point — all inputs declared here
├── flake.lock
├── hosts/
│   └── macbook/
│       ├── default.nix        # nix-darwin system config
│       └── homebrew.nix       # casks + mas apps via nix-homebrew
├── home/
│   ├── default.nix            # home-manager entry, imports all modules
│   ├── shell.nix              # zsh, plugins, aliases, env vars
│   ├── packages.nix           # CLI tools + dev toolchains (bun, node)
│   ├── git.nix                # git config + GPG signing
│   └── programs/
│       ├── ghostty.nix        # ghostty config
│       ├── vim.nix            # vim config
│       ├── zed.nix            # zed settings.json + keymap.json
│       ├── tmux.nix           # tmux config
│       └── lazygit.nix        # lazygit config
├── config/                    # raw config files sourced by nix modules
│   ├── vim/                   # .vimrc + .vim/ contents
│   ├── zed/                   # settings.json, keymap.json
│   └── ghostty/               # ghostty config file
└── bootstrap.sh               # one-shot installer
```

**Flake inputs:** `nixpkgs` (unstable), `nix-darwin`, `home-manager`, `nix-homebrew`.

The `hosts/macbook/` layer is machine identity. The `home/` layer is portable — adding a new Mac means a new host directory reusing the same home modules.

---

## System Layer (nix-darwin)

### `hosts/macbook/default.nix`

- **System packages:** `git`, `curl`, `gnupg`
- **Architecture:** `aarch64-darwin`
- **macOS defaults (`system.defaults`):**
  - Dock: auto-hide, minimize to app icon
  - Keyboard: fast key repeat, disable press-and-hold
  - Trackpad: tap-to-click, natural scrolling
  - Finder: show hidden files, show extensions, path bar
- **System services:**
  - `security.pam.enableSudoTouchIdAuth = true` (Touch ID for sudo)
  - nix-daemon auto-upgrade

### `hosts/macbook/homebrew.nix`

- **Casks:** `ghostty`, `obs`, `docker`, `zed`
- **Mac App Store (`mas`):** Helium (ID: 1054607607)
- `onActivation.autoUpdate = true`
- `onActivation.cleanup = "zap"` — removes unlisted casks on `darwin-rebuild switch`

---

## User Layer (home-manager)

### `home/shell.nix`

- zsh with native plugin management (no oh-my-zsh):
  - `zsh-autosuggestions`
  - `zsh-syntax-highlighting`
  - `zsh-completions`
- All aliases ported from current `.zshrc`:
  - `eza`, `bat`, `yazi`, `tmux`, `git` aliases preserved
  - DNF aliases (`uu`, `i`, `r`, `s`) replaced with Nix equivalents
- History settings, keybindings, zstyle completions ported verbatim
- `fzf` and `zoxide` integrations via home-manager options (not manual `eval`)
- `EDITOR=vim`
- `OPENROUTER_API_KEY` and other non-secret env vars in shell config
- `~/.zshrc.local` sourced if present (for secrets/API keys not in repo)

### `home/packages.nix`

CLI tools:
- `eza`, `fzf`, `zoxide`, `bat`, `yazi`, `fastfetch`
- `tmux`, `lazygit`, `btop`, `htop`, `gh`
- `ripgrep`, `fd`
- `claude-code` (if available in nixpkgs, else via Homebrew cask)

Dev toolchains:
- `bun` — primary JS runtime
- `nodejs_22` — pinned Node version, no version manager

### `home/git.nix`

Ported verbatim from `.gitconfig`:
- `user.name = Purbayan Pramanik`
- `user.email = purbayanpramanik62@gmail.com`
- `commit.gpgsign = true`
- `tag.gpgsign = true`
- `user.signingkey = C5C35170013BB4E5`
- `gh` credential helper

GPG private key requires one manual import (see Bootstrap section).

### `home/programs/`

Each program module uses `home.file` or home-manager program options to symlink configs into `~/.config/`:

| Module | Config source | Target |
|---|---|---|
| `ghostty.nix` | `config/ghostty/config` | `~/.config/ghostty/config` |
| `vim.nix` | `config/vim/` | `~/.vimrc` + `~/.vim/` |
| `zed.nix` | `config/zed/settings.json` + `keymap.json` | `~/.config/zed/` |
| `tmux.nix` | `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` |
| `lazygit.nix` | `config/lazygit/config.yml` | `~/.config/lazygit/config.yml` |

Ghostty config carried over as-is (Tokyo Night theme, Iosevka Nerd Font Mono, transparency, blur).

---

## Bootstrap Flow

### First-time setup on a new Mac

```bash
curl -fsSL https://raw.githubusercontent.com/you/dotfiles/main/bootstrap.sh | bash
```

`bootstrap.sh` steps:
1. Install Nix via **Determinate Systems installer** (handles Apple Silicon, multi-user, flakes enabled by default)
2. Install Homebrew if not present
3. Clone the dotfiles repo to `~/.dotfiles`
4. Run `darwin-rebuild switch --flake ~/.dotfiles#macbook`

### Ongoing updates

```bash
darwin-rebuild switch --flake ~/.dotfiles#macbook
```

### Manual one-time steps (not automated)

1. **GPG key import:**
   ```bash
   gpg --import your-private-key.gpg
   gpg --edit-key C5C35170013BB4E5  # trust ultimately
   ```
2. **API keys / secrets:** Add to `~/.zshrc.local` (sourced by shell, never committed)
3. **Helium settings:** Manual — browser data not automated

---

## What Is NOT in the Repo

- Private keys (SSH, GPG)
- API keys and tokens (`.npmrc` auth token, `OPENROUTER_API_KEY`, etc.)
- Browser profiles/data
- Linux-only configs: Hyprland, waybar, rofi, X11 configs (these stay on Linux)
