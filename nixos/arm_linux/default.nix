{ config, lib, pkgs, nixos-lima, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    nixos-lima.nixosModules.lima
    ./hardware-configuration.nix
  ];

  services.lima.enable = true;

  # Lima handles boot directly — disable systemd-boot from linux_configuration.nix
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = lib.mkForce false;
  boot.loader.grub.enable = lib.mkForce false;

  networking.hostName = "arm-linux";

  security.sudo.wheelNeedsPassword = false;

  # Lima creates the user home with .linux suffix to avoid conflicting with the macOS mount
  users.users.jackschumann.home = lib.mkForce "/home/jackschumann.linux";

  # SSH — required for Lima connectivity
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # DHCP — required for Lima networking
  networking.dhcpcd.enable = true;

  # Auto login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "jackschumann";

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  system.stateVersion = "25.11";
}
