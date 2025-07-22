# modules/nixos/development.nix - Development tools
{ config, pkgs, ... }:

{
  # Development packages
  environment.systemPackages = with pkgs; [
    # JetBrains IDEs
    jetbrains.rider
    jetbrains.datagrip

    # .Net development
    dotnet-sdk_9

    # Python development
    uv

    # Android development
    apksigner

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
    unzip
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
