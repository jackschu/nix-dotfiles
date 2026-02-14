{
  description = "Home Manager configuration of devbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code.url = "github:sadjow/claude-code-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      claude-code,
      sops-nix,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      plasma-manager,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      linuxPkgs = import nixpkgs {
        system = linuxSystem;
        config.allowUnfree = true;
        overlays = [ claude-code.overlays.default ];
      };
      inetutilsOverlay = final: prev: {
        inetutils = prev.inetutils.overrideAttrs (oldAttrs: rec {
          version = "2.6";
          src = prev.fetchurl {
            url = "mirror://gnu/inetutils/inetutils-${version}.tar.xz";
            hash = "sha256-aL7b/q9z99hr4qfZm8+9QJPYKfUncIk5Ga4XTAsjV8o=";
          };
        });
      };
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
        overlays = [ claude-code.overlays.default inetutilsOverlay ];
      };
      commonModules = [
        sops-nix.homeManagerModules.sops
      ];
      linuxBaseModules = commonModules ++ [
        plasma-manager.homeModules.plasma-manager
        ./config/linux_common.nix
      ];
    in
    {
      homeConfigurations."laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        modules = linuxBaseModules ++ [ ./config/laptop.nix ];
      };

      homeConfigurations."desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        modules = linuxBaseModules ++ [ ./config/desktop.nix ];
      };

      homeConfigurations."macbook_air" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        modules = commonModules ++ [ ./config/darwin.nix ];
      };

      darwinConfigurations."macbook_air" =
        let
          # Darwin user constants — update these for your machine
          username = "jackschumann";
          uid = 501;
        in nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit username uid; };
          modules = [
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = username;
                # Enable x86_64 Homebrew prefix (/usr/local) for Intel-only packages
                # enableRosetta = true;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
                mutableTaps = false;
              };
            }
            ({ config, ... }: {
              homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
            })
            ./nixos/darwin_configuration.nix
          ];
        };

      nixosConfigurations."dev_thinkpad" = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { username = "devbox"; userDescription = "Jack Schumann"; };
        modules = [
          ./nixos/linux_configuration.nix
          ./nixos/dev_thinkpad
        ];
      };

      nixosConfigurations."desktop" = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        specialArgs = { username = "jackschu"; userDescription = "Jack S"; };
        modules = [
          ./nixos/linux_configuration.nix
          ./nixos/desktop
        ];
      };
    };
}
