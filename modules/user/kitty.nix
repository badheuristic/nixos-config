{ config, pkgs, theme, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "Iosevka Term";
      size = 17;
    };
    settings = {
      background = "#${theme.bg}";
      foreground = "#${theme.fg}";
      background_opacity = "0.94";
      cursor = "#${theme.fg}";
      cursor_text_color = "#${theme.bg}";
      selection_background = "#${theme.surface3}";
      selection_foreground = "#${theme.fg}";
      url_color = "#${theme.blue}";

      # neutral 16-colour palette (theme.nix)
      color0 = "#${theme.surface}";
      color8 = "#${theme.fg_faint}";
      color1 = "#${theme.red}";
      color9 = "#${theme.red}";
      color2 = "#${theme.green}";
      color10 = "#${theme.primary_hi}";
      color3 = "#${theme.yellow}";
      color11 = "#${theme.yellow}";
      color4 = "#${theme.blue}";
      color12 = "#${theme.blue}";
      color5 = "#${theme.magenta}";
      color13 = "#${theme.magenta}";
      color6 = "#${theme.cyan}";
      color14 = "#${theme.cyan}";
      color7 = "#${theme.fg_dim}";
      color15 = "#${theme.fg}";

      window_padding_width = 15;
      enable_audio_bell = false;
      cursor_shape = "block";
      shell_integration = "no-rc no-cursor";
      confirm_os_window_close = 0;
      text_composition_strategy = "legacy";
      cursor_trail = 1;

      # Tabs are handled by tmux now; hide kitty's own tab bar
      tab_bar_style = "hidden";
    };
  };
}
