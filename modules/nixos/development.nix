# modules/nixos/development.nix - Development tools
{ config, pkgs, ... }:

{
  # Development packages
  environment.systemPackages = with pkgs; [
    # JetBrains IDEs
    jetbrains.rider
    jetbrains.datagrip

    # Python development
    uv

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
    fd
    openssl
  ];

  # Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
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
