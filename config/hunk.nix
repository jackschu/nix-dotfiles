# hunk - review-first terminal diff viewer (https://hunk.dev)
{ ... }:

{
  # Installs the flake-pinned hunk package via homeManagerModules.default.
  #   - git: delta stays the default pager; hunk is opt-in via
  #          `git hdiff` / `git hshow` (aliases in git.nix).
  #   - jj:  a content-sniffing pager dispatcher (see jj.nix) routes diff
  #          output (jj diff / jj show) to hunk and everything else
  #          (jj log, ...) to delta, so short logs still skip the pager.
  programs.hunk.enable = true;
}
