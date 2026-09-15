# WSL guest: imports common.nix directly rather than going through linux_common.nix,
# which is built around a graphical Plasma session (plasma-manager, chromium,
# easyeffects, mime handlers, GUI packages).
{ ... }:

{
  imports = [ ./common.nix ];

  home.username = "sophie";
  home.homeDirectory = "/home/sophie";

  custom.secrets.enable = true;

  # Off like tonks_macbook: gpg.nix imports a signing key out of secrets/private.yaml,
  # which is keyed to Jack's devices only.
  custom.gpg.enable = false;
}
