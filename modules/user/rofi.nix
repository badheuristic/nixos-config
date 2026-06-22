{ config, pkgs, theme, ... }:

{
  programs.rofi = {
    enable = true;
    # font = "DejaVu Sans Mono 9";
    font = "DejaVu Sans 10";
    extraConfig = {
      show-icons = false;
      display-drun = "";
      display-run = "";
      drun-display-format = "{name}";
      location = 0; # 0 = Center
      anchor = "center";
      yoffset = -150;
    };
    theme = let
      inherit (config.lib.formats.rasi) mkLiteral;
    in {
      "*" = {
        background-color = mkLiteral "#${theme.bg}aa";
        text-color = mkLiteral "#${theme.fg}";
        border-color = mkLiteral "#${theme.alt}";
        background-alt = mkLiteral "#${theme.bg_alt}aa";
        foreground-alt = mkLiteral "#${theme.primary}";
        selected-bg = mkLiteral "#${theme.alt}";
        border = 0;
        margin = 0;
        padding = 0;
        spacing = 0;
      };
      "window" = {
        width = mkLiteral "600px";
        border = mkLiteral "1px solid";
        border-color = mkLiteral "@border-color";
        border-radius = mkLiteral "8px";
        background-color = mkLiteral "@background-color";
        transparency = "real";
      };
      "mainbox" = {
        background-color = mkLiteral "@background-color";
        children = map mkLiteral [ "inputbar" "listview" ];
      };
      "inputbar" = {
        padding = mkLiteral "15px 20px";
        children = map mkLiteral [ "prompt" "entry" ];
      };
      "prompt" = {
        text-color = mkLiteral "@foreground-alt";
        padding = mkLiteral "0 12px 0 0";
      };
      "entry" = {
        text-color = mkLiteral "@foreground-alt";
        placeholder-color = mkLiteral "@text-color";
        placeholder = "search...";
      };
      "listview" = {
        background-color = mkLiteral "@background-color";
        spacing = 0;
        lines = 5;
      };
      "element" = {
        padding = mkLiteral "10px 20px";
        background-color = mkLiteral "#00000000";
        text-color = mkLiteral "@text-color";
      };
      "element selected" = {
        background-color = mkLiteral "@selected-bg";
        text-color = mkLiteral "@foreground-alt";
      };
      "element-text" = {
        background-color = mkLiteral "inherit";
        text-color = mkLiteral "inherit";
      };
    };
  };
}
