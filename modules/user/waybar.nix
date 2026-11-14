{ config, pkgs, theme, ... }:

{
  # Waybar configuration from https://github.com/vimichael/arch-i3-cfg/tree/main/waybar
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        position = "bottom";
        spacing = 0;
        height = 0;
        reload_style_on_change = true;
        layer = "top";
        "custom/separator" = {
          format = "::";
          interval = "once";
          tooltip = false;
        };
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [
          "sway/window"
        ];
        modules-right = [
          "tray"
          "cpu"
          "custom/separator"
          "memory"
          "custom/separator"
          "battery"
          "custom/separator"
          "clock"
        ];
        "sway/window" = {
          max-length = 50;
        };
        tray = {
          spacing = 10;
          tooltip = false;
        };
        cpu = {
          format = "cpu {usage}%";
          interval = 2;
          states = {
            critical = 90;
          };
        };
        memory = {
          format = "mem {percentage}%";
          interval = 2;
          states = {
            critical = 80;
          };
        };
        battery = {
          format = "bat {capacity}%";
          interval = 5;
          states = {
            warning = 20;
            critical = 10;
          };
          tooltip = false;
        };
        network = {
          format-wifi = "wifi {bandwidthDownBits}";
          format-ethernet = "enth {bandwidthDownBits}";
          format-disconnected = "no network";
          interval = 5;
          tooltip = false;
        };
        pulseaudio = {
          scroll-step = 5;
          max-volume = 150;
          format = "vol {volume}%";
          format-bluetooth = "vol {volume}%";
          nospacing = 1;
          on-click = "pavucontrol";
          tooltip = false;
        };
        clock = {
          format = "{:%a %d %b  %H:%M:%S}";
        };
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        min-height: 0;
        font-family: "Iosevka Term", "Iosevka", monospace;
        font-size: 16px;
        padding: 0;
      }

      window#waybar {
        background: #202020;
        color: #9b8d7f;
      }

      tooltip {
        background-color: #202020;
      }

      #clock,
      #tray,
      #cpu,
      #memory,
      #battery,
      #network,
      #pulseaudio {
        margin: 2px 2px 0px 0px;
        padding: 2px 8px;
      }

      #workspaces button {
        color: #9b8d7f;
        padding: 2px 8px;
      }

      #workspaces button.focused {
        background-color: #9b8d7f;
        color: #202020;
      }

      #workspaces button.active {
        background-color: #202020;
        color: #9b8d7f;
      }

      #battery, #tray, #clock, #cpu, #pulseaudio, #memory {
        color: #9b8d7f;
      }
    '';
  };
}
