{ config, pkgs, ... }:

let
  volumeOsd = pkgs.writeShellApplication {
    name = "volume-osd";
    runtimeInputs = [ pkgs.wireplumber pkgs.libnotify pkgs.gawk pkgs.gnugrep ];
    text = ''
      case "$1" in
        up) wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ ;;
        down) wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- ;;
        mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
      esac

      vol_raw=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
      pct=$(echo "$vol_raw" | awk '{printf "%d", $2*100}')

      if echo "$vol_raw" | grep -q MUTED; then
        notify-send -h string:x-canonical-private-synchronous:volume -h int:value:0 -a "volume" "Volume muted"
      else
        notify-send -h string:x-canonical-private-synchronous:volume -h int:value:"$pct" -a "volume" "Volume: $pct%"
      fi
    '';
  };

  brightnessOsd = pkgs.writeShellApplication {
    name = "brightness-osd";
    runtimeInputs = [ pkgs.brightnessctl pkgs.libnotify pkgs.gawk ];
    text = ''
      case "$1" in
        up) brightnessctl set 5%+ ;;
        down) brightnessctl set 5%- ;;
      esac

      pct=$(brightnessctl get -m | awk -F, '{gsub("%","",$4); print $4}')
      notify-send -h string:x-canonical-private-synchronous:brightness -h int:value:"$pct" -a "brightness" "Brightness: $pct%"
    '';
  };
in
{
  # Volume/brightness OSD: just change the value and fire a mako notification
  # with a progress-bar hint, synchronously, right from the keybinding. No
  # separate daemon or systemd unit to race at login/reboot.
  home.packages = [ volumeOsd brightnessOsd ];
}
