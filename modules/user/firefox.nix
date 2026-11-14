{ config, pkgs, theme, ... }:

{
  programs.firefox = {
    enable = true;
    profiles.chaka = {
      userChrome = ''
        /* Remove border radius everywhere */
        * {
          border-radius: 0 !important;
          -moz-border-radius: 0 !important;
          font-family: "Iosevka Term" !important;
        }

        /* Remove window close/min/max buttons */
        .titlebar-buttonbox-container {
          display: none !important;
        }

        /* Remove the titlebar spacer that shifts content */
        .titlebar-spacer[type="post-tabs"] {
          display: none !important;
        }

        /* Square tab corners */
        .tab-background {
          border-radius: 0 !important;
        }

        /* Square toolbar / urlbar */
        #urlbar,
        #urlbar-input-container,
        #urlbar-background,
        .urlbarView,
        .urlbarView-body-inner,
        #searchbar {
          border-radius: 0 !important;
        }

        /* Square context menus and popups */
        menupopup,
        panel,
        tooltip {
          border-radius: 0 !important;
        }

        /* Square dropdowns */
        .autocomplete-richlistbox {
          border-radius: 0 !important;
        }

        /* Square notification bars */
        .notificationbox-stack > .notification,
        notification {
          border-radius: 0 !important;
        }
      '';
      settings = {
        # Required for userChrome.css to be loaded
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Disable rounded corners in content area
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
    "x-scheme-handler/about" = [ "firefox.desktop" ];
    "x-scheme-handler/unknown" = [ "firefox.desktop" ];
  };
}
