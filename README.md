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

### nix-darwin (macOS system-level)

Initial setup (requires sudo since system activation runs as root):
```bash
sudo nix run nix-darwin -- switch --flake .#<profile>
```

After initial setup:
```bash
darwin-rebuild switch --flake .#<profile>
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

