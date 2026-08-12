# Homelab binary cache + remote builder. The module lives in the homelab flake with
# the builder/cache addresses and cache public key baked in, so this only hands it
# the one secret it can't bake in. NixOS rather than home-manager on purpose:
# nix.buildMachines has no HM equivalent, and a substituter in a user's nix.conf is
# ignored unless the daemon trusts that user. See homelab's README.
{ config, homelabFlake, ... }:

{
  imports = [ homelabFlake.nixosModules.buildCluster ];

  # Root-owned: the nix daemon opens the builder connection, not a user.
  sops.secrets.builder_ssh_key = {
    key = "ssh_key";
    sopsFile = "${homelabFlake}/secrets/builder.yaml";
    owner = "root";
    mode = "0400";
  };

  # Root-owned too: the watcher runs as root, because it reads every path in /nix/store.
  sops.secrets.attic_push_token = {
    key = "push_token";
    sopsFile = "${homelabFlake}/secrets/attic-push.yaml";
    owner = "root";
    mode = "0400";
  };

  homelab.buildCluster = {
    enable = true;
    builderSshKeyFile = config.sops.secrets.builder_ssh_key.path;
    # These machines are no longer readers only: nix prefers the remote builder, but when it is down or
    # busy they build locally, and nothing else would ever capture those paths.
    pushTokenFile = config.sops.secrets.attic_push_token.path;
    # tier stays "trusted" — a claim about this host, not a performance knob, since
    # a client is root on the builder it dispatches to.
    # cacheHost stays the LAN address here; roaming hosts override it (see dev_thinkpad).
    # localMaxJobs stays null: local builds remain the normal path when off the LAN.
  };
}
