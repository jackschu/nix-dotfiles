# Do not remove pkgs-unstable — it is intentionally plumbed through for packages missing from stable nixpkgs
{ pkgs, pkgs-unstable, llm-agents-pkgs, task_task }:
with pkgs;
let
  isX86 = pkgs.stdenv.hostPlatform.isx86;
  opencode_mcp_auth = pkgs-unstable.opencode.overrideAttrs (old: {
    patches = (old.patches or []) ++ [ ./patches/opencode_mcp_auth_workaround.patch ];
  });
in {
  # Prefer using home.* for new packages (declaratively managed via home-manager)
  # NOTE: Emacs runtime deps (rust-analyzer, prettier, sphinx, etc.) are in config/emacs.nix
  home = {
    common = [
      opencode_mcp_auth
      llm-agents-pkgs.claude-code llm-agents-pkgs.claude-agent-acp
      task_task.packages.${pkgs.stdenv.hostPlatform.system}.default
      ripgrep tree yt-dlp
      # Fonts
      inter noto-fonts noto-fonts-cjk-sans noto-fonts-color-emoji
      nerd-fonts.jetbrains-mono
      sioyek
      jujutsu
    ];
    linux = [ wl-clipboard kdePackages.kdbusaddons ] ++ lib.optionals isX86 [
      zoom-us discord spotify
    ];
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
      pavucontrol firefox vlc
      # Linux-specific tools
      xclip patchelf emscripten docker
      # Graphics / Wayland libs
      libGL libxkbcommon wayland
      xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
    ] ++ lib.optionals isX86 [
      steam-run
      obs-studio
    ];
  };

  # Homebrew formulas are usually CLI tools; casks are usually GUI/macOS app bundles.
  brew.formulas = [ "lima" "xcode-build-server" "xcodebuildmcp" ];
  brew.casks = [
    "google-chrome"
    "docker-desktop" 
    "bazecor"
    {
      name = "ghostty";
      greedy = true;
    }
    "unnaturalscrollwheels"
    "signal"
    "vlc"
    "discord"
    "spotify"
    "sf-symbols"
    "zoom"
    "steam"
    "obs"
  ];
}
