# hosts/mydesktop/configuration.nix - Main system configuration
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
  ];

  # System basics
  networking.hostName = "homedesktop";
  networking.networkmanager.enable = true;
  
  # Bootloader - fast but not extreme
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1; # Quick but not instant
  
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

  # Tmpfs root - immutable OS
  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };

  # SSH
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