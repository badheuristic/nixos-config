{ config, pkgs, lib, theme, ... }:

# Closs — the Quickshell island that replaces waybar, rofi, mako, the
# OSD scripts, the tray and the polkit agent. QML lives in ./closs; the
# palette is generated from theme.nix.
let
  home = config.home.homeDirectory;
  wallpaperDir = "${home}/Pictures/wallpapers";
  wallpapers = {
    "bedroom.jpg" = ../../assets/wallpapers/bedroom.jpg;
    "wooded-landscape.jpg" = ../../assets/wallpapers/wooded-landscape.jpg;
    "locchio-occidentale.jpg" = ../../assets/wallpapers/locchio-occidentale.jpg;
  };
in
{
  home.packages = with pkgs; [
    quickshell
    hyprsunset     # night light
    brightnessctl  # display slider / OSD
    cliphist       # clipboard view
    wl-clipboard
    material-symbols
  ];

  xdg.configFile."quickshell/closs" = {
    source = ./closs;
    recursive = true;
  };

  xdg.configFile."quickshell/closs/config/Colors.qml".text = import ./closs-palette.nix {
    inherit theme wallpaperDir;
    defaultWallpaper = "${wallpaperDir}/bedroom.jpg";
  };

  # Bundled wallpapers. Drop more images into ~/Pictures/wallpapers and
  # they show up in the picker (Super+Ctrl+W).
  home.file = lib.mapAttrs' (name: src:
    lib.nameValuePair "Pictures/wallpapers/${name}" { source = src; }
  ) wallpapers;

  systemd.user.services.closs = {
    Unit = {
      Description = "Closs shell (Quickshell island)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };
    Service = {
      ExecStart = "${pkgs.quickshell}/bin/qs -c closs";
      Restart = "on-failure";
      RestartSec = 1;
      # Apps launched from the island are children of this process; don't
      # take them down when the shell restarts.
      KillMode = "process";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
