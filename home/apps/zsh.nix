# Zsh with performance optimizations
{ config, pkgs, ... }:

{

programs.zsh = {
  enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;

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
  initContent = ''
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
}
