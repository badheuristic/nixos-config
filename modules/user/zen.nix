{ config, pkgs, inputs, theme, ... }:

# Zen browser: colours only. The existing profile is adopted in place so
# history, logins and spaces are untouched.
let
  c = name: "#${theme.${name}}";
in
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;

    profiles."Default Profile" = {
      id = 0;
      path = "2ghuv66l.Default Profile";
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "zen.theme.accent-color" = c "primary";
        "zen.view.grey-out-inactive-windows" = false;
        "zen.widget.linux.transparency" = false;
        "browser.theme.content-theme" = 0; # dark
        "browser.theme.toolbar-theme" = 0;
        "layout.css.prefers-color-scheme.content-override" = 0;
        "ui.systemUsesDarkTheme" = 1;
      };

      userChrome = ''
        /* Closs palette (generated from theme.nix) */
        :root {
          --zen-primary-color: ${c "primary"} !important;
          --zen-colors-primary: ${c "surface"} !important;
          --zen-colors-secondary: ${c "surface2"} !important;
          --zen-colors-tertiary: ${c "bg"} !important;
          --zen-colors-border: ${c "surface"} !important;
          --zen-colors-border-contrast: ${c "surface2"} !important;
          --zen-colors-primary-foreground: ${c "fg"} !important;
          --zen-dialog-background: ${c "surface"} !important;
          --zen-main-browser-background: ${c "bg_alt"} !important;
          --zen-main-browser-background-toolbar: ${c "bg_alt"} !important;
          --zen-themed-toolbar-bg: ${c "bg_alt"} !important;
          --zen-themed-toolbar-bg-transparent: ${c "bg_alt"} !important;

          --toolbar-bgcolor: ${c "bg_alt"} !important;
          --toolbar-color: ${c "fg"} !important;
          --toolbar-field-background-color: ${c "surface"} !important;
          --toolbar-field-focus-background-color: ${c "surface2"} !important;
          --toolbar-field-color: ${c "fg"} !important;
          --toolbar-field-focus-color: ${c "fg"} !important;
          --toolbarbutton-hover-background: ${c "surface"} !important;
          --toolbarbutton-active-background: ${c "surface2"} !important;
          --tab-selected-bgcolor: ${c "surface"} !important;
          --tab-hover-background-color: ${c "surface"} !important;
          --focus-outline-color: ${c "primary"} !important;

          --arrowpanel-background: ${c "surface"} !important;
          --arrowpanel-color: ${c "fg"} !important;
          --arrowpanel-border-color: ${c "surface2"} !important;
          --panel-separator-color: ${c "surface2"} !important;
          --urlbarView-highlight-background: ${c "surface2"} !important;
          --urlbarView-highlight-color: ${c "fg"} !important;
          --sidebar-background-color: ${c "bg_alt"} !important;
          --sidebar-text-color: ${c "fg"} !important;
          --lwt-accent-color: ${c "bg_alt"} !important;
          --lwt-text-color: ${c "fg"} !important;
        }

        #navigator-toolbox,
        #zen-main-app-wrapper,
        #browser {
          background-color: ${c "bg_alt"} !important;
          background-image: none !important;
        }

        ::selection {
          background-color: ${c "primary"} !important;
          color: ${c "on_primary"} !important;
        }
      '';

      userContent = ''
        /* Neutral new-tab and about: pages */
        @-moz-document url-prefix("about:newtab"), url-prefix("about:home"), url-prefix("about:blank") {
          body { background-color: ${c "bg"} !important; }
        }
      '';
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "zen-beta.desktop" ];
    "x-scheme-handler/http" = [ "zen-beta.desktop" ];
    "x-scheme-handler/https" = [ "zen-beta.desktop" ];
    "x-scheme-handler/about" = [ "zen-beta.desktop" ];
    "x-scheme-handler/unknown" = [ "zen-beta.desktop" ];
    "application/pdf" = [ "org.pwmt.zathura.desktop" ];
  };
}
