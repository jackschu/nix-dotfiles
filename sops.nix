# sops/age secrets management
{ config, pkgs, lib, ... }:

let
  sopsAgeRelPath = "sops/age";
  ageKeyDir = "${config.xdg.configHome}/${sopsAgeRelPath}";
  ageKeyFile = "${ageKeyDir}/keys.txt";

  # Age public keys for all devices that can decrypt secrets
  # Add new devices here and run 'home-manager switch' to update the sops-edit wrapper
  ageKeys = {
    devbox = "age12x8hm7w8nns7w7z2ufsfz4ey9yyklatv3pfu508va4ej5hxq3dcsydq9as";
    desktop = "age192ar45qk70f7jh2wa4457lx03ddcfntjtg9l376gra2mrmt3za2qp9ye9a";
  };

  ageRecipients = lib.concatStringsSep "," (lib.attrValues ageKeys);

  sopsEdit = pkgs.writeShellScriptBin "sops-edit" ''
    export SOPS_AGE_KEY_FILE="${ageKeyFile}"
    exec ${pkgs.sops}/bin/sops --age "${ageRecipients}" "$@"
  '';

  showAgeKey = pkgs.writeShellScriptBin "show-age-pubkey" ''
    if [ -f "${ageKeyFile}" ]; then
      ${pkgs.gnused}/bin/sed -n 's/.*public key: \(.*\)/\1/p' "${ageKeyFile}"
    else
      echo "No age key found. Run 'home-manager switch' first." >&2
      exit 1
    fi
  '';

  sopsRekey = pkgs.writeShellScriptBin "sops-rekey" ''
    export SOPS_AGE_KEY_FILE="${ageKeyFile}"
    exec ${pkgs.sops}/bin/sops --rotate --in-place --age "${ageRecipients}" "$@"
  '';
in
{
  home.packages = [
    pkgs.age
    pkgs.sops
    showAgeKey
    sopsEdit
    sopsRekey
  ];

  # Ensure the age key directory exists
  xdg.configFile."${sopsAgeRelPath}/.keep".text = "";

  # Generate age key on first activation
  home.activation.generateAgeKey = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ ! -f "${ageKeyFile}" ]; then
      run ${pkgs.age}/bin/age-keygen -o "${ageKeyFile}"
    fi
  '';

  # sops-nix configuration
  sops = {
    validateSopsFiles = false;
    age.keyFile = ageKeyFile;
    defaultSopsFile = ./secrets/secrets.yaml;
  };
}
