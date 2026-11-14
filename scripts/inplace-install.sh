#!/usr/bin/env bash
set -euo pipefail

# In-Place NixOS Btrfs Subvolume Installer (from CachyOS)
# Creates /root, /home, and /nix Btrfs subvolumes on nvme0n1p2 alongside CachyOS,
# installs NixOS, and clones all user work, Claude history, and Antigravity chat
# history into /mnt/home/chaka using zero-space Btrfs reflinks.

BTRFS_DEV="/dev/disk/by-partuuid/f1612475-d2c5-4259-a2f0-2c06ec2471e6"
BOOT_DEV="/dev/disk/by-partuuid/4cb2d933-b4ef-4c98-a7dd-f784985a0cb0"
BTRFS_TOP="/mnt/btrfs-top"
TARGET="/mnt/nixos"
OLD_HOME="/home/chakka3000"
NEW_HOME="$TARGET/home/chaka"
NIX_BIN="/nix/var/nix/profiles/default/bin"

echo "==> 1/8 Pre-building NixOS system closure (so /boot is not touched until build succeeds) ..."
SYSTEM_PATH="$("$NIX_BIN/nix" --extra-experimental-features "nix-command flakes" \
  build "/home/chakka3000/nixos-config#nixosConfigurations.flow.config.system.build.toplevel" --no-link --print-out-paths)"
echo "    Built system closure: $SYSTEM_PATH"

echo "==> 2/8 Mounting top-level Btrfs volume ($BTRFS_DEV) at $BTRFS_TOP ..."
sudo mkdir -p "$BTRFS_TOP" "$TARGET"
if ! mountpoint -q "$BTRFS_TOP"; then
  sudo mount -o subvolid=5 "$BTRFS_DEV" "$BTRFS_TOP"
fi

echo "==> 3/8 Creating NixOS Btrfs subvolumes (/root, /home, /nix) if not present ..."
for subvol in root home nix; do
  if [ ! -d "$BTRFS_TOP/$subvol" ]; then
    sudo btrfs subvolume create "$BTRFS_TOP/$subvol"
  else
    echo "    Subvolume /$subvol already exists."
  fi
done

echo "==> 4/8 Mounting NixOS target filesystem tree at $TARGET ..."
if ! mountpoint -q "$TARGET"; then
  sudo mount -o subvol=/root,compress=zstd,noatime "$BTRFS_DEV" "$TARGET"
fi
sudo mkdir -p "$TARGET/home" "$TARGET/nix" "$TARGET/boot"
if ! mountpoint -q "$TARGET/home"; then
  sudo mount -o subvol=/home,compress=zstd,noatime "$BTRFS_DEV" "$TARGET/home"
fi
if ! mountpoint -q "$TARGET/nix"; then
  sudo mount -o subvol=/nix,compress=zstd,noatime "$BTRFS_DEV" "$TARGET/nix"
fi
if ! mountpoint -q "$TARGET/boot"; then
  sudo mount -o umask=0077 "$BOOT_DEV" "$TARGET/boot"
fi

echo "==> 5/8 Cleaning old CachyOS kernel/Limine files from /boot (preserving /boot/EFI/Microsoft) ..."
sudo rm -rf \
  "$TARGET/boot/vmlinuz"* \
  "$TARGET/boot/initramfs"* \
  "$TARGET/boot/amd-ucode.img" \
  "$TARGET/boot/limine"* \
  "$TARGET/boot/EFI/limine"

echo "==> 6/8 Running nixos-install --system $SYSTEM_PATH ..."
INSTALL_TOOLS="$("$NIX_BIN/nix" --extra-experimental-features "nix-command flakes" \
  build nixpkgs#nixos-install-tools --no-link --print-out-paths)"
sudo PATH="$INSTALL_TOOLS/bin:$NIX_BIN:$PATH" \
  "$INSTALL_TOOLS/bin/nixos-install" --root "$TARGET" --no-root-passwd --system "$SYSTEM_PATH"

echo "==> 7/8 Cloning user data into /home/chaka via instant Btrfs reflinks (cp --reflink=always) ..."
sudo mkdir -p "$NEW_HOME"

