# hosts/mydesktop/configuration.nix - Main system configuration with BTRFS impermanence
{
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "homedesktop";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    supportedFilesystems = [ "btrfs" ];
    initrd = {
      supportedFilesystems = [ "btrfs" ];
      systemd.enable = true;
      
      # Create systemd service for root rollback
#      systemd.services.rollback-root = {
#        description = "Rollback BTRFS root subvolume";
#        wantedBy = [ "initrd.target" ];
#        after = [ "systemd-cryptsetup@.service" ];
#        before = [ "sysroot.mount" ];
#        unitConfig.DefaultDependencies = "no";
#        serviceConfig.Type = "oneshot";
#        script = ''
#          set -euo pipefail
    
#          # Use the actual partition device (part2 = root partition)
#          DEVICE="/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_S5GXNG0NB07224Z-part2"
    
#          echo "Waiting for device $DEVICE..."
#          until [ -e "$DEVICE" ]; do
#            sleep 0.1
#          done
    
#          mkdir -p /btrfs_tmp
#          mount -t btrfs "$DEVICE" /btrfs_tmp
    
#          if [[ -e /btrfs_tmp/root ]]; then
#            mkdir -p /btrfs_tmp/old_roots
#            timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
#            mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
#          fi
    
#          delete_subvolume_recursively() {
#            IFS=$'\n'
#            for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
#              delete_subvolume_recursively "/btrfs_tmp/$i"
#            done
#            btrfs subvolume delete "$1"
#          }
    
#          for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +5 2>/dev/null || true); do
#            delete_subvolume_recursively "$i"
#          done
    
#          btrfs subvolume create /btrfs_tmp/root
#          umount /btrfs_tmp
#        '';
#      };
    };
    loader = {
      timeout = 3;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10; # Keep 10 generations
    };

    kernelParams = [
      "nowatchdog" # Disable watchdog for slight performance gain
      "quiet" # Clean boot messages
    ];
  };

  # Override disko-generated filesystem options
  fileSystems."/persist" = {
    neededForBoot = true;
  };

  # BTRFS maintenance
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [
      "/"
      "/home"
    ];
  };

  # Impermanence configuration
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/var/lib/docker"
      "/var/lib/libvirt"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  # User configuration
  users.users.p = {
    isNormalUser = true;
    description = "p";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "corectrl"
    ];
    shell = pkgs.fish;
  };

  environment.variables.EDITOR = "zed-editor";

  # Enable Fish system-wide
  programs.fish.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };

  # SSH (disabled)
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  system.stateVersion = "25.05";
}
