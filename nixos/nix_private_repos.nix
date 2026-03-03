{ config, username, ... }:

{
  imports = [ ./sops.nix ];

  sops.secrets."nix-access-tokens" = {
    owner = username;
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets."nix-access-tokens".path}
  '';
}
