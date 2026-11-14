{ config, pkgs, inputs, theme, ... }:

{
  imports = [ ../../modules/system/z13ctl-daemon.nix ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # sops-nix secrets disabled for minimal setup
  # sops.defaultSopsFile = ../../secrets/secrets.yaml;
  # sops.defaultSopsFormat = "yaml";
  # sops.age.keyFile = "/home/chaka/.config/sops/age/keys.txt";
  # sops.secrets."discord_token" = { owner = "chaka"; };
  # sops.secrets."aerc_gmail_1" = { owner = "chaka"; };
  # sops.secrets."aerc_gmail_2" = { owner = "chaka"; };
  # sops.secrets."aerc_gmail_3" = { owner = "chaka"; };
  # sops.secrets."aerc_gmail_4" = { owner = "chaka"; };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
  boot.kernelModules = [ "hid_playstation" ];
  boot.kernelParams = [
    "amdgpu.ip_block_mask=0xfffff7ff"
    "nvme_core.default_ps_max_latency_us=0"
    "pcie_aspm=off"
    "amdgpu.audio=1"
  ] ++ (let
    # Unified memory: the iGPU borrows system RAM on demand (GTT) on top of
    # the BIOS carve-out. Raise the ceiling from the default (half of RAM)
    # to 22 GiB, leaving ~5.5 GiB for the system at worst. Lower the BIOS
    # UMA buffer to 512 MB to hand the rest back to RAM, then this can grow.
    gpuSharedGiB = 22;
    pages = toString (gpuSharedGiB * 262144); # 4 KiB pages
  in [ "ttm.pages_limit=${pages}" "ttm.page_pool_size=${pages}" ]);

  # Curve Optimizer access for z13ctl undervolting (amkillam fork, Strix Halo)
  hardware.cpu.amd.ryzen-smu.enable = true;
  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="ASUSTeK Computer Inc. GZ302EA-Keyboard Touchpad", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal", ENV{ID_INTEGRATION}="internal"
  ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="RAPOO Keyboard-1 Keyboard", SYMLINK+="input/by-id/rapoo-keyboard"

  # ASUS ROG Flow Z13 - z13ctl permissions live in modules/system/z13ctl-daemon.nix
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="19b6", MODE="0666", TAG+="uaccess"

  # Vial (QMK live-edit) - Corne keyboard
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  networking.hostName = "flow";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_CA.UTF-8";

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-v14n.psf.gz";
    packages = with pkgs; [ terminus_font ];
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        AutoEnable = true;
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  security.polkit.enable = true;
  services.blueman.enable = true;
  services.udev.packages = [
    pkgs.game-devices-udev-rules
    pkgs.dualsensectl
    pkgs.sc-controller
  ];
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  virtualisation.docker = {
    enable = true;
    enableOnBoot = false;
  };
  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true; 
  };

  # Allow dynamically linked binaries (e.g. uv Python wheels / node / bun native addons)
  programs.nix-ld.enable = true;

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  users.users.chaka = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" "docker" ];
    initialPassword = "changeme";
  };

  fonts = {
    packages = with pkgs; [
      # The plain `iosevka` package does not ship the "Iosevka Term" family
      (iosevka-bin.override { variant = "SGr-IosevkaTerm"; })
      nerd-fonts.iosevka-term # icon glyph fallback for yazi/etc.
      # Apple UI faces (SF Compact for the shell/GTK/Qt, SF Pro + Mono as fallbacks)
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-compact
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-pro
      inputs.apple-fonts.packages.${pkgs.stdenv.hostPlatform.system}.sf-mono
      material-symbols # island icons
      dejavu_fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ theme.font.ui "SF Pro Display" "DejaVu Sans" ];
        serif = [ "DejaVu Serif" ];
        monospace = [ "Iosevka Term" "IosevkaTerm Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  hardware.enableAllFirmware = true;

  services.displayManager.ly.enable = true;
  programs.hyprland = {
    enable = true;
    withUWSM = false;
  };
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Closs shell dependencies
  services.upower.enable = true;        # battery in the island
  services.gvfs.enable = true;          # Nautilus trash/mounts
  programs.kdeconnect.enable = true;    # opens 1714-1764 for the phone link
  programs.dconf.enable = true;
  # Secret Service (libsecret) so apps stop falling back to plaintext.
  # The login keyring unlocks with your password at the ly login; its rare
  # unlock prompt is GTK4 (gcr) and picks up the palette from gtk.nix.
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.ly.enableGnomeKeyring = true;
  programs.seahorse.enable = true; # "Passwords and Keys", to browse/manage it

  security.pam.services.closs = { }; # the island's lock screen
  security.pam.services.hyprlock = { }; # fallback locker

  services.kmonad = {
    enable = true;
    keyboards = {
      main = {
        device = "/dev/input/by-id/usb-ASUSTeK_Computer_Inc._GZ302EA-Keyboard-if02-event-kbd";
        config = builtins.readFile ./kmonad.kbd;
      };
      rapoo = {
        device = "/dev/input/by-id/rapoo-keyboard";
        config = builtins.readFile ./kmonad_rapoo.kbd;
      };
    };
  };

  # z13ctl (modules/system/z13ctl-daemon.nix) now owns lighting, profiles and
  # the charge limit; asusd would fight it over the same devices.
  services.asusd.enable = false;

  # Power button sleeps; holding it still powers off.
  services.logind.settings.Login = {
    HandlePowerKey = "suspend";
    HandlePowerKeyLongPress = "poweroff";
  };
  services.power-profiles-daemon.enable = true;

  environment.systemPackages = with pkgs; [
    git
    python3
    gcc
  ];

  environment.localBinInPath = true;
  environment.sessionVariables = {
    XDG_DATA_DIRS = [ "$XDG_DATA_DIRS" "$HOME/.local/share/flatpak/exports/share" "/var/lib/flatpak/exports/share" ];
  };

  # sudoedit's $EDITOR lookup goes through sudo's secure_path, which doesn't
  # include the per-user home-manager profile — point it at chaka's nvim directly.
  security.sudo.extraConfig = ''
    Defaults editor=/etc/profiles/per-user/chaka/bin/nvim
  '';

  zramSwap.enable = true;
  system.stateVersion = "24.05";
}
