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

    # BTRFS root rollback service
    initrd.systemd.services.rollback = {
      description = "Rollback BTRFS root subvolume";
      wantedBy = [ "initrd.target" ];
      before = [ "sysroot.mount" ];
      unitConfig.DefaultDependencies = "no";
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /mnt

        # Mount the BTRFS root of OS drive
        mount -o subvol=/ /dev/disk/by-label/nixos /mnt

        # Delete all subvolumes under root
        btrfs subvolume list -o /mnt/root |
        cut -f9 -d' ' |
        while read subvolume; do
          echo "Deleting /$subvolume subvolume"
          btrfs subvolume delete "/mnt/$subvolume"
        done &&
        echo "Deleting /root subvolume" &&
        btrfs subvolume delete /mnt/root

        # Restore blank root
        echo "Restoring blank /root subvolume"
        btrfs subvolume snapshot /mnt/root-blank /mnt/root

        umount /mnt
      '';
    };
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
      "/var/lib/flatpak"
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
