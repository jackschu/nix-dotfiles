# The pure half of the Emacs config: package set, patches, swift grammar and
# init text. Takes no home-manager `config`, so `nix build .#emacs` can use it.
{ pkgs
, pkgs-unstable
, lib ? pkgs.lib
, agentTools ? null   # llm-agents-pkgs; null omits claude-agent-acp
, tixPkg ? null       # tix package;      null omits tix
}:
let
  # Runtime binaries expected to be on $PATH by our emacs config
  runtimeDeps = (with pkgs; [
    rust-analyzer
    prettier
    python3Packages.sphinx
    ripgrep
    # Starlark LSP fallback + buildifier; buck2 itself comes from $PATH (see emacs-init.el)
    starpls
    bazel-buildtools
  ])
  ++ lib.optional (agentTools != null) agentTools.claude-agent-acp
  ++ lib.optional (tixPkg != null) tixPkg
  ++ lib.optionals pkgs.stdenv.isLinux (with pkgs; [
    # Linux needs explicit Swift toolchain/LSP; macOS gets sourcekit-lsp from Xcode.
    swift
    sourcekit-lsp
  ]);

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

  emacsPackage = pkgs.emacs-nox;

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
in
{
  inherit runtimeDeps extraPackages emacsPackage;

  swiftGrammar = tree-sitter-swift-grammar;

  # Built the same way home-manager's programs.emacs builds finalPackage.
  emacs = (pkgs.emacsPackagesFor emacsPackage).emacsWithPackages extraPackages;

  # emacs-init.el loads custom-file without NOERROR, so a standalone consumer
  # must place this at ~/.emacs-custom.el or startup errors.
  customFile = ./emacs-custom.el;

  initText = builtins.readFile ./emacs-init.el + ''

    (add-to-list 'treesit-extra-load-path "${tree-sitter-swift-grammar}/lib")
  '';
}
