# flake.nix - Root flake configuration
{
  description = "Balanced High-Performance NixOS Configuration - AMD 5950X + RTX 4070 Ti Super";

  inputs = {
    # Use unstable for latest packages and Nvidia drivers
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Home Manager - unstable for latest features
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware-specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Disk management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence for true immutability
    impermanence.url = "github:nix-community/impermanence";

    # Hyprland - latest version
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nixos-hardware,
      disko,
      impermanence,
      hyprland,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        # Replace with your hostname
        homedesktop = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            # Core modules
            disko.nixosModules.disko
            impermanence.nixosModules.impermanence
            home-manager.nixosModules.home-manager
            hyprland.nixosModules.default

            # Hardware configuration
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
            nixos-hardware.nixosModules.common-pc-ssd

            # Host-specific configuration
            ./hosts/homedesktop/configuration.nix
            ./hosts/homedesktop/hardware-configuration.nix
            ./hosts/homedesktop/disko.nix

            # System modules

            ## Common modules
            ./modules/nixos/audio.nix
            ./modules/nixos/cli-tools.nix
            ./modules/nixos/locale-swe.nix
            ./modules/nixos/memory.nix
            ./modules/nixos/network.nix
            ./modules/nixos/nix.nix
            ./modules/nixos/systemd.nix
            ./modules/nixos/desktop.nix
            ./modules/nixos/sddm.nix

            ## Amd CPU
            ./modules/nixos/cpu-amd.nix

            ## Nvidia GPU
            ./modules/nixos/gpu-nvidia.nix

            ## Nvme Drives
            ./modules/nixos/nvme.nix

            ## Gaming
            ./modules/nixos/game-controllers.nix

            ## Development
            ./modules/nixos/development.nix

            # Home Manager configuration
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                extraSpecialArgs = {
                  inherit hyprland;
                };
                users.p = import ./home/p.nix;
              };
            }
          ];
          specialArgs = { inherit hyprland; };
        };
      };
    };
}
