{
  description = "Home Manager configuration of devbox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "git+https://github.com/jackschu/sops-nix?ref=fix-darwin-activation-order";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
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
    homebrew-getsentry-xcodebuildmcp = {
      url = "github:getsentry/homebrew-xcodebuildmcp";
      flake = false;
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    agent-runtime = {
      url = "github:jackschu/agent_runtime/multiagent";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
    hunk = {
      url = "github:modem-dev/hunk";
    };
    homelab = {
      url = "github:jackschu/homelab";
      inputs.nixpkgs.follows = "nixpkgs";
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
      homebrew-getsentry-xcodebuildmcp,
      plasma-manager,
      agent-runtime,
      llm-agents,
      emacs-overlay,
      tix,
      task_task,
      hunk,
      homelab,
      ...
    }:
    let
      linuxSystem = "x86_64-linux";
      darwinSystem = "aarch64-darwin";
      defaultGitName = "jackschu";
      defaultGitEmail = "31808950+jackschu@users.noreply.github.com";
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
        hunk.homeManagerModules.default
        homelab.homeManagerModules.fleetCockpit
        homelab.homeManagerModules.motionSyncthing
        homelab.homeManagerModules.agentTools
        {
          _module.args = {
            gitName = defaultGitName;
            gitEmail = defaultGitEmail;
          };
        }
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
            ./nixos/build_cluster.nix
            ./nixos/linux_configuration.nix
            ./nixos/${name}
          ];
          # homelabFlake, not homelab: the module it carries owns the `homelab.*`
          # option namespace, so sharing the name would read as the options tree.
          nixosSpecialArgs = {
            inherit username userDescription task_task;
            homelabFlake = homelab;
            pkgs-unstable = linuxPkgsUnstable;
            llm-agents-pkgs = llm-agents.packages.${linuxSystem};
          };
        in
        {
          "${name}" = nixpkgs.lib.nixosSystem {
            system = linuxSystem;
            specialArgs = nixosSpecialArgs;
            modules = sharedModules ++ privateModules;
          };
          "${name}-bootstrap" = nixpkgs.lib.nixosSystem {
            system = linuxSystem;
            specialArgs = nixosSpecialArgs;
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
            ./nixos/darwin_build_cluster.nix
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                user = username;
                # When declaring taps, please ensure to name the key as a unique folder starting with `homebrew-`... (requirement from nix-homebrew README)
                taps = {
                  "homebrew/homebrew-core" = homebrew-core;
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "getsentry/homebrew-xcodebuildmcp" = homebrew-getsentry-xcodebuildmcp;
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
          # homelabFlake, not homelab: the module it carries owns the `homelab.*`
          # option namespace, so sharing the name would read as the options tree.
          darwinSpecialArgs = {
            inherit username uid task_task;
            homelabFlake = homelab;
            pkgs-unstable = darwinPkgsUnstable;
            llm-agents-pkgs = llm-agents.packages.${darwinSystem};
          };
        in
        {
          "${name}" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = darwinSpecialArgs;
            modules = commonDarwinModules ++ privateModules;
          };
          "${name}-bootstrap" = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = darwinSpecialArgs;
            modules = commonDarwinModules;
          };
        };

      mkEmacsPackage =
        pkgs: pkgs-unstable:
        (import ./config/emacs_package.nix { inherit pkgs pkgs-unstable; }).emacs;

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
        # emacs: the same package set the home configs use, minus the private
        # runtime deps, so it evaluates without their inputs.
        ${darwinSystem} = {
          tix_stubs = tix.packages.${darwinSystem}.stubs;
          emacs = mkEmacsPackage darwinPkgs darwinPkgsUnstable;
        };
        ${linuxSystem} = {
          tix_stubs = tix.packages.${linuxSystem}.stubs;
          emacs = mkEmacsPackage linuxPkgs linuxPkgsUnstable;
        };
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
          gitName = "williamrntonks";
          gitEmail = "245291231+williamrntonks@users.noreply.github.com";
          inherit tix task_task;
        };
        modules = commonModules ++ [ ./config/darwin.nix ./config/tonks_macbook.nix ];
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
