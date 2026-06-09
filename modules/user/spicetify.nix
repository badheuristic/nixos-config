{ config, pkgs, inputs, theme, ... }:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;
    theme = {
      name = "text";
      src = ./spotify-text-theme;
      injectCss = true;
      replaceColors = true;
      overwriteAssets = true;
      sidebarConfig = true;
    };
    colorScheme = "custom";

    customColorScheme = {
      text               = "${theme.fg}";
      subtext            = "${theme.primary}";
      main               = "${theme.bg}";
      sidebar            = "${theme.bg_alt}";
      player             = "${theme.bg_alt}";
      card               = "${theme.bg_alt}";
      shadow             = "${theme.shadow}";
      selected-row       = "${theme.alt}";
      button             = "${theme.primary}";
      button-active      = "${theme.fg}";
      button-disabled    = "${theme.alt}";
      tab-active         = "${theme.alt}";
      notification       = "${theme.urgent}";
      notification-error = "${theme.urgent}";
      misc               = "${theme.bg}";
      accent             = "${theme.alt}";
      "accent-active"    = "ffffff";
      "accent-inactive"  = "${theme.bg_alt}";
      banner             = "${theme.bg_alt}";
      "border-active"    = "${theme.alt}";
      "border-inactive"  = "${theme.bg_alt}";
      header             = "${theme.bg_alt}";
      highlight          = "${theme.alt}";
    };
  };
}
