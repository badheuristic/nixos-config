{ config, pkgs, lib, theme, ... }:

# Qt apps (KDE Connect, pcsx2, ...) through qt6ct/qt5ct with a
# Fusion style and a palette generated from theme.nix.
let
  c = name: "#ff${theme.${name}}";
  # QPalette order: WindowText, Button, Light, Midlight, Dark, Mid, Text,
  # BrightText, ButtonText, Base, Window, Shadow, Highlight, HighlightedText,
  # Link, LinkVisited, AlternateBase, NoRole, ToolTipBase, ToolTipText,
  # PlaceholderText, Accent
  active = [
    (c "fg") (c "surface2") (c "surface3") (c "surface2") (c "bg_alt") (c "surface")
    (c "fg") "#ffffffff" (c "fg") (c "bg") (c "bg") "#ff000000"
    (c "primary") (c "on_primary") (c "blue") (c "magenta") (c "surface")
    "#ff000000" (c "surface") (c "fg") (c "fg_faint") (c "primary")
  ];
  disabled = [
    (c "fg_faint") (c "surface") (c "surface2") (c "surface") (c "bg_alt") (c "surface")
    (c "fg_faint") "#ffffffff" (c "fg_faint") (c "bg") (c "bg") "#ff000000"
    (c "surface3") (c "fg_dim") (c "fg_dim") (c "fg_dim") (c "surface")
    "#ff000000" (c "surface") (c "fg_dim") (c "fg_faint") (c "surface3")
  ];
  colors = pkgs.writeText "closs.conf" ''
    [ColorScheme]
    active_colors=${lib.concatStringsSep ", " active}
    disabled_colors=${lib.concatStringsSep ", " disabled}
    inactive_colors=${lib.concatStringsSep ", " active}
  '';
  ctConf = ''
    [Appearance]
    color_scheme_path=${colors}
    custom_palette=true
    icon_theme=Papirus-Dark
    standard_dialogs=xdgdesktopportal
    style=Fusion

    [Fonts]
    fixed="${theme.font.mono},11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"
    general="${theme.font.ui},11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1"

    [Interface]
    activate_item_on_single_click=1
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3
  '';
in
{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "Fusion";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = ctConf;
  xdg.configFile."qt6ct/qt6ct.conf".text = ctConf;
}
