# modules/nixos/game-controllers
{ config, pkgs, ... }:

{
  # Gaming packages
  environment.systemPackages = with pkgs; [
    game-devices-udev-rules
  ];

  # Kernel modules for controllers
  boot.kernelModules = [
    "uinput"
  ];

  # Udev rules for gaming hardware
  services.udev.packages = with pkgs; [
    game-devices-udev-rules
  ];

  # Udev rules for controller support
  services.udev.extraRules = ''
    # Sony DualSense controller over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

    # Sony DualSense controller over bluetooth hidraw
    KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

    # Xbox controllers
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="02ea", MODE="0660", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="045e", ATTRS{idProduct}=="0719", MODE="0660", TAG+="uaccess"
  '';
}
