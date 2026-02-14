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
    g = import ./starship_glyphs.nix;
    colors = [
      "#090c0c" # 0: dark text
      "#a3aed2" # 1: header accent
      "#769ff0" # 2: directory/highlight
      "#394260" # 3: mid dark
      "#e3e5e5" # 4: light text
      "#1d2230" # 5: darkest bg
    ];
    c = i: builtins.elemAt colors i;
    style = fg: bg: "fg:${c fg} bg:${c bg}";
    # sep: null for no separator, true to fade to terminal, or a color
    #      index for the next block's background
    block = fg: bg: content: sep:
      "[${content}](${style fg bg})"
      + (if sep == null then ""
         else if sep == true then "[${g.separator}](fg:${c bg})"
         else "[${g.separator}](${style bg sep})");
  in {
    enable = true;
    enableBashIntegration = true;
    settings = {
      format = ''
        [${g.gradient}](${c 1})[  ](${style 0 1})[${g.separator}](${style 1 2})$directory$git_branch$git_status$env_var
        $character'';

      git_branch = {
        disabled = false;
        style = style 2 3;
        format = block 2 3 " $symbol$branch " null;
      };

      git_status = {
        style = style 2 3;
        format = block 2 3 "($all_status$ahead_behind)" true;
      };

      env_var.context = {
        variable = "SHELL_CONTEXT";
        style = style 2 5;
	# TODO this isnt quite right, 
        format = block 2 5 " $env_value " 3;
        disabled = false;
      };

      directory = {
        style = style 4 2;
        format = block 4 2 " $path " 3;
        truncation_length = 3;
        truncation_symbol = "${g.ellipsis}/";
        home_symbol = "${g.home}";
      };

      character = {
        format = "[${g.prompt} ](bold purple)";
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
