{ config, pkgs, lib, theme, ... }:

# Obsidian: a vault CSS snippet in the Closs palette, layered over the
# user's chosen community theme. Obsidian's appearance.json stays writable —
# activation only switches the snippet on and sets fonts/accent.
let
  c = name: "#${theme.${name}}";
  vault = "${config.home.homeDirectory}/Documents/Vault";
in
{
  # Electron can't detect the keyring under Hyprland; point it at libsecret
  home.packages = [ (pkgs.obsidian.override { commandLineArgs = "--password-store=gnome-libsecret"; }) ];

  home.file."Documents/Vault/.obsidian/snippets/closs.css".text = ''
    /* Closs palette (generated from theme.nix) */
    body.theme-dark,
    .theme-dark {
      --color-base-00: ${c "bg"};
      --color-base-05: ${c "bg_alt"};
      --color-base-10: ${c "bg_alt"};
      --color-base-20: ${c "surface"};
      --color-base-25: ${c "surface"};
      --color-base-30: ${c "surface2"};
      --color-base-35: ${c "surface3"};
      --color-base-40: ${c "surface3"};
      --color-base-50: ${c "fg_faint"};
      --color-base-60: ${c "fg_dim"};
      --color-base-70: ${c "fg_dim"};
      --color-base-100: ${c "fg"};

      --color-red: ${c "red"};
      --color-orange: ${c "orange"};
      --color-yellow: ${c "yellow"};
      --color-green: ${c "green"};
      --color-cyan: ${c "cyan"};
      --color-blue: ${c "blue"};
      --color-purple: ${c "magenta"};

      --color-accent: ${c "primary"};
      --color-accent-1: ${c "primary"};
      --color-accent-2: ${c "primary_hi"};
      --interactive-accent: ${c "primary"};
      --interactive-accent-hover: ${c "primary_hi"};
      --text-on-accent: ${c "on_primary"};

      --background-primary: ${c "bg"};
      --background-primary-alt: ${c "bg_alt"};
      --background-secondary: ${c "bg_alt"};
      --background-secondary-alt: ${c "bg_alt"};
      --background-modifier-border: ${c "surface"};
      --background-modifier-border-hover: ${c "surface2"};
      --background-modifier-border-focus: ${c "surface3"};
      --background-modifier-form-field: ${c "surface"};
      --background-modifier-hover: rgba(255, 255, 255, 0.04);
      --background-modifier-active-hover: rgba(255, 255, 255, 0.07);
      --titlebar-background: ${c "bg_alt"};
      --titlebar-background-focused: ${c "bg_alt"};
      --tab-container-background: ${c "bg_alt"};
      --ribbon-background: ${c "bg_alt"};
      --modal-background: ${c "surface"};
      --menu-background: ${c "surface"};
      --code-background: ${c "bg_alt"};

      --text-normal: ${c "fg"};
      --text-muted: ${c "fg_dim"};
      --text-faint: ${c "fg_faint"};
      --text-accent: ${c "primary"};
      --text-accent-hover: ${c "primary_hi"};
      --text-error: ${c "red"};
      --text-warning: ${c "yellow"};
      --text-success: ${c "green"};
      --text-selection: color-mix(in srgb, ${c "primary"} 22%, transparent);

      --link-color: ${c "primary"};
      --link-color-hover: ${c "primary_hi"};
      --link-external-color: ${c "blue"};
      --tag-color: ${c "primary"};
      --tag-background: color-mix(in srgb, ${c "primary"} 12%, transparent);

      --radius-s: 6px;
      --radius-m: ${toString theme.radius.control}px;
      --radius-l: ${toString theme.radius.card}px;
      --radius-xl: ${toString theme.radius.card}px;

      --font-interface-theme: "${theme.font.ui}";
      --font-text-theme: "${theme.font.ui}";
      --font-monospace-theme: "${theme.font.mono}";
    }

    /* a settings sub-page's sticky title bar (and the shadow that fades it
       out) is drawn in the modal's colour, a shade lighter than the page,
       which showed as a grey band dissolving into a gradient; match the page */
    .vertical-tab-content .setting-page-titlebar {
      background-color: var(--background-primary);
      box-shadow: 0 var(--size-4-2) var(--size-4-2) 0 var(--background-primary);
    }
  '';

  home.activation.obsidianSnippet = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="${vault}/.obsidian/appearance.json"
    if [ -f "$f" ]; then
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq '
        .enabledCssSnippets = ((.enabledCssSnippets // []) + ["closs"] | unique)
        | .accentColor = "${c "primary"}"
        | .interfaceFontFamily = "${theme.font.ui}"
        | .theme = "obsidian"
      ' "$f" > "$tmp" && run cp "$tmp" "$f"
      rm -f "$tmp"
    fi
  '';
}
