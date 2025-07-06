# hosts/mydesktop/disko.nix - Balanced performance EXT4 with persistence
{ ... }:

{
  disko.devices = {
    disk = {
      # OS Disk (1TB NVMe) - Performance with persistence structure
      os = {
        type = "disk";
        device = "/dev/nvme0n1"; # Adjust to your OS disk
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
              size = "400G"; # Large nix store partition
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/nix";
                mountOptions = [
                  "defaults"
                  "noatime"           # Don't update access times
                  "discard"           # Enable TRIM for SSD
                  "barrier=0"         # Disable write barriers (good PSU)
                ];
                extraArgs = [
                  "-m" "1"            # Reserve only 1% for root
                ];
              };
            };
            persist = {
              size = "100%";          # Rest of space for persistence
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
      
      # Data Disk - Performance optimized EXT4
      data = {
        type = "disk";
        device = "/dev/sda"; # Adjust to your data disk
        content = {
          type = "gpt";
          partitions = {
            home = {
              size = "70%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/home";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "discard"
                  "user_xattr"        # Extended attributes
                  "barrier=0"
                ];
                extraArgs = [
                  "-m" "0"              # No space reserved for root on data partition
                ];
              };
            };
            games = {
              size = "20%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/games";
                mountOptions = [
                  "defaults"
                  "noatime"
                  "discard"
                  "barrier=0"
                ];
                extraArgs = [
                  "-m" "0"
                ];
              };
            };
            projects = {
              size = "10%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/mnt/projects";
                mountOptions = [
                  "defaults"
                  "relatime"          # Keep some access time info for development
                  "discard"
                  "user_xattr"
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