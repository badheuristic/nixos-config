{ config, pkgs, ... }:

let 
  z13ctl = pkgs.callPackage ../../modules/system/z13ctl.nix { };
in
{
  # nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/badheuristic/.config/sops/age/keys.txt";

  sops.secrets."discord_token" = {
    owner = "badheuristic";
  };
  sops.secrets."aerc_gmail_1" = {
    owner = "badheuristic";
  };
  sops.secrets."aerc_gmail_2" = {
    owner = "badheuristic";
  };
  sops.secrets."aerc_gmail_3" = {
    owner = "badheuristic";
  };
  sops.secrets."aerc_gmail_4" = {
    owner = "badheuristic";
  };

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
  ];
  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="ASUSTeK Computer Inc. GZ302EA-Keyboard Touchpad", ENV{ID_INPUT_TOUCHPAD_INTEGRATION}="internal", ENV{ID_INTEGRATION}="internal"
  ACTION=="add|change", KERNEL=="event*", ATTRS{name}=="RAPOO Keyboard-1 Keyboard", SYMLINK+="input/by-id/rapoo-keyboard"

  # ASUS ROG Flow Z13 - z13ctl HIDRAW permissions
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="1a30", MODE="0666", TAG+="uaccess"
  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="0b05", ATTRS{idProduct}=="19b6", MODE="0666", TAG+="uaccess"
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

  programs.zsh.enable = true;
  environment.shells = with pkgs; [ zsh ];

  users.users.badheuristic = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "bluetooth" "video" "audio" "docker" ];
    initialPassword = "changeme";
  };

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      nerd-fonts.dejavu-sans-mono
      #dejavu_fonts
      #nerd-fonts.departure-mono


    ];
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "DejaVu Sans" "Noto Sans CJK SC" ];
        serif = [ "DejaVu Serif" "Noto Sans CJK SC" ];
        monospace = [ "DejaVu Sans Mono" "Noto Sans CJK SC" ];
        # monospace = [ "DepartureMono Nerd Font" "Not Sans Mono CJK SC" ];
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
    # jack.enable = true;
    wireplumber.enable = true;
  };
  hardware.enableAllFirmware = true;

  services.displayManager.ly.enable = true;
  programs.hyprland.enable = true;
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
  # systemd.services."kmonad-main" = {
  #   serviceConfig = {
  #     Restart = "always";
  #     RestartSec = "3s";
  #     StartLimitBurst = 5;
  #     StartLimitIntervalSec="30s";
  #   };
  # };

  services.asusd = {
    enable = true;
  };
  services.power-profiles-daemon.enable = true;
  services.handheld-daemon = {
      enable = true;
      user = "badheuristic";
  };

  environment.systemPackages = with pkgs; [
    git
    firefox
    kitty
    hyprlock
    python3
    gcc
    # wineasio
    z13ctl
  ];

  environment.localBinInPath = true;
  environment.sessionVariables = {
    XDG_DATA_DIRS = [ "$XDG_DATA_DIRS" "$HOME/.local/share/flatpak/exports/share" "/var/lib/flatpak/exports/share" ];
  };

  systemd.services.z13ctl = {
    description = "z13ctl daemon";
    after = [ "multi-user.target" "hhd.service" ];
    wants = [ "hhd.service" ];
    serviceConfig = {
      ExecStart = "${z13ctl}/bin/z13ctl daemon --no-button";
      Restart = "always";
      CPUSchedulingPolicy = "idle";
    };
    wantedBy = [ "multi-user.target" ];
  };

  zramSwap.enable = true;
  system.stateVersion = "24.05";
}
