{ config, pkgs, theme, ... }:

{
  services.mako = {
    enable = true;
    settings = {
      background-color = "#${theme.bg}";
      text-color = "#${theme.fg}";
      border-color = "#${theme.primary}";
      progress-color = "over #${theme.bg_alt}";
      default-timeout = 5000;
    };
  };
}
