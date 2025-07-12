# home/p.nix - Home Manager configuration
{
  config,
  pkgs,
  hyprland,
  ...
}:

{
  imports = [
    ./hyprland.nix
    #./apps/zsh.nix
    ./apps/fish.nix
    ./apps/alacritty.nix
    ./apps/starship.nix
    ./apps/firefox.nix
    ./apps/zed-editor.nix
    ./packages.nix
  ];

  home.username = "p";
  home.homeDirectory = "/home/p";

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
