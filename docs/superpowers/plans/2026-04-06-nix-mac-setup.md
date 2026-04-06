# Nix Mac Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a fully declarative, version-controlled dotfiles repo that bootstraps a fresh Apple Silicon Mac with one command using nix-darwin + home-manager + nix-homebrew.

**Architecture:** A single `flake.nix` declares all inputs. `hosts/macbook/` owns system-level macOS config via nix-darwin. `home/` owns the user environment via home-manager. GUI apps are managed declaratively via nix-homebrew. A `bootstrap.sh` ties everything together for first-time setup.

**Tech Stack:** Nix flakes, nix-darwin, home-manager, nix-homebrew, zsh (native plugins), Ghostty, Zed, Vim, tmux, lazygit

---

## File Map

**Create:**
- `flake.nix` — flake inputs + darwinConfiguration entry point
- `hosts/macbook/default.nix` — nix-darwin system config (macOS defaults, system packages, Touch ID)
- `hosts/macbook/homebrew.nix` — Homebrew casks + mas apps
- `home/default.nix` — home-manager entry, imports all modules, sets stateVersion
- `home/shell.nix` — zsh config, plugins, aliases, env vars, fzf+zoxide integrations
- `home/packages.nix` — CLI tools, bun, pinned Node
- `home/git.nix` — git user config + GPG signing
- `home/programs/ghostty.nix` — ghostty config via home.file
- `home/programs/vim.nix` — all vim config files via home.file
- `home/programs/zed.nix` — zed settings.json + keymap.json via home.file
- `home/programs/tmux.nix` — tmux config via home.file
- `home/programs/lazygit.nix` — lazygit config via home.file
- `bootstrap.sh` — first-time installer script

---

## Task 1: Initialize repo and flake skeleton

**Files:**
- Create: `flake.nix`
- Create: `hosts/macbook/default.nix` (stub)
- Create: `home/default.nix` (stub)
- Create: `.gitignore`

- [ ] **Step 1: Create repo directory and git init**

```bash
mkdir -p ~/dotfiles
cd ~/dotfiles
git init
```

- [ ] **Step 2: Create `.gitignore`**

```
# Nix
result
.direnv/

# Secrets — never commit these
*.local
.env
.env.*
```

- [ ] **Step 3: Create `flake.nix`**

```nix
{
  description = "Purbayan's macOS dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager, nix-homebrew, homebrew-core, homebrew-cask, ... }:
  let
    # Change this if your Mac username differs
    username = "ppramanik62";
  in {
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      specialArgs = { inherit inputs username; };
      modules = [
        ./hosts/macbook/default.nix
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = username;
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
            };
            mutableTaps = false;
          };
        }
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit inputs username; };
            users.${username} = import ./home/default.nix;
          };
        }
      ];
    };
  };
}
```

- [ ] **Step 4: Create stub `hosts/macbook/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [ ./homebrew.nix ];

  environment.systemPackages = with pkgs; [ git curl gnupg ];

  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  nix.settings.experimental-features = "nix-command flakes";
  services.nix-daemon.enable = true;

  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
```

- [ ] **Step 5: Create stub `hosts/macbook/homebrew.nix`**

```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = [];
    masApps = {};
  };
}
```

- [ ] **Step 6: Create stub `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 7: Create initial directories**

```bash
mkdir -p hosts/macbook home/programs config/ghostty config/zed config/vim
```

- [ ] **Step 8: Commit**

```bash
git add .
git commit -m "feat: initialize flake skeleton with nix-darwin + home-manager + nix-homebrew"
```

---

## Task 2: macOS system defaults

**Files:**
- Modify: `hosts/macbook/default.nix`

- [ ] **Step 1: Replace the stub `hosts/macbook/default.nix` with full system defaults**

```nix
{ pkgs, username, ... }: {
  imports = [ ./homebrew.nix ];

  # System-wide packages (minimal — user packages go in home-manager)
  environment.systemPackages = with pkgs; [ git curl gnupg ];

  # User setup
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  # macOS system defaults
  system.defaults = {
    dock = {
      autohide = true;
      minimize-to-application = true;
      show-recents = false;
      launchanim = false;
    };
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      AppleInterfaceStyle = "Dark";
    };
    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
    };
    finder = {
      AppleShowAllFiles = true;
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
    };
    screensaver = {
      askForPasswordDelay = 0;
    };
  };

  # Touch ID for sudo
  security.pam.enableSudoTouchIdAuth = true;

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };
  services.nix-daemon.enable = true;

  system.stateVersion = 4;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
