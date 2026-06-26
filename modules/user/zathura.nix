{ config, pkgs, theme, ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      default-bg = "#${theme.bg}";
      default-fg = "#${theme.fg}";
      statusbar-bg = "#${theme.bg}";
      statusbar-fg = "#${theme.fg}";
      inputbar-bg = "#${theme.bg}";
      inputbar-fg = "#${theme.primary}";
      highlight-color = "#${theme.primary}";
      highlight-active-color = "#${theme.urgent}";
      font = "D2CodingLigature Nerd Font 12";
      
      recolor = false;
      recolor-lightcolor = "#${theme.bg}";
      recolor-darkcolor = "#${theme.fg}";
      recolor-keephue = true;
    };
  };
}
