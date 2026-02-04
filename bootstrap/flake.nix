{
  description = "Bootstrap age key for home-manager sops setup";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          ageKeyDir = "\${XDG_CONFIG_HOME:-$HOME/.config}/sops/age";
          ageKeyFile = "${ageKeyDir}/keys.txt";
        in
        {
          default = pkgs.writeShellScriptBin "bootstrap-age-key" ''
            set -e
            AGE_KEY_DIR="${ageKeyDir}"
            AGE_KEY_FILE="${ageKeyFile}"

            mkdir -p "$AGE_KEY_DIR"

            if [ -f "$AGE_KEY_FILE" ]; then
              echo "Age key already exists at $AGE_KEY_FILE"
            else
              echo "Generating new age key..."
              ${pkgs.age}/bin/age-keygen -o "$AGE_KEY_FILE"
              echo "Created $AGE_KEY_FILE"
            fi

            echo ""
            echo "Your public key (add this to ageKeys in sops.nix):"
            echo ""
            ${pkgs.gnused}/bin/sed -n 's/.*public key: \(.*\)/\1/p' "$AGE_KEY_FILE"
          '';
        }
      );
    };
}
