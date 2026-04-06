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
