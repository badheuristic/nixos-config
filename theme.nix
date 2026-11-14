# Closs palette — one source of truth for every themed surface.
#
# Neutral, Apple-dark inspired: a pitch-black island that melts into the
# bezel, graphite surfaces, soft off-white text and a single muted sage
# accent pulled from the default wallpaper. Hex values have no leading '#'.
rec {
  # ── Neutrals ────────────────────────────────────────────────────────────
  black    = "000000"; # the island / notch — must stay pure black
  bg       = "151516"; # app window background
  bg_alt   = "0e0e0f"; # sidebars, status lines, deeper wells
  surface  = "1c1c1e"; # cards and grouped rows
  surface2 = "2c2c2e"; # raised controls, hover
  surface3 = "3a3a3c"; # pressed controls, hairline borders

  fg       = "ebebf0"; # primary label
  fg_dim   = "9a9a9f"; # secondary label
  fg_faint = "636366"; # tertiary label, placeholders

  # ── Accent ──────────────────────────────────────────────────────────────
  primary    = "b4bea4"; # muted sage
  primary_hi = "c9d1bb"; # hover / highlighted accent
  on_primary = "151612"; # text & glyphs drawn on the accent

  # ── Semantic hues (kept low-saturation so nothing shouts) ───────────────
  red     = "d98b80";
  orange  = "d6a27c";
  yellow  = "d8c38e";
  green   = "a7b98f";
  cyan    = "93b8b1";
  blue    = "94aac2";
  magenta = "b8a0bc";

  # ── Legacy aliases used by older modules (yazi, tmux, zathura, ...) ─────
  alt    = fg_dim;
  urgent = red;
  shadow = "000000";

  # ── Typography ──────────────────────────────────────────────────────────
  font = {
    ui      = "SF Compact Display"; # all interface text
    rounded = "SF Compact Rounded"; # clocks and big numerals
    mono    = "Iosevka Term";       # terminals and editors
    icons   = "Material Symbols Rounded";
  };

  # ── Shape ───────────────────────────────────────────────────────────────
  radius = {
    window = 18; # Hyprland window rounding
    card   = 18;
    control = 12;
  };
}
