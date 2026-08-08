{ config, pkgs, theme, ... }:

let
  nixosIcon = pkgs.writeText "nixos-icon.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24">
      <text x="0" y="18" font-family="DejaVu Sans" font-size="18" fill="#${theme.fg}"></text>
    </svg>
  '';
in
{
  programs.wofi = {
    enable = true;
    settings = {
      width = 600;
      height = "auto";
      lines = 5;
      prompt = "search...";
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      hide_scroll = true;
      term = "kitty";
      image_size = 0;
    };
    style = ''
      * {
        font-family: "DejaVu Sans", sans-serif;
        font-size: 10pt;
        border: none;
        margin: 0;
        padding: 0;
        outline: none;
        box-shadow: none;
      }

      #window {
        background-color: alpha(#${theme.bg}, 0.95);
        border: 1px solid #${theme.alt};
        border-radius: 8px;
      }

      #input {
        margin: 15px 20px;
        background-color: transparent;
        color: #${theme.fg};
        padding-left: 28px;
        background-image: url("file://${nixosIcon}");
        background-position: left center;
        background-repeat: no-repeat;
      }

      #input image.left {
        -gtk-icon-transform: scale(0);
        min-width: 0px;
        opacity: 0;
      }

      #inner-box {
        background-color: transparent;
      }

      #outer-box {
        background-color: transparent;
      }

      #scroll {
        margin-bottom: 10px;
        background-color: transparent;
      }

      #entry {
        padding: 10px 20px;
        background-color: transparent;
      }

      #text {
        color: #${theme.fg};
      }

      #entry:selected {
        background-color: #${theme.alt};
        border-radius: 0px;
      }

      #entry:selected #text {
        color: #${theme.primary};
      }
    '';
  };
}
