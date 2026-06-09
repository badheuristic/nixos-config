{ config, pkgs, theme, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox-beta;
    nativeMessagingHosts = [ pkgs.uget-integrator ];
    profiles.badheuristic = {
      isDefault = true;
      path = "badheuristic";
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "ui.key.menuAccessKeyFocuses" = false;
        "browser.tabs.tabClipWidth" = 140000;
        "browser.uidensity" = 1;
      };
      search = {
      force = true;
      default = "google";
      engines = {
        "NixOS Packages" = {
          urls = [{
            template = "https://search.nixos.org/packages";
            params = [
              { name = "channel"; value = "unstable"; }
              { name = "query"; value = "{searchTerms}"; }
            ];
          }];
          icon = "https://nixos.org/favicon.png";
          updateInterval = 24 * 60 * 60 * 1000; # every day
          definedAliases = [ "@np" ];
          };
          "Home Manager Options" = {
            urls = [{
              template = "https://home-manager-options.extranix.com/";
              params = [
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            definedAliases = [ "@hm" ];
          };
        };
      };
      userChrome = ''
        * {
          font-family: 'DejaVu Sans', sans-serif !important;
          font-size: 13px !important;
          border-radius: 0px !important;
        }

        .titlebar-buttonbox-container { display: none; }
        .titlebar-spacer[type="post-tabs"]{ display: none; }

        :root {
          --bg-color: #${theme.bg};
          --fg-color: #${theme.fg};
          --alt-color: #${theme.alt};
          --primary-color: #${theme.primary};
          --tab-min-height: 24px !important;
          --tab-block-margin: 0 !important;
        }
        
        #navigator-toolbox {
          background-color: var(--bg-color) !important;
          border: none !important;
        }

        #TabsToolbar {
          background-color: var(--bg-color) !important;
        }

        .tab-background[selected="true"] {
          background-color: var(--alt-color) !important;
          background-image: none !important;
          margin-bottom: 0 !important;
        }

        .tab-line { display: none !important; }
        .tabbrowser-tab { 
          color: var(--fg-color) !important; 
          padding: 0 !important;
          margin: 0 !important;
        }
        
        .tab-icon-image { display: none !important; }

        #urlbar-background {
          background-color: var(--bg-color) !important;
          border: 1px solid var(--alt-color) !important;
        }

        #urlbar[focused="true"] > #urlbar-background {
          border: 1px solid var(--primary-color) !important;
        }

        #urlbar-input { color: var(--fg-color) !important; }

        #nav-bar {
          min-height: 28px !important;
          max-height: 28px !important;
          padding: 0 !important;
          margin: 0 !important;
        }

        #urlbar-container, #urlbar {
          min-height: 24px !important;
          margin-top: 0 !important;
          margin-bottom: 0 !important;
        }

        .toolbarbutton-1 {
          padding: 2px !important;
          margin: 0 !important;
        }
      '';
    };
  };
}
