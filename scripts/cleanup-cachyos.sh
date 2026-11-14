#!/usr/bin/env bash
set -euo pipefail

# Run once booted into NixOS as `chaka` to remove the old CachyOS Btrfs
# subvolumes (@, @home, @root, @srv, @cache, @tmp, @log) plus any nested
# Snapper snapshots, leaving only NixOS (root, home, nix).

BTRFS_DEV="/dev/disk/by-partuuid/f1612475-d2c5-4259-a2f0-2c06ec2471e6"
MNT="/mnt/btrfs-cleanup"

sudo mkdir -p "$MNT"
mountpoint -q "$MNT" || sudo mount -o subvolid=5 "$BTRFS_DEV" "$MNT"

for sub in @ @home @root @srv @cache @tmp @log; do
  if [ -d "$MNT/$sub" ]; then
    echo "==> Deleting $sub (recursively, including snapshots) ..."
    sudo btrfs subvolume delete --recursive "$MNT/$sub"
  fi
done

echo "==> Remaining subvolumes (should only be root, home, nix):"
sudo btrfs subvolume list "$MNT"

sudo umount "$MNT"
sudo rmdir "$MNT"
df -h /
