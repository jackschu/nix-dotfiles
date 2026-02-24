{ config, pkgs, username, uid, ... }:

let
  packages = import ../installed_packages.nix pkgs;
in
{
  imports = [
    ./base_configuration.nix
    ./overlays/inet-utils.nix
  ];

  system.stateVersion = 6;
  system.primaryUser = username;
  # Garbage collection schedule (launchd interval)
  nix.gc.interval = { Weekday = 0; Hour = 2; Minute = 0; };
  nix.gc.options = "--delete-older-than 30d";

  # User account
  environment.shells = [ pkgs.bash ];
  users.knownUsers = [ username ];
  users.users.${username} = {
    inherit uid;
    home = "/Users/${username}";
    shell = pkgs.bash;
  };

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Disable autocorrect
  system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;

  # Show keyboard brightness in Control Center
  system.defaults.CustomUserPreferences."com.apple.controlcenter" = {
    "NSStatusItem Visible KeyboardBrightness" = true;
    KeyboardBrightness = 25;
  };

  # Shell
  environment.shellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';

  # App switching hotkeys
  # After applying changes, run `skhd --reload` to pick up new bindings
  services.skhd = {
    enable = true;
    skhdConfig = ''
      ctrl - 1 : open -a "Ghostty"
      ctrl - 2 : open -a "Google Chrome"
      ctrl - 3 : open -a "Discord"
      ctrl - 4 : open -a "Spotify"
      ctrl - 5 : open -a "Messages"
    '';
  };

  # Homebrew integration (for apps not in nixpkgs)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    brews = packages.brew.formulas;
    casks = packages.brew.casks;
  };
}
