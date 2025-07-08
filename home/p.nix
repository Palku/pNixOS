# home/p.nix - Home Manager configuration
{ config, pkgs, hyprland, ... }:

{
  imports = [
    ./hyprland.nix
    ./terminal.nix
    ./applications.nix
  ];

  home.username = "p";
  home.homeDirectory = "/home/p";

  # Persistence for home directory
  home.persistence."/home/p" = {
    directories = [
      "Documents"
      "Pictures"
      "Videos"
      "Downloads"
      "Music"
      "Projects"
      ".ssh"
      ".gnupg"
      ".local/share/keyrings"
      ".local/share/Steam"
      ".config/JetBrains"
      ".config/zed"
      ".config/corectrl"  # AMD GPU/CPU control tool
    ];
    files = [
      ".gitconfig"
      ".zsh_history"
    ];
    allowOther = true;
  };

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Johan Lindberg";
    userEmail = "johan.lindberg@seamen.se";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      # Performance optimizations
      core.preloadindex = true;
      core.fscache = true;
      gc.auto = 256;
    };
  };

  # Enable home-manager
  programs.home-manager.enable = true;
  home.stateVersion = "25.05";
}