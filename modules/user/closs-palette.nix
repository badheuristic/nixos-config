# Renders theme.nix into the shell's Colors.qml singleton.
{ theme, wallpaperDir, defaultWallpaper }:
''
  pragma Singleton

  import QtQuick
  import Quickshell

  // Generated from theme.nix (modules/user/closs-palette.nix). Edit there.
  Singleton {
      readonly property color black: "#${theme.black}"
      readonly property color bg: "#${theme.bg}"
      readonly property color bgAlt: "#${theme.bg_alt}"
      readonly property color surface: "#${theme.surface}"
      readonly property color surface2: "#${theme.surface2}"
      readonly property color surface3: "#${theme.surface3}"

      readonly property color fg: "#${theme.fg}"
      readonly property color fgDim: "#${theme.fg_dim}"
      readonly property color fgFaint: "#${theme.fg_faint}"

      readonly property color primary: "#${theme.primary}"
      readonly property color primaryHi: "#${theme.primary_hi}"
      readonly property color primaryFg: "#${theme.on_primary}"

      readonly property color red: "#${theme.red}"
      readonly property color orange: "#${theme.orange}"
      readonly property color yellow: "#${theme.yellow}"
      readonly property color green: "#${theme.green}"
      readonly property color cyan: "#${theme.cyan}"
      readonly property color blue: "#${theme.blue}"
      readonly property color magenta: "#${theme.magenta}"

      readonly property string fontUi: "${theme.font.ui}"
      readonly property string fontRounded: "${theme.font.rounded}"
      readonly property string fontMono: "${theme.font.mono}"
      readonly property string fontIcons: "${theme.font.icons}"

      readonly property string wallpaperDir: "${wallpaperDir}"
      readonly property string defaultWallpaper: "${defaultWallpaper}"
  }
''