# Copy nixos-config & Programming (excluding 4GB nixpkgs)
sudo rm -rf "$NEW_HOME/nixos-config"
sudo cp -a --reflink=always "$OLD_HOME/nixos-config" "$NEW_HOME/nixos-config"
sudo mkdir -p "$NEW_HOME/Programming"
for dir in "$OLD_HOME"/Programming/*; do
  [ -e "$dir" ] || continue
  base="$(basename "$dir")"
  [ "$base" = "nixpkgs" ] && continue
  sudo cp -a --reflink=always "$dir" "$NEW_HOME/Programming/"
done

# Copy Claude (CLI & Desktop), Antigravity (CLI & IDE, including this chat!), SSH, GPG, SOPS, CLI auth, and systemd user timers
for item in \
  .claude \
  .claude.json \
  .config/Claude \
  .gemini \
  ".config/Antigravity IDE" \
  .config/systemd/user \
  .ssh \
  .gnupg \
  .gitconfig \
  .config/sops \
  .config/gh \
  .config/glab
do
  if [ -e "$OLD_HOME/$item" ]; then
    sudo mkdir -p "$NEW_HOME/$(dirname "$item")"
    sudo cp -a --reflink=always "$OLD_HOME/$item" "$NEW_HOME/$item"
  fi
done

echo "==> 7/7 Updating paths from /home/chakka3000 -> /home/chaka & enabling timers ..."
# Update Claude Code project paths
if [ -d "$NEW_HOME/.claude/projects" ]; then
  for dir in "$NEW_HOME/.claude/projects"/-home-chakka3000*; do
    [ -e "$dir" ] || continue
    new_dir="${dir//-home-chakka3000/-home-chaka}"
    if [ "$dir" != "$new_dir" ]; then
      sudo rm -rf "$new_dir"
      sudo mv "$dir" "$new_dir"
    fi
  done
  sudo find "$NEW_HOME/.claude" -type f \( -name "*.json" -o -name "*.jsonl" \) \
    -exec sed -i "s|$OLD_HOME|/home/chaka|g" {} + 2>/dev/null || true
fi
if [ -f "$NEW_HOME/.claude.json" ]; then
  sudo sed -i "s|$OLD_HOME|/home/chaka|g" "$NEW_HOME/.claude.json"
fi

# Update Antigravity metadata paths so resuming this chat works under /home/chaka
if [ -d "$NEW_HOME/.gemini" ]; then
  sudo find "$NEW_HOME/.gemini" -type f \( -name "*.json" -o -name "*.jsonl" \) \
    -exec sed -i "s|$OLD_HOME|/home/chaka|g" {} + 2>/dev/null || true
fi

# Update Git worktree pointers (.git files and .git/worktrees/*/gitdir)
sudo find "$NEW_HOME/Programming" -maxdepth 4 \( -name ".git" -type f -o -path "*/.git/worktrees/*/gitdir" \) \
  -exec sed -i "s|$OLD_HOME|/home/chaka|g" {} + 2>/dev/null || true

# Update Python .venv scripts
sudo find "$NEW_HOME/Programming" -maxdepth 4 -path "*/.venv/bin/*" -type f \
  -exec sed -i "s|$OLD_HOME|/home/chaka|g" {} + 2>/dev/null || true

# Configure systemd user timers (uv, bun, notify-send paths + timers.target.wants symlinks)
sudo mkdir -p "$NEW_HOME/.local/bin" "$NEW_HOME/.bun/bin" "$NEW_HOME/.config/systemd/user/timers.target.wants"
sudo ln -sf /etc/profiles/per-user/chaka/bin/uv "$NEW_HOME/.local/bin/uv"
sudo ln -sf /etc/profiles/per-user/chaka/bin/bun "$NEW_HOME/.bun/bin/bun"
sudo rm -f "$NEW_HOME/.config/systemd/user/timers.target.wants/arch-update.timer"
sudo ln -sf ../hubval-daily.timer "$NEW_HOME/.config/systemd/user/timers.target.wants/hubval-daily.timer"
sudo ln -sf ../lba-roster.timer "$NEW_HOME/.config/systemd/user/timers.target.wants/lba-roster.timer"

if [ -f "$NEW_HOME/.config/systemd/user/hubval-daily-failed.service" ]; then
  sudo sed -i 's|/usr/bin/notify-send|/etc/profiles/per-user/chaka/bin/notify-send|g' \
    "$NEW_HOME/.config/systemd/user/hubval-daily-failed.service"
fi
for svc in "$NEW_HOME/.config/systemd/user/hubval-daily.service" "$NEW_HOME/.config/systemd/user/lba-roster.service"; do
  if [ -f "$svc" ]; then
    sudo sed -i 's|Environment=PATH=.*|Environment=PATH=%h/.bun/bin:%h/.local/bin:/etc/profiles/per-user/chaka/bin:/run/current-system/sw/bin|g' "$svc"
    if ! grep -q '^Environment=PATH=' "$svc"; then
      sudo sed -i '/^\[Service\]/a Environment=PATH=%h/.bun/bin:%h/.local/bin:/etc/profiles/per-user/chaka/bin:/run/current-system/sw/bin' "$svc"
    fi
  fi
done

# Copy NetworkManager saved Wi-Fi connections so Wi-Fi auto-connects on first NixOS boot
if [ -d /etc/NetworkManager/system-connections ]; then
  sudo mkdir -p "$TARGET/etc/NetworkManager/system-connections"
  sudo cp -a /etc/NetworkManager/system-connections/. "$TARGET/etc/NetworkManager/system-connections/"
  sudo chmod 600 "$TARGET/etc/NetworkManager/system-connections"/* 2>/dev/null || true
fi

# Fix ownership to chaka (UID 1000, GID 100)
sudo chown -R 1000:100 "$NEW_HOME"

sync
echo ""
echo "==> NixOS In-Place Installation Complete!"
echo "==> You can now reboot into NixOS (login: chaka, initial password: changeme)."
echo "==> After logging in, run 'agy' to resume this exact conversation, and run:"
echo "      ~/nixos-config/scripts/cleanup-cachyos.sh"
echo "    when you are ready to delete the old CachyOS @ subvolumes."