```

- [ ] **Step 2: Commit**

```bash
git add hosts/macbook/default.nix
git commit -m "feat: add macOS system defaults (dock, keyboard, trackpad, finder, Touch ID)"
```

---

## Task 3: Homebrew casks and Mac App Store apps

**Files:**
- Modify: `hosts/macbook/homebrew.nix`

- [ ] **Step 1: Update `hosts/macbook/homebrew.nix` with all GUI apps**

```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    casks = [
      "ghostty"
      "obs"
      "docker"
    ];
    masApps = {
      # Helium — floating browser
      "Helium" = 1054607607;
    };
  };
}
```

Note: Zed is installed via homebrew cask here if not available in nixpkgs for darwin,
but since Zed is also in nixpkgs, it's managed via home-manager packages instead.
If you prefer the Homebrew version, add `"zed"` to casks.

- [ ] **Step 2: Commit**

```bash
git add hosts/macbook/homebrew.nix
git commit -m "feat: add Homebrew casks (Ghostty, OBS, Docker) and Helium via mas"
```

---

## Task 4: home-manager shell config

**Files:**
- Create: `home/shell.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/shell.nix`**

```nix
{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    completionInit = ''
      autoload -Uz compinit && compinit
    '';

    plugins = [
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
        file = "share/zsh-completions/zsh-completions.plugin.zsh";
      }
    ];

    initExtra = ''
      # Keybindings
      bindkey -e
      bindkey '^p' history-search-backward
      bindkey '^n' history-search-forward
      bindkey '^[w' kill-region
      bindkey '^z' undo
      bindkey '^x^e' edit-command-line

      autoload -Uz edit-command-line
      zle -N edit-command-line

      # Completions
      zstyle ':completion:*' file-sort date
      zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'
      zstyle ':completion:*:paths' path-completion yes
      zstyle ':completion:*:processes' command 'ps -afu $USER'

      setopt CORRECT
      setopt appendhistory
      setopt sharehistory
      setopt hist_ignore_space
      setopt hist_ignore_all_dups
      setopt hist_save_no_dups
      setopt hist_find_no_dups

      # Source local secrets (API keys, tokens — never committed)
      [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
    '';

    shellAliases = {
      # General
      cl    = "clear";
      v     = "vim";
      op    = "opencode";

      # ls (eza)
      ls    = "eza --icons --color=always --group-directories-first";
      l     = "eza -F --icons --color=always --group-directories-first";
      la    = "eza -la --icons --color=always --group-directories-first";
      ll    = "eza -alF --icons --color=always --group-directories-first";
      lt    = "eza --tree --icons --color=always --group-directories-first";
      lf    = "yazi";

      # Navigation
      ".."  = "cd ..";

      # Git
      ga    = "git add .";
      gs    = "git status";
      gc    = "git commit -m";
      gsp   = "git stash pop";
      gsl   = "git stash list";
      gwl   = "git worktree list";

      # Tools
      ff    = "fastfetch";
      ffc   = "fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc";
      cat   = "bat -p";

      # Tmux
      tl    = "tmux list-sessions";
      ta    = "tmux attach";
      tn    = "tmux new-session";
      ts    = "tmux source-file ~/.config/tmux/tmux.conf";

      # Nix (replaces DNF)
      uu    = "darwin-rebuild switch --flake ~/.dotfiles#macbook";
      ns    = "nix search nixpkgs";

      # Dev
      ned   = "ln -s ../../node_modules node_modules && ln -s ../../.env.local .env.local & ln -s ../../.dev.vars .dev.vars";
    };

    history = {
      size       = 10000;
      save       = 10000;
      path       = "$HOME/.zsh_history";
      ignoreDups = true;
      ignoreSpace = true;
      share      = true;
    };

    sessionVariables = {
      EDITOR     = "vim";
      PNPM_HOME  = "$HOME/.local/share/pnpm";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
```

- [ ] **Step 2: Add `shell.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add home/shell.nix home/default.nix
git commit -m "feat: add zsh shell config with native plugins, aliases, fzf, zoxide"
```

---

## Task 5: CLI packages and dev toolchains

**Files:**
- Create: `home/packages.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/packages.nix`**

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ls/navigation
    eza
    yazi

    # file/text tools
    bat
    ripgrep
    fd

    # system monitoring
    btop
    htop
    fastfetch

    # git tools
    gh
    lazygit

    # terminal multiplexer
    tmux

    # JS/dev toolchains
    bun
    nodejs_22
  ];
}
```

Note: `fzf` and `zoxide` are declared as `programs.*` in `shell.nix` — home-manager
installs their packages automatically. Do not duplicate them here.

- [ ] **Step 2: Add `packages.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add home/packages.nix home/default.nix
git commit -m "feat: add CLI packages and dev toolchains (bun, node 22)"
```

---

## Task 6: Git config

**Files:**
- Create: `home/git.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/git.nix`**

```nix
{ ... }: {
  programs.git = {
    enable = true;
    userName  = "Purbayan Pramanik";
    userEmail = "purbayanpramanik62@gmail.com";
    signing = {
      key          = "C5C35170013BB4E5";
      signByDefault = true;
    };
    extraConfig = {
      commit.gpgsign = true;
      tag.gpgsign    = true;
      "credential \"https://github.com\"" = {
        helper = "";
        # second helper line — home-manager merges list values
      };
    };
  };
}
```

Note on gh credential helper: `gh auth git-credential` path differs on Mac vs Linux.
On Mac after `gh` is installed it will be at `/opt/homebrew/bin/gh` or in your Nix store.
The safest approach: after first `darwin-rebuild switch`, run `gh auth login` once —
this configures the credential helper automatically in `~/.gitconfig` locally.
The `home/git.nix` sets everything else; let `gh auth login` handle the credential helper.

- [ ] **Step 2: Add `git.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add home/git.nix home/default.nix
git commit -m "feat: add git config with GPG signing"
```

---

## Task 7: Ghostty config

**Files:**
- Create: `home/programs/ghostty.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/programs/ghostty.nix`**

```nix
{ ... }: {
  home.file.".config/ghostty/config".text = ''
    theme = TokyoNight
    font-family = Iosevka Nerd Font Mono
    font-size = 15
    mouse-hide-while-typing = true
    window-decoration = true
    background-opacity = 0.7
    background-blur-radius = 20
    cursor-style = block
  '';
}
```

Note: Ghostty on Mac reads from `~/.config/ghostty/config`. The font `Iosevka Nerd Font Mono`
must be installed separately — add it to Homebrew fonts tap in homebrew.nix (see note below),
or download manually from nerdfonts.com.

To add font via Homebrew, add to `hosts/macbook/homebrew.nix`:
```nix
taps = [ "homebrew/cask-fonts" ];
casks = [
  # existing casks ...
  "font-iosevka-nerd-font"
];
```

- [ ] **Step 2: Add `ghostty.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./programs/ghostty.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Update `hosts/macbook/homebrew.nix` to add font tap**

```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "homebrew/cask-fonts"
    ];
    casks = [
      "ghostty"
      "obs"
      "docker"
      "font-iosevka-nerd-font"
    ];
    masApps = {
      "Helium" = 1054607607;
    };
  };
}
```

- [ ] **Step 4: Commit**

```bash
git add home/programs/ghostty.nix home/default.nix hosts/macbook/homebrew.nix
git commit -m "feat: add Ghostty config and Iosevka Nerd Font via Homebrew"
```

---

## Task 8: Vim config

**Files:**
- Create: `home/programs/vim.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/programs/vim.nix`**

The vim setup uses a custom git-clone plugin manager (no vim-plug/packer). All config
files are managed as `home.file` entries so they land in the right places on Mac.

```nix
{ ... }: {
  home.file.".vimrc".text = ''
    source ~/.vim/vimrc
  '';

  home.file.".vim/vimrc".text = ''
    source ~/.vim/options.vim
    source ~/.vim/keybinds.vim
    source ~/.vim/plugins.vim
    source ~/.vim/colors.vim
    source ~/.vim/fzf.vim
  '';

  home.file.".vim/options.vim".text = ''
    set number
    set relativenumber

    filetype plugin indent on
    set expandtab
    set shiftwidth=4
    set softtabstop=4
    set tabstop=4
    set smartindent

    set backspace=indent,eol,start

    syntax on
  '';

  home.file.".vim/keybinds.vim".text = ''
    let mapleader = " "

    nnoremap <leader>cd :Ex<CR>
  '';

  home.file.".vim/colors.vim".text = ''
    set termguicolors

    set laststatus=2

    let g:tokyonight_style = 'night'
    let g:tokyonight_enable_italic = 1
    let g:lightline = { 'colorscheme' : 'tokyonight' }

    colorscheme tokyonight
  '';

  home.file.".vim/fzf.vim".text = ''
    nnoremap <leader>ff :Files<CR>
    nnoremap <leader>fh :History<CR>
    nnoremap <leader>fb :Buffers<CR>
    nnoremap <leader>fg :Rg<space>
  '';

  home.file.".vim/plugins.vim".text = ''
    let s:plugin_dir = expand('~/.vim/plugged')

    function! s:ensure(repo)
        let name = split(a:repo, '/')[-1]
        let path = s:plugin_dir . '/' . name

        if !isdirectory(path)
            if !isdirectory(s:plugin_dir)
                call mkdir(s:plugin_dir, 'p')
            endif
            execute '!git clone --depth=1 https://github.com/' . a:repo . ' ' . shellescape(path)
        endif

        execute 'set runtimepath+=' . fnameescape(path)
    endfunction

    call s:ensure('ghifarit53/tokyonight-vim')
    call s:ensure('junegunn/fzf')
    call s:ensure('junegunn/fzf.vim')
    call s:ensure('itchyny/lightline.vim')
    call s:ensure('yegappan/lsp')
  '';
}
```

Note: On first `vim` launch, plugins will auto-clone from GitHub via `s:ensure()`.
Subsequent launches are instant (plugins already in `~/.vim/plugged/`).

- [ ] **Step 2: Add `vim.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./programs/ghostty.nix
    ./programs/vim.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add home/programs/vim.nix home/default.nix
