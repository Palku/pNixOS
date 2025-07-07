# hosts/mydesktop/disko.nix - BTRFS only for root, ext4 for performance
{ ... }:
{
  disko.devices = {
    disk = {
      # OS Disk (1TB NVMe) - Mixed filesystems for optimal performance
      os = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ 
                  "defaults" 
                  "umask=0077"
                ];
              };
            };
            
            # Root partition - BTRFS for snapshots only
            root = {
              size = "50G";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                subvolumes = {
                  # Root subvolume (gets reset)
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
            
            # Nix store - ext4 for maximum performance
            nix = {
              size = "750G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "discard"
                  "barrier=0"
                ];
                extraArgs = [
                  "-m" "1"
                ];
              };
            };
            
            # Persist - ext4 for maximum performance  
            persist = {
              size = "100%"; # ~200G remaining
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/persist";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "discard"
                  "barrier=0"
                ];
                extraArgs = [
                  "-m" "1"
                ];
              };
            };
          };
        };
      };
      
      # Data Disk - Simple ext4
      data = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "discard"
                  "user_xattr"
                  "barrier=0"
                ];
                extraArgs = [
                  "-m" "0"
                ];
              };
            };
          };
        };
      };
    };
  };
}