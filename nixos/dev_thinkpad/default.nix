{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  # Thinkpad touchpad
  services.libinput.touchpad.accelProfile = "flat";
  services.libinput.touchpad.accelStepScroll = 10000;

  # Tailscale auto-connect with thinkpad-specific hostname
  systemd.user.services.kfsvpn = {
    script = ''
      ${pkgs.tailscale}/bin/tailscale up --hostname bonked --accept-routes --shields-up
    '';
    wantedBy = [ "default.target" ];
  };

  system.stateVersion = "23.05";
}
