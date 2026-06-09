{ config, pkgs, theme, ... }:

{
  programs.cava = {
    enable = true;
    settings = {
      color = {
        background = "'#${theme.bg}'";
        foreground = "'#${theme.fg}'";
      };
    };
  };
}
