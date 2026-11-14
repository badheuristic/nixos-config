{ config, pkgs, lib, inputs, theme, ... }:

# Spotify via Spicetify, styled after Apple Music on the Closs palette.
# Spotify's own layout is kept (layout-rearranging themes break with new
# clients); the look comes from one stylesheet plus a tiny extension:
#   - the window chrome (top bar, sidebar, player) picks up the playing
#     cover as a dark blurred wash, like macOS vibrancy; content stays a
#     solid neutral sheet
#   - SF Compact, Apple-sized titles, no colour bands, shadowed art,
#     quiet zebra rows; Spicy Lyrics' colour canvas dimmed in the sidebar
#   - squarer geometry: 10px panels, 6–8px cards and art
#   - the player floats as a glass bar over panels that run underneath it
#   - Spicy Lyrics for Apple-style word-by-word lyrics
#
# Marketplace is installed for browsing, but with this flake it can't
# install anything (Spotify's files are read-only Nix store paths).
# Extensions are added below instead: browse in Marketplace, then add the
# matching entry from spicePkgs.extensions here.
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # "rgba(r, g, b, a)" from a palette name
  rgba = name: alpha:
    let
      h = theme.${name};
      ch = i: toString (lib.fromHexString (builtins.substring i 2 h));
    in "rgba(${ch 0}, ${ch 2}, ${ch 4}, ${alpha})";

  font = ''"${theme.font.ui}", "SF Pro Text", system-ui, sans-serif'';

  # Publishes the playing track's cover as --closs-cover on <html>.
  coverJs = pkgs.writeTextDir "closs.js" ''
    (function closs() {
      const P = window.Spicetify && Spicetify.Player;
      if (!P || !P.addEventListener || !P.data) {
        setTimeout(closs, 300);
        return;
      }
      const toUrl = (u) => !u ? null
        : u.startsWith("spotify:image:") ? "https://i.scdn.co/image/" + u.slice(14)
        : u;
      const update = () => {
        const m = (P.data && P.data.item && P.data.item.metadata) || {};
        const url = toUrl(m.image_xlarge_url || m.image_large_url || m.image_url);
        const root = document.documentElement;
        if (url) {
          root.style.setProperty("--closs-cover", 'url("' + url + '")');
          root.classList.add("closs-has-cover");
        } else {
          root.classList.remove("closs-has-cover");
        }
      };
      P.addEventListener("songchange", update);
      update();
    })();
  '';

  css = ''
    :root, .encore-dark-theme, .encore-base-set {
      --encore-title-font-stack: ${font} !important;
      --encore-body-font-stack: ${font} !important;
      --encore-variable-font-stack: ${font} !important;
    }
    body, body button, body input, body .encore-text { font-family: ${font} !important; letter-spacing: 0 !important; }

    /* window chrome picks up the cover colour, faintly (vibrancy) */
    body { background: #${theme.bg_alt} !important; }
    .Root__top-container { background: transparent !important; }
    .Root__top-container::before {
      content: ""; position: fixed; inset: -20%; z-index: -1; pointer-events: none;
      background: var(--closs-cover, none) center / cover no-repeat;
      filter: blur(100px) saturate(1.2) brightness(0.24);
      opacity: 0; transition: opacity 600ms ease;
    }
    .closs-has-cover .Root__top-container::before { opacity: 1; }
    .Root__globalNav, .main-topBar-container { background: transparent !important; }

    /* panels: solid content, glass sidebar */
    .Root__main-view, .Root__right-sidebar {
      background: #${theme.bg} !important; border-radius: 10px !important;
      box-shadow: inset 0 0 0 1px rgba(255,255,255,0.04) !important; overflow: hidden;
    }
    .Root__nav-bar, .main-yourLibraryX-libraryContainer {
      background: ${rgba "bg" "0.45"} !important; backdrop-filter: blur(40px) saturate(140%) !important;
      border-radius: 10px !important; box-shadow: inset 0 0 0 1px rgba(255,255,255,0.05) !important;
    }
    .playlist-playlist-playlistContent { background: #${theme.bg} !important; }

    /* headers: no colour band, art-forward, Apple-sized title */
    .playlist-playlist-actionBarBackground-background,
    .main-actionBarBackground-background,
    .main-entityHeader-backgroundColor, .main-entityHeader-overlay { background: none !important; background-image: none !important; }
    .main-entityHeader-image, .main-entityHeader-image img { border-radius: 8px !important; box-shadow: 0 16px 40px rgba(0,0,0,0.55) !important; }
    .main-entityHeader-title h1, .main-entityHeader-title .encore-text {
      letter-spacing: -0.02em !important; font-weight: 700 !important;
    }
    .main-topBar-background { background-color: ${rgba "bg" "0.72"} !important; backdrop-filter: blur(24px) saturate(150%) !important; }
    .main-topBar-overlay { background: none !important; }

    /* track lists: hairline-divided, quiet zebra */
    .main-trackList-trackListRow { border-radius: 6px !important; background-color: transparent !important; }
    [role="row"]:nth-child(odd) > .main-trackList-trackListRow { background-color: rgba(255,255,255,0.03) !important; }
    .main-trackList-trackListRow:hover { background-color: rgba(255,255,255,0.08) !important; }
    .main-trackList-trackListRow[aria-selected="true"] { background-color: ${rgba "primary" "0.18"} !important; }
    .main-trackList-trackListHeaderStuck { background-color: ${rgba "bg" "0.75"} !important; backdrop-filter: blur(24px) !important; border-bottom: 1px solid rgba(255,255,255,0.06) !important; }

    /* cards & art */
    .main-card-card { border-radius: 8px !important; background: transparent !important; }
    .main-card-card:hover { background: rgba(255,255,255,0.05) !important; }
    .main-card-imageContainer:not(:has(.main-cardImage-circular)),
    .main-card-imageContainer img:not(.main-cardImage-circular),
    .main-trackList-trackListRow img, .main-nowPlayingWidget-coverArt, .main-nowPlayingWidget-coverArt img { border-radius: 6px !important; }
    .main-card-imageContainer:not(:has(.main-cardImage-circular)) { box-shadow: 0 8px 22px rgba(0,0,0,0.45) !important; }

    /* right sidebar: Spicy Lyrics' colour canvas, dimmed so text stays calm */
    .spicy-dynamic-bg { filter: brightness(0.5) saturate(1.1) !important; }
    .main-nowPlayingView-section, #SpicyLyricsNPVCard, .SpicyLyricsNPVCard {
      background-color: rgba(255,255,255,0.06) !important; border-radius: 10px !important;
      backdrop-filter: blur(20px) !important;
    }



    /* search: rounded rect glass */
    .main-globalNav-searchInputContainer input { border-radius: 10px !important; background-color: rgba(255,255,255,0.07) !important; box-shadow: inset 0 0 0 1px rgba(255,255,255,0.05) !important; }
    .main-globalNav-searchInputContainer input:hover { background-color: rgba(255,255,255,0.1) !important; }
    .main-globalNav-searchInputContainer input:focus { background-color: rgba(255,255,255,0.12) !important; box-shadow: inset 0 0 0 1px rgba(255,255,255,0.18) !important; }
    .main-globalNav-searchInputWrapper, .main-globalNav-searchInputContainer [class*="form-input-icon__icon"] { background: transparent !important; }

    /* menus */
    /* the blur sits on a pseudo-element: backdrop-filter on the menu itself
       would trap submenus inside it (scrolling) instead of beside it */
    .main-contextMenu-menu, [data-tippy-root] > div {
      background-color: transparent !important;
      border: 1px solid rgba(255,255,255,0.07) !important; border-radius: 10px !important; box-shadow: 0 12px 32px rgba(0,0,0,0.45) !important;
    }
    [data-tippy-root] > div, [data-tippy-root] > .main-contextMenu-menu { position: relative; isolation: isolate; }
    [data-tippy-root] > div::before, [data-tippy-root] > .main-contextMenu-menu::before {
      content: ""; position: absolute; inset: 0; z-index: -1; border-radius: inherit; pointer-events: none;
      background-color: ${rgba "surface" "0.85"}; backdrop-filter: blur(30px) saturate(160%);
    }

    /* shortcut hints: soft keycaps, no fade band behind them */
    kbd { background: rgba(255,255,255,0.08) !important; box-shadow: none !important; border: none !important; border-radius: 5px !important; color: #${theme.fg_dim} !important; }
    .main-globalNav-searchInputTextWrapper span:has(> kbd) { background: none !important; }

    /* quick search (Ctrl+K): one glass sheet like the island launcher */
    .GenericModal__overlay:has(input[role="combobox"]) { background-color: rgba(0,0,0,0.45) !important; backdrop-filter: blur(6px) !important; }
    .GenericModal__overlay [role="dialog"] > div:has(input[role="combobox"]) {
      background-color: ${rgba "surface" "0.88"} !important; backdrop-filter: blur(40px) saturate(160%) !important;
      border-radius: 16px !important; border: 1px solid rgba(255,255,255,0.08) !important;
      box-shadow: 0 24px 60px rgba(0,0,0,0.55) !important;
    }
    .GenericModal__overlay [role="dialog"] > div:has(input[role="combobox"]) > div { background: transparent !important; border-radius: 0 !important; }
    .GenericModal__overlay div:has(> input[role="combobox"]) {
      background-color: rgba(255,255,255,0.07) !important; border-radius: 10px !important;
      box-shadow: inset 0 0 0 1px rgba(255,255,255,0.06) !important;
    }
    .GenericModal__overlay input[role="combobox"] { color: #${theme.fg} !important; }
    .GenericModal__overlay div:has(> input[role="combobox"]) svg { fill: #${theme.fg_dim} !important; color: #${theme.fg_dim} !important; }
    .GenericModal__overlay [role="option"] { border-radius: 8px !important; }
    .GenericModal__overlay [role="option"][aria-selected="true"] { background-color: rgba(255,255,255,0.08) !important; }
    .GenericModal__overlay [role="option"] > div[aria-hidden="true"]:last-child > span { background: rgba(255,255,255,0.06) !important; border-radius: 6px !important; }
    .main-contextMenu-menu button, .main-contextMenu-menu a { border-radius: 6px !important; }
    .os-scrollbar-handle { background: rgba(255,255,255,0.14) !important; border-radius: 4px !important; }
    /* Apple-sized titles instead of Spotify's poster type */
    .main-entityHeader-title h1, .main-entityHeader-title .encore-text,
    [data-testid="entityTitle"] h1, [data-testid="entityTitle"] span { font-size: clamp(2rem, 3.6vw, 3.4rem) !important; line-height: 1.08 !important; }
    /* home: no grey band, glassy shortcut tiles */
    .main-home-homeHeader, .main-home-filterChipsSection { background: none !important; background-color: transparent !important; }
    .main-home-filterChipsSection { background-color: ${rgba "bg" "0.72"} !important; backdrop-filter: blur(24px) !important; }
    .view-homeShortcutsGrid-shortcut {
      background: rgba(255,255,255,0.055) !important; border-radius: 8px !important; overflow: hidden;
      box-shadow: inset 0 0 0 1px rgba(255,255,255,0.04) !important; transition: background-color 160ms ease !important;
    }
    .view-homeShortcutsGrid-shortcut:hover { background: rgba(255,255,255,0.1) !important; }

    /* top bar: bare glyphs with a soft hover; nothing inside the search field */
    .Root__globalNav button[class*="legacy-button-tertiary"] {
      background-color: transparent !important; box-shadow: none !important;
      transition: background-color 160ms ease, opacity 160ms ease !important;
    }
    .main-globalNav-historyButtons button:hover,
    .main-actionButtons button:hover { background-color: rgba(255,255,255,0.08) !important; }
    .Root__globalNav button[aria-label="Marketplace"]:hover,
    .main-globalNav-searchContainer > button:hover { background-color: rgba(255,255,255,0.08) !important; }
    .main-globalNav-searchInputContainer button, .main-globalNav-browseButtonWrapper button { background: transparent !important; box-shadow: none !important; }
    .spicetify-sc-chevronBtn { background: transparent !important; }

    /* player: a floating glass bar over the panels, which run to the bottom */
    .Root__nav-bar, .Root__main-view, .Root__right-sidebar { grid-row: 3 / 5 !important; }
    .Root__now-playing-bar {
      grid-row: 4 / 5 !important; position: relative !important; z-index: 10 !important;
      align-self: end; margin: 0 12px 8px !important; padding: 0 4px !important;
      background: ${rgba "bg" "0.62"} !important; backdrop-filter: blur(36px) saturate(170%) !important;
      border-radius: 14px !important;
      box-shadow: 0 10px 34px rgba(0,0,0,0.55), inset 0 1px 0 rgba(255,255,255,0.08), inset 0 0 0 1px rgba(255,255,255,0.06) !important;
    }
    /* room to scroll the last rows out from under the bar */
    .main-nowPlayingView-panel,
    .Root__nav-bar [data-overlayscrollbars-viewport] > :first-child,
    .Root__right-sidebar [data-overlayscrollbars-viewport] > :first-child { padding-bottom: 128px !important; }
    /* the main view is pinned to the window height and its pages overflow it,
       so padding there never shows; a spacer after the page does */
    .main-view-container__scroll-node-child > main::after { content: ""; display: block; height: 128px; }
  '';

  clossTheme = pkgs.runCommand "spicetify-closs" { } ''
    mkdir -p $out
    cp ${pkgs.writeText "user.css" css} $out/user.css
    touch $out/color.ini
  '';
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.spicetify ];

  programs.spicetify = {
    enable = true;
    theme = {
      name = "Closs";
      src = clossTheme;
      injectCss = true;
      replaceColors = true;
      overwriteAssets = false;
      homeConfig = true;
    };
    colorScheme = "custom";
    customColorScheme = {
      text = theme.fg;
      subtext = theme.fg_dim;
      main = theme.bg;
      main-elevated = theme.surface;
      main-transition = theme.bg;
      highlight = theme.surface;
      highlight-elevated = theme.surface2;
      sidebar = theme.bg_alt;
      player = theme.bg_alt;
      card = theme.surface;
      shadow = theme.black;
      selected-row = theme.fg;
      button = theme.primary;
      button-active = theme.primary_hi;
      button-secondary = theme.fg_dim;
      button-disabled = theme.surface3;
      tab-active = theme.surface2;
      notification = theme.surface2;
      notification-error = theme.red;
      misc = theme.fg_faint;
      play-button = theme.fg;
      play-button-active = theme.fg;
      progress-fg = theme.fg;
      progress-bg = theme.surface3;
      heart = theme.primary;
      pagelink-active = theme.fg;
      radio-btn-active = theme.primary;
    };
    enabledExtensions = with spicePkgs.extensions; [
      hidePodcasts
      shuffle
      spicyLyrics
      { src = coverJs; name = "closs.js"; }
    ];
    enabledCustomApps = with spicePkgs.apps; [
      marketplace
    ];
  };
}
