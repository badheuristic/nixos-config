{
  description = "nixos flake configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";


    claude-desktop.url = "github:patrickjaja/claude-desktop-extra";

    # Rice: Zen browser (with home-manager module), Spicetify, Apple SF fonts
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    zen-browser.inputs.home-manager.follows = "home-manager";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";

    apple-fonts.url = "github:Lyndeno/apple-fonts.nix";
    apple-fonts.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager, sops-nix, ... }@inputs: {
    nixosConfigurations.flow = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; theme = import ./theme.nix; };
      modules = [
        {
          nixpkgs.hostPlatform = "x86_64-linux";
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnfreePredicate = _: true;
          nixpkgs.overlays = [
            (final: prev: {
              openldap = prev.openldap.overrideAttrs (old: {
                doCheck = false;
              });
              electron_44 = prev.electron_44 or prev.electron_43;
              # nixpkgs is far behind upstream (1.8 vs 2.x) and unmaintained
              motrix = final.callPackage ./pkgs/motrix.nix { };
              # window corners animate into/out of fullscreen instead of snapping
              hyprland = prev.hyprland.overrideAttrs (old: {
                patches = (old.patches or [ ]) ++ [ ./patches/hyprland-fullscreen-rounding.patch ];
              });
            })
          ];
        }
        disko.nixosModules.disko
        ./hosts/flow/disk-config.nix
        ./hosts/flow/hardware-configuration.nix
        ./hosts/flow/configuration.nix
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inherit inputs;
            # Closs palette, shared by every themed app
            theme = import ./theme.nix;
          };
          home-manager.users.chaka = import ./users/chaka/home.nix;
        }
      ];
    };
  };
}
