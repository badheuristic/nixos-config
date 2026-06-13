{ config, pkgs, inputs, theme, ... }:

let
  wvkbd-deskintl = pkgs.wvkbd.overrideAttrs (old: {
    makeFlags = (old.makeFlags or []) ++ [ "LAYOUT=deskintl" ];
  });
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/user/hyprland.nix
    ../../modules/user/hyprlock.nix
    ../../modules/user/waybar.nix
    ../../modules/user/zathura.nix
    ../../modules/user/rofi.nix
    ../../modules/user/mako.nix
    ../../modules/user/kitty.nix
    ../../modules/user/zsh.nix
    ../../modules/user/cava.nix
    ../../modules/user/nixvim.nix
    ../../modules/user/firefox.nix
    ../../modules/user/gtk.nix
    ../../modules/user/yazi.nix
    ../../modules/user/tmux.nix
    ../../modules/user/fastfetch.nix
  ];
  # nixpkgs.config.allowUnfree = true;

  home.username = "badheuristic";
  home.homeDirectory = "/home/badheuristic";

  home.packages = with pkgs; [
    claude-code
    uget
    qbittorrent
    fastfetch
    feh
    pavucontrol
    brightnessctl
    bluetuith
    nmgui
    antigravity
    ripgrep
    grim
    slurp
    wl-clipboard
    obs-studio
    mpv
    lutris
    wineWow64Packages.stable
    winetricks
    protonup-qt
    # (bottles.override { removeWarningPopup = true; })
    texlive.combined.scheme-full
    sc-controller
    # dualsensectl
    codex
    inputs.concord.packages.${pkgs.system}.default
    aerc
    ncdu
    calcurse
    spotify-player
    #postman
    imagemagick
    ffmpeg
    yt-dlp
    xournalpp
    wvkbd-deskintl
    mixxx
    (nchat.overrideAttrs (old: {
      buildInputs = (old.buildInputs or []) ++ [ pkgs.libpng ];
    }))
    slsk-batchdl
    # rpcs3 # Currently broken in nixos-unstable (GLEW linking error)
    sops
  ];

  services.cliphist.enable = true;

  programs.git = {
    enable = true;
    signing.format = null;
    settings = {
      user.name = "stephen";
      user.email = "steveoncaffeine@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.vesktop.enable = true;

  services.hyprpaper = let
    wallpaper_path = "${../../assets/checker.png}";
  in {
    enable = true;
    settings = {
      ipc = "on";
      splash = false;
      wallpaper = [
        {
          monitor = "";
          path = "${wallpaper_path}";
          fit_mode = "cover";
        }
      ];
    };
  };

  home.stateVersion = "24.05";
}
