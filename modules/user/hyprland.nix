{ config, pkgs, theme, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    settings = {
      # variables
      "$mod" = "SUPER";
      "$terminal" = "kitty";

      # autostart
      exec-once = [
        "waybar"
        "dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "swaybg -i ${../../assets/checker.png} -m fill"
      ];

      # input
      input = {
        kb_layout = "us";
	      follow_mouse = 1;
	      sensitivity = 0;
	      touchpad = {
	        natural_scroll = true;
	        disable_while_typing = true;
	        tap-to-click = true;
	      };
      };

      gesture = [ "3, horizontal, workspace" ];

      # appearance
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 1;
        # "col.active_border" = "0x77ffffff 0x11181818 0x77ffffff 30deg";
        # "col.inactive_border" = "0xff181800";
        "col.active_border" = "0x77ffffff";
        "col.inactive_border" = "0x55555555";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
        no_focus_fallback = true;
      };

      decoration = {
        rounding = 0;
        rounding_power = 2;
        active_opacity = 0.95;
        inactive_opacity = 0.9;
        fullscreen_opacity = 0.95;
        blur = {
          enabled = false;
        };
        shadow = {
          enabled = false;
          range = 15;              # creates a soft blur instead of a sharp edge
          render_power = 3;        # controls the falloff gradient of the shadow
          offset = "0 0";          # centers the shadow directly behind the window
          color = "rgba(${theme.shadow}B3)"; # 70% opacity black
          color_inactive = "rgba(${theme.shadow}80)"; # 50% opacity black
        };
      };

      animations = {
        enabled = true;
	      bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
	      ];
	      animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
	      ];
      };

      dwindle = {
	      preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = 0;
	      disable_hyprland_logo = true;
      };

      # window rules
      windowrule = [
        "match:title ^(Picture-in-Picture)$,float true,pin true"
        "match:class .*,suppress_event maximize"
        "match:class ^$,match:title ^$,match:xwayland true,match:float true,match:fullscreen false,match:pin false,no_focus true"
        "match:class hyprland-run,move 20 monitor_h-120,float yes"
        "match:initial_class ^(firefox-beta)$,opacity 1.0 override 1.0 override"
        "match:initial_class ^(kitty)$,match:initial_class ^(obsidian)$,opacity 0.87 override 0.80 override 0.77 override"
        "match:title ^(btop)$,opacity 0.9 0.87"
        "match:initial_class ^(mpv)$,opacity 1.0 override 1.0 override 1.0 override"
        "match:initial_class ^(com.github.xournalpp.xournalpp)$,opacity 0.90 0.87"
        "match:class ^(hhd-ui)$,float true,pin true,stay_focused true,focus_on_activate true"
        "match:class ^(Spotify|spotify)$,opacity 0.90 override 0.87 override"
        "match:class ^(vesktop|discord)$,opacity 0.90 override 0.87 override"
        "match:class ^(antigravity)$,opacity 0.90 override 0.87 override"
      ];

      layerrule = [
	      "match:namespace wvkbd,above_lock 2"
      ];

      # keybindings
      bind = [
	      "$mod SHIFT, Q, exit"
        "$mod, Q, killactive"
        "$mod, Return, exec, $terminal"
        "$mod, Space, togglefloating"
        "$mod, D, exec, pkill rofi || rofi -show run"
        "$mod, P, pseudo"
        "$mod SHIFT, P, pin"
        "$mod, V, layoutmsg, togglesplit"
        "$mod, F, fullscreen"
        "$mod, M, exec, hyprlock"
        "$mod, B, exec, flatpak run com.bitwig.BitwigStudio"
        "$mod, C, exec, grim -g \"$(slurp)\" - | wl-copy"
        "$mod SHIFT, C, exec, grim - | wl-copy"
        "$mod CTRL, C, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot_$(date +%F_%H-%M-%S).png"
        "$mod ALT, C, exec, grim ~/Pictures/screenshot_$(date +%F_%H-%M-%S).png"
        #"$mod, C, exec, hyprshot -m region --clipboard-only" #TODO: screenshots
        "$mod SHIFT, Space, exec, $(hyprctl activewindow -j | jq '.floating') && hyprctl dispatch cyclenext tiled || hyprctl dispatch cyclenext floating"
        "ALT, F8, exec, hyprctl keyword monitor eDP-1,2560x1600@180,auto,1"
        "ALT, F7, exec, hyprctl keyword monitor eDP-1,2560x1600@60,auto,1"
        "ALT, bracketleft, exec, hyprctl keyword debug:overlay false"
        "ALT, bracketright, exec, hyprctl keyword debug:overlay true"
        "ALT SHIFT, V, exec, cliphist list | rofi -dmenu -p \"\"| cliphist decode | wl-copy "
        "$mod, h, movefocus, l"
        "$mod, j, movefocus, d"
        "$mod, k, movefocus, u"
        "$mod, l, movefocus, r"
        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, j, movewindow, d"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, l, movewindow, r"
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
        "$mod, bracketright, exec, brightnessctl s 5%+"
        "$mod, bracketleft, exec, brightnessctl s 5%-"
        "$mod SHIFT, bracketleft, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
        "$mod SHIFT, bracketright, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        "$mod, O, exec, pkill waybar || waybar"
      ];
      
      binde = [
        "$mod CTRL, h, resizeactive, -10 0"
        "$mod CTRL, j, resizeactive, 0 10"
        "$mod CTRL, k, resizeactive, 0 -10"
        "$mod CTRL, l, resizeactive, 10 0"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl s 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl s 5%-"
      ];

      monitor = [
        "eDP-1,preferred,0x0,1"
        "HDMI-A-1,preferred,2560x0,1"
        # "HDMI-A-1,2560x1440,0x-1440,1"
      ];

      env = [
        "XCURSOR_THEME,Bibata-Modern-Classic"
        "XCURSOR_SIZE,24"
      ];

      cursor = {
        no_hardware_cursors = true;
      };

      device = [
        {
          name = "elan9008:00-04f3:43c7-stylus";
          output = "eDP-1";
        }
      ];
    };
  };
}
