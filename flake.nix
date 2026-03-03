{
  description = "Home Manager configuration of devbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "git+https://github.com/jackschu/sops-nix?ref=fix-darwin-activation-order";
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
    agent-runtime = {
      url = "github:jackschu/agent_runtime";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tix = {
      url = "github:JRMurr/tix";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      sops-nix,
      nix-darwin,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      plasma-manager,
      agent-runtime,
      llm-agents,
      emacs-overlay,
      tix,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      linuxPkgs = import nixpkgs {
        system = linuxSystem;
        config.allowUnfree = true;
        overlays = [ emacs-overlay.overlays.default ];
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
      doltOverlay = final: prev: {
        dolt = prev.dolt.overrideAttrs (oldAttrs: rec {
          version = "1.83.0";
          src = prev.fetchFromGitHub {
            owner = "dolthub";
            repo = "dolt";
            tag = "v${version}";
            hash = "sha256-rEImycuuuX3IAPnkCnA1n6mjauzqQR7Z8eVgkx48Pig=";
          };
          vendorHash = "sha256-599NDn2SXvKwwaAzpgw/zp8703uG62rF1jlS7FYUYFo=";
        });
      };
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
        overlays = [
          inetutilsOverlay
          emacs-overlay.overlays.default
        ];
      };
      linuxPkgsUnstable = import nixpkgs-unstable {
        system = linuxSystem;
        overlays = [ doltOverlay ];
      };
      darwinPkgsUnstable = import nixpkgs-unstable {
        system = darwinSystem;
        overlays = [ doltOverlay ];
      };
      commonModules = [
        sops-nix.homeManagerModules.sops
      ];
      linuxBaseModules = commonModules ++ [
        plasma-manager.homeModules.plasma-manager
        ./config/linux_common.nix
      ];

      # Helper to create NixOS configs with optional agent-runtime
      mkNixos =
        {
          name,
          username,
          userDescription,
          privateModules ? [ ],
        }:
        let
          sharedModules = [
            sops-nix.nixosModules.sops
            ./nixos/nix_private_repos.nix
            ./nixos/linux_configuration.nix
            ./nixos/${name}
          ];
        in
        {
          "${name}" = nixpkgs.lib.nixosSystem {
            system = linuxSystem;
            specialArgs = {
              inherit username userDescription;
              pkgs-unstable = linuxPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${linuxSystem};
            };
            modules = sharedModules ++ privateModules;
          };
          "${name}-bootstrap" = nixpkgs.lib.nixosSystem {
            system = linuxSystem;
            specialArgs = {
              inherit username userDescription;
              pkgs-unstable = linuxPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${linuxSystem};
            };
            modules = sharedModules;
          };
        };

      # Helper to create Darwin configs with optional bootstrap
      mkDarwin =
        {
          name,
          username,
          uid,
          privateModules ? [ ],
        }:
        let
          commonDarwinModules = [
            sops-nix.darwinModules.sops
            ./nixos/nix_private_repos.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = username;
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
                mutableTaps = false;
              };
            }
            (
              { config, ... }:
              {
                homebrew.taps = builtins.attrNames config.nix-homebrew.taps;
              }
            )
            ./nixos/darwin_configuration.nix
          ];
        in
        {
          "${name}" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit username uid;
              pkgs-unstable = darwinPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${darwinSystem};
            };
            modules = commonDarwinModules ++ privateModules;
          };
          "${name}-bootstrap" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit username uid;
              pkgs-unstable = darwinPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${darwinSystem};
            };
            modules = commonDarwinModules;
          };
        };
    in
    {
      homeConfigurations."laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        extraSpecialArgs = {
          pkgs-unstable = linuxPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${linuxSystem};
          inherit tix;
        };
        modules = linuxBaseModules ++ [ ./config/laptop.nix ];
      };

      homeConfigurations."desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        extraSpecialArgs = {
          pkgs-unstable = linuxPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${linuxSystem};
          inherit tix;
        };
        modules = linuxBaseModules ++ [ ./config/desktop.nix ];
      };

      homeConfigurations."macbook_air" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        extraSpecialArgs = {
          pkgs-unstable = darwinPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${darwinSystem};
          inherit tix;
        };
        modules = commonModules ++ [ ./config/darwin.nix ];
      };

      darwinConfigurations = mkDarwin {
        name = "macbook_air";
        username = "jackschumann";
        uid = 501;
      };

      nixosConfigurations =
        (mkNixos {
          name = "dev_thinkpad";
          username = "devbox";
          userDescription = "Jack Schumann";
          privateModules = [
            agent-runtime.nixosModules.host
            ./nixos/dev_thinkpad/agent-runtime.nix
          ];
        })
        // (mkNixos {
          name = "desktop";
          username = "jackschu";
          userDescription = "Jack S";
          privateModules = [
            agent-runtime.nixosModules.host
            ./nixos/desktop/agent-runtime.nix
          ];
        });
    };
}
