{ config, pkgs, gitName, gitEmail, ... }:

let
  hunk = "${config.programs.hunk.package}/bin/hunk";
  # jj's ui.pager is global (it also paginates `jj log`, `jj status`, ...),
  # so route by content instead: git-format diffs (jj diff / jj show, which
  # start with "diff --git") go to hunk's review TUI, everything else goes to
  # delta. delta pages via `less -F`, so short `jj log` output still skips the
  # pager the way it did before hunk was involved.
  diffPager = pkgs.writeShellScript "jj-diff-pager" ''
    set -u
    peek="$(mktemp)"
    trap 'rm -f "$peek"' EXIT
    head -c 65536 > "$peek"
    # jj colorizes for the pager, so the header is "\e[1mdiff --git ..." —
    # match the substring rather than anchoring to the start of the line.
    if ${pkgs.gnugrep}/bin/grep -qsE 'diff --git ' "$peek"; then
      { cat "$peek"; cat; } | ${hunk} pager
    else
      { cat "$peek"; cat; } | ${pkgs.delta}/bin/delta
    fi
  '';
in
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
        pager = [ "${diffPager}" ];
        "diff-formatter" = ":git";
        default-command = "log";
      };

      aliases = {
        b = [ "bookmark" ];
      };
    };
  };
}
