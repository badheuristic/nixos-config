{ config, pkgs, theme, ... }:

{
  # Sway configuration adapted from https://github.com/vimichael/arch-i3-cfg
  xdg.configFile."sway/config".text = ''
    ### Variables
    # Mod4 = Super/Windows key — doesn't conflict with app shortcuts
    set $mod Mod4
    # Home row direction keys, like vim
    set $left h
    set $down j
    set $up k
    set $right l
    set $term kitty
    set $browser firefox

    font pango:Iosevka Term 10

    ### Output configuration (ASUS ROG Flow Z13 + external monitor)
    output eDP-1 mode 2560x1600@165Hz pos 0 0 scale 1
    output * bg ${../../assets/wallpapers/wooded-landscape.jpg} fill
    output * allow_tearing yes
    output * max_render_time off

    ### Idle configuration
    exec swayidle -w \
             timeout 3000 'swaylock -f -c 000000' \
             timeout 6000 'swaymsg "output * power off"' resume 'swaymsg "output * power on"' \
             before-sleep 'swaylock -f -c 000000'

    ### Input configuration
    input type:touchpad {
        dwt enabled
        tap enabled
        natural_scroll enabled
        middle_emulation enabled
    }

    input "1267:17351:ELAN9008:00_04F3:43C7_Stylus" {
        map_to_output eDP-1
    }

    input * {
        repeat_delay 200
        repeat_rate 50
    }

    ### Key bindings
    #
    # Basics:
    #
        bindsym $mod+Return exec $term
        bindsym $mod+Shift+d exec $browser

        # Corne home-row action keys (Y U I O P)
        bindsym $mod+d exec --no-startup-id rofi -show drun
        bindsym $mod+u floating toggle
        bindsym $mod+i fullscreen
        bindsym $mod+o focus parent
        bindsym $mod+p kill

        # Drag floating windows: $mod + left mouse button; resize: right mouse
        floating_modifier $mod normal

        # Focus mode toggle (tiling <-> floating)
        bindsym $mod+space focus mode_toggle

        # Lock screen
        bindsym $mod+m exec swaylock -f -c 000000

        # Clipboard history (cliphist + rofi)
        bindsym $mod+Shift+v exec cliphist list | rofi -dmenu -p "clipboard" | cliphist decode | wl-copy

        # Reload / exit — must NOT use Shift+Q/W/E/R/T (those are move-to-workspace 1-5)
        bindsym $mod+Shift+g reload
        bindsym $mod+Shift+BackSpace exec swaynag -t warning -m 'Exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'

    #
    # Moving around (vim-style + arrow keys):
    #
        bindsym $mod+$left focus left
        bindsym $mod+$down focus down
        bindsym $mod+$up focus up
        bindsym $mod+$right focus right
        bindsym $mod+Left focus left
        bindsym $mod+Down focus down
        bindsym $mod+Up focus up
        bindsym $mod+Right focus right

        bindsym $mod+Shift+$left move left
        bindsym $mod+Shift+$down move down
        bindsym $mod+Shift+$up move up
        bindsym $mod+Shift+$right move right
        bindsym $mod+Shift+Left move left
        bindsym $mod+Shift+Down move down
        bindsym $mod+Shift+Up move up
        bindsym $mod+Shift+Right move right

    #
    # Workspaces: Q/W/E/R/T = 1-5, number row = 1-10
    #
        bindsym $mod+q workspace number 1
        bindsym $mod+w workspace number 2
        bindsym $mod+e workspace number 3
        bindsym $mod+r workspace number 4
        bindsym $mod+t workspace number 5
        bindsym $mod+1 workspace number 1
        bindsym $mod+2 workspace number 2
        bindsym $mod+3 workspace number 3
        bindsym $mod+4 workspace number 4
        bindsym $mod+5 workspace number 5
        bindsym $mod+6 workspace number 6
        bindsym $mod+7 workspace number 7
        bindsym $mod+8 workspace number 8
        bindsym $mod+9 workspace number 9
        bindsym $mod+0 workspace number 10

        bindsym $mod+Shift+q move container to workspace number 1
        bindsym $mod+Shift+w move container to workspace number 2
        bindsym $mod+Shift+e move container to workspace number 3
        bindsym $mod+Shift+r move container to workspace number 4
        bindsym $mod+Shift+t move container to workspace number 5
        bindsym $mod+Shift+1 move container to workspace number 1
        bindsym $mod+Shift+2 move container to workspace number 2
        bindsym $mod+Shift+3 move container to workspace number 3
        bindsym $mod+Shift+4 move container to workspace number 4
        bindsym $mod+Shift+5 move container to workspace number 5
        bindsym $mod+Shift+6 move container to workspace number 6
        bindsym $mod+Shift+7 move container to workspace number 7
        bindsym $mod+Shift+8 move container to workspace number 8
        bindsym $mod+Shift+9 move container to workspace number 9
        bindsym $mod+Shift+0 move container to workspace number 10

    #
    # Layout modes:
    #   Super+S  -> stacking
    #   Super+A  -> tabbed
    #   Super+X  -> toggle split (horizontal <-> vertical)
    #   Super+B  -> split horizontal
    #   Super+V  -> split vertical
    #
        bindsym $mod+s layout stacking
        bindsym $mod+a layout tabbed
        bindsym $mod+x layout toggle split
        bindsym $mod+b splith
        bindsym $mod+v splitv

    #
    # Scratchpad:
    #
        bindsym $mod+Shift+f move scratchpad
        bindsym $mod+f scratchpad show

    #
    # Resize mode:
    #
    mode "resize" {
        bindsym $left resize shrink width 80px
        bindsym $down resize grow height 80px
        bindsym $up resize shrink height 80px
        bindsym $right resize grow width 80px
        bindsym Left resize shrink width 80px
        bindsym Down resize grow height 80px
        bindsym Up resize shrink height 80px
        bindsym Right resize grow width 80px

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym $mod+r mode "default"
    }
    bindsym $mod+z mode "resize"

    #
    # Screenshots:
    #
        # Quick region screenshot -> clipboard
        bindsym $mod+c exec grim -g "$(slurp)" - | wl-copy
        bindsym $mod+Shift+c exec grim - | wl-copy
        # Screenshot to file
        bindsym Print exec grim "$HOME/screenshot-$(date +%Y%m%d-%H%M%S).png"

    #
    # Media / Hardware keys (each bind just runs a script that changes the
    # value and fires a mako notification directly — no extra daemon):
    #
        bindsym --locked XF86AudioMute exec volume-osd mute
        bindsym --locked XF86AudioLowerVolume exec volume-osd down
        bindsym --locked XF86AudioRaiseVolume exec volume-osd up
        bindsym --locked XF86MonBrightnessDown exec brightness-osd down
        bindsym --locked XF86MonBrightnessUp exec brightness-osd up

        # Software binds (hardware volume/brightness controls don't send key events on this device)
        bindsym $mod+comma exec volume-osd down
        bindsym $mod+period exec volume-osd up
        bindsym $mod+n exec volume-osd mute
        bindsym $mod+bracketleft exec brightness-osd down
        bindsym $mod+bracketright exec brightness-osd up

    #
    # Colors (vimichael palette):
    #
    client.focused #9b8d7f #9b8d7f #000000 #9b8d7f #9b8d7f
    client.focused_inactive #202020 #202020 #9b8d7f #202020 #202020
    client.unfocused #202020 #202020 #9b8d7f #202020 #202020

    bar {
        swaybar_command waybar
    }

    for_window [app_id="pavucontrol"] floating enable
    for_window [title="game-*"] floating enable, resize set 1920 1080

    gaps inner 16
    gaps outer 0

    #workspace 5 gaps horizontal 100
    #workspace 5 gaps vertical 30
    #workspace 5 gaps inner 20

    default_border pixel 2
    default_floating_border pixel 2

    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK XDG_CURRENT_DESKTOP
    include /etc/sway/config.d/*
  '';
}
