#!/usr/bin/env bash
set -euo pipefail

# One-step backup script before installing NixOS.
# Saves ~/Programming (excluding 4GB nixpkgs clone), Claude Code + Claude Desktop
# history, systemd user timers, SSH/GPG/SOPS/GitHub/GitLab auth, and nixos-config
# onto an external drive / SD card (defaults to /dev/mmcblk0p1 if mounted or auto-mounted).

MOUNT_DIR="${1:-/mnt/nixos-backup}"
SD_DEV="/dev/mmcblk0p1"

if ! mountpoint -q "$MOUNT_DIR"; then
  if [ -b "$SD_DEV" ]; then
    echo "==> Mounting $SD_DEV at $MOUNT_DIR ..."
    sudo mkdir -p "$MOUNT_DIR"
    sudo mount -o uid="$(id -u)",gid="$(id -g)" "$SD_DEV" "$MOUNT_DIR"
  else
    echo "ERROR: $MOUNT_DIR is not mounted and $SD_DEV not found."
    echo "Usage: $0 /path/to/backup/drive"
    exit 1
  fi
fi

BACKUP_ROOT="$MOUNT_DIR/chaka-migration-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_ROOT"

echo "==> Backing up to: $BACKUP_ROOT"

echo "1/5 Backing up ~/nixos-config ..."
rsync -a --info=progress2 ~/nixos-config/ "$BACKUP_ROOT/nixos-config/"

echo "2/5 Backing up systemd user timers & services (~/.config/systemd/user) ..."
mkdir -p "$BACKUP_ROOT/systemd-user"
cp -a ~/.config/systemd/user/. "$BACKUP_ROOT/systemd-user/"

echo "3/5 Backing up SSH, GPG, SOPS, GitHub/GitLab CLI configs, and ~/.local/bin ..."
mkdir -p "$BACKUP_ROOT/dotfiles"
for item in .ssh .gnupg .gitconfig .claude.json .gemini ".config/Antigravity IDE" .config/sops .config/gh .config/glab; do
  if [ -e "$HOME/$item" ]; then
    mkdir -p "$BACKUP_ROOT/dotfiles/$(dirname "$item")"
    cp -a "$HOME/$item" "$BACKUP_ROOT/dotfiles/$item"
  fi
done

echo "4/5 Archiving Claude Code (~/.claude) and Claude Desktop (~/.config/Claude) ..."
tar --zstd -cf "$BACKUP_ROOT/claude-data.tar.zst" \
  -C "$HOME" \
  --exclude='.config/Claude/Cache*' \
  --exclude='.config/Claude/Code Cache*' \
  --exclude='.config/Claude/GPUCache*' \
  .claude .claude.json .config/Claude

echo "5/5 Archiving ~/Programming (excluding ~/Programming/nixpkgs) ..."
tar --zstd -cf "$BACKUP_ROOT/programming.tar.zst" \
  -C "$HOME" \
  --exclude='Programming/nixpkgs' \
  Programming

cp -a ~/nixos-config/scripts/restore-on-nixos.sh "$BACKUP_ROOT/restore-on-nixos.sh"
chmod +x "$BACKUP_ROOT/restore-on-nixos.sh"

sync
echo ""
echo "==> Backup complete!"
du -sh "$BACKUP_ROOT"/*
echo "==> Saved at: $BACKUP_ROOT"
