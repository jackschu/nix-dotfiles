{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "nixos";

  # Thinkpad touchpad
  services.libinput.touchpad.accelProfile = "flat";
  services.libinput.touchpad.accelStepScroll = 10000;

  # Auto login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "devbox";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Tailscale auto-connect with thinkpad-specific hostname
  systemd.user.services.kfsvpn = {
    script = ''
      ${pkgs.tailscale}/bin/tailscale up --hostname bonked --accept-routes --shields-up
    '';
    wantedBy = [ "default.target" ];
  };

  services.agent-microvm = {
    enable = true;
    externalInterface = "enp2s0";
  };

  system.stateVersion = "23.05";
}
