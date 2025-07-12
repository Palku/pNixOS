# modules/nixos/desktop.nix - Desktop environment
{
  config,
  pkgs,
  hyprland,
  ...
}:

{

  environment.systemPackages = [
    pkgs.kdePackages.dolphin # File manager
    pkgs.kdePackages.qtsvg # Dep for kde(Dolphin)
  ];

  # Hyprland
  programs.hyprland = {
    enable = true;
    package = hyprland.packages."x86_64-linux".hyprland;
    portalPackage = hyprland.packages."x86_64-linux".xdg-desktop-portal-hyprland;
  };

  # In modules/nixos/desktop.nix, add:
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # This helps with portal configuration
    config = {
      common = {
        default = [
          "hyprland"
          "gtk"
        ];
      };
    };
  };

  # Audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Fonts
  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      jetbrains-mono
      font-awesome
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        monospace = [ "JetBrains Mono" ];
      };
    };
  };

  # Polkit
  security.polkit.enable = true;

  # GNOME Keyring
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
