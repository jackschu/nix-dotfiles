# Bare-metal Linux: bootloader, graphical session, and hardware services. Everything
# a WSL guest can also use lives in linux_base.nix.
{ config, lib, pkgs, pkgs-unstable, llm-agents-pkgs, task_task, ... }:

let
  packages = import ../installed_packages.nix { inherit pkgs pkgs-unstable llm-agents-pkgs task_task; };
  isX86 = pkgs.stdenv.hostPlatform.isx86;
in
{
  imports = [ ./linux_base.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
#  networking.enableIPv6 = false;

  # Display and desktop
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Printing (drivers are x86-only)
  services.printing.enable = true;
  services.printing.drivers = lib.mkIf isX86 packages.system.linuxPrinting;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  programs.steam.enable = isX86;
  programs.xfconf.enable = true;
}
