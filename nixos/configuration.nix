{ config, pkgs, ... }:

{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "8.8.8.8" "8.8.4.4" ];
  networking.enableIPv6 = false;

  # Timezone and locale
  time.timeZone = "America/New_York";

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
  services.desktopManager.plasma6.enable = true;

  # Printing
  services.printing.enable = true;
  services.printing.drivers = with pkgs; [
    cups-filters
    cups-browsed
    brlaser
    brgenml1lpr
    brgenml1cupswrapper
  ];

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
  users.users.devbox = {
    isNormalUser = true;
    description = "Jack Schumann";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    packages = with pkgs; [
      spotify discord pavucontrol
      unzip imagemagick xclip
      nil bat ngrok
      xfce.xfce4-terminal git delta jq wget htop tokei gh clang clang-tools
      rustup
      firefox
      awscli2
      python3
      tailscale
      steam-run
      patchelf
      libGL
      libxkbcommon
      wayland
      xorg.libX11
      xorg.libXcursor
      xorg.libXi
      xorg.libXrandr
    ];
  };

  # Auto login
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "devbox";

  # Tailscale VPN
  services.tailscale.enable = true;

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

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    fd
    bottom
    gnuplot
    perf
    emacs-nox
    ispell nixfmt silver-searcher
    nodejs
  ];

  # Emacs config
  environment.etc = {
    "personalconfig/.emacs" = {
      text = builtins.readFile (pkgs.fetchurl {
        url =
          "https://raw.githubusercontent.com/jackschu/emacsconfig/bd2bff606009d4e2be0f8ac7b1589180e47f4dc2/.emacs";
        sha256 = "sha256-fBPAXkYeBn0z+cz5+2qR/N8EDhmyGYcXOYsXbpQzcfg=";
      });
    };
  };

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Automatic store optimization
  nix.optimise.automatic = true;

  # Shell
  environment.interactiveShellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';
  programs.bash.shellAliases = {
    hg = "git";
  };
  programs.xfconf.enable = true;
}
