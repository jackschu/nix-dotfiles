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

  # Common configuration for all machines
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


  programs.starship = let
  
    colors = [
      "#090c0c" # 0: dark text
      "#a3aed2" # 1: header accent
      "#769ff0" # 2: directory/highlight
      "#394260" # 3: mid dark
      "#e3e5e5" # 4: light text
      "#1d2230" # 5: darkest bg
    ];
    c = i: builtins.elemAt colors i;
  in {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = ''
        [░▒▓](${c 1})[ ](bg:${c 1} fg:${c 0})[](bg:${c 2} fg:${c 1})$directory$git_branch$git_status$env_var
        $character'';

      git_branch = {
        disabled = false;
        style = "fg:${c 2} bg:${c 3}";
        format = "[[ $symbol$branch ](fg:${c 2} bg:${c 3})]($style)";
      };

      git_status = {
        style = "fg:${c 2} bg:${c 3}";
        format = "[[($all_status$ahead_behind)](fg:${c 2} bg:${c 3})]($style)[](fg:${c 3})";
      };

      env_var.context = {
        variable = "SHELL_CONTEXT";
        style = "fg:${c 2} bg:${c 5}";
        format = "[ $env_value ]($style)[](fg:${c 5} bg:${c 3})";
        disabled = false;
      };

      directory = {
        style = "fg:${c 4} bg:${c 2}";
        format = "[ $path ]($style)[](fg:${c 2} bg:${c 3})";
        truncation_length = 3;
        truncation_symbol = "…/";
        home_symbol = "";
      };

      character = {
        format = "[❯ ](bold purple)";
      };

      time = {
        disabled = true;
      };
    };
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
