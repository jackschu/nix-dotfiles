{ pkgs, pkgs-unstable, llm-agents-pkgs, tix, lib, config, ... }:
let
  tix_stubs_path = "${config.xdg.dataHome}/tix/stubs";

  # Runtime binaries expected to be on $PATH by our emacs config
  runtimeDeps = with pkgs; [
    rust-analyzer
    prettier
    python3Packages.sphinx
    ripgrep
    llm-agents-pkgs.claude-agent-acp
    tix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ] ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux needs explicit Swift toolchain/LSP; macOS gets sourcekit-lsp from Xcode.
    swift
    sourcekit-lsp
  ];

  # Tree-sitter grammars not in nixpkgs
  tree-sitter-swift-grammar = pkgs.stdenv.mkDerivation {
    pname = "tree-sitter-swift-grammar";
    version = "0.7.1";
    src = pkgs.fetchFromGitHub {
      owner = "alex-pinkus";
      repo = "tree-sitter-swift";
      rev = "0.7.1-with-generated-files";
      hash = "sha256-jVZpnwpcQ3sXE4hXQIHKzQgEE13pqE3fGqdRMjb1AOQ=";
    };
    buildPhase = let
      ext = if pkgs.stdenv.isDarwin then "dylib" else "so";
      flag = if pkgs.stdenv.isDarwin then "-dynamiclib" else "-shared";
    in ''
      cc ${flag} -fPIC -o libtree-sitter-swift.${ext} -I src src/parser.c src/scanner.c
    '';
    installPhase = let
      ext = if pkgs.stdenv.isDarwin then "dylib" else "so";
    in ''
      mkdir -p $out/lib
      cp libtree-sitter-swift.${ext} $out/lib/
    '';
  };
in
{
  home.sessionVariables = {
    TIX_BUILTIN_STUBS = tix_stubs_path;
  };

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

  home.activation.warnMissingTixStubs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -e "${tix_stubs_path}" ]; then
      echo "warning: TIX_BUILTIN_STUBS path missing (${tix_stubs_path}); run 'nix run .#refresh_tix_stubs'" >&2
    fi
  '';

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-nox;
    extraPackages = epkgs:
      let
        patchedEpkgs = epkgs.overrideScope (_final: prev: {
          helm-ag = prev.trivialBuild {
            pname = "helm-ag";
            version = "0.64";
            src = pkgs.fetchFromGitHub {
              owner = "emacsorphanage";
              repo = "helm-ag";
              rev = "a7b43d9622ea5dcff3e3e0bb0b7dcc342b272171";
              hash = "sha256-bIuZPMsY0iwkUFOfB6rGno0WvlPtbqqgujwhUb6nTLw=";
            };
            packageRequires = [ prev.helm ];
          };

          projectile = prev.projectile.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              rm -f projectile-consult.el
            '';
          });

          # GNU ELPA regenerates release tarballs, so the hash nixpkgs pinned
          # for org drifts. Pin the current upstream hash ourselves; re-prefetch
          # https://elpa.gnu.org/packages/org-<version>.tar whenever this mismatches.
          org = prev.org.overrideAttrs (old: {
            src = old.src.overrideAttrs (_: {
              outputHash = "sha256-nXdqYGrMVy/FrBaY38Eqw2H67vFkD5hGBJ8LKZ8q0Vg=";
            });
          });
        });
      in
      with patchedEpkgs; [
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
        lsp-sourcekit
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
        swift-mode
        swift-ts-mode
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

        # AI / agent-shell
        agent-shell
        acp
        shell-maker

        # Navigation
        dumb-jump

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

  home.file.".emacs".text = builtins.readFile ./emacs-init.el + ''

    (add-to-list 'treesit-extra-load-path "${tree-sitter-swift-grammar}/lib")
  '';
}
