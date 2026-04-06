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
            size        = 10000;
            save        = 10000;
            path        = "$HOME/.zsh_history";
            ignoreDups  = true;
            ignoreSpace = true;
            share       = true;
        };

        sessionVariables = {
            EDITOR    = "vim";
            PNPM_HOME = "$HOME/.local/share/pnpm";
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
