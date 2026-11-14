{ config, pkgs, inputs, theme, ... }:

let
  wvkbd-deskintl = pkgs.wvkbd.overrideAttrs (old: {
    makeFlags = (old.makeFlags or []) ++ [ "LAYOUT=deskintl" ];
  });

  # Lightweight TeX Live bundle (~200MB instead of 5GB scheme-full) with all
  # packages required by ~/Programming/resume-workspace
  texResume = pkgs.texliveSmall.withPackages (ps: with ps; [
    marvosym
    titlesec
    enumitem
    preprint
    fancyhdr
  ]);
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ../../modules/user/hyprland.nix
    ../../modules/user/hypridle.nix
    ../../modules/user/hyprlock.nix
    ../../modules/user/closs.nix
    ../../modules/user/zathura.nix
    ../../modules/user/kitty.nix
    ../../modules/user/zsh.nix
    ../../modules/user/nixvim.nix
    ../../modules/user/zen.nix
    ../../modules/user/gtk.nix
    ../../modules/user/qt.nix
    ../../modules/user/yazi.nix
    ../../modules/user/tmux.nix
    ../../modules/user/fastfetch.nix
    ../../modules/user/obsidian.nix
    ../../modules/user/spicetify.nix
    ../../modules/user/vesktop.nix
    ../../modules/user/obs.nix
    ../../modules/user/swayimg.nix
    ../../modules/user/vscode.nix
  ];

  home.username = "chaka";
  home.homeDirectory = "/home/chaka";

  home.packages = with pkgs; [
    # Claude (CLI & Desktop) + Coding Agents (VS Code: modules/user/vscode.nix)
    claude-code
    inputs.claude-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
    codex

    # Jaza work & systemd timer dependencies
    uv
    bun
    gh
    glab
    libnotify

    # Wayland utilities (shell, lock, idle: modules/user/{closs,hypr*}.nix)
    grim
    slurp
    wl-clipboard
    pavucontrol
    brightnessctl
    nmgui
    nautilus
    wvkbd-deskintl

    # Lightweight LaTeX for building resumes
    texResume

    # CLI utilities
    ripgrep
    fzf
    ncdu
    btop
    tldr
    sops
    unzip
    _7zz
    rsync

    # Media, Notes & Apps
    # mixxx
    # slsk-batchdl
    qbittorrent
    mpv
    imagemagick
    ffmpeg
    yt-dlp
    xournalpp
    vial

    # Gaming & Emulators
    lutris
    rpcs3
    pcsx2
    wineWow64Packages.stable
    winetricks
    protonup-qt
    sc-controller
  ];

  # Claude Desktop's launcher reads this for Electron's --password-store
  # (it would detect gnome-keyring anyway; this makes it unconditional).
  home.sessionVariables.CLAUDE_PASSWORD_STORE = "gnome-libsecret";

  services.cliphist.enable = true;

  # Phone link (the island's dashboard reads it through kdeconnect-cli)
  services.kdeconnect = {
    enable = true;
    indicator = false;
  };

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
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
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
