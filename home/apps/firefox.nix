# Firefox configuration
{ config, pkgs, ... }:

{
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
