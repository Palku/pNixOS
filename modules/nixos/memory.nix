# modules/nixos/performance.nix - Balanced performance optimizations
{
  config,
  pkgs,
  lib,
  ...
}:

{
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "vm.dirty_ratio" = 3;
    "vm.dirty_background_ratio" = 2;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 20;
  };
}
