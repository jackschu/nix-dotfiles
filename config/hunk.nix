# hunk - review-first terminal diff viewer (https://hunk.dev)
{ ... }:

{
  # Installs the flake-pinned hunk package via homeManagerModules.default.
  # delta stays the default pager for git and jj; hunk is opt-in via
  # `git hdiff` / `git hshow` (aliases in git.nix).
  programs.hunk.enable = true;
}
