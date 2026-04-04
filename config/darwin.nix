{
  config,
  pkgs,
  lib,
  username,
  ...
}:

{
  imports = [
    ./common.nix
  ];

  custom.secrets.enable = true;
  custom.gpg.enable = true;

  programs.ssh.extraConfig = ''
    Host *
      UseKeychain yes
  '';


  programs.ghostty.package = null; # installed via brew

  home.username = username;
  home.homeDirectory = "/Users/${username}";
}
