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
