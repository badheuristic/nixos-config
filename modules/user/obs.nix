{ config, pkgs, lib, theme, ... }:

# OBS Studio: a Yami variant in the Closs palette.
let
  c = name: "#${theme.${name}}";
  variant = ''
    @OBSThemeMeta {
        name: 'Closs';
        id: 'com.obsproject.Yami.Closs';
        extends: 'com.obsproject.Yami';
        author: 'chaka';
        dark: 'true';
    }

    @OBSThemeVars {
        --grey1: ${c "fg_faint"};
        --grey2: #4a4a4d;
        --grey3: ${c "surface3"};
        --grey4: ${c "surface2"};
        --grey5: #242426;
        --grey6: ${c "surface"};
        --grey7: ${c "bg"};
        --grey8: ${c "bg_alt"};

        --primary: ${c "primary"};
        --primary_light: ${c "primary_hi"};
        --primary_lighter: ${c "primary_hi"};
        --primary_dark: #8e977f;
        --primary_darker: #6f7763;

        --text: ${c "fg"};
        --text_light: ${c "fg"};
        --text_muted: ${c "fg_dim"};

        --list_item_bg_selected: var(--grey3);
        --list_item_bg_hover: var(--grey4);
        --highlight_color: ${c "primary"};
        --border_color: ${c "surface2"};

        --border_radius: 8px;
        --border_radius_small: 6px;
        --border_radius_large: 12px;
    }

    QWidget {
        font-family: "${theme.font.ui}";
    }
  '';
in
{
  programs.obs-studio.enable = true;

  xdg.configFile."obs-studio/themes/Closs.ovt".text = variant;

  # Select the theme without owning user.ini (OBS rewrites it constantly).
  home.activation.obsTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="${config.xdg.configHome}/obs-studio/user.ini"
    if [ -f "$f" ] && ! ${pkgs.procps}/bin/pgrep -x obs >/dev/null; then
      run ${pkgs.crudini}/bin/crudini --set "$f" Appearance Theme com.obsproject.Yami.Closs
    fi
  '';
}
