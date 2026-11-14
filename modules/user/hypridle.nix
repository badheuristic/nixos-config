{ config, pkgs, ... }:

# Idle → lock. The shell picks the hyprlock config matching the island;
# if the shell isn't running, hyprlock starts with its default config.
let
  lock = "${pkgs.quickshell}/bin/qs -c closs ipc call lock lock || pidof hyprlock || hyprlock";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = lock;
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
        ignore_dbus_inhibit = false;
      };
      listener = [
        {
          timeout = 3000;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 6000;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };
}
