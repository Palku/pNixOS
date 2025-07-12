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
    # Enable systemd in initrd for rollback service
    initrd.systemd.enable = true;

    initrd.postResumeCommands = lib.mkAfter ''
      mkdir /btrfs_tmp
      mount /dev/disk/by-label/nixos /btrfs_tmp
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi

      delete_subvolume_recursively() {
      IFS=$'\n'
      for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
      done
      btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +5); do
        delete_subvolume_recursively "$i"
      done

      btrfs subvolume create /btrfs_tmp/root
      umount /btrfs_tmp
    '';
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
