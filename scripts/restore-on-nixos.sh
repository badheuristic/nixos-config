#!/usr/bin/env bash
set -euo pipefail

# Run this script once booted into NixOS as user `chaka` from your backup folder:
#   ./restore-on-nixos.sh

BACKUP_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLD_HOME="/home/chakka3000"
NEW_HOME="$HOME" # /home/chaka

echo "==> Restoring backup from $BACKUP_ROOT into $NEW_HOME ..."

echo "1/6 Restoring ~/nixos-config ..."
rsync -a "$BACKUP_ROOT/nixos-config/" "$NEW_HOME/nixos-config/"

echo "2/6 Restoring SSH, GPG, SOPS, and CLI auth ..."
if [ -d "$BACKUP_ROOT/dotfiles" ]; then
  cp -a "$BACKUP_ROOT/dotfiles/." "$NEW_HOME/"
  [ -d "$NEW_HOME/.ssh" ] && chmod 700 "$NEW_HOME/.ssh" && chmod 600 "$NEW_HOME/.ssh"/* 2>/dev/null || true
fi

echo "3/6 Extracting Claude Code & Claude Desktop history ..."
tar --zstd -xf "$BACKUP_ROOT/claude-data.tar.zst" -C "$NEW_HOME"

# Update /home/chakka3000 -> /home/chaka in Claude Code project directory names & config
if [ -d "$NEW_HOME/.claude/projects" ]; then
  for dir in "$NEW_HOME/.claude/projects"/-home-chakka3000*; do
    [ -e "$dir" ] || continue
    new_dir="${dir//-home-chakka3000/-home-chaka}"
    if [ "$dir" != "$new_dir" ]; then
      mv "$dir" "$new_dir"
    fi
  done
  find "$NEW_HOME/.claude" -type f \( -name "*.json" -o -name "*.jsonl" \) \
    -exec sed -i "s|$OLD_HOME|$NEW_HOME|g" {} + 2>/dev/null || true
fi
if [ -f "$NEW_HOME/.claude.json" ]; then
  sed -i "s|$OLD_HOME|$NEW_HOME|g" "$NEW_HOME/.claude.json"
fi

echo "4/6 Extracting ~/Programming & repairing Git worktree paths ..."
tar --zstd -xf "$BACKUP_ROOT/programming.tar.zst" -C "$NEW_HOME"

# Fix hardcoded /home/chakka3000 paths inside git worktrees (.git files and worktree gitdir pointers)
find "$NEW_HOME/Programming" -maxdepth 4 \( -name ".git" -type f -o -path "*/.git/worktrees/*/gitdir" \) \
  -exec sed -i "s|$OLD_HOME|$NEW_HOME|g" {} + 2>/dev/null || true

# Fix hardcoded /home/chakka3000 paths in Python .venv scripts inside Programming
find "$NEW_HOME/Programming" -maxdepth 4 -path "*/.venv/bin/*" -type f \
  -exec sed -i "s|$OLD_HOME|$NEW_HOME|g" {} + 2>/dev/null || true

echo "5/6 Restoring systemd user timers (hubval-daily & lba-roster) ..."
mkdir -p "$NEW_HOME/.config/systemd/user"
cp -a "$BACKUP_ROOT/systemd-user/." "$NEW_HOME/.config/systemd/user/"

# Symlink uv and bun into ~/.local/bin and ~/.bun/bin so the original service files
# work identically without modifying their ExecStart paths
mkdir -p "$NEW_HOME/.local/bin" "$NEW_HOME/.bun/bin"
ln -sf /etc/profiles/per-user/chaka/bin/uv "$NEW_HOME/.local/bin/uv"
ln -sf /etc/profiles/per-user/chaka/bin/bun "$NEW_HOME/.bun/bin/bun"

# Ensure PATH in systemd user services includes NixOS user & system profiles, and fix /usr/bin/notify-send
if [ -f "$NEW_HOME/.config/systemd/user/hubval-daily-failed.service" ]; then
  sed -i 's|/usr/bin/notify-send|/etc/profiles/per-user/chaka/bin/notify-send|g' \
    "$NEW_HOME/.config/systemd/user/hubval-daily-failed.service"
fi
for svc in "$NEW_HOME/.config/systemd/user/hubval-daily.service" "$NEW_HOME/.config/systemd/user/lba-roster.service"; do
  if [ -f "$svc" ]; then
    sed -i 's|Environment=PATH=.*|Environment=PATH=%h/.bun/bin:%h/.local/bin:/etc/profiles/per-user/chaka/bin:/run/current-system/sw/bin|g' "$svc"
    if ! grep -q '^Environment=PATH=' "$svc"; then
      sed -i '/^\[Service\]/a Environment=PATH=%h/.bun/bin:%h/.local/bin:/etc/profiles/per-user/chaka/bin:/run/current-system/sw/bin' "$svc"
    fi
  fi
done

echo "6/6 Enabling and starting hubval-daily.timer and lba-roster.timer ..."
systemctl --user daemon-reload
systemctl --user enable --now hubval-daily.timer lba-roster.timer

echo ""
echo "==> Restore complete! Active user timers:"
systemctl --user list-timers --all --no-pager
