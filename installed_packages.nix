pkgs: with pkgs; let isX86 = pkgs.stdenv.hostPlatform.isx86; in {
  # Prefer using home.* for new packages (declaratively managed via home-manager)
  # NOTE: Emacs runtime deps (rust-analyzer, prettier, sphinx, etc.) are in config/emacs.nix
  home = {
    common = [
      claude-code ripgrep tree yt-dlp
      # Fonts
      inter noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
    ] ++ lib.optionals isX86 [
      # Desktop apps (x86-only)
      discord spotify
    ];
    linux = [ wl-clipboard kdePackages.kdbusaddons ];
  };

  system = {
    common = [
      home-manager fd bottom gnuplot emacs-nox git
      ispell nixfmt silver-searcher nodejs node2nix
    ];
    linux = [ perf gparted e2fsprogs dosfstools ntfsprogs ];
    linuxPrinting = [
      cups-filters cups-browsed brlaser
      brgenml1lpr brgenml1cupswrapper
    ];
  };

  user = {
    common = [
      unzip imagemagick nil bat ngrok git delta jq wget htop tokei gh
      clang clang-tools rustup awscli2 python3 tailscale go gopls
      yarn nodePackages.prettier tree-sitter graphviz pkg-config
    ];
    linux = [
      # GUI apps
      pavucontrol firefox
      # Linux-specific tools
      xclip patchelf emscripten docker
      # Graphics / Wayland libs
      libGL libxkbcommon wayland
      xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
    ] ++ lib.optionals isX86 [
      zoom-us steam-run
    ];
  };

  brew.formulas = [ "lima" ];
  brew.casks = [ "google-chrome" "ghostty" ];
}
