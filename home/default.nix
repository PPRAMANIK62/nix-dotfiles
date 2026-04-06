{ pkgs, username, ... }: {
    imports = [
        ./shell.nix
        ./packages.nix
        ./git.nix
        ./programs/ghostty.nix
        ./programs/vim.nix
    ];

    home = {
        username    = username;
        homeDirectory = "/Users/${username}";
        stateVersion  = "24.05";
    };

    programs.home-manager.enable = true;
}
