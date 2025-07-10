# hosts/mydesktop/hardware-configuration.nix - AMD 5950X balanced configuration
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Kernel - latest for best AMD support
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # Reasonable kernel parameters - no extreme hacks
  boot.kernelParams = [
    # Standard AMD optimizations
    "amd_pstate=active"        # Use AMD P-State driver for better power management
    "amd_iommu=on"            # Enable AMD IOMMU for virtualization
    
    # Reasonable performance tweaks
    "nowatchdog"              # Disable watchdog for slight performance gain
    "quiet"                   # Clean boot messages
  ];

  # Use latest kernel for best AMD Zen 3 support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # CPU microcode - AMD
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable firmware
  hardware.enableRedistributableFirmware = true;

  # Power management - balanced for performance and silence
  powerManagement = {
    enable = true;
    cpuFreqGovernor = lib.mkDefault "schedutil"; # Better than performance, scales down when idle
  };
  
  # AMD specific power management for monitoring
  hardware.cpu.amd.ryzen-smu.enable = true; # Enable Ryzen SMU for better monitoring

  # Enable ZRAM for better memory management
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 10; # Conservative 10% of RAM for compressed swap
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}