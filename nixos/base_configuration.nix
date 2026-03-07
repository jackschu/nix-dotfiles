{ config, pkgs, pkgs-unstable, username, llm-agents-pkgs, task_task, ... }:

let
  packages = import ../installed_packages.nix { inherit pkgs pkgs-unstable llm-agents-pkgs task_task; };
in
{
  # Timezone
  time.timeZone = "America/New_York";

  # Nix settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ username ];
  nix.settings.download-buffer-size = 268435456; # 256 MiB

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Automatic garbage collection
  nix.gc.automatic = true;

  # Automatic store optimization
  nix.optimise.automatic = true;

  # System packages (cross-platform)
  environment.systemPackages = packages.system.common;

  # User packages (cross-platform)
  users.users.${username}.packages = packages.user.common;

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
