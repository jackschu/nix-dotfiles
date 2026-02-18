{ pkgs, pkgs-unstable, lib, config, ... }:
let
  # Runtime binaries expected to be on $PATH by our emacs config
  runtimeDeps = with pkgs; [
    rust-analyzer
    nodePackages.prettier
    python3Packages.sphinx
  ];
in
{
  home.packages = runtimeDeps ++ [
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

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages = epkgs:
      let
        helm-ag = epkgs.trivialBuild {
          pname = "helm-ag";
          version = "0.64";
          src = pkgs.fetchFromGitHub {
            owner = "emacsorphanage";
            repo = "helm-ag";
            rev = "a7b43d9622ea5dcff3e3e0bb0b7dcc342b272171";
            hash = "sha256-bIuZPMsY0iwkUFOfB6rGno0WvlPtbqqgujwhUb6nTLw=";
          };
          packageRequires = [ epkgs.helm ];
        };
      in
      with epkgs; [
        # Core
        use-package
        company

        # UI
        golden-ratio-scroll-screen
        nlinum
        pulsar
        colorful-mode
        rainbow-delimiters
        helm
        helm-ag
        helm-projectile
        projectile
        avy
        multiple-cursors
        zzz-to-char

        # Org
        org

        # LSP
        lsp-mode
        flycheck
        flycheck-rust

        # Languages
        nix-mode
        nix-ts-mode
        rust-mode
        go-mode
        web-mode
        tide
        typescript-mode
        lua-mode
        yaml-mode
        protobuf-mode
        protobuf-ts-mode
        php-mode
        sml-mode
        terraform-mode
        company-terraform
        jinja2-mode
        capnp-mode

        # Python
        blacken
        python-black
        python-django

        # JS/TS
        prettier-js
        pkgs-unstable.emacsPackages.ws-butler

        # Tools
        mmm-mode
        clang-format
        json-reformat
        xclip
        no-littering
        yasnippet
        sphinx-mode
        ein

        # Tree-sitter grammars
        treesit-grammars.with-all-grammars
      ];
  };

  # Ensure emacs temporary-file-directory exists (see emacs-init.el)
  home.file.".cache/emacs/.keep".text = "";

  home.file.".emacs".source = ./emacs-init.el;
}
