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
    task_task = {
      url = "github:jackschu/task-task";
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
      task_task,
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
      darwinPkgs = import nixpkgs {
        system = darwinSystem;
        config.allowUnfree = true;
        overlays = [ emacs-overlay.overlays.default ];
      };
      linuxPkgsUnstable = import nixpkgs-unstable {
        system = linuxSystem;
      };
      darwinPkgsUnstable = import nixpkgs-unstable {
        system = darwinSystem;
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
              inherit username userDescription task_task;
              pkgs-unstable = linuxPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${linuxSystem};
            };
            modules = sharedModules ++ privateModules;
          };
          "${name}-bootstrap" = nixpkgs.lib.nixosSystem {
            system = linuxSystem;
            specialArgs = {
              inherit username userDescription task_task;
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
              inherit username uid task_task;
              pkgs-unstable = darwinPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${darwinSystem};
            };
            modules = commonDarwinModules ++ privateModules;
          };
          "${name}-bootstrap" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit username uid task_task;
              pkgs-unstable = darwinPkgsUnstable;
              llm-agents-pkgs = llm-agents.packages.${darwinSystem};
            };
            modules = commonDarwinModules;
          };
        };

      mkRefreshTixStubsApp = pkgs: {
        type = "app";
        program = toString (pkgs.writeShellScript "refresh_tix_stubs" ''
          set -euo pipefail

          repo_root="$(${pkgs.git}/bin/git rev-parse --show-toplevel 2>/dev/null || ${pkgs.coreutils}/bin/pwd)"
          tix_stubs_link="''${XDG_DATA_HOME:-$HOME/.local/share}/tix/stubs"
          mkdir -p "$(dirname "$tix_stubs_link")"
          ${pkgs.nix}/bin/nix build "$repo_root#tix_stubs" --out-link "$tix_stubs_link" >/dev/null

          printf 'Updated %s\n' "$tix_stubs_link"
        '');
      };
    in
    {
      packages = {
        ${darwinSystem}.tix_stubs = tix.packages.${darwinSystem}.stubs;
        ${linuxSystem}.tix_stubs = tix.packages.${linuxSystem}.stubs;
      };

      apps = {
        ${darwinSystem}.refresh_tix_stubs = mkRefreshTixStubsApp darwinPkgs;
        ${linuxSystem}.refresh_tix_stubs = mkRefreshTixStubsApp linuxPkgs;
      };

      homeConfigurations."laptop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        extraSpecialArgs = {
          pkgs-unstable = linuxPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${linuxSystem};
          inherit tix task_task;
        };
        modules = linuxBaseModules ++ [ ./config/laptop.nix ];
      };

      homeConfigurations."desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = linuxPkgs;
        extraSpecialArgs = {
          pkgs-unstable = linuxPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${linuxSystem};
          inherit tix task_task;
        };
        modules = linuxBaseModules ++ [ ./config/desktop.nix ];
      };

      homeConfigurations."jack_macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        extraSpecialArgs = {
          pkgs-unstable = darwinPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${darwinSystem};
          username = "jackschumann";
          inherit tix task_task;
        };
        modules = commonModules ++ [ ./config/darwin.nix ];
      };

      homeConfigurations."tonks_macbook" = home-manager.lib.homeManagerConfiguration {
        pkgs = darwinPkgs;
        extraSpecialArgs = {
          pkgs-unstable = darwinPkgsUnstable;
          llm-agents-pkgs = llm-agents.packages.${darwinSystem};
          username = "williamtonks";
          inherit tix task_task;
        };
        modules = commonModules ++ [ ./config/darwin.nix ];
      };

      darwinConfigurations =
        (mkDarwin {
          name = "jack_macbook";
          username = "jackschumann";
          uid = 501;
        })
        // (mkDarwin {
          name = "tonks_macbook";
          username = "williamtonks";
          uid = 501;
        });

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
