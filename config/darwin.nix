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

  home.username = "jackschumann";
  home.homeDirectory = "/Users/jackschumann";
}
