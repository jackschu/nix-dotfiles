{ config, pkgs, username, ... }:

{
  imports = [ ./base_configuration.nix ];

  system.stateVersion = 6;
  system.primaryUser = username;
  # Garbage collection schedule (launchd interval)
  nix.gc.interval = { Weekday = 0; Hour = 2; Minute = 0; };
  nix.gc.options = "--delete-older-than 30d";

  # User account
  users.users.${username} = {
    home = "/Users/${username}";
  };

  # Shell
  environment.shellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';

  # Homebrew integration (for apps not in nixpkgs)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "xcode"
    ];
  };
}
