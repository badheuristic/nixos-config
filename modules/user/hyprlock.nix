{ config, pkgs, theme, ... }:

{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      
      background = [
        {
          path = "${../../assets/light.png}";
          blur_passes = 0;
          blur_size = 0;
        }
      ];

      shape = [
        {
          size = "250, 120";
          position = "60, 40";
          halign = "left";
          valign = "bottom";
          color = "rgba(0, 0, 0, 0.7)";
          rounding = 0;
        }
      ];

      label = [
        {
          text = "$TIME";
          font_size = 54;
          font_family = "DejaVu Math TeX Gyre";
          color = "rgba(255, 255, 255, 1.0)";
          position = "80, 65";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
        }
        {
          text = "cmd[update:1000] echo \"$(date +'%d %B %Y')\"";
          font_size = 12;
          font_family = "DejaVu Math TeX Gyre";
          color = "rgba(255, 255, 255, 0.7)";
          position = "80, 45";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
        }
      ];
      
      input-field = [
        {
          size = "250, 50";
          position = "60, 160";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
          dots_size = 0.2;
          dots_spacing = 3;
          dots_center = true;
          dots_text_format = "＊";
          fade_on_empty = true;
          font_family = "DejaVu Math TeX Gyre";
          font_color = "rgba(255, 255, 255, 1.0)";
          inner_color = "rgba(255, 255, 255, 0.1)";
          outer_color = "rgba(255, 255, 255, 0.5)";
          outline_thickness = 0;
          placeholder_text = " ";
          hide_input = false;
          rounding = 0;
        }
      ];
    };
  };
}
