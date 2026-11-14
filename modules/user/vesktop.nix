{ config, pkgs, lib, theme, ... }:

# Vesktop: a Vencord theme generated from the palette. Vencord's settings
# file stays writable — we only add the theme to `enabledThemes`.
let
  c = name: "#${theme.${name}}";
  css = ''
    /**
     * @name Closs
     * @description Neutral graphite palette matching the Closs rice.
     * @author chaka
     * @version 1.0.0
     */

    /* `html:root:root` outranks the plain selectors in quickCss.css */
    html:root:root,
    html .theme-dark,
    html .theme-darker,
    html .theme-midnight,
    html .visual-refresh.theme-dark {
      --font-primary: "${theme.font.ui}", sans-serif !important;
      --font-display: "${theme.font.ui}", sans-serif !important;
      --font-headline: "${theme.font.ui}", sans-serif !important;
      --font-code: "${theme.font.mono}", monospace !important;

      /* surfaces (visual refresh) */
      --background-base-lowest: ${c "bg_alt"} !important;
      --background-base-lower: ${c "bg_alt"} !important;
      --background-base-low: ${c "bg"} !important;
      --background-surface-high: ${c "surface"} !important;
      --background-surface-higher: ${c "surface"} !important;
      --background-surface-highest: ${c "surface2"} !important;
      --chat-background-default: ${c "bg"} !important;
      --bg-base-primary: ${c "bg"} !important;
      --bg-base-secondary: ${c "bg_alt"} !important;
      --bg-base-tertiary: ${c "bg_alt"} !important;
      --bg-surface-raised: ${c "surface"} !important;
      --bg-surface-overlay: ${c "surface"} !important;

      /* surfaces (legacy names) */
      --background-primary: ${c "bg"} !important;
      --background-secondary: ${c "bg_alt"} !important;
      --background-secondary-alt: ${c "bg_alt"} !important;
      --background-tertiary: ${c "bg_alt"} !important;
      --background-floating: ${c "surface"} !important;
      --background-nested-floating: ${c "surface"} !important;
      --background-mobile-primary: ${c "bg"} !important;
      --background-mobile-secondary: ${c "bg_alt"} !important;
      --channeltextarea-background: ${c "surface"} !important;
      --modal-background: ${c "surface"} !important;
      --modal-footer-background: ${c "bg_alt"} !important;
      --input-background: ${c "surface"} !important;
      --app-frame-background: ${c "bg_alt"} !important;

      --background-modifier-hover: rgba(255, 255, 255, 0.04) !important;
      --background-modifier-active: rgba(255, 255, 255, 0.07) !important;
      --background-modifier-selected: rgba(255, 255, 255, 0.08) !important;
      --background-modifier-accent: ${c "surface2"} !important;
      --border-subtle: ${c "surface"} !important;
      --border-faint: ${c "surface"} !important;

      /* text */
      --text-normal: ${c "fg"} !important;
      --text-default: ${c "fg"} !important;
      --text-strong: ${c "fg"} !important;
      --text-muted: ${c "fg_dim"} !important;
      --text-subtle: ${c "fg_dim"} !important;
      --header-primary: ${c "fg"} !important;
      --header-secondary: ${c "fg_dim"} !important;
      --channels-default: ${c "fg_dim"} !important;
      --interactive-normal: ${c "fg_dim"} !important;
      --interactive-hover: ${c "fg"} !important;
      --interactive-active: ${c "fg"} !important;
      --interactive-muted: ${c "fg_faint"} !important;
      --text-link: ${c "blue"} !important;

      /* accent */
      --brand-500: ${c "primary"} !important;
      --brand-560: ${c "primary"} !important;
      --brand-experiment: ${c "primary"} !important;
      --brand-experiment-560: ${c "primary"} !important;
      --control-brand-foreground: ${c "primary"} !important;
      --control-brand-foreground-new: ${c "primary"} !important;
      --button-filled-brand-background: ${c "primary"} !important;
      --button-filled-brand-background-hover: ${c "primary_hi"} !important;
      --button-filled-brand-text: ${c "on_primary"} !important;
      --mention-background: color-mix(in srgb, ${c "primary"} 12%, transparent) !important;
      --mention-foreground: ${c "primary"} !important;
      --info-warning-foreground: ${c "yellow"} !important;
      --text-danger: ${c "red"} !important;
      --status-danger: ${c "red"} !important;
      --status-positive: ${c "green"} !important;
      --status-warning: ${c "yellow"} !important;

      --radius-sm: 8px !important;
      --radius-md: 12px !important;
      --radius-lg: 16px !important;
    }

    html body,
    html [class^="app_"],
    html [class^="text-"] {
      font-family: "${theme.font.ui}", sans-serif !important;
    }
  '';
in
{
  home.packages = [ pkgs.vesktop ];

  xdg.configFile."vesktop/themes/closs.theme.css".text = css;

  # Enable the theme without taking ownership of Vencord's settings file.
  home.activation.vesktopTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    f="${config.xdg.configHome}/vesktop/settings/settings.json"
    if [ -f "$f" ]; then
      tmp=$(mktemp)
      ${pkgs.jq}/bin/jq '.enabledThemes = ((.enabledThemes // []) + ["closs.theme.css"] | unique)' "$f" > "$tmp" \
        && run cp "$tmp" "$f"
      rm -f "$tmp"
    fi
  '';
}
