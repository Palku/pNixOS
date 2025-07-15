# modules/nixos/sddm.nix - The simple d? display manager
{
  config,
  pkgs,
  lib,
  ...
}:

{
  services.displayManager.sddm = {
    package = pkgs.kdePackages.sddm; # qt6 sddm version
    enable = true;
    wayland = {
      enable = true;
    };
    autoNumlock = true;
    theme = "sddm-astronaut-theme";
    settings = {
      Theme = {
        Background = "./pixel_sakura.gif";
      };
    };
    extraPackages = with pkgs; [
      sddm-astronaut
      kdePackages.qtmultimedia
      kdePackages.qtsvg
      kdePackages.qtvirtualkeyboard
    ];
  };

  #environment.systemPackages = with pkgs; [
  #  sddm-astronaut
  #];
}