git commit -m "feat: add vim config (TokyoNight, fzf, LSP, lightline)"
```

---

## Task 9: Zed config

**Files:**
- Create: `home/programs/zed.nix`
- Modify: `home/default.nix`

- [ ] **Step 1: Create `home/programs/zed.nix`**

```nix
{ ... }: {
  home.file.".config/zed/settings.json".text = ''
    {
        "edit_predictions": {
            "provider": "zed"
        },
        "git_panel": {
            "dock": "right"
        },
        "disable_ai": true,
        "icon_theme": "JetBrains New UI Icons (Dark)",
        "base_keymap": "VSCode",
        "project_panel": {
            "dock": "right"
        },
        "agent": {
            "tool_permissions": {
                "default": "allow"
            },
            "play_sound_when_agent_done": true,
            "default_model": {
                "provider": "zed.dev",
                "model": "claude-sonnet-4"
            }
        },
        "ui_font_size": 18,
        "buffer_font_size": 18,
        "theme": {
            "mode": "dark",
            "light": "One Light",
            "dark": "Tokyo Night"
        },
        "autosave": {
            "after_delay": {
                "milliseconds": 500
            }
        },
        "buffer_font_family": "Iosevka Nerd Font Mono",
        "ui_font_family": "Iosevka Nerd Font Mono",
        "cursor_blink": false,
        "cursor_shape": "block",
        "toolbar": {
            "breadcrumbs": false,
            "quick_actions": false
        },
        "scrollbar": {
            "show": "never"
        },
        "tab_size": 4,
        "terminal": {
            "copy_on_select": false,
            "font_size": 17.0,
            "toolbar": {
                "breadcrumbs": false
            }
        },
        "soft_wrap": "editor_width",
        "format_on_save": "on",
        "formatter": "auto",
        "code_actions_on_format": {
            "source.organizeImports": true,
            "source.fixAll.eslint": true,
            "source.addMissingImports": true,
            "source.removeUnusedImports": true
        },
        "prettier": {
            "tabWidth": 4,
            "useTabs": false,
            "semi": true,
            "singleQuote": false,
            "jsxSingleQuote": false,
            "trailingComma": "es5",
            "allowParens": "always"
        }
    }
  '';

  home.file.".config/zed/keymap.json".text = ''
    [
      {
        "bindings": {
          "ctrl-b": "project_panel::ToggleFocus"
        }
      },
      {
        "context": "(Editor && mode == full)",
        "bindings": {
          "ctrl-enter": "editor::NewlineBelow"
        }
      }
    ]
  '';
}
```

Note: Zed is installed via the `"zed"` Homebrew cask (managed in homebrew.nix).
Add it to casks if not already there:
```nix
casks = [
  "ghostty"
  "obs"
  "docker"
  "zed"
  "font-iosevka-nerd-font"
];
```

- [ ] **Step 2: Add `"zed"` to `hosts/macbook/homebrew.nix` casks**

```nix
{ ... }: {
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    taps = [
      "homebrew/cask-fonts"
    ];
    casks = [
      "ghostty"
      "obs"
      "docker"
      "zed"
      "font-iosevka-nerd-font"
    ];
    masApps = {
      "Helium" = 1054607607;
    };
  };
}
```

- [ ] **Step 3: Add `zed.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./programs/ghostty.nix
    ./programs/vim.nix
    ./programs/zed.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 4: Commit**

