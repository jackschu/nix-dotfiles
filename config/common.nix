{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./sops.nix
    ./gpg.nix
    ./git.nix
  ];

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    claude-code
    ripgrep
    tree

    # General fonts
    inter
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  home.sessionVariables = {
    EDITOR = "emacs --no-desktop";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      cd = "z";
    };
  };

  programs.readline = {
    enable = true;
    extraConfig = "set bell-style none";
  };
}
