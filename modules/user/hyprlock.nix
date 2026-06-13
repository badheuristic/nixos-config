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

      label = [
        {
          text = "$TIME";
          font_size = 32;
          font_family = "DejaVuSansMono Nerd Font";
          color = "rgba(255, 255, 255, 1.0)";
          position = "80, 130";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
        }
        {
          text = "cmd[update:1000] echo \"$(date +'%d %B %Y')\"";
          font_size = 12;
          font_family = "DejaVuSansMono Nerd Font";
          color = "rgba(255, 255, 255, 0.7)";
          position = "80, 100";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
        }
      ];
      
      input-field = [
        {
          size = "150, 40";
          position = "80, 45";
          monitor = "eDP-1";
          halign = "left";
          valign = "bottom";
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          dots_text_format = "＊";
          fade_on_empty = true;
          font_family = "DejaVuSansMono Nerd Font";
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
