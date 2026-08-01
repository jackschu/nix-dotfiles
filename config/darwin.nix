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
  custom.gpg.enable = lib.mkDefault true;

  programs.ssh.extraConfig = ''
    Host *
      IgnoreUnknown UseKeychain
      UseKeychain yes
  '';


  programs.ghostty.package = null; # installed via brew

  home.username = username;
  home.homeDirectory = "/Users/${username}";
}