```bash
git add home/programs/zed.nix home/default.nix hosts/macbook/homebrew.nix
git commit -m "feat: add Zed settings and keymap config"
```

---

## Task 10: tmux config

**Files:**
- Create: `home/programs/tmux.nix`
- Modify: `home/default.nix`

No existing tmux config was found on your Linux machine, so this creates a clean baseline.

- [ ] **Step 1: Create `home/programs/tmux.nix`**

```nix
{ ... }: {
  home.file.".config/tmux/tmux.conf".text = ''
    # Set prefix to Ctrl-a
    unbind C-b
    set -g prefix C-a
    bind C-a send-prefix

    # Enable mouse
    set -g mouse on

    # Start windows and panes at 1
    set -g base-index 1
    setw -g pane-base-index 1
    set -g renumber-windows on

    # Increase history
    set -g history-limit 10000

    # Split panes with | and -
    bind | split-window -h -c "#{pane_current_path}"
    bind - split-window -v -c "#{pane_current_path}"
    unbind '"'
    unbind %

    # Vim-style pane navigation
    bind h select-pane -L
    bind j select-pane -D
    bind k select-pane -U
    bind l select-pane -R

    # Fast config reload
    bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded"

    # Terminal colors
    set -g default-terminal "tmux-256color"
    set -ag terminal-overrides ",xterm-256color:RGB"

    # Status bar
    set -g status-position bottom
    set -g status-style 'bg=#1a1b26 fg=#c0caf5'
    set -g status-left '#[fg=#7aa2f7,bold] #S '
    set -g status-right '#[fg=#7aa2f7] %H:%M '
    set -g window-status-current-format '#[fg=#7aa2f7,bold] #I:#W '
    set -g window-status-format '#[fg=#565f89] #I:#W '
  '';
}
```

