pkgs: with pkgs; {
  home = {
    common = [
      claude-code ripgrep tree
      # Fonts
      inter noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      # Apps
      discord spotify
    ];
    linux = [ wl-clipboard kdePackages.kdbusaddons ];
  };

  system = {
    common = [
      home-manager fd bottom gnuplot emacs-nox
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
      pavucontrol zoom-us xfce.xfce4-terminal firefox
      # Linux-specific tools
      xclip steam-run patchelf emscripten docker
      # Graphics / Wayland libs
      libGL libxkbcommon wayland
      xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
    ];
  };

  brew.casks = [ "google-chrome" "ghostty" ];
}
