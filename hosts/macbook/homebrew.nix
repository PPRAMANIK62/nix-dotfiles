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
            "Helium" = 1054607607;
        };
    };
}
