# home/applications.nix - Application configurations
{ config, pkgs, ... }:

{
  # Application packages
  home.packages = with pkgs; [
    # Browsers
    firefox
    spotify
    bitwarden-desktop
    # chromium
    # Communication
    discord
    # telegram-desktop
    # Media
    # vlc
    # Utilities
    # file-roller
    # gnome.nautilus
    # pavucontrol
    # blueman
    vscode
    zed-editor
# Games

  ];

  # Firefox configuration
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "media.ffmpeg.vaapi.enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
      };
    };
  };
}