- [ ] **Step 2: Add `tmux.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./programs/ghostty.nix
    ./programs/vim.nix
    ./programs/zed.nix
    ./programs/tmux.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 3: Commit**

```bash
git add home/programs/tmux.nix home/default.nix
git commit -m "feat: add tmux config (Tokyo Night colors, vim keybinds)"
```

---

## Task 11: lazygit config

**Files:**
- Create: `home/programs/lazygit.nix`
- Modify: `home/default.nix`

No existing lazygit config found — this creates a sensible baseline with Tokyo Night theme.

- [ ] **Step 1: Create `home/programs/lazygit.nix`**

```nix
{ ... }: {
  home.file.".config/lazygit/config.yml".text = ''
    gui:
      theme:
        activeBorderColor:
          - "#7aa2f7"
          - bold
        inactiveBorderColor:
          - "#565f89"
        optionsTextColor:
          - "#7aa2f7"
        selectedLineBgColor:
          - "#283457"
        cherryPickedCommitBgColor:
          - "#45475a"
        cherryPickedCommitFgColor:
          - "#7aa2f7"
        unstagedChangesColor:
          - "#f7768e"
        defaultFgColor:
          - "#c0caf5"
        searchingActiveBorderColor:
          - "#e0af68"
      mouseEvents: true
      showIcons: true
    git:
      paging:
        colorArg: always
        pager: delta --dark --paging=never
  '';
}
```

Note: The `delta` pager gives beautiful diffs. Add `delta` to `home/packages.nix`:
```nix
home.packages = with pkgs; [
  # ... existing packages ...
  delta
];
```

- [ ] **Step 2: Add `delta` to `home/packages.nix`**

```nix
{ pkgs, ... }: {
  home.packages = with pkgs; [
    eza
    yazi
    bat
    ripgrep
    fd
    btop
    htop
    fastfetch
    gh
    lazygit
    tmux
    bun
    nodejs_22
    delta
  ];
}
```

- [ ] **Step 3: Add `lazygit.nix` import to `home/default.nix`**

```nix
{ pkgs, username, ... }: {
  imports = [
    ./shell.nix
    ./packages.nix
    ./git.nix
    ./programs/ghostty.nix
    ./programs/vim.nix
    ./programs/zed.nix
    ./programs/tmux.nix
    ./programs/lazygit.nix
  ];

  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;
}
```

- [ ] **Step 4: Commit**

```bash
git add home/programs/lazygit.nix home/packages.nix home/default.nix
git commit -m "feat: add lazygit config (Tokyo Night theme, delta pager)"
```

---

## Task 12: Bootstrap script

**Files:**
- Create: `bootstrap.sh`

- [ ] **Step 1: Create `bootstrap.sh`**

```bash
#!/usr/bin/env bash
set -euo pipefail

