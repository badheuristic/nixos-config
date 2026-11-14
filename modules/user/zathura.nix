{ config, pkgs, theme, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      # Core colors — warm dark palette
      default-bg           = "#${theme.bg}";      # #202020
      default-fg           = "#${theme.fg}";      # #c1c1c1

      # Statusbar
      statusbar-bg         = "#${theme.bg_alt}";  # #121212
      statusbar-fg         = "#${theme.fg}";      # #c1c1c1

      # Input bar (the ":" command line)
      inputbar-bg          = "#${theme.bg_alt}";
      inputbar-fg          = "#${theme.primary}"; # #9b8d7f warm brown

      # Search / selection highlight
      highlight-color          = "#${theme.primary}80"; # semi-transparent brown
      highlight-active-color   = "#${theme.urgent}cc";  # teal

      # Completion menu
      completion-bg        = "#${theme.bg_alt}";
      completion-fg        = "#${theme.fg}";
      completion-highlight-bg  = "#${theme.primary}";
      completion-highlight-fg  = "#${theme.bg}";

      # Notification colors
      notification-bg      = "#${theme.bg_alt}";
      notification-fg      = "#${theme.fg}";
      notification-error-bg    = "#${theme.bg_alt}";
      notification-error-fg    = "#5f3737";
      notification-warning-bg  = "#${theme.bg_alt}";
      notification-warning-fg  = "#${theme.primary}";

      # Recolor (invert PDF colors for dark mode reading)
      recolor              = false;
      recolor-lightcolor   = "#${theme.bg}";
      recolor-darkcolor    = "#${theme.fg}";
      recolor-keephue      = true;

      font = "Iosevka Term 12";

      # UI tweaks
      guioptions         = "";   # hide scroll bars
      statusbar-h-padding = 8;
      statusbar-v-padding = 4;
    };
  };
}
