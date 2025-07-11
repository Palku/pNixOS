# modules/nixos/development.nix - Development tools
{ config, pkgs, ... }:

{
  # Development packages
  environment.systemPackages = with pkgs; [
    # JetBrains IDEs
    jetbrains.rider
    jetbrains.datagrip

    # Editors
    zed-editor

    # Python development
    uv
    # python3

    # Version control
    git
    git-lfs
    gh

    # Build tools
    gnumake
    cmake
    gcc
    clang

    # Container tools
    docker
    docker-compose

    # Utilities
    nil # nix linter dep
    nixd # nix language server
    jq
    yq
    curl
    wget
    tree
    fd
    ripgrep
    bat
    eza
    openssl
    # Test
    # kitty  # Required for default Hyprland config
    egl-wayland # Critical for Nvidia
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Enable development services
  services.postgresql = {
    enable = false;
    package = pkgs.postgresql_15;
    ensureDatabases = [ "development" ];
    ensureUsers = [
      {
        name = "p";
        ensureDBOwnership = true;
      }
    ];
  };

  # Git configuration (global)
  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };
}
