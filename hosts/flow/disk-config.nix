{
  # Mount the existing 4GB EFI partition (nvme0n1p1) at /boot without wiping
  # /boot/EFI/Microsoft so Windows dual-boot stays intact.
  fileSystems."/boot" = {
    device = "/dev/disk/by-partuuid/4cb2d933-b4ef-4c98-a7dd-f784985a0cb0";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  # Format ONLY the 700GB Linux partition (nvme0n1p2) with plain Btrfs,
  # leaving the GPT table and Windows partitions (nvme0n1p3..p5) completely untouched.
  disko.devices = {
    disk = {
      linux = {
        type = "disk";
        device = "/dev/disk/by-partuuid/f1612475-d2c5-4259-a2f0-2c06ec2471e6";
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "/root" = {
              mountpoint = "/";
              mountOptions = [ "compress=zstd" "noatime" ];
            };
            "/home" = {
              mountpoint = "/home";
              mountOptions = [ "compress=zstd" "noatime" ];
            };
            "/nix" = {
              mountpoint = "/nix";
              mountOptions = [ "compress=zstd" "noatime" ];
            };
          };
        };
      };
    };
  };
}
