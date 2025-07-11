# modules/nixos/gaming.nix - Balanced gaming configuration
{ config, pkgs, ... }:

{
  # Steam with reasonable optimizations
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
    #gamescopeSession.enable = true;
  };

  # GameMode for automatic performance optimizations
  #programs.gamemode = {
  #  enable = true;
  #  settings = {
  #     general = {
  #       renice = 10;
  #       ioprio = 0;
  #       inhibit_screensaver = 1;
  #       softrealtime = "auto";
  #       reaper_freq = 5;
  #     };

  #     # Reasonable GPU optimizations
  #     gpu = {
  #       apply_gpu_optimisations = "accept-responsibility";
  #       gpu_device = 0;
  #     };

  #     # Balanced CPU optimizations
  #     cpu = {
  #       park_cores = "no";
  #       pin_cores = "no";
  #     };

  #     # Custom scripts for notifications
  #     custom = {
  #       start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
  #       end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
  #     };
  #   };
  # };

  # Gamescope for better gaming performance
  #programs.gamescope = {
  #  enable = true;
  #  capSysNice = true;
  #};

  # Gaming packages
  environment.systemPackages = with pkgs; [
    # Game launchers and compatibility
    # lutris
    # heroic
    # bottles

    # Wine and compatibility
    # wineWowPackages.stable
    # winetricks
    # protontricks

    # Performance monitoring
    mangohud
    goverlay  # GUI for MangoHud
    #gamemode
    #gamescope

    # Controller support
    game-devices-udev-rules

    # Vulkan tools
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers

    # Audio for gaming
    pavucontrol
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

  # Audio optimizations for gaming (reasonable latency)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # Balanced latency configuration
    extraConfig.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 256; # Reasonable latency
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 8192;
      };
    };
  };

  # Gaming-specific groups
  users.groups.gamemode = {};

  # Reasonable limits for gaming performance
  security.pam.loginLimits = [
    { domain = "@gamemode"; item = "nice"; type = "soft"; value = "-10"; }
    { domain = "@gamemode"; item = "rtprio"; type = "soft"; value = "20"; }
  ];

  # Gaming environment variables (let games control their own settings)
  environment.sessionVariables = {
    # Enable MangoHud for performance monitoring (optional)
    # MANGOHUD = "1";  # Uncomment if you want it always on

    # Enable GPU threading
    __GL_THREADED_OPTIMIZATIONS = "0";
  };
}
