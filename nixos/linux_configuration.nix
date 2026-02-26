{ config, lib, pkgs, username, userDescription, ... }:

let
  packages = import ../installed_packages.nix { inherit pkgs llm-agents-pkgs; };
  isX86 = pkgs.stdenv.hostPlatform.isx86;
in
{
  imports = [ ./base_configuration.nix ];
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.enableIPv6 = false;

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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

  # User account
  users.users.${username} = {
    isNormalUser = true;
    description = userDescription;
    extraGroups = [ "networkmanager" "wheel" "docker" "kvm" ];
    packages = packages.user.linux;
  };

  # Docker
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      runtimes = {
        runsc = {
          path = "${pkgs.gvisor}/bin/runsc";
        };
      };
    };
  };

  # Linux-only system packages
  environment.systemPackages = packages.system.linux;

  # Garbage collection schedule (systemd timer)
  nix.gc = {
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Shell
  environment.interactiveShellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';
  programs.bash.shellAliases = {
    hg = "git";
  };
  programs.xfconf.enable = true;
  programs.npm.enable = true;
}
