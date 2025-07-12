# disko-config.nix - Optimized for dual M.2 NVMe drives
{
  disko.devices = {
    disk = {
      # First drive - OS drive (adjust device name as needed)
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "boot";
              size = "1G"; # Larger for multiple kernels/generations
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                  "umask=0077" # Boot security
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  # Root subvolume - will be cleared on boot
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress-force=zstd:1" # Fast compression for OS
                      "noatime"
                      "ssd"
                      "space_cache=v2" # Better for NVMe
                      "discard=async" # TRIM support
                    ];
                  };
                  # NixOS store - never cleared
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress-force=zstd:3" # Higher compression for store
                      "noatime"
                      "ssd"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };
                  # Persistent system data
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "ssd"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };
                  # Swap file for hibernation/emergency
                  "/swap" = {
                    mountpoint = "/.swapvol";
                    swap = {
                      swapfile = {
                        size = "8G"; # Adjust based on your RAM
                      };
                    };
                  };
                  # Snapshot for root rollback
                  "/root-blank" = {
                    mountpoint = "/.root-blank";
                    mountOptions = [
                      "compress-force=zstd:1"
                      "noatime"
                      "ssd"
                      "space_cache=v2"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      # Second drive - Home drive
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1"; # Adjust to your second drive
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "home"
                  "-f"
                ];
                subvolumes = {
                  # Main home subvolume
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "compress=lzo" # Fast compression
                      "noatime" # Better for home dirs
                      "ssd"
                      "space_cache=v2"
                      "discard=async"
                    ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
