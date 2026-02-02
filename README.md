# home-manager config

## Secrets

Secrets are encrypted with [sops](https://github.com/getsops/sops) using [age](https://github.com/FiloSottile/age) keys. The `secrets/` directory contains encrypted files that are safe to commit publicly - only devices with a corresponding age private key can decrypt them.

- **Public (committed):** `secrets/*.yaml`, age public keys in `home.nix`
- **Private (per-device):** `~/.config/sops/age/keys.txt`

### Adding a new device

1. Clone this repo and run `home-manager switch` (generates age key, will fail on secrets)
2. Run `show-age-pubkey` to get the new device's public key
3. Add the public key to `ageKeys` in `home.nix`
4. On a device that can already decrypt, run:
   ```bash
   sops-edit secrets/secrets.yaml  # opens, re-saves with new key
   ```
5. Commit and push
6. On the new device: pull and run `home-manager switch`

### Editing secrets

```bash
sops-edit secrets/secrets.yaml
```

