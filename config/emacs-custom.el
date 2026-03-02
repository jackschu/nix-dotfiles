(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(agent-shell-transcript-file-path-function
   (lambda nil
     (let*
         ((project-name
           (file-name-nondirectory
            (directory-file-name (agent-shell-cwd))))
          (base
           (if (fboundp 'xdg-data-home) (xdg-data-home)
             "~/.local/share"))
          (dir
           (expand-file-name
            (concat "agent-shell/transcripts/" project-name) base))
          (filename (format-time-string "%F-%H-%M-%S.md")))
       (expand-file-name filename dir))))
 '(clang-format-style
   "{BasedOnStyle: llvm, ColumnLimit: 120, IndentWidth: 4, AlwaysBreakTemplateDeclarations: Yes}")
 '(custom-safe-themes
   '("8de9f0d0e8d041ac7e7fc9d7db2aff119259eea297ccc247e81470851df32602"
     default))
 '(display-buffer-alist '(("CAPTURE*" (display-buffer-in-side-window))))
 '(flycheck-checker-error-threshold 800)
 '(flycheck-disabled-checkers nil)
 '(flycheck-rst-sphinx-executable "sphinx-build")
 '(gc-cons-threshold 100000000)
 '(helm-ag-base-command
   "ag --no-color --nogroup -W 150 --ignore=output/ --ignore=*.orig --ignore=*.*#")
 '(helm-always-two-windows nil)
 '(indent-tabs-mode nil)
 '(lsp-disabled-clients '(nix-nil))
 '(lsp-file-watch-ignored-directories
   '("[/\\\\]\\.cargo\\'" "[/\\\\]\\output\\'" "[/\\\\]\\cargo-target\\'"
     "[/\\\\]\\.git\\'" "[/\\\\]\\.github\\'" "[/\\\\]\\.gitlab\\'"
     "[/\\\\]\\.circleci\\'" "[/\\\\]\\.hg\\'" "[/\\\\]\\.bzr\\'"
     "[/\\\\]_darcs\\'" "[/\\\\]\\.svn\\'" "[/\\\\]_FOSSIL_\\'"
     "[/\\\\]\\.idea\\'" "[/\\\\]\\.ensime_cache\\'"
     "[/\\\\]\\.eunit\\'" "[/\\\\]node_modules" "[/\\\\]\\.yarn\\'"
     "[/\\\\]\\.turbo\\'" "[/\\\\]\\.fslckout\\'" "[/\\\\]\\.tox\\'"
     "[/\\\\]\\.nox\\'" "[/\\\\]dist\\'" "[/\\\\]dist-newstyle\\'"
     "[/\\\\]\\.stack-work\\'" "[/\\\\]\\.bloop\\'" "[/\\\\]\\.bsp\\'"
     "[/\\\\]\\.metals\\'" "[/\\\\]target\\'"
     "[/\\\\]\\.ccls-cache\\'" "[/\\\\]\\.vs\\'" "[/\\\\]\\.vscode\\'"
     "[/\\\\]\\.venv\\'" "[/\\\\]\\.mypy_cache\\'"
     "[/\\\\]\\.pytest_cache\\'" "[/\\\\]\\.build\\'"
     "[/\\\\]__pycache__\\'" "[/\\\\]site-packages\\'"
     "[/\\\\].pyenv\\'" "[/\\\\]\\.deps\\'" "[/\\\\]build-aux\\'"
     "[/\\\\]autom4te.cache\\'" "[/\\\\]\\.reference\\'"
     "[/\\\\]bazel-[^/\\\\]+\\'" "[/\\\\]\\.cache[/\\\\]lsp-csharp\\'"
     "[/\\\\]\\.meta\\'" "[/\\\\]\\.nuget\\'" "[/\\\\]Library\\'"
     "[/\\\\]\\.lsp\\'" "[/\\\\]\\.clj-kondo\\'"
     "[/\\\\]\\.shadow-cljs\\'" "[/\\\\]\\.babel_cache\\'"
     "[/\\\\]\\.cpcache\\'" "[/\\\\]\\checkouts\\'"
     "[/\\\\]\\.gradle\\'" "[/\\\\]\\.m2\\'" "[/\\\\]bin/Debug\\'"
     "[/\\\\]obj\\'" "[/\\\\]_opam\\'" "[/\\\\]_build\\'"
     "[/\\\\]\\.elixir_ls\\'" "[/\\\\]\\.elixir-tools\\'"
     "[/\\\\]\\.terraform\\'" "[/\\\\]\\.terragrunt-cache\\'"
     "[/\\\\]\\result" "[/\\\\]\\result-bin" "[/\\\\]\\.direnv\\'"))
 '(lsp-file-watch-threshold 2000)
 '(lsp-rust-analyzer-cargo-extra-args [])
 '(lsp-rust-analyzer-cargo-extra-env [])
 '(lsp-rust-analyzer-cargo-override-command [])
 '(lsp-rust-analyzer-cargo-watch-enable t)
 '(lsp-rust-analyzer-rustfmt-extra-args ["--config" "max_width=120"])
 '(lsp-rust-analyzer-server-command '("rust-analyzer"))
 '(make-backup-files nil)
 '(mode-require-final-newline nil)
 '(nix-ts-mode-indent-offset 2)
 '(org-agenda-files '("~/Documents/jacks_org/notes.org"))
 '(org-agenda-restore-windows-after-quit nil)
 '(org-agenda-window-setup 'current-window)
 '(org-clock-idle-time 10)
 '(org-duration-format '((special . h:mm)))
 '(org-refile-targets '(("backlog.org" :maxlevel . 1)))
 '(org-refile-use-outline-path nil)
 '(org-todo-keywords '((sequence "TODO" "WAIT" "DONE")))
 '(prettier-js-args '("--tab-width" "4" "--print-width" "120" "--semi" "false"))
 '(prettier-js-command "prettier")
 '(pulsar-iterations 2)
 '(temporary-file-directory "~/.cache/emacs/" nil nil "This directory is created by home-manager (see emacs.nix)")
 '(terraform-indent-level 4)
 '(tide-completion-fuzzy t)
 '(tide-server-max-response-length 204800)
 '(tide-user-preferences
   '(:includeCompletionsForModuleExports t
                                         :includeCompletionsWithInsertText
                                         t :allowTextChangesInNewFiles
                                         t
                                         :generateReturnInDocTemplate
                                         t :noErrorTruncation t))
 '(treesit-font-lock-level 4)
 '(typescript-ts-mode-indent-offset 4)
 '(vc-annotate-background-mode nil)
 '(warning-suppress-types '((auto-save)))
 '(zzz-to-char-reach 200))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(avy-lead-face ((t (:background "gray20" :foreground "white"))))
 '(avy-lead-face-0 ((t (:background "gray22" :foreground "white"))))
 '(avy-lead-face-1 ((t (:background "gray24" :foreground "white"))))
 '(avy-lead-face-2 ((t (:background "gray26" :foreground "white"))))
 '(diff-added ((t (:inherit diff-changed :extend t :background "green4"))))
 '(diff-file-header ((t (:extend t :background "thistle4" :foreground "lightskyblue"))))
 '(diff-header ((t (:extend t :background "dimgray"))))
 '(diff-refine-added ((t (:inherit diff-refine-changed :background "green3"))))
 '(diff-refine-removed ((t (:inherit diff-refine-changed :background "firebrick3"))))
 '(diff-removed ((t (:inherit diff-changed :extend t :background "firebrick4"))))
 '(ediff-current-diff-C ((t (:extend t :background "#5f0087"))))
 '(ediff-fine-diff-C ((t (:background "#8700af"))))
 '(font-lock-builtin-face ((t (:foreground "#5f87af"))))
 '(font-lock-comment-face ((t (:foreground "#8FA6B2"))))
 '(font-lock-constant-face ((t (:foreground "#3cbab0"))))
 '(font-lock-function-name-face ((t (:foreground "dodgerblue1"))))
 '(font-lock-keyword-face ((t (:foreground "#AC69F2"))))
 '(font-lock-string-face ((t (:foreground "#9FB8F6"))))
 '(font-lock-type-face ((t (:foreground "#00af00"))))
 '(font-lock-variable-name-face ((t (:foreground "#d78700"))))
 '(helm-ff-file ((t (:inherit font-lock-builtin-face :extend t :foreground "brightwhite"))))
 '(highlight ((t (:background "#5f005f"))))
 '(linum ((t (:inherit default :foreground "#808080"))))
 '(log-view-message ((t (:extend t :background "brightblack"))))
 '(lsp-face-highlight-textual ((t (:inherit highlight :background "magenta"))))
 '(lsp-headerline-breadcrumb-path-face ((t (:inherit lsp-headerline-breadcrumb-symbols-face))))
 '(lsp-headerline-breadcrumb-symbols-face ((t (:foreground "black" :weight bold))))
 '(match ((t (:background "purple"))))
 '(minibuffer-prompt ((t (:foreground "#00d7ff"))))
 '(org-date ((t (:foreground "lightskyblue" :underline t))))
 '(org-done ((t (:foreground "mediumspringgreen" :weight bold))))
 '(org-drawer ((t (:foreground "deepskyblue"))))
 '(org-table ((t (:foreground "lightskyblue"))))
 '(org-todo ((t (:foreground "hotpink2" :weight bold))))
 '(region ((t (:extend t :background "mediumorchid4"))))
 '(rst-level-1 ((t (:background "brightblack"))))
 '(rst-level-2 ((t (:background "brightblack"))))
 '(rst-level-3 ((t (:background "brightblack"))))
 '(vc-annotate-face-FFCCCC ((t (:background "#Ffcccc"))) t))
