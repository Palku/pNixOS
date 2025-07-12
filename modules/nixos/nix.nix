# modules/nixos/nix.nix - Nix optimizations
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Optimize Nix builds
  nix = {
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      max-jobs = "auto";
      cores = 0; # Use all cores
      auto-optimise-store = true;
      min-free = lib.mkDefault (1024 * 1024 * 1024); # 1GB
      max-free = lib.mkDefault (3 * 1024 * 1024 * 1024); # 3GB
      download-buffer-size = 268435456; # 256MB instead of default 64MB
      download-attempts = 5; # Retry failed downloads
      substituters = [ "https://hyprland.cachix.org" ];
      trusted-substituters = [ "https://hyprland.cachix.org" ];
      trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
    };
  };
  nixpkgs.config.allowUnfree = true;
}
