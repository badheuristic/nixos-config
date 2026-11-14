{ config, pkgs, lib, theme, ... }:

# GTK3 (adw-gtk3) and GTK4/libadwaita share one set of named colours, so
# Nautilus, pavucontrol, file pickers, etc. all land on the Closs palette.
let
  c = name: "#${theme.${name}}";

  # libadwaita named colours (also honoured by adw-gtk3)
  adwaita = ''
    @define-color accent_color ${c "primary"};
    @define-color accent_bg_color ${c "primary"};
    @define-color accent_fg_color ${c "on_primary"};

    @define-color destructive_color ${c "red"};
    @define-color destructive_bg_color ${c "red"};
    @define-color destructive_fg_color ${c "on_primary"};
    @define-color success_color ${c "green"};
    @define-color success_bg_color ${c "green"};
    @define-color success_fg_color ${c "on_primary"};
    @define-color warning_color ${c "yellow"};
    @define-color warning_bg_color ${c "yellow"};
    @define-color warning_fg_color ${c "on_primary"};
    @define-color error_color ${c "red"};
    @define-color error_bg_color ${c "red"};
    @define-color error_fg_color ${c "on_primary"};

    @define-color window_bg_color ${c "bg"};
    @define-color window_fg_color ${c "fg"};
    @define-color view_bg_color ${c "bg"};
    @define-color view_fg_color ${c "fg"};
    @define-color headerbar_bg_color ${c "bg_alt"};
    @define-color headerbar_fg_color ${c "fg"};
    @define-color headerbar_border_color ${c "surface"};
    @define-color headerbar_backdrop_color ${c "bg_alt"};
    @define-color headerbar_shade_color rgba(0, 0, 0, 0.36);
    @define-color headerbar_darker_shade_color rgba(0, 0, 0, 0.9);
    @define-color sidebar_bg_color ${c "bg_alt"};
    @define-color sidebar_fg_color ${c "fg"};
    @define-color sidebar_backdrop_color ${c "bg_alt"};
    @define-color sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color sidebar_border_color ${c "surface"};
    @define-color secondary_sidebar_bg_color ${c "bg"};
    @define-color secondary_sidebar_fg_color ${c "fg"};
    @define-color secondary_sidebar_backdrop_color ${c "bg"};
    @define-color secondary_sidebar_shade_color rgba(0, 0, 0, 0.25);
    @define-color secondary_sidebar_border_color ${c "surface"};
    @define-color card_bg_color ${c "surface"};
    @define-color card_fg_color ${c "fg"};
    @define-color card_shade_color rgba(0, 0, 0, 0.36);
    @define-color dialog_bg_color ${c "surface"};
    @define-color dialog_fg_color ${c "fg"};
    @define-color popover_bg_color ${c "surface"};
    @define-color popover_fg_color ${c "fg"};
    @define-color popover_shade_color rgba(0, 0, 0, 0.25);
    @define-color thumbnail_bg_color ${c "surface"};
    @define-color thumbnail_fg_color ${c "fg"};
    @define-color shade_color rgba(0, 0, 0, 0.36);
    @define-color scrollbar_outline_color rgba(0, 0, 0, 0.5);
  '';

  # Small shape tweaks so GTK chrome echoes the island
  shape = ''
    popover > contents, popover.menu > contents { border-radius: 14px; }
    window.dialog, messagedialog, .message-dialog { border-radius: 18px; }
  '';
in
{
  gtk = {
    enable = true;
    font = {
      name = theme.font.ui;
      size = 11;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-decoration-layout = "appmenu:none";
      gtk-application-prefer-dark-theme = 1;
    };
    gtk3.extraCss = adwaita + shape;
    # libadwaita apps take colours from gtk.css below, not from a GTK theme
    gtk4.theme = null;
    gtk4.extraConfig = {
      gtk-decoration-layout = "appmenu:none";
    };
    gtk4.extraCss = adwaita + shape;
  };

  home.pointerCursor = {
    enable = true;
    name = "Bibata-Modern-Classic";
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      font-name = "${theme.font.ui} 11";
      document-font-name = "${theme.font.ui} 11";
      monospace-font-name = "${theme.font.mono} 12";
      cursor-theme = "Bibata-Modern-Classic";
      cursor-size = 24;
      accent-color = "slate";
    };
    # libdecor's gtk plugin draws window-frame buttons for non-GTK Wayland
    # clients (e.g. Electron apps like Claude Desktop) based on this key.
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      show-image-thumbnails = "always";
    };
    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
    };
  };
}
