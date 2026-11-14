{ config, pkgs, theme, ... }:

# Fallback locker only. The island's own lock screen is the primary one; if
# the shell is ever wedged while locked, from a TTY run:
#   hyprctl --instance 0 dispatch exec hyprlock
# Styled to look like the island lock so the fallback isn't jarring.
let
  rgb = hex: "rgb(${hex})";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "${config.home.homeDirectory}/Pictures/wallpapers/bedroom.jpg";
          blur_passes = 3;
          blur_size = 10;
          brightness = 0.6;
        }
      ];

      label = [
        {
          text = "cmd[update:60000] date +'%A, %B %-d'";
          font_size = 22;
          font_family = theme.font.ui;
          color = "rgba(255, 255, 255, 0.85)";
          position = "0, -170";
          halign = "center";
          valign = "top";
        }
        {
          text = "$TIME";
          font_size = 220;
          font_family = "${theme.font.rounded} Black";
          color = "rgba(255, 255, 255, 0.92)";
          position = "0, -200";
          halign = "center";
          valign = "top";
        }
        {
          text = "$USER";
          font_size = 15;
          font_family = "${theme.font.ui} Semibold";
          color = rgb theme.fg;
          position = "0, 150";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = [
        {
          size = "220, 40";
          position = "0, 90";
          halign = "center";
          valign = "bottom";
          rounding = -1;
          outline_thickness = 0;
          inner_color = rgb theme.black;
          font_color = rgb theme.fg;
          check_color = rgb theme.surface2;
          fail_color = rgb theme.red;
          dots_size = 0.25;
          dots_spacing = 0.35;
          dots_center = true;
          fade_on_empty = false;
          placeholder_text = "<span foreground='##${theme.fg_dim}'>Password</span>";
          fail_text = "Incorrect password";
          font_family = theme.font.ui;
        }
      ];
    };
  };
}
