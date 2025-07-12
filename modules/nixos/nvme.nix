# modules/nixos/nvme.nix - Optimizations for nvme disks
{
  config,
  pkgs,
  lib,
  ...
}:
{
  boot = {
    kernelParams = [
      "nvme_core.default_ps_max_latency_us=0" # Disable power saving
    ];
  };

  boot.kernel.sysctl = {
    "fs.file-max" = 2097152;
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 256;
  };

  # I/O Scheduler optimizations
  services.udev.extraRules = ''
    # Set appropriate scheduler for SSDs
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"

    # Reasonable readahead for SSDs
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{bdi/read_ahead_kb}="128"
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{bdi/read_ahead_kb}="128"
  '';

  services.smartd.enable = true; # S.M.A.R.T monitoring enable

  # Enable TRIM for SSDs
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };
}
