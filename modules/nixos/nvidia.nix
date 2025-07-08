# modules/nixos/nvidia.nix - RTX 4070 Ti Super balanced configuration
{ config, pkgs, lib, ... }:

{
  # Enable OpenGL with performance optimizations
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver # Hardware video acceleration
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # Nvidia drivers - latest for 4070 Ti Super
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    # Use open-source kernel modules (stable for 40-series)
    open = true;
    
    # Nvidia settings menu
    nvidiaSettings = true;
    
    # Use the latest driver for best 4070 Ti Super support
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    
    # Modesetting required for Wayland
    modesetting.enable = true;
    
    # Power management - enable for proper scaling and silence when idle
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    
    # Don't force full composition pipeline (let it scale properly)
    forceFullCompositionPipeline = false;
  };

  # Balanced kernel parameters for RTX 4070 Ti Super
  boot.kernelParams = [
    # Nvidia optimizations
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # Better power management
    
    # Allow proper power scaling
    "nvidia.NVreg_EnableGpuFirmware=1"             # Enable GPU firmware loading
  ];

  # Environment variables for optimal Nvidia + Wayland performance
  environment.sessionVariables = {
    # Nvidia-specific
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    
    # Wayland compatibility
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    
    # GPU acceleration for applications
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    
    # Let applications control VSync (don't force off globally)
    __GL_MaxFramesAllowed = "1"; # Reduce input lag but allow scaling
  };

  # Nvidia packages and monitoring tools
  environment.systemPackages = with pkgs; [
    # Monitoring and control
    nvtopPackages.nvidia
    nvidia-system-monitor-qt
    
    # Video utilities
    ffmpeg-full
    libva-utils
    vdpauinfo
    clinfo # OpenCL info
    
    # GPU control
    nvitop  # Better nvidia-smi alternative
  ];

  # Nvidia container runtime for Docker (if using containers)
  hardware.nvidia-container-toolkit.enable = true;
  
  # Hardware video acceleration
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # Systemd service for optimal GPU power management
  systemd.services.nvidia-power-management = {
    description = "Nvidia GPU power management optimization";
    after = [ "display-manager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.writeShellScript "nvidia-power-setup" ''
        # Enable persistence mode for better power management
        ${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi -pm 1
        
        # Set power management mode to adaptive (scales with load)
        echo auto > /sys/bus/pci/devices/0000:01:00.0/power/control || true
        
        # Enable GPU boost (allows proper scaling)
        ${pkgs.linuxPackages.nvidia_x11}/bin/nvidia-smi -acp 0 || true
      ''}";
    };
  };
}