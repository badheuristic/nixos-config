{ config, pkgs, theme, ... }:

{
  programs.swaylock = {
    enable = true;
    settings = {
      # Background
      image = "${../../assets/wallpapers/wooded-landscape.jpg}";
      scaling = "fill";

      # No ring, just a subtle indicator
      indicator-radius = 80;
      indicator-thickness = 4;

      # Colors from vimichael palette
      # Inside ring (the fill)
      inside-color = "00000000";           # transparent
      inside-clear-color = "00000000";
      inside-ver-color = "00000000";
      inside-wrong-color = "00000000";

      # Ring colors
      ring-color = "${theme.primary}ff";        # #9b8d7f — warm brown
      ring-clear-color = "${theme.alt}ff";      # #888888
      ring-ver-color = "${theme.urgent}ff";     # #5f8787 teal — verifying
      ring-wrong-color = "5f3737ff";            # muted red — wrong password

      # Key press highlight on ring
      key-hl-color = "${theme.fg}ff";           # #c1c1c1
      bs-hl-color = "${theme.urgent}ff";        # teal for backspace

      # Text
      text-color = "${theme.fg}ff";
      text-clear-color = "${theme.alt}ff";
      text-ver-color = "${theme.fg}ff";
      text-wrong-color = "5f3737ff";

      # Separator between ring and inside
      separator-color = "00000000";

      # Line around indicator
      line-color = "00000000";
      line-clear-color = "00000000";
      line-ver-color = "00000000";
      line-wrong-color = "00000000";

      font = "Iosevka Term";
      font-size = 14;
    };
  };
}
