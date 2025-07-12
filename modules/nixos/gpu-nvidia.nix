# modules/nixos/nvidia.nix — For Nvidia 4070 Ti Super, Wayland-ready
{
  config,
  pkgs,
  lib,
  ...
}:

{
  nixpkgs.config.allowUnfree = lib.mkForce true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      egl-wayland
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      egl-wayland
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    open = true; # use mixed proprietary + open kernel modules
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    forceFullCompositionPipeline = false;
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  boot.initrd.kernelModules = [
    "nvidia"
    "nvidia_modeset"
    "nvidia_uvm"
    "nvidia_drm"
  ];

  systemd.services.nvidia-suspend = {
    enable = true;
    wantedBy = [ "systemd-suspend.service" ];
  };
  systemd.services.nvidia-resume = {
    enable = true;
    wantedBy = [ "systemd-resume.service" ];
  };

  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "nvidia";
    XDG_SESSION_TYPE = "wayland";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    MOZ_ENABLE_WAYLAND = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    __GL_MaxFramesAllowed = "1";
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    nvidia-system-monitor-qt
    ffmpeg-full
    libva-utils
    vdpauinfo
    clinfo
    nvitop
  ];

  hardware.nvidia-container-toolkit.enable = true;

  systemd.services.nvidia-power-management = {
    description = "Enable NVIDIA persistence mode";
    after = [ "multi-user.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.bin}/bin/nvidia-smi -pm 1";
    };
  };
}
