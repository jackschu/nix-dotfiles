{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "nixos";

  # NVIDIA GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  hardware.graphics.extraPackages = [ pkgs.libvdpau-va-gl ];
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Tailscale auto-connect
  systemd.user.services.kfsvpn = {
    script = ''
      ${pkgs.tailscale}/bin/tailscale up --hostname bonked --accept-routes --shields-up
    '';
    wantedBy = [ "default.target" ];
  };

  system.stateVersion = "23.11";
}
