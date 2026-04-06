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
