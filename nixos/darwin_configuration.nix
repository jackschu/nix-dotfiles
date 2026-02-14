{ config, pkgs, username, ... }:

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
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.bash;
  };

  # Dark mode
  system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";

  # Shell
  environment.shellInit = ''
    export PATH="$HOME/.cargo/bin/:$PATH"
  '';

  # Homebrew integration (for apps not in nixpkgs)
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";
    casks = [
      "google-chrome"
      # TODO need xcode
      # "ghostty"
    ];
  };
}
