# Git configuration
{ config, pkgs, lib, ... }:

{
  home.packages = [
    pkgs.delta
  ];

  programs.git = {
    enable = true;

    signing.key = "2A0AF30A3BD43ABB";

    settings = {
      user = {
        name = "jackschu";
        email = "31808950+jackschu@users.noreply.github.com";
      };

      commit = {
        gpgsign = true;
      };

      init = {
        defaultBranch = "main";
      };

      # Automatically setup remote tracking when pushing new branches
      push = {
        autoSetupRemote = true;
      };

      # Show original conflict markers in diffs
      merge = {
        conflictStyle = "diff3";
      };

      core = {
        pager = "delta";
        editor = "emacs -nw --no-desktop";
      };

      interactive = {
        diffFilter = "delta --color-only";
      };

      # Delta pager settings
      delta = {
        side-by-side = true;
        navigate = true;
        line-numbers = true;
        light = false;
      };

      diff = {
        colorMoved = "default";
      };

      color = {
        ui = true;
      };

      alias = {
        check = "checkout";
        unshelve = "stash apply";
        shelve = "stash";
        revert = "checkout";
        branches = "branch -a --sort=-committerdate";
      };

      # GitHub credential helper using gh CLI
      credential = {
        "https://github.com" = {
          helper = "!/etc/profiles/per-user/devbox/bin/gh auth git-credential";
        };
        "https://gist.github.com" = {
          helper = "!/etc/profiles/per-user/devbox/bin/gh auth git-credential";
        };
      };
    };
  };
}
