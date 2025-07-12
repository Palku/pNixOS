# modules/nixos/performance.nix - Balanced performance optimizations
{
  config,
  pkgs,
  lib,
  ...
}:

{

  # Systemd optimizations (reasonable)
  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=20s
      DefaultTimeoutStartSec=20s
    '';

    user.extraConfig = ''
      DefaultTimeoutStopSec=20s
      DefaultTimeoutStartSec=20s
    '';
  };
}
