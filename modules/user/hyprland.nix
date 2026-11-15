{ config, pkgs, lib, theme, ... }:

# Hyprland, keyed to the same muscle memory as the old sway config
# (Corne home-row actions on Y/U/I/O/P, Q-T workspaces), with the
# Closs island handling every piece of shell UI.
let
  qs = "${pkgs.quickshell}/bin/qs -c closs ipc call";
  # media keys: Spotify whenever it's running, else any player but a
  # browser (Zen registers as firefox.instance_*), so a paused video never
  # gets resumed by accident; matches services/Media.qml in the shell
  player = "playerctl -p spotify,%any -i firefox,chromium,zen,brave,vivaldi";
  rgba = hex: alpha: "rgba(${hex}${alpha})";

  # Super+Space: hop between tiled and floating windows (sway's focus mode_toggle)
  focusModeToggle = pkgs.writeShellScript "hypr-focus-mode-toggle" ''
    if [ "$(${pkgs.hyprland}/bin/hyprctl activewindow -j | ${pkgs.jq}/bin/jq -r .floating)" = "true" ]; then
      ${pkgs.hyprland}/bin/hyprctl dispatch cyclenext tiled
    else
      ${pkgs.hyprland}/bin/hyprctl dispatch cyclenext floating
    fi
  '';

  screenshotDir = "${config.home.homeDirectory}/Pictures/screenshots";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Use the compositor + portal from the NixOS module (programs.hyprland)
    package = null;
    portalPackage = null;
    # Export the full session environment (PATH, XDG_DATA_DIRS, ...) so the
    # island's systemd service sees the same apps and icons as the desktop.
    systemd.variables = [ "--all" ];
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";
      "$term" = "kitty";
      "$browser" = "zen-beta";

      # Electron apps can't detect gnome-keyring under Hyprland; Claude
      # Desktop's launcher reads this (VS Code/Obsidian get a flag instead)
      env = [ "CLAUDE_PASSWORD_STORE,gnome-libsecret" ];

      monitor = [
        "eDP-1, 2560x1600@165, 0x0, 1"
        "HDMI-A-1, preferred, auto-right, 1"
        ", preferred, auto, 1"
      ];

      input = {
        kb_layout = "us";
        repeat_delay = 200;
        repeat_rate = 50;
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          tap-to-click = true;
          middle_button_emulation = true;
        };
      };

      device = [
        {
          name = "elan9008:00-04f3:43c7-stylus";
          output = "eDP-1";
        }
      ];

      gesture = [ "3, horizontal, workspace" ];

      general = {
        gaps_in = 6;
        gaps_out = 12;
        border_size = 1;
        # A hairline, not a highlight: focus is shown by dimming the rest.
        "col.active_border" = rgba "ffffff" "26";
        "col.inactive_border" = rgba "ffffff" "0d";
        resize_on_border = true;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = theme.radius.window;
        rounding_power = 3; # closer to Apple's continuous corners
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        # Focus through light, not colour
        dim_inactive = true;
        dim_strength = 0.12;
        dim_special = 0.35;
        dim_around = 0.4;

        blur = {
          enabled = true;
          size = 8;
          passes = 3;
          noise = 0.01;
          vibrancy = 0.18;
          popups = true;
        };

        shadow = {
          enabled = true;
          range = 28;
          render_power = 3;
          offset = "0 8";
          color = rgba theme.shadow "70";
          color_inactive = rgba theme.shadow "40";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "spring, 0.32, 1.22, 0.42, 1.0"
          "emphasized, 0.2, 0.0, 0.0, 1.0"
          "accel, 0.3, 0.0, 0.8, 0.15"
          "linear, 0, 0, 1, 1"
        ];
        animation = [
          # No overshoot on open: a springy pop-in grows past its tile and
          # overlaps the neighbour that is still shrinking out of the way.
          # Neighbours move a touch faster than the new window grows, and
          # the new window fades in, so the two never visibly overlap.
          "windowsIn, 1, 4, emphasized, popin 85%"
          "fadeIn, 1, 3.5, emphasized"
          "windowsOut, 1, 2.5, accel, popin 90%"
          "windowsMove, 1, 3.5, emphasized"
          "border, 1, 4, emphasized"
          "fade, 1, 3, emphasized"
          "fadeDim, 1, 4, emphasized"
          "layers, 1, 3.5, emphasized, fade"
          "workspaces, 1, 4.5, emphasized, slide"
          "specialWorkspace, 1, 4.5, emphasized, slidevert"
        ];
      };

      dwindle = {
        preserve_split = true;
        smart_split = false;
      };

      group = {
        "col.border_active" = rgba "ffffff" "26";
        "col.border_inactive" = rgba "ffffff" "0d";
        groupbar = {
          font_family = theme.font.ui;
          font_size = 11;
          height = 20;
          gradients = false;
          indicator_height = 0;
          rounding = 6;
          "col.active" = rgba theme.surface2 "ff";
          "col.inactive" = rgba theme.bg_alt "ff";
          text_color = rgba theme.fg "ff";
        };
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        force_default_wallpaper = 0;
        background_color = "0x${theme.black}";
        focus_on_activate = true;
        # If hyprlock crashes, a new one can take the lock over
        # (hyprctl --instance 0 dispatch exec hyprlock from a TTY).
        allow_session_lock_restore = true;
      };

      cursor = {
        no_hardware_cursors = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      # ── Rules ──────────────────────────────────────────────────────────
      windowrule = [
        "match:class .*, suppress_event maximize"
        "match:class ^$, match:title ^$, match:xwayland true, match:float true, match:fullscreen false, match:pin false, no_focus true"
        "match:title ^(Picture-in-Picture)$, float true, pin true"
        "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|nmgui|.blueman-manager-wrapped|blueman-manager)$, float true, size 720 520, center true"
        "match:class ^(xdg-desktop-portal-gtk)$, float true, center true"
        "match:class ^(org.kde.kdeconnect.app)$, float true, size 900 640, center true"
        "match:title ^(game-.*)$, float true, size 1920 1080"
        "match:class ^(swayimg)$, float true, size 1400 900, center true"
      ];

      layerrule = [
        # The island animates itself; don't let Hyprland fade it twice.
        "match:namespace ^(closs.*)$, no_anim true"
        "match:namespace wvkbd, above_lock 2"
      ];

      # ── Binds ──────────────────────────────────────────────────────────
      bind = [
        # Apps
        "$mod, Return, exec, $term"
        "$mod, B, exec, $browser"
        "$mod, Y, exec, nautilus"

        # The island (Hyprland global shortcuts registered by the shell)
        "$mod, D, global, closs:launcher"
        "$mod, V, global, closs:clipboard"
        "$mod, A, global, closs:control"
        "$mod, X, global, closs:tray"
        "$mod, N, global, closs:calendar"
        "$mod, S, global, closs:dashboard"
        "$mod, G, global, closs:wallpaper"
        "$mod, Escape, global, closs:power"
        "$mod, M, global, closs:lock"
        ", XF86Launch3, global, closs:armoury" # Armoury Crate key (KEY_PROG3)
        "$mod, semicolon, global, closs:armoury"
        "$mod, minus, exec, ${player} play-pause"

        # Session
        "$mod SHIFT, Escape, exit"

        # Corne home-row actions (Y U I O P)
        "$mod, U, togglefloating"
        "$mod, I, fullscreen, 0"
        "$mod, O, layoutmsg, togglesplit" # flip split orientation
        "$mod, P, killactive"
        "$mod, Space, exec, ${focusModeToggle}"

        # Focus / move (vim keys + arrows)
        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
        "$mod, Left, movefocus, l"
        "$mod, Down, movefocus, d"
        "$mod, Up, movefocus, u"
        "$mod, Right, movefocus, r"
        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, Left, movewindow, l"
        "$mod SHIFT, Down, movewindow, d"
        "$mod SHIFT, Up, movewindow, u"
        "$mod SHIFT, Right, movewindow, r"

        "$mod, Z, submap, resize"

        # Scratchpad
        "$mod SHIFT, F, movetoworkspacesilent, special:scratch"
        "$mod, F, togglespecialworkspace, scratch"

        # Screenshots
        "$mod, C, exec, grim -g \"$(slurp -d)\" - | wl-copy"
        "$mod SHIFT, C, exec, grim - | wl-copy"
        ", Print, exec, mkdir -p ${screenshotDir} && grim ${screenshotDir}/$(date +%Y%m%d-%H%M%S).png"

        "$mod SHIFT, G, exec, hyprctl reload"

        # Workspaces: Q W E R T = 1-5, number row = 1-10.
        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ]
      ++ (lib.concatLists (lib.imap1 (i: key: [
        "$mod, ${key}, workspace, ${toString i}"
        "$mod SHIFT, ${key}, movetoworkspace, ${toString i}"
      ]) [ "Q" "W" "E" "R" "T" ]))
      ++ (lib.concatLists (lib.genList (i: let ws = i + 1; key = toString (lib.mod ws 10); in [
        "$mod, ${key}, workspace, ${toString ws}"
        "$mod SHIFT, ${key}, movetoworkspace, ${toString ws}"
      ]) 10));

      # Repeatable, and allowed on the lock screen
      bindel = [
        ", XF86AudioRaiseVolume, exec, ${qs} osd volumeUp"
        ", XF86AudioLowerVolume, exec, ${qs} osd volumeDown"
        ", XF86MonBrightnessUp, exec, ${qs} osd brightnessUp"
        ", XF86MonBrightnessDown, exec, ${qs} osd brightnessDown"
        # Software binds (the Flow's hardware keys don't always emit events)
        "$mod, period, exec, ${qs} osd volumeUp"
        "$mod, comma, exec, ${qs} osd volumeDown"
        "$mod, bracketright, exec, ${qs} osd brightnessUp"
        "$mod, bracketleft, exec, ${qs} osd brightnessDown"
      ];

      bindl = [
        ", XF86AudioMute, exec, ${qs} osd volumeMute"
        ", XF86AudioMicMute, exec, ${qs} osd micMute"
        "$mod, slash, exec, ${qs} osd volumeMute"
        ", XF86AudioPlay, exec, ${player} play-pause"
        ", XF86AudioPause, exec, ${player} play-pause"
        ", XF86AudioNext, exec, ${player} next"
        ", XF86AudioPrev, exec, ${player} previous"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    # Submaps are order-sensitive, so they live in raw config.
    extraConfig = ''
      submap = resize
      binde = , H, resizeactive, -80 0
      binde = , J, resizeactive, 0 80
      binde = , K, resizeactive, 0 -80
      binde = , L, resizeactive, 80 0
      binde = , Left, resizeactive, -80 0
      binde = , Down, resizeactive, 0 80
      binde = , Up, resizeactive, 0 -80
      binde = , Right, resizeactive, 80 0
      bind = , Return, submap, reset
      bind = , Escape, submap, reset
      bind = $mod, Z, submap, reset
      submap = reset
    '';
  };

  home.packages = with pkgs; [ playerctl jq grim slurp ];
}
