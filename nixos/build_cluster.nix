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

  homelab.buildCluster = {
    enable = true;
    builderSshKeyFile = config.sops.secrets.builder_ssh_key.path;
    # tier stays "trusted" — a claim about this host, not a performance knob, since
    # a client is root on the builder it dispatches to.
    # pushTokenFile stays null: the bastion is the sole pusher.
    # localMaxJobs stays null: local builds remain the normal path when off the LAN.
  };
}
