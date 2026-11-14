{ config, lib, theme, ... }:

# The lock screen. The shell starts it (Session.lock) with the config that
# matches the island's shape, after pointing ~/.cache/closs/lock-wallpaper at
# the current wallpaper. A black island with a lock glyph sits where the
# real island rests; the password field sits at the bottom, under the user.
let
  rgb = hex: "rgb(${hex})";
  wallpaper = "${config.xdg.cacheHome}/closs/lock-wallpaper";

  settings = notch: {
    general = {
      hide_cursor = true;
      ignore_empty_input = true;
    };

    background = [
      {
        path = wallpaper;
        color = rgb theme.black;
        blur_passes = 3;
        blur_size = 10;
        brightness = 0.6;
      }
    ];

    # the island: flush with the top edge (notch) or floating (pill)
    shape = [
      {
        size = if notch then "72, 46" else "72, 32";
        rounding = if notch then 14 else -1;
        color = rgb theme.black;
        border_size = 0;
        position = if notch then "0, 14" else "0, -8";
        halign = "center";
        valign = "top";
        zindex = 1;
      }
    ];

    image = [
      {
        path = "${../../assets/face.jpg}";
        size = 64;
        rounding = -1;
        border_size = 0;
        position = "0, 196";
        halign = "center";
        valign = "bottom";
      }
    ];

    label = [
      {
        text = "lock";
        font_family = theme.font.icons;
        font_size = 15;
        color = rgb theme.fg;
        position = if notch then "0, -7" else "0, -14";
        halign = "center";
        valign = "top";
        zindex = 2;
      }
      {
        text = "cmd[update:60000] date +'%A, %B %-d'";
        font_size = 22;
        font_family = "${theme.font.ui} Semibold";
        color = "rgba(255, 255, 255, 0.85)";
        position = "0, -130";
        halign = "center";
        valign = "top";
      }
      {
        text = "$TIME";
        font_size = 150;
        font_family = "${theme.font.rounded} Black";
        color = "rgba(255, 255, 255, 0.92)";
        shadow_passes = 2;
        shadow_size = 6;
        shadow_color = "rgba(0, 0, 0, 0.25)";
        position = "0, -160";
        halign = "center";
        valign = "top";
      }
      {
        text = "$USER";
        font_size = 15;
        font_family = "${theme.font.ui} Semibold";
        color = rgb theme.fg;
        position = "0, 160";
        halign = "center";
        valign = "bottom";
      }
    ];

    input-field = [
      {
        size = "240, 44";
        position = "0, 92";
        halign = "center";
        valign = "bottom";
        rounding = -1;
        outline_thickness = 0;
        inner_color = "rgba(0, 0, 0, 0.75)";
        font_color = rgb theme.fg;
        check_color = rgb theme.surface2;
        fail_color = rgb theme.red;
        dots_size = 0.22;
        dots_spacing = 0.4;
        dots_center = true;
        fade_on_empty = false;
        placeholder_text = "<span foreground='##${theme.fg_dim}'>Enter Password</span>";
        fail_text = "<span foreground='##${theme.red}'>Incorrect password</span>";
        font_family = theme.font.ui;
      }
    ];
  };

  render = notch: lib.hm.generators.toHyprconf { attrs = settings notch; };
in
{
  # installs hyprlock and its PAM-facing defaults; the configs below are
  # the ones actually used
  programs.hyprlock = {
    enable = true;
    settings = settings false;
  };

  xdg.configFile."hypr/hyprlock-pill.conf".text = render false;
  xdg.configFile."hypr/hyprlock-notch.conf".text = render true;
}
