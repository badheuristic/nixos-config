{ config, pkgs, theme, ... }:

{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        margin = "8px 8px 0px 8px";
        height = 30;
        spacing = 4;
        
        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [];
        modules-right = [ "custom/wvkbd" "network" "bluetooth" "pulseaudio" "battery" "temperature" "cpu" "memory" "disk" "clock" "tray" ];

        "custom/wvkbd" = {
          format = "US";
          on-click = "pkill -x wvkbd-deskintl || wvkbd-deskintl -L 600 &";
          tooltip = false;
        };

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}";
          persistent-workspaces = {
            "*" = [ 1 2 3 4 5 ];
          };
        };

        "hyprland/window" = {
          format = "{title}";
          max-length = 50;
        };

        "clock" = {
          format = "{:%A %B %d; %H:%M}";
          tooltip = false;
        };

        network = {
          format-wifi = "  {essid}";
          format-ethernet = "󰈀 ";
          format-disconnected = "󰖪 ";
          on-click = "nmgui";
          tooltip = false;
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "󰂲 ";
          format-connected = " {device_alias}";
          on-click = "blueman-manager";
          tooltip = false;
        };

        pulseaudio = {
          format = "  {volume}%";
          format-muted = "  MUTED";
          on-click = "pavucontrol";
          tooltip = false;
        };

        battery = {
          states = { warning = 30; critical = 15; };
          format = "  {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "  {capacity}%";
          tooltip = false;
        };

        temperature = {
          format = " {temperatureC}°C";
          tooltip = false;
        };

        cpu = {
          format = "  {usage}%";
          tooltip = false;
        };

        memory = {
          format = "  {used:0.1f}G";
          tooltip = false;
        };

        disk = {
          format = "  {percentage_used}%";
          path = "/";
          tooltip = false;
        };

        tray = {
          icon-size = 14;
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        /* font-family: monospace, "DejaVuSansM Nerd Font"; */
        font-family: sans-serif, "DejaVu Sans";
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
        margin: 0;
        padding: 0;
        box-shadow: none;
      }

      window#waybar {
        background-color: alpha(#${theme.bg}, 0.93);
        color: #${theme.fg};
        border-radius: 8px;
        border: 1px solid #${theme.bg_alt};
      }

      /* Base padding for all modules to prevent text from hitting edges */
      #workspaces button, #clock, #network, #bluetooth, #pulseaudio, #battery,
      #window, #temperature, #cpu, #memory, #disk, #tray,
      #custom-wvkbd {
        padding: 0 8px;
        color: #${theme.fg};
        border-left: 1px solid #${theme.bg_alt};
      }

      #workspaces button { 
        color: #${theme.alt}; 
        border-left: none;
      }
      #workspaces button.active { color: #${theme.primary}; }
      #workspaces button:hover { color: #${theme.urgent}; }

      #battery.charging, #battery.plugged { color: #${theme.primary}; }
      #battery.critical:not(.charging) { color: #${theme.urgent}; }
    '';
  };
}
