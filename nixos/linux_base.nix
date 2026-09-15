# Parts of a Linux system config that don't assume physical hardware or a graphical
# session, so a WSL guest can share them. The bare-metal stack lives in
# linux_configuration.nix.
{ config, lib, pkgs, pkgs-unstable, username, userDescription, llm-agents-pkgs, task_task, ... }:

let
  packages = import ../installed_packages.nix { inherit pkgs pkgs-unstable llm-agents-pkgs task_task; };
in
{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  imports = [ ./base_configuration.nix ];

  # Tailscale VPN
  # extraSetFlags, not extraUpFlags: the latter only runs from tailscaled-autoconnect,
  # which nixpkgs gates on an authKeyFile these machines don't have.
  # useRoutingFeatures = "client" is what loosens rp_filter for subnet routes.
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    extraSetFlags = [
      "--accept-routes=true"
      "--shields-up=true"
    ];
  };

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
  programs.npm.enable = true;
}
