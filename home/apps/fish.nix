# Fish shell with performance optimizations
{ config, pkgs, ... }:
{
  programs.fish = {
    enable = true;

    # Fish has excellent tab completion built-in
    interactiveShellInit = ''
      # Enable vi key bindings for performance (optional)
      # fish_vi_key_bindings

      # Fish-specific optimizations
      set -g fish_greeting "" # Disable greeting for faster startup

      # Better directory navigation (fish has this built-in, but we can enhance it)
      set -g fish_autosuggestion_enabled 1

      # Quick system info
      function sysinfo
        echo "=== System Information ==="
        echo "CPU: "(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | string trim)
        echo "GPU: "(nvidia-smi --query-gpu=name --format=csv,noheader,nounits | head -1)
        echo "RAM: "(free -h | awk '/^Mem:/ {print $3 "/" $2}')
        echo "Uptime: "(uptime -p)
        echo "Load: "(uptime | awk -F'load average:' '{print $2}')
      end

      # Performance monitoring
      function perfmon
        echo "=== Performance Monitor ==="
        echo "CPU Governor: "(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo "CPU Frequency: "(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq | awk '{print $1/1000 " MHz"}')
        echo "GPU Power State: "(nvidia-smi --query-gpu=power.state --format=csv,noheader,nounits)
        echo "GPU Utilization: "(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits)"%"
      end
    '';

    # Performance-focused shell aliases
    shellAliases = {
      # Modern replacements for better performance
      ll = "eza -ll --git --group-directories-first";
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

      # Development shortcuts
      myip = "curl -s ifconfig.me";

      # File operations with progress
      cpi = "cp -iv";
      mvi = "mv -iv";
      rmi = "rm -Iv";

      # Disk usage
      du = "dust";
      df = "duf";
    };

    plugins = [
      # Fish plugin manager equivalents
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
    ];
  };

  # Configure fish history
  home.file.".config/fish/conf.d/history.fish".text = ''
    # History configuration for performance
    set -g fish_history_max 50000
    set -g fish_history_save_on_exit 1

    # Remove duplicates from history
    set -g fish_history_ignore_duplicates 1

    # Don't save commands starting with space
    set -g fish_history_ignore_space 1
  '';

  # Fish completions are automatically enabled and very fast
  # No need for additional completion configuration
}
