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
    ../../modules/user/zen.nix
    ../../modules/user/gtk.nix
    ../../modules/user/yazi.nix
    ../../modules/user/tmux.nix
    ../../modules/user/fastfetch.nix

  ];
  # nixpkgs.config.allowUnfree = true;

  home.username = "badheuristic";
  home.homeDirectory = "/home/badheuristic";

  home.packages = with pkgs; [
    vesktop
    claude-code
    uget
    qbittorrent
    swaybg
    swayimg
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

    ncdu
    obsidian
    spotify
    #postman
    imagemagick
    ffmpeg
    yt-dlp
    xournalpp
    wvkbd-deskintl
    mixxx
    slsk-batchdl
    # rpcs3 # Currently broken in nixos-unstable (GLEW linking error)
    sops
    tldr
    fzf
    direnv
    nix-direnv
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



  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "image/png" = [ "swayimg.desktop" ];
      "image/jpeg" = [ "swayimg.desktop" ];
      "image/gif" = [ "swayimg.desktop" ];
      "image/webp" = [ "swayimg.desktop" ];
      "image/x-webp" = [ "swayimg.desktop" ];
      "image/svg+xml" = [ "swayimg.desktop" ];
      "audio/ogg" = [ "mpv.desktop" ];
      "audio/oga" = [ "mpv.desktop" ];
      "audio/x-vorbis+ogg" = [ "mpv.desktop" ];
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/mp3" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/x-wav" = [ "mpv.desktop" ];
      "audio/opus" = [ "mpv.desktop" ];
      "audio/x-opus+ogg" = [ "mpv.desktop" ];
      "video/mp4" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];
    };
  };

  home.stateVersion = "24.05";
}
