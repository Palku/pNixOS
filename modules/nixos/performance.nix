# modules/nixos/performance.nix - Balanced performance optimizations
{ config, pkgs, lib, ... }:

{
  # I/O Scheduler optimizations
  services.udev.extraRules = ''
    # Set appropriate scheduler for SSDs
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    
    # Reasonable readahead for SSDs
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{bdi/read_ahead_kb}="128"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{bdi/read_ahead_kb}="128"
  '';

  # CPU frequency scaling - balanced for performance and silence
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil"; # Scales up fast, down gradually for silence
    powertop.enable = false; # Don't interfere with our tuning
  };

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

  # Network and system optimizations (conservative)
  boot.kernel.sysctl = {
    # Modern TCP optimizations
    "net.core.default_qdisc" = "fq_codel";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    
    # Conservative memory settings
    "vm.swappiness" = 10;            # Low but reasonable
    "vm.dirty_ratio" = 20;           # Keep defaults
    "vm.dirty_background_ratio" = 10;
    
    # File system (reasonable limits)
    "fs.file-max" = 2097152;
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 256;
  };

  # Faster DNS resolution
  services.resolved = {
    enable = true;
    dnssec = "false"; # Slight performance boost
    domains = [ "~." ];
    fallbackDns = [ "1.1.1.1" "8.8.8.8" ];
    extraConfig = ''
      DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
      DNSOverTLS=yes
      Cache=yes
    '';
  };

  # Optimize Nix builds
  nix = {
    settings = {
      max-jobs = "auto";
      cores = 0; # Use all cores
      auto-optimise-store = true;
      min-free = lib.mkDefault (1024 * 1024 * 1024); # 1GB
      max-free = lib.mkDefault (3 * 1024 * 1024 * 1024); # 3GB
    };
  };

  # Performance monitoring packages
  environment.systemPackages = with pkgs; [
    # System monitoring
    htop
    btop
    iotop
    nvtop
    lm_sensors
    smartmontools
    
    # AMD-specific tools
    zenmonitor   # AMD Zen CPU monitoring
    corectrl     # AMD GPU/CPU control
    
    # Performance analysis
    sysbench
    stress-ng
    
    # Modern CLI tools
    eza          # Better ls
    bat          # Better cat
    fd           # Better find
    ripgrep      # Better grep
    dust         # Better du
    duf          # Better df
  ];

  # Enable hardware monitoring
  services.smartd.enable = true;
  
  # Enable thermal monitoring without interference
  services.thermald.enable = false; # Let AMD handle thermal management natively
  services.power-profiles-daemon.enable = false; # Use our own power management
  
  # Enable CoreCtrl for AMD GPU/CPU management
  # programs.corectrl = {
  #  enable = true;
  #  gpuOverclock.enable = true;
  # };
  
  # Gaming performance optimizations (reasonable)
  security.pam.loginLimits = [
    { domain = "@gamemode"; item = "nice"; type = "soft"; value = "-10"; }
    { domain = "@gamemode"; item = "rtprio"; type = "soft"; value = "20"; }
  ];

  # Enable CPU microcode updates
  hardware.cpu.amd.updateMicrocode = true;
}