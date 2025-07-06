# home/terminal.nix - High-performance terminal configuration
{ config, pkgs, ... }:

{
  # Alacritty terminal - optimized for performance
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

  # Zsh with performance optimizations
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;

    # Performance-focused shell aliases
    shellAliases = {
      # Modern replacements for better performance
      ll = "eza -la --git --group-directories-first";
      ls = "eza --group-directories-first";
      la = "eza -la --git --group-directories-first";
      tree = "eza --tree";
      cat = "bat --paging=never";
      grep = "rg";
      find = "fd";
      
      # System management
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config --fast";
      update = "cd ~/nixos-config && nix flake update && sudo nixos-rebuild switch --flake . --fast";
      clean = "sudo nix-collect-garbage -d && nix-store --optimize";
      
      # Performance monitoring
      cpu = "watch -n1 'cat /proc/cpuinfo | grep MHz'";
      temp = "watch -n1 sensors";
      gpu = "watch -n1 nvidia-smi";
      top = "htop";
      iotop = "sudo iotop";
      
      # Gaming shortcuts
      gamemode-status = "gamemoded -s";
      steam-perf = "gamemode steam";
      
      # Quick performance tweaks
      perf-mode = "sudo cpupower frequency-set -g performance";
      power-save = "sudo cpupower frequency-set -g powersave";
      
      # Development shortcuts
      serve = "python -m http.server 8000";
      myip = "curl -s ifconfig.me";
      
      # File operations with progress
      cpi = "cp -iv";
      mvi = "mv -iv";
      rmi = "rm -Iv";
      
      # Disk usage
      du = "dust";
      df = "duf";
    };

    # History optimization
    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
    };

    # Oh-my-zsh with minimal plugins for performance
    oh-my-zsh = {
      enable = true;
      plugins = [ 
        "git" 
        "docker" 
        "systemd"
        "sudo"
      ];
      theme = "robbyrussell"; # Lightweight theme
    };

    # Additional optimizations
    initExtra = ''
      # Faster directory navigation
      setopt AUTO_CD
      setopt AUTO_PUSHD
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      
      # Better globbing
      setopt EXTENDED_GLOB
      setopt GLOB_DOTS
      
      # Performance optimizations
      setopt HIST_FCNTL_LOCK
      setopt HIST_REDUCE_BLANKS
      setopt HIST_VERIFY
      
      # Gaming functions
      gamemode-start() {
        systemctl --user start gamemode-optimization.service
        echo "Gaming optimizations enabled"
      }
      
      gamemode-stop() {
        systemctl --user stop gamemode-optimization.service  
        echo "Gaming optimizations disabled"
      }
      
      # Quick system info
      sysinfo() {
        echo "=== System Information ==="
        echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)"
        echo "GPU: $(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)"
        echo "RAM: $(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
        echo "Uptime: $(uptime -p)"
        echo "Load: $(uptime | awk -F'load average:' '{print $2}')"
      }
      
      # Performance monitoring
      perfmon() {
        echo "=== Performance Monitor ==="
        echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
        echo "CPU Frequency: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk '{print $1/1000 " MHz"}')"
        echo "GPU Power State: $(nvidia-smi --query-gpu=power.state --format=csv,noheader,nounits)"
        echo "GPU Utilization: $(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)%"
      }
    '';
  };

  # Starship prompt - fast and informative
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      
      # Minimal format for speed
      format = "$directory$git_branch$git_status$cmd_duration$character";
      
      # Show command duration for performance awareness
      cmd_duration = {
        min_time = 500;
        format = "[$duration]($style) ";
        style = "yellow";
      };
      
      # Git optimization
      git_branch = {
        format = "[$branch]($style) ";
        style = "purple";
      };
      
      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "red";
        conflicted = "🏳";
        ahead = "🏎💨";
        behind = "😰";
        diverged = "😵";
        up_to_date = "✓";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "👍";
        renamed = "👅";
        deleted = "🗑";
      };
      
      # Directory display
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "cyan";
      };
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Additional performance tools
  home.packages = with pkgs; [
    # Modern CLI tools for performance
    eza      # Better ls
    bat      # Better cat  
    fd       # Better find
    ripgrep  # Better grep
    dust     # Better du
    duf      # Better df
    bottom   # Better top
    procs    # Better ps
    
    # Network tools
    bandwhich # Network usage
    dog       # Better dig
    
    # System monitoring
    btop     # Beautiful system monitor
    zenith   # System monitor
  ];
}