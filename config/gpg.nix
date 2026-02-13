{ config, pkgs, lib, ... }:

let
  cfg = config.custom.gpg;
in
{
  options.custom.gpg.enable = lib.mkEnableOption "GPG key management";

  config = lib.mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };

    services.gpg-agent = {
      enable = true;
      defaultCacheTtl = 3600;
      maxCacheTtl = 28800;
      enableSshSupport = false;
      pinentry.package = pkgs.pinentry-curses;
    };

    # Decrypt GPG key from sops
    sops.secrets."github-gpg-key" = { };

    # Import GPG key from sops secret after decryption
    home.activation.importGpgKey = lib.hm.dag.entryAfter [ "sops-nix" ] ''
      GPG_KEY_FILE="${config.sops.secrets."github-gpg-key".path}"
      if [ -f "$GPG_KEY_FILE" ]; then
        # Check if key is already imported by looking for the signing key
        if ! ${pkgs.gnupg}/bin/gpg --list-secret-keys "${config.programs.git.signing.key}" &>/dev/null; then
          run ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_KEY_FILE"
          echo "GPG key imported successfully"
        fi
      fi
    '';
  };
}
