{ config, pkgs, username, ... }:

{
  # Timezone
  time.timeZone = "America/New_York";

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ username ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Automatic garbage collection
  nix.gc.automatic = true;

  # Automatic store optimization
  nix.optimise.automatic = true;

  # Tailscale VPN
  services.tailscale.enable = true;

  # System packages (cross-platform)
  environment.systemPackages = with pkgs; [
    fd
    bottom
    gnuplot
    emacs-nox
    ispell nixfmt silver-searcher
    nodejs
    node2nix
  ];

  # User packages (cross-platform)
  users.users.${username}.packages = with pkgs; [
    unzip imagemagick
    nil bat ngrok
    git delta jq wget htop tokei gh clang clang-tools
    rustup
    awscli2
    python3
    tailscale
    go gopls
    yarn nodePackages.prettier
    tree-sitter
    graphviz
    pkg-config
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
}
