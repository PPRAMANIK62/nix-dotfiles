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
