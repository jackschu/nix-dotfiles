# nix-dotfiles

## Applying Changes

### Home Manager (user-level)
```bash
home-manager switch --flake .#<profile>
```

### NixOS System (system-level)
```bash
sudo nixos-rebuild switch --flake .#<profile>
```

### Bootstrap for Private Repo Access

Systems with private flake inputs need to authenticate first. Use the `-bootstrap` variant:

```bash
# 1. Build bootstrap config (no private inputs needed)
sudo nixos-rebuild switch --flake ~/.config/home-manager#<profile>-bootstrap --override-input agent-runtime path:./bootstrap-stub

# 2. Switch to full config (auth now available)
sudo nixos-rebuild switch --flake ~/.config/home-manager#<profile>
```

### macOS Setup

Set your darwin profile values in `flake.nix` under `darwinConfigurations` for your machine:

```nix
username = "your-macos-username";
uid = 501;  # your user ID (run `id -u` to find it)
```

You may want to create a new configuration and profile name in `flake.nix` for your machine.

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Lix (https://lix.systems/install/)
curl -sSf -L https://install.lix.systems/lix | sh -s -- install

# Apply home-manager configuration
sudo home-manager switch --flake .#jack_macbook

# Bootstrap (required if using private flake inputs)
sudo nix run nix-darwin -- switch --flake .#jack_macbook-bootstrap --override-input agent-runtime path:./bootstrap-stub

# Initial nix-darwin setup (system-level, requires sudo)
sudo nix run nix-darwin -- switch --flake .#jack_macbook

# After initial nix-darwin setup, use:
darwin-rebuild switch --flake .#jack_macbook
```

Use `laptop` or `desktop` for Linux home-manager profiles. For NixOS profiles use `dev_thinkpad` or `desktop`. For macOS use `jack_macbook` or `tonks_macbook`.

## Emacs Customization

Emacs settings saved via `M-x customize` are kept separate from the main init file
since `custom-save-all` rewrites the file from scratch and would destroy any hand-written content.

### How it works

- `config/emacs-custom.el` — the canonical custom settings, committed to this repo
- `~/.emacs-custom.el` — writable working copy, seeded from the repo on every `home-manager switch`

On each `home-manager switch`, the repo version overwrites `~/.emacs-custom.el` — the repo is source of truth.

### Persisting interactive customizations

After using `customize-face`, `customize-variable`, etc., Emacs will display a reminder in the minibuffer. To commit those changes back to the repo:

```bash
sync-emacs-custom   # copies ~/.emacs-custom.el → config/emacs-custom.el
git add config/emacs-custom.el && git commit
```

### What not to put in the custom file

Keep settings in `emacs-init.el` when possible — the custom file is machine-generated and comments are stripped on every save, so youll need to use configures 'add comment' ability (select [State] and then its an option).

## Tix Stubs (Manual Refresh)

`tix` now uses the default binary during normal `home-manager switch` runs for faster evaluation. Generated stubs are refreshed manually and injected through `TIX_BUILTIN_STUBS`.

`TIX_BUILTIN_STUBS` points to `${XDG_DATA_HOME:-$HOME/.local/share}/tix/stubs`. Home Manager will warn during activation if that path does not exist.

Refresh stubs after changing `flake.lock` (especially `nixpkgs` or `home-manager`):

```bash
nix run .#refresh_tix_stubs
home-manager switch --flake .#<profile>
```

## Secrets

Secrets are encrypted with [sops](https://github.com/getsops/sops) using [age](https://github.com/FiloSottile/age) keys. The `secrets/` directory contains encrypted files that are safe to commit publicly - only devices with a corresponding age private key can decrypt them.

- **Public (committed):** `secrets/*.yaml`, age public keys in `home.nix`
- **Private (per-device):** `~/.config/sops/age/keys.txt`

### Adding a new machine

Add a new entry to `homeConfigurations` in `flake.nix` and create a corresponding `<machine>.nix` that sets `home.username` and `home.homeDirectory`.

### Adding a new device

1. Clone this repo and generate an age key:
   ```bash
   nix run ~/.config/home-manager/bootstrap
   ```
2. Copy the public key from the output
3. Add the public key to `ageKeys` in `sops.nix` (the attr name is just for your reference)
4. On a device that can already decrypt, re-encrypt for all keys:
   ```bash
   sops-rekey secrets/secrets.yaml
   ```
5. Commit and push
6. On the new device: pull and run `nix run home-manager -- switch --flake "~/.config/home-manager#<machine>"`

### Editing secrets

```bash
sops-edit secrets/secrets.yaml
```
