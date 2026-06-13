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

    concord.url = "github:chojs23/concord";
    concord.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, home-manager, sops-nix, ... }@inputs: {
    nixosConfigurations.flow = nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs; };
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
            theme = {
              bg = "121212";
              bg_alt = "1c1c1c";
              fg = "d4d4d4";
              alt = "555555";
              primary = "a0a0a0";
              urgent = "666666";
              shadow = "000000";
            };
          };
          home-manager.users.badheuristic = import ./users/badheuristic/home.nix;
        }
      ];
    };
  };
}
