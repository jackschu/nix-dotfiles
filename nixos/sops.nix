{ pkgs, username, ... }:

let
  homeBase = if pkgs.stdenv.isDarwin then "/Users" else "/home";
in
{
  sops = {
    age.keyFile = "${homeBase}/${username}/.config/sops/age/keys.txt";
    age.sshKeyPaths = [];
    gnupg.sshKeyPaths = [];
    defaultSopsFile = ../secrets/secrets.yaml;
  };
}
