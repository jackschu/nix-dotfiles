{ pkgs, pkgs-unstable, llm-agents-pkgs, tix, lib, config, ... }:
let
  tix_stubs_path = "${config.xdg.dataHome}/tix/stubs";

  emacsPkg = import ./emacs_package.nix {
    inherit pkgs pkgs-unstable lib;
    agentTools = llm-agents-pkgs;
    tixPkg = tix.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };
in
{
  home.sessionVariables = {
    TIX_BUILTIN_STUBS = tix_stubs_path;
  };

  home.packages = emacsPkg.runtimeDeps ++ [
    (pkgs.writeShellScriptBin "sync-emacs-custom" ''
      DEST="${config.home.homeDirectory}/.config/home-manager/config/emacs-custom.el"
      cp ~/.emacs-custom.el "$DEST"
      echo "Synced ~/.emacs-custom.el -> $DEST"
      echo "Don't forget to git commit"
    '')
  ];

  # home.file cannot be used here: it creates a read-only symlink into the Nix
  # store, and Emacs checks file-writable-p on the symlink target before saving
  # custom settings. We use activation to place a writable copy instead.
  # Repo is source of truth — every switch overwrites the local file.
  # To persist interactive customizations back to the repo: run sync-emacs-custom.
  home.activation.initEmacsCustom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD cp ${./emacs-custom.el} "$HOME/.emacs-custom.el"
    $DRY_RUN_CMD chmod 644 "$HOME/.emacs-custom.el"
  '';

  home.activation.warnMissingTixStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${tix_stubs_path}" ]; then
      echo "warning: TIX_BUILTIN_STUBS path missing (${tix_stubs_path}); run 'nix run .#refresh_tix_stubs'" >&2
    fi
  '';

  programs.emacs = {
    enable = true;
    package = emacsPkg.emacsPackage;
    extraPackages = emacsPkg.extraPackages;
  };

  # Ensure emacs temporary-file-directory exists (see emacs-init.el)
  home.file.".cache/emacs/.keep".text = "";

  home.file.".emacs".text = emacsPkg.initText;
}
