{ config, pkgs, theme, ... }:
{
  programs.swaylock = {
    enable = true;
    package = pkgs.swaylock-effects;
    settings = {
      clock = true;
      indicator = true;
      font = "DejaVuSansMono Nerd Font";
      image = "${../../assets/cbpnk.png}";
    };
  };
}
