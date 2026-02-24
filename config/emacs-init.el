
;; Point customize to a writable file outside the Nix store.
;; This file is seeded from config/emacs-custom.el on every home-manager switch.
;; After using customize, run sync-emacs-custom to persist changes back to the repo.
(setq custom-file "~/.emacs-custom.el")
(load custom-file)

(advice-add 'custom-save-all :after
            (lambda (&rest _)
              (message "Customize saved — run sync-emacs-custom to commit to home-manager repo")))

;; comment commands

(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.react.js\\'" . web-mode))

(setq web-mode-engines-alist
      '(("django" . "\\.html\\'")))
(add-to-list 'auto-mode-alist '("\\.js[x]?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts[x]?\\'" . web-mode))
(defun pk-web-mode-hook ()
  "Hooks for Web mode."
  (set-face-attribute 'web-mode-html-tag-bracket-face nil :foreground "White")
  (set-face-attribute 'web-mode-html-tag-face nil :foreground "Yellow")
  )
(add-hook 'web-mode-hook  'pk-web-mode-hook)
;; tab spaces war
(setq-default tab-width 4)



;; enabling line numbers by defaut

;; Preset `nlinum-format' for minimum width.
(defun my-nlinum-mode-hook ()
  (when nlinum-mode
    (setq-local nlinum-format
                (concat "%" (number-to-string
                             ;; Guesstimate number of buffer lines.
                             (ceiling (log (max 1 (/ (buffer-size) 80)) 10)))
                        "d "))))
(add-hook 'nlinum-mode-hook #'my-nlinum-mode-hook)

(global-nlinum-mode)
;;merge mode hook



;; adding themes
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")


;; not full scroll c-v m-v
(require 'golden-ratio-scroll-screen)
(global-set-key [remap scroll-down-command] 'golden-ratio-scroll-screen-down)
(global-set-key [remap scroll-up-command] 'golden-ratio-scroll-screen-up)

(defvar non-pulse-func-is-running-p nil
  "Dynamically-scoped flag that is non-nil when `other-function` is executing.")

(defun non-pulse-function-wrapper (original-function &rest args)
  "Advice to set `other-function-is-running-p` while executing."
  (let ((non-pulse-func-is-running-p t))
    (apply original-function args)))

(advice-add 'diff-goto-source :around #'non-pulse-function-wrapper)


(defun pulse-hook-function (orig-fun &rest args)
  "Function to run before or after `diff-hunk-next`."
  ;; Code to run before the original function

  ;; Call the original function

  (apply orig-fun args)

  (message (if non-pulse-func-is-running-p "true" "false"))
  ;; Code to run after the original function
  (if non-pulse-func-is-running-p nil (pulse-momentary-highlight-one-line (point)))
  )


(advice-add 'diff-hunk-next :around #'pulse-hook-function)
(advice-add 'diff-hunk-prev :around #'pulse-hook-function)
(advice-add 'diff-file-next :around #'pulse-hook-function)
(advice-add 'diff-file-prev :around #'pulse-hook-function)

(setq org-default-notes-file  "~/Documents/jacks_org/notes.org")
;; org mode bindings
(add-hook 'org-load-hook
          (lambda ()
            (define-key org-mode-map "\M-n" 'org-metadown)
            (define-key org-mode-map "\M-p" 'org-metaup)))
;; org mode invis text
(setq org-catch-invisible-edits 'smart)
(setq org-list-demote-modify-bullet '( ("-" . "+") ("*" . "+")("+" . "-")))
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
;; (setq org-capture-templates
;;   '(("t" "Task" entry (file "~/Documents/jacks_org/notes.org")
;;      (file "~/Documents/jacks_org/template.org") :empty-lines-before 1)
;;     ("m" "Meeting" entry (file "~/Documents/jacks_org/notes.org")
;;      (file "~/Documents/jacks_org/template_meeting.org") :empty-lines-before 1)
;;     ("n" "Notif task" entry (file "~/Documents/jacks_org/notes.org")
;;      (file "~/Documents/jacks_org/template_notifs.org") :empty-lines-before 1)
;;     ("r" "Review Task" entry (file "~/Documents/jacks_org/notes.org")
;;      (file "~/Documents/jacks_org/template_review.org") :empty-lines-before 1)))
(advice-add 'org-refile :after 'org-save-all-org-buffers)

;; (setq org-agenda-window-setup 'only-window); agenda takes whole window
;; (setq org-agenda-restore-windows-after-quit t); restore window configuration on exit


;; from https://www.reddit.com/r/emacs/comments/jp5ear/sorting_org_clocktables_by_category_instead_of/ (wayback machine 2021)
(defun my-org-clocktable-formatter (ipos tables params)
  "Custom formatter for org-mode clocktables which groups by category rather than file.
It uses `org-clock-clocktable-formatter' for the insertion of the table after sorting
the items into tables based on an items category property. Thus all parameters supported
by `org-clock-clocktable-formatter' are supported. To use this to sort a clocktable add
`:properties (\"PROJECT\") :formatter my-org-clocktable-formatter' to that clocktable's
arguments."
  (let* ((tt (-flatten-n 1 (-map #'-last-item tables)))
         (formatter (or org-clock-clocktable-formatter
                        'org-clocktable-write-default))
         (newprops (remove "PROJECT" (plist-get params :properties)))
         (newparams (plist-put (plist-put params :multifile t) :properties newprops))
         newtables)

    ;; Compute net clocked time for each item
    (setq tt
          (--map-indexed
           (let* ((it-level (car it))
                  (it-time (nth 4 it))
                  (it-subtree (--take-while (< it-level (car it))
                                            (-drop (1+ it-index) tt)))
                  (it-children (--filter (= (1+ it-level) (car it))
                                         it-subtree)))
             (-replace-at 4 (- it-time (-sum (--map (nth 4 it) it-children)))
                          it))
           tt))

    ;; Add index (ie id) and indexes of parents (these are needed in the
    ;; sorting step). This can probably be written more functionally using --reduce?
    ;; At least without having to modify hist.
    (setq tt
          (let (hist)
            (--map-indexed (let* ((it-level (car it))
                                  (it-hist (-drop (- (length hist)
                                                     it-level -1)
                                                  hist)))
                             (setq hist (cons it-index it-hist))
                             (cons it-index (cons it-hist it)))
                           tt)))

    ;; Now comes the important phase: sorting, where we copy items with >0 net time
    ;; into newtables based on their category, and we copy their parents when
    ;; appropriate.
    (--each tt (let* ((it-hist (nth 1 it))
                      (it-time (nth 6 it))
                      (it-prop (-last-item it))
                      (it-cat (alist-get "PROJECT" it-prop nil nil #'string=))
                      ;; Find the index of the table for category: it-cat or if
                      ;; it doesn't yet exist add it to the start of newtables.
                      (cat-pos (or
                                (--find-index (string= (car it) it-cat) newtables)
                                (progn (push (list it-cat nil) newtables) 0)))
                      (cat-members (-map #'car (-last-item (nth cat-pos newtables))))
                      (it-parent
                       (or (--find-index (member it
                                                 cat-members)
                                         it-hist)
                           (length it-hist)))
                      (hist-to-add
                       ;; replace the time of copied parents with 0 since if a
                       ;; parents is being copied and has time >0 then it has
                       ;; already been placed in the table for a different
                       ;; category. ie. We don't want time double counted.
                       (--map (-replace-at 6 0 (nth it tt))
                              (-take it-parent it-hist))))

                 (when (not (= 0 it-time))
                   (setf (-last-item (nth cat-pos newtables))
                         (append (cons it hist-to-add)
                                 (-last-item (nth cat-pos newtables)))))))

    (--each newtables (setf (-last-item it) (reverse (-last-item it))))
    ;; Cleanup, remove ids and list of parents, as they are no longer needed.
    (setq newtables
          (--map (list (car it) 0 (--map (-drop 2 it) (-last-item it))) newtables))

    ;; Recompute the total times for each node.
    ;; (replace this with --each and setf?)
    (setq newtables
          (--map (let* ((it-children (sum-direct-children-org 1 (-last-item it)))
                        (it-total-time (-sum
                                        (--map (nth 4 it)
                                               (--filter (= 1 (car it))
                                                         it-children)))))
                   (list (car it) it-total-time it-children))
                 newtables))
    ;; Actually insert the clocktable now.
    (funcall formatter ipos newtables newparams)
    ;; Replace "File" with "Category" in the "file" column and "*File time*" with "*
    ;; Category time*" in the table.
    (org-table-goto-line 1)
    (org-table-blank-field)
    (insert "Category")
    (org-table-align)
    (let ((n 2))
      (while (org-table-goto-line n)
        (org-table-next-field)
        ;; This won't work if there are addition columns eg. Property column.
        ;; Instead look forward along each line to see if that regexp is matched?
        (when (looking-at "\\*File time\\* .*\| *\\*.*[0-9]:[0-9][0-9]\\*")
          (org-table-blank-field)
          (insert "*Category time*")
          (org-table-align))
        (incf n)))))

(defun sum-direct-children-org (level children)
  "Update the time LEVEL nodes recursively to be the sum of the times of its children.
Used in `my-org-clocktable-formatter' to go from net times back to tatal times."
  (let ((subtrees (-partition-before-pred (lambda (it) (= level (car it))) children)))
    (-flatten-n 1
                (--map (let ((it-children (sum-direct-children-org (1+ level)
                                                                   (cdr it))))
                         (cons (--update-at
                                4 (+ it
                                     (-sum
                                      (--map (nth 4 it)
                                             (--filter (= (1+ level)
                                                          (car it))
                                                       it-children))))
                                (car it))
                               it-children))
                       subtrees))))



;; company
(require 'company)
(setq company-idle-delay  nil) ;; removing typeahead display
(add-hook 'after-init-hook 'global-company-mode) ;; default on

;; python+ sql = mmm
 (require 'mmm-mode)
 (set-face-background 'mmm-default-submode-face nil)

(mmm-add-classes
 '((python-sql
    :submode sql-mode
    :face mmm-code-submode-face
    :front "# SQL\\(\n\\|\t\\)*\\(\[ -_A-Z0-9\]+\\)\\(\[ =\]\\)\\(\"\"\"\\|'''\\)"
    :back "\\(\"\"\"\\|'''\\)\\( \\|\t\\|\n\\)*\\# /SQL")))

(mmm-add-mode-ext-class 'python-mode "*.py" 'python-sql)
;; python interpreter
(setq python-shell-interpreter "python3")


(defun hphpd-localhost ()
  "Start HipHop Debugger against localhost"
  (interactive)
  (hphpd "hphpd -h localhost"))

(defun hphpd-script ()
  "Start HipHop Debugger against script"
  (interactive)
  (hphpd "hphpd -f ~/www/scripts/insights/insights_generate_metrics.php"))

;; clang-format
(require 'clang-format)
(global-set-key (kbd "C-c u") 'clang-format-buffer)

;; prettier
(require 'prettier-js)
(defun enable-prettier-mode (my-pair)
  "Enable minor mode if filename match the regexp.  MY-PAIR is a cons cell (regexp . minor-mode)."
  (if (buffer-file-name)
      (if (string-match (car my-pair) buffer-file-name)
		  (funcall (cdr my-pair)))))

;; auto prettier
;; (add-hook 'web-mode-hook #'(lambda ()
;;                             (enable-prettier-mode
;;                              '("\\.jsx?\\'" . prettier-js-mode))))


;; my keybindings
(defvar my-keys-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "M-q") 'company-complete)
    (define-key map (kbd "C-x l r") 'lsp-rename)
    (define-key map (kbd "C-x ;") 'comment-line)
    (define-key map (kbd "C-j") nil)
    (define-key map (kbd "C-j w") 'avy-goto-word-0)
    (define-key map (kbd "C-j c") 'avy-goto-char-in-line)
    (define-key map (kbd "C-x C-f") 'helm-projectile-find-file)
    (define-key map (kbd "C-x c b") 'helm-bookmarks)
    (define-key map (kbd "C-c C-x C-p") 'org-set-property)
    (define-key map (kbd "C-x c k") 'helm-show-kill-ring)
    (define-key map (kbd "C-x c r") 'helm-resume)
    (define-key map (kbd "C-x r l") 'helm-bookmarks)
    (define-key map (kbd "C-x f") 'find-file)
    map)
  "my-keys-minor-mode keymap.")



(define-minor-mode my-keys-minor-mode
  "A minor mode so that my key settings override annoying major modes."
  :init-value t
  :lighter " my-keys")

(my-keys-minor-mode 1)

;; save sessions
(desktop-save-mode 1)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)


;; backup in one place. flat, no tree structure
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))

(require 'no-littering)



; roslaunch highlighting
(add-to-list 'auto-mode-alist '("\\.launch$" . xml-mode))

;; lsp stuff
(require 'lsp)
(add-hook 'nix-mode-hook 'lsp)
(add-hook 'rust-mode-hook #'lsp-deferred)
(add-hook 'rust-ts-mode-hook #'lsp-deferred)

(with-eval-after-load 'rust-mode
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(with-eval-after-load 'lsp-mode
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\cargo-target\\'") ;; i think this one is ineffectual
  (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\output\\'")
)


(use-package lsp-nix
  :ensure lsp-mode
  :after (lsp-mode)
  :demand t
  :custom
  (lsp-nix-nil-formatter ["nixpkgs-fmt"]))

(use-package nix-mode
  :hook (nix-mode . lsp-deferred)
  :ensure t)

(setq read-process-output-max (* 1024 1024)) ;; 1mb


;; disable flymake
(setq lsp-diagnostics-provider :none)
;; enable flycheck
(add-hook 'rust-mode-hook 'flycheck-mode)

;; helm
(with-eval-after-load 'helm
  (define-key helm-map (kbd "TAB")       #'nil)
  (define-key helm-map (kbd "C-TAB")       #'helm-select-action)
  (define-key helm-map (kbd "<backtab>") #'helm-previous-line))

(global-set-key (kbd "M-x") 'helm-M-x)
(helm-mode 1)
(set-face-attribute 'helm-selection nil
                    :background "purple"
                    :foreground "black")
;; projectile
(projectile-mode +1)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

;; helm-ag
(require 'helm-ag)
(setq helm-ag-insert-at-point 'symbol)
(global-set-key (kbd "M-/") 'helm-ag-project-root)




;; lock files
(setq create-lockfiles nil)


;; prevent window split (helm + grep)
(setq split-height-threshold nil
      split-width-threshold nil)

;; ediff
    ;; (add-hook 'ediff-startup-hook
    ;;           (lambda ()
    ;;             (progn
    ;;               (select-frame-by-name "Ediff")
    ;;               (set-frame-size(selected-frame) 40 40))))
;;     (defun my-ediff-ash ()
;;       "Function to be called after buffers and window setup for ediff."
;; 	  (other-window))
;; (add-hook 'ediff-after-setup-windows-hook 'my-ediff-ash 'append)


;; tide

;; tide things,
(require 'tide)
(defun setup-tide-mode ()
  (interactive)
  (tide-setup)
  (flycheck-mode +1)
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (eldoc-mode +1)
  (ws-butler-mode +1)
  ;;(typescript-mode)
  ;;(prettier-js-mode +1)
  (tide-hl-identifier-mode +1)
;;  (typescript-ts-mode)
  ;; company is an optional dependency. You have to
  ;; install it separately via package-install
  ;; `M-x package-install [ret] company`
  (company-mode +1)
)

(defun patch-ts-syntax-mode ()
  (modify-syntax-entry ?# "_" typescript-mode-syntax-table)
)
(defun patch-ts-ts-syntax-mode ()
  (modify-syntax-entry ?# "_" typescript-ts-mode--syntax-table)
)

;; tree sitter
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (rust "https://github.com/tree-sitter/tree-sitter-rust")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (nix "https://github.com/nix-community/tree-sitter-nix")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

;; (setq major-mode-remap-alist nil)
;; (setq major-mode-remap-alist
;;  '((typescript-mode . typescript-ts-mode)))


;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; formats the buffer before saving
;;(add-hook 'before-save-hook ')

(add-hook 'typescript-mode-hook #'patch-ts-syntax-mode)
(add-hook 'typescript-mode-hook #'patch-ts-ts-syntax-mode)
(add-hook 'typescript-mode-hook #'setup-tide-mode)

(add-hook 'typescript-ts-mode-hook #'setup-tide-mode)
(add-hook 'typescript-ts-mode-hook #'patch-ts-ts-syntax-mode)

(add-hook 'tsx-ts-mode-hook #'setup-tide-mode)
(add-hook 'tsx-ts-mode-hook #'patch-ts-ts-syntax-mode)

(eval-after-load "tide"
  '(define-key tide-mode-map (kbd "C-x c f") 'prettier-region))

(eval-after-load "tide"
  '(define-key tide-mode-map (kbd "C-x x s") 'tide-restart-server))


(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (tsx-ts-mode))))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "ts" (file-name-extension buffer-file-name))
              (typescript-ts-mode))))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "js" (file-name-extension buffer-file-name))
              (typescript-ts-mode))))
(add-hook 'js2-mode-hook #'setup-tide-mode)
;; configure javascript-tide checker to run after your default javascript checker
(require 'flycheck)
(flycheck-add-next-checker 'javascript-tide 'javascript-eslint 'append)
;; configure jsx-tide checker to run after your default jsx checker
(flycheck-add-mode 'javascript-eslint 'web-mode)
(flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)

(defun my-print-region ()
  (message "%d %d" (region-beginning) (region-end))
  )

(defun prettier-region (posBegin posEnd)
  "Print number of words and chars in region."
  (interactive "r")
  (message "Formatting …")
  (let* (
         (old-prettier-args prettier-js-args)
         (prettier-js-args (append old-prettier-args (list "--range-start" (number-to-string posBegin) "--range-end" (number-to-string posEnd))))
         )
    (prettier-js)
    )
  )

(defun display-ansi-colors ()
  (interactive)
  (ansi-color-apply-on-region (point-min) (point-max)))

;; nix stuffn
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-ts-mode))
(add-hook 'nix-mode-hook 'lsp-mode)
(add-hook 'nix-ts-mode-hook 'lsp-mode)

;; swift
(add-to-list 'auto-mode-alist '("\\.swift\\'" . swift-ts-mode))

;; go stuffn
(add-hook 'go-mode-hook 'lsp-mode)

;; dont kill
(setq confirm-kill-emacs 'y-or-n-p)

;; dumb-jump (global fallback + local fallback behind lsp)
(require 'dumb-jump)
(setq dumb-jump-force-searcher 'rg)
(remove-hook 'xref-backend-functions #'etags--xref-backend)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate 100)
(add-hook 'lsp-mode-hook
          (lambda ()
            (add-hook 'xref-backend-functions #'dumb-jump-xref-activate 100 t)))

;; zzz-mode
(global-set-key (kbd "M-z") #'zzz-to-char)

;; protobuf
  (defconst my-protobuf-style
    '((c-basic-offset . 2)))

  (add-hook 'protobuf-mode-hook
    (lambda () (c-add-style "my-style" my-protobuf-style t)))

(add-hook 'rust-mode-hook
          (lambda ()  (define-key rust-mode-map (kbd "M-?") 'lsp-find-references)))
