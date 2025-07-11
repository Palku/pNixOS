# Alacritty terminal - optimized for performance

{ config, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = {
          x = 10;
          y = 10;
        };
        opacity = 0.95; # Slightly transparent for style
        dynamic_title = true;
      };

      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        bold = {
          family = "JetBrains Mono";
          style = "Bold";
        };
        italic = {
          family = "JetBrains Mono";
          style = "Italic";
        };
        size = 12.0;
      };

      colors = {
        primary = {
          background = "0x1e1e2e";
          foreground = "0xcdd6f4";
        };
        normal = {
          black = "0x45475a";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xbac2de";
        };
        bright = {
          black = "0x585b70";
          red = "0xf38ba8";
          green = "0xa6e3a1";
          yellow = "0xf9e2af";
          blue = "0x89b4fa";
          magenta = "0xf5c2e7";
          cyan = "0x94e2d5";
          white = "0xa6adc8";
        };
      };

      # Performance optimizations
      scrolling = {
        history = 50000;
        multiplier = 3;
      };

      cursor = {
        style = {
          shape = "Block";
          blinking = "Off"; # Disable for performance
        };
      };

      env = {
        TERM = "alacritty";
      };
    };
  };
}
