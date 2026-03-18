{ config, pkgs, pkgs-unstable, username, uid, llm-agents-pkgs, task_task, ... }:

let
  packages = import ../installed_packages.nix { inherit pkgs pkgs-unstable llm-agents-pkgs task_task; };
in
{
  imports = [
    ./base_configuration.nix
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

  # Key repeat speed (match Linux: 500ms delay, ~30 chars/sec)
  system.defaults.NSGlobalDomain.InitialKeyRepeat = 33;
  system.defaults.NSGlobalDomain.KeyRepeat = 2;

  # Show keyboard brightness in Control Center
  system.defaults.CustomUserPreferences."com.apple.controlcenter" = {
    "NSStatusItem Visible KeyboardBrightness" = true;
    KeyboardBrightness = 25;
  };

  # Shell
  environment.shellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';

  # Tailscale VPN
  services.tailscale.enable = true;
  launchd.daemons.tailscale_set_flags = {
    script = ''
      ${pkgs.tailscale}/bin/tailscale set --accept-routes=true --shields-up=true
    '';
    serviceConfig = {
      RunAtLoad = true;
    };
  };

  # App switching hotkeys
  # After applying changes, run `skhd --reload` to pick up new bindings
  services.skhd = {
    enable = true;
    skhdConfig = ''
      ctrl + shift - 1 : open -a "Xcode"
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
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = packages.brew.formulas;
    casks = packages.brew.casks;
  };
}
