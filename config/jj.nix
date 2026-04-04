{ gitName ? "jackschu", gitEmail ? "31808950+jackschu@users.noreply.github.com", ... }:

{
  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = gitName;
        email = gitEmail;
      };

      ui = {
        editor = "emacs -nw --no-desktop";
        pager = "delta";
        "diff-formatter" = ":git";
        default-command = "log";
      };

      aliases = {
        b = [ "bookmark" ];
      };
    };
  };
}
