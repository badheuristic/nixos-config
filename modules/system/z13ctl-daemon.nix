{ pkgs, lib, ... }:

# z13ctl as a declarative service: what `z13ctl setup` would install, done the
# NixOS way. The user daemon owns the HID lighting devices and exposes a
# socket the Closs shell's Armoury panel talks to.
#
# The daemon's own Armoury-button watcher is disabled (--no-button): it grabs
# the whole "Asus WMI hotkeys" device exclusively, which would also swallow
# the other Fn keys on it. Hyprland binds the key (XF86Launch3) instead.
let
  z13ctl = pkgs.callPackage ./z13ctl.nix { };
  group = "users";
  chgrp = "${pkgs.coreutils}/bin/chgrp";
  chmod = "${pkgs.coreutils}/bin/chmod";
  sh = "${pkgs.bash}/bin/sh";

  # Group-writable sysfs knobs that only exist after the drivers settle.
  grantSysfs = pkgs.writeShellScript "z13ctl-perms" ''
    for f in \
      /sys/firmware/acpi/platform_profile \
      /sys/class/platform-profile/*/profile \
      /sys/class/power_supply/BAT*/charge_control_end_threshold \
      /sys/class/firmware-attributes/asus-armoury/attributes/boot_sound/current_value \
      /sys/class/firmware-attributes/asus-armoury/attributes/panel_overdrive/current_value \
      /sys/devices/platform/asus-nb-wmi/ppt_* \
      /sys/kernel/ryzen_smu_drv/smu_args \
      /sys/kernel/ryzen_smu_drv/mp1_smu_cmd \
      /sys/kernel/ryzen_smu_drv/rsmu_cmd; do
      [ -e "$f" ] && ${chgrp} ${group} "$f" && ${chmod} g+w "$f" || true
    done
    # fan curves: only the ASUS hwmon devices
    for h in /sys/class/hwmon/hwmon*; do
      case "$(cat "$h/name" 2>/dev/null)" in
        asus|asus_custom_fan_curve)
          for f in "$h"/pwm*; do [ -e "$f" ] && ${chgrp} ${group} "$f" && ${chmod} g+w "$f"; done ;;
      esac
    done
  '';
in
{
  environment.systemPackages = [ z13ctl ];

  services.udev.extraRules = ''
    # z13ctl: Aura HID (keyboard 1a30, lightbar 18c6)
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="18c6", MODE="0660", GROUP="${group}"
    SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1a30", MODE="0660", GROUP="${group}"
    # z13ctl: performance profile, fan curves, PPT/TDP
    ACTION=="add", SUBSYSTEM=="platform-profile", RUN+="${chgrp} ${group} /sys%p/profile", RUN+="${chmod} g+w /sys%p/profile"
    ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="asus_custom_fan_curve", RUN+="${sh} -c '${chgrp} ${group} /sys%p/pwm*; ${chmod} g+w /sys%p/pwm*'"
    ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="asus", RUN+="${sh} -c 'for f in /sys%p/pwm*_enable; do [ -e \"$$f\" ] && ${chgrp} ${group} \"$$f\" && ${chmod} g+w \"$$f\"; done'"
    ACTION=="add", SUBSYSTEM=="platform", KERNEL=="asus-nb-wmi", RUN+="${sh} -c 'for f in /sys/devices/platform/asus-nb-wmi/ppt_*; do [ -e \"$$f\" ] && ${chgrp} ${group} \"$$f\" && ${chmod} g+w \"$$f\"; done'"
  '';

  # Battery threshold and firmware attributes appear after udev's last event
  # for their parents, so a oneshot catches the rest (and re-runs on resume).
  systemd.services.z13ctl-perms = {
    description = "Grant z13ctl group access to ASUS sysfs attributes";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    # after ryzen_smu loads, so its sysfs nodes exist
    after = [ "systemd-udev-settle.service" "systemd-modules-load.service" "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = grantSysfs;
    };
  };

  # Charge limit: the firmware forgets it on every boot, so set 80% at startup.
  # Changing it from the Armoury panel lasts until the next reboot.
  systemd.services.battery-charge-limit = {
    description = "Limit battery charge to 80%";
    wantedBy = [ "multi-user.target" ];
    after = [ "systemd-udev-settle.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${sh} -c 'for f in /sys/class/power_supply/BAT*/charge_control_end_threshold; do echo 80 > \"$f\"; done'";
    };
  };

  # The daemon (socket-activated per user; Closs connects at login).
  systemd.user.sockets.z13ctl = {
    description = "z13ctl control socket";
    wantedBy = [ "sockets.target" ];
    socketConfig = {
      ListenStream = "%t/z13ctl/z13ctl.sock";
      SocketMode = "0600";
      DirectoryMode = "0700";
    };
  };

  systemd.user.services.z13ctl = {
    description = "z13ctl device daemon";
    requires = [ "z13ctl.socket" ];
    after = [ "z13ctl.socket" ];
    serviceConfig = {
      Type = "notify";
      ExecStart = "${z13ctl}/bin/z13ctl --no-button daemon";
      Restart = "on-failure";
    };
  };
}
