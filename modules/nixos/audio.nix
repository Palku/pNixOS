# modules/nixos/gaming.nix - Balanced gaming configuration
{ config, pkgs, ... }:

{
  # Gaming packages
  environment.systemPackages = with pkgs; [
    pavucontrol
  ];

  # Audio optimizations for gaming (reasonable latency)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Balanced latency configuration
    extraConfig.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256; # Reasonable latency
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };
  };
}