DOTFILES_REPO="https://github.com/ppramanik62/dotfiles"  # update with your actual repo URL
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
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x bootstrap.sh
```

- [ ] **Step 3: Commit**

```bash
git add bootstrap.sh
git commit -m "feat: add bootstrap.sh for one-command Mac setup"
```

---

## Task 13: Push to GitHub and verify

- [ ] **Step 1: Create a new GitHub repo named `dotfiles`**

```bash
gh repo create dotfiles --public --description "macOS dotfiles: nix-darwin + home-manager + nix-homebrew"
```

- [ ] **Step 2: Push**

```bash
git remote add origin https://github.com/ppramanik62/dotfiles
git push -u origin main
```

- [ ] **Step 3: On the Mac — run bootstrap**

```bash
curl -fsSL https://raw.githubusercontent.com/ppramanik62/dotfiles/main/bootstrap.sh | bash
```

- [ ] **Step 4: Verify the build succeeds**

Expected: `darwin-rebuild switch` completes without errors. Watch for:
- Homebrew casks downloading (Ghostty, OBS, Docker, Zed, font)
- Helium installing from Mac App Store (requires being signed in to App Store)
- home-manager activation symlinking all configs

- [ ] **Step 5: Verify configs landed correctly**

```bash
# Check shell
echo $SHELL          # should be /run/current-system/sw/bin/zsh or similar nix zsh
type ls              # should show eza alias

# Check symlinks
ls -la ~/.config/ghostty/config
ls -la ~/.config/zed/settings.json
ls -la ~/.config/tmux/tmux.conf
ls -la ~/.config/lazygit/config.yml
ls -la ~/.vimrc

# Check tools
bun --version
node --version       # should be 22.x
gh --version
lazygit --version
```

- [ ] **Step 6: Final commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: post-bootstrap adjustments"
git push
```

---

## Post-Setup Manual Steps (not automated)

```bash
# 1. GPG key
gpg --import your-private-key.gpg
gpg --edit-key C5C35170013BB4E5
# In gpg shell: trust → 5 (ultimate) → y → quit

# 2. GitHub auth
gh auth login

# 3. Secrets — create ~/.zshrc.local and add:
export OPENROUTER_API_KEY='your-key-here'
# Add any other API keys here — this file is gitignored

# 4. Claude Code
npm install -g @anthropic-ai/claude-code
```
