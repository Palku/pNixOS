# hosts/mydesktop/configuration.nix - Main system configuration with BTRFS impermanence
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # System basics
  networking.hostName = "homedesktop";
  networking.networkmanager.enable = true;

  # Ensure BTRFS support
  boot.supportedFilesystems = [ "btrfs" ];
  boot.initrd.supportedFilesystems = [ "btrfs" ];
  
  # Bootloader - fast but not extreme
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # Quick but not instant
  boot.loader.systemd-boot.configurationLimit = 10;
  
  # BTRFS impermanence setup - reset root on boot
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    mkdir /btrfs_tmp
    mount -o subvol=/ /dev/disk/by-partlabel/root /btrfs_tmp
    
    if [[ -e /btrfs_tmp/root ]]; then
        # Keep a few old roots for debugging
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
        
        # Clean old roots (keep last 2)
        (cd /btrfs_tmp/old_roots && ls -t | tail -n +3 | xargs -r btrfs subvolume delete)
    fi

    # Create fresh root
    btrfs subvolume create /btrfs_tmp/root
    umount /btrfs_tmp
  '';
  
  # Enable flakes and reasonable optimizations
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    max-jobs = "auto"; # Use all CPU cores
    cores = 0; # Use all available cores for building
  };
  
  # Timezone and locale
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # User configuration
  users.users.p = {
    isNormalUser = true;
    description = "p";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "gamemode" "corectrl" ];
    shell = pkgs.zsh;
  };

  # Essential system packages
  environment.systemPackages = with pkgs; [
    git
    nano
    curl
    wget
    tree
    htop
    neofetch
    lm_sensors # For temperature monitoring
    nvtop      # GPU monitoring
  ];

  # Enable ZSH system-wide
  programs.zsh.enable = true;

  # Impermanence configuration - keep immutable OS
  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/etc/nixos"
    ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  # SSH (disabled)
  services.openssh = {
    enable = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Firewall
  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}