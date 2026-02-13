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

  home.username = "jackschumann";
  home.homeDirectory = "/Users/jackschumann";
}
