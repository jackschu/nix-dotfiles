# Home Manager Configuration

## Overview

This is a flake-based NixOS and home-manager configuration. The flake manages both system-level NixOS configurations and user-level home-manager configurations declaratively.

## Structure

- `flake.nix` - Flake inputs, home configurations, and NixOS system configurations
- `home.nix` - Shared configuration for all machines
- `laptop.nix` / `desktop.nix` - Machine-specific overrides (username, home directory, hardware-specific settings)
- `git.nix`, `gpg.nix`, `sops.nix` - Modular configurations imported by home.nix
- `nixos/` - NixOS system configurations (per-machine in subdirectories)

## Tools

### rc2nix

`rc2nix` is a tool for converting application configuration files to Nix expressions. It's particularly useful for KDE Plasma configurations.

```bash
# Convert KDE Plasma config to Nix
nix run github:nix-community/rc2nix <config-file>
```

This tool helps translate imperative configuration files into declarative Nix syntax that can be managed through home-manager.

## Applying Changes

After making configuration changes, apply them by determining the correct profile and running:

```bash
home-manager switch --flake .#<profile>
```

To determine `<profile>`, check the hostname (`hostnamectl` or `cat /etc/hostname`). Use `laptop` if the hostname contains "laptop" or "thinkpad", otherwise use `desktop`.

## Other Commands

```bash
# Update flake inputs
nix flake update

# Update a specific input
nix flake update <input-name>
```

## NixOS System Config

System-level configuration is managed via the flake in this repo under `nixos/`. Changes require:

```bash
sudo nixos-rebuild switch --flake .#<profile>
```

The `<profile>` should match the NixOS configuration defined in `flake.nix` (e.g., `dev_thinkpad`).

## Key Differences

- **home-manager**: User packages, dotfiles, shell config, services like easyeffects
- **NixOS (configuration.nix)**: System services, hardware, networking, display manager, desktop environment
