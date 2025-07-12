# modules/nixos/cpu-amd.nix - Optimizations for AMD cpus
{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernelParams = [
      "amd_pstate=active" # Use AMD P-State driver for better power management
      "amd_iommu=on" # Enable AMD IOMMU for virtualization
    ];
    kernelModules = [ "kvm-amd" ];
  };

  # Enable thermal monitoring without interference
  services.thermald.enable = false; # Let AMD handle thermal management natively
  services.power-profiles-daemon.enable = false; # Use our own power management

  # Enable CPU microcode updates
  hardware.cpu.amd.updateMicrocode = true;
  hardware.cpu.amd.ryzen-smu.enable = true; # Enable Ryzen SMU for better monitoring

  # Performance monitoring packages
  environment.systemPackages = with pkgs; [
    zenmonitor # AMD Zen CPU monitoring
    corectrl # AMD GPU/CPU control
  ];

  # Power management
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = false;
  };
}
