{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./common.nix
  ];

  custom.secrets.enable = true;
  custom.gpg.enable = true;

  # sops-nix's activation runs launchctl bootstrap before setupLaunchAgents
  # has created the plist file, causing a fatal error on first activation.
  # setupLaunchAgents already handles the bootstrap correctly on its own.
  home.activation.sops-nix = lib.mkForce (lib.hm.dag.entryAfter [ "linkGeneration" ] "");

  home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
    background-image = ${./terminal_bg.png}
    background-image-opacity = 1
    background-image-fit = cover
    background-opacity = 0.9
  '';

  home.username = "jackschumann";
  home.homeDirectory = "/Users/jackschumann";
}
