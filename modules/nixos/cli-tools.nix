# modules/nixos/nvme.nix - Optimizations for nvme disks
{
  config,
  pkgs,
  lib,
  ...
}:
{

  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    iotop
    lm_sensors
    smartmontools

    # Modern CLI tools
    eza # Better ls
    bat # Better cat
    fd # Better find
    ripgrep # Better grep
    dust # Better du
    duf # Better df
  ];
}
