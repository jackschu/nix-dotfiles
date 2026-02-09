# Home Manager Configuration

## Overview

This is a flake-based home-manager configuration for NixOS. Home-manager manages user-level packages and dotfiles declaratively.

## Structure

- `flake.nix` - Flake inputs and home configurations
- `home.nix` - Shared configuration for all machines
- `laptop.nix` / `desktop.nix` - Machine-specific overrides (username, home directory, hardware-specific settings)
- `git.nix`, `gpg.nix`, `sops.nix` - Modular configurations imported by home.nix

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

System-level configuration is at `/etc/nixos/configuration.nix`. Changes there require:

```bash
sudo nixos-rebuild switch
```

## Key Differences

- **home-manager**: User packages, dotfiles, shell config, services like easyeffects
- **NixOS (configuration.nix)**: System services, hardware, networking, display manager, desktop environment
