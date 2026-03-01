{ config, pkgs, username, ... }:

let
  homeBase = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  sops = {
    age.keyFile = "${homeBase}/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets."nix-access-tokens" = { };
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets."nix-access-tokens".path}
  '';
}
