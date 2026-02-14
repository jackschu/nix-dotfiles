# home-manager config

## Applying Changes

### Home Manager (user-level)
```bash
home-manager switch --flake .#<profile>
```

### NixOS System (system-level)
```bash
sudo nixos-rebuild switch --flake .#<profile>
```

### macOS Setup

Update the darwin constants in `flake.nix` under `darwinConfigurations` for your machine:

```nix
username = "jackschumann";  # your macOS username
uid = 501;                  # your user ID (run `id -u` to find it)
```

You may want to create a new configuration and profile name in `flake.nix` for your machine.

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Install Lix (https://lix.systems/install/)
curl -sSf -L https://install.lix.systems/lix | sh -s -- install

# Apply home-manager configuration
sudo home-manager switch --flake .#macbook_air

# Initial nix-darwin setup (system-level, requires sudo)
sudo nix run nix-darwin -- switch --flake .#macbook_air

# After initial nix-darwin setup, use:
darwin-rebuild switch --flake .#macbook_air
```

Use `laptop` or `desktop` for home-manager profiles. For NixOS profiles use `dev_thinkpad` or `desktop`. For nix-darwin profiles use `macbook_air`.

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

