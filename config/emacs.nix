{ pkgs, pkgs-unstable, ... }:
let
  # Runtime binaries expected to be on $PATH by our emacs config
  runtimeDeps = with pkgs; [
    rust-analyzer
    nodePackages.prettier
    python3Packages.sphinx
  ];
in
{
  home.packages = runtimeDeps;

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
