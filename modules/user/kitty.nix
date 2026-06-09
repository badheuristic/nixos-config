{ config, pkgs, theme, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "DejaVuSansMono Nerd Font";
      size = 10;
    };
    settings = {
      background = "#${theme.bg}";
      foreground = "#${theme.fg}";
      cursor = "#${theme.fg}";
      cursor_text_color = "#${theme.bg}";
      selection_background = "#${theme.primary}";
      selection_foreground = "#${theme.bg}";
      
      color0 = "#${theme.bg_alt}";
      color8 = "#${theme.alt}";
      color1 = "#${theme.urgent}";
      color9 = "#${theme.urgent}";
      color2 = "#${theme.primary}";
      color10 = "#${theme.primary}";
      color3 = "#${theme.fg}";
      color11 = "#${theme.fg}";
      color4 = "#${theme.fg}";
      color12 = "#${theme.fg}";
      color5 = "#${theme.fg}";
      color13 = "#${theme.fg}";
      color6 = "#${theme.primary}";
      color14 = "#${theme.primary}";
      color7 = "#${theme.fg}";
      color15 = "#${theme.fg}";

      window_padding_width = 15;
      enable_audio_bell = false;
      cursor_shape = "block";
      shell_integration = "no-rc no-cursor";
      confirm_os_window_close = 0;
      text_composition_strategy = "legacy";
    };
  };
}
