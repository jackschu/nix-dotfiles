{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  # This one roams. A bare 192.168.68.26 would be offered the push token by any café network using that
  # range, because the directly-connected route beats the tailscale one.
  homelab.buildCluster.cacheHost = "cache.taild3c1e.ts.net";

  # Thinkpad touchpad
  services.libinput.touchpad.accelProfile = "flat";
  services.libinput.touchpad.accelStepScroll = 10000;

  # Auto login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "devbox";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  system.stateVersion = "23.05";
}
