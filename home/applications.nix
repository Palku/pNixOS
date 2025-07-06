# home/applications.nix - Application configurations
{ config, pkgs, ... }:

{
  # Application packages
  home.packages = with pkgs; [
    # Browsers
    firefox
    # chromium

    # Communication
    discord
    # telegram-desktop

    # Media
    vlc
    spotify

    # Utilities
    # file-roller
    # gnome.nautilus
    # pavucontrol
    # blueman
    
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