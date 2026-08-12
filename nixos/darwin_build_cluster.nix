# Homelab binary cache + remote builder, darwin half. Same file as the NixOS one — only the watcher
# daemon differs (launchd rather than systemd), so the platform is the module's one argument.
{ config, homelabFlake, ... }:

{
  imports = [ homelabFlake.darwinModules.buildCluster ];

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
    # The whole point of the darwin half: no x86_64-linux box can ever produce an aarch64-darwin path,
    # so if darwin paths are to be cached at all, a Mac has to push them.
    pushTokenFile = config.sops.secrets.attic_push_token.path;
    # Laptops roam. A bare 192.168.68.26 would be offered the push token by any café network that
    # happens to use that range, because the directly-connected route beats the tailscale one.
    cacheHost = "cache.taild3c1e.ts.net";
  };
}
