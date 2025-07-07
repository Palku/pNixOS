# hosts/mydesktop/disko.nix - Corrected configuration
{ ... }:
{
  disko.devices = {
    disk = {
      # OS Disk (1TB NVMe) - Performance with persistence structure
      os = {
        type = "disk";
        device = "/dev/nvme0n1"; # ✅ Whole disk, not partition
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
            nix = {
              size = "750G"; # Large nix store partition
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
            persist = {
              size = "100%"; # Rest of space for system persistence
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
      
      # Data Disk - Simple 100% home
      data = {
        type = "disk";
        device = "/dev/nvme1n1"; # ✅ Whole disk, not partition
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "100%"; # ✅ All space for home
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