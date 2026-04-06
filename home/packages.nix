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
