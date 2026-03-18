{ ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "jackschu";
        email = "31808950+jackschu@users.noreply.github.com";
      };

      ui = {
        editor = "emacs -nw --no-desktop";
        pager = "delta";
        "diff-formatter" = ":git";
      };

      signing = {
        backend = "gpg";
        behavior = "own";
        key = "2A0AF30A3BD43ABB";
      };

      git = {
        sign-on-push = true;
      };
    };
  };
}
