;; ARTIFACT: C++ elisp removed during home-manager migration (2026-02-18).
;; This file is not loaded. Kept for reference in case C++ support is re-added.

;; custom-set-variables entries:
;; '(cmake-ide-build-dir "PATH")
 '(irony-server-install-prefix "/run/current-system/sw")

;; lsp
(add-hook 'c++-mode-hook 'lsp)
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; cmake
(require 'rtags)
(cmake-ide-setup)
(add-hook 'c-mode-hook 'rtags-start-process-unless-running)
(add-hook 'c++-mode-hook 'rtags-start-process-unless-running)

;; flycheck
(add-hook 'c++-mode-hook #'global-flycheck-mode)

;; flycheck c++ include
;; (add-hook 'c++-mode-hook
;;           (lambda () (setq flycheck-clang-include-path
;;                            (list (expand-file-name "PATH")))))
(with-eval-after-load "flycheck"
    (setq flycheck-clang-warnings `(,@flycheck-clang-warnings
                                    "no-pragma-once-outside-header")))
;;flycheck clangcheck
;; (require 'flycheck-clangcheck)

;; (defun my-select-clangcheck-for-checker ()
;;   "Select clang-check for flycheck's checker."
;;   (flycheck-set-checker-executable 'c/c++-clangcheck
;;                                    "/home/jschumann/.nix-profile/bin/clang-check")
;;   (flycheck-select-checker 'c/c++-clangcheck))

;; (add-hook 'c-mode-hook #'my-select-clangcheck-for-checker)
;; (add-hook 'c++-mode-hook #'my-select-clangcheck-for-checker)
;; (setq debug-on-message "Error")
;; enable static analysis
;;(setq flycheck-clangcheck-analyze t)


;;flycheck rtags
;; ensure that we use only rtags checking
;; https://github.com/Andersbakken/rtags#optional-1

;;(require 'flycheck-rtags)

;; doesnt highlight missing semicolon :/

;; Optional explicitly select the RTags Flycheck checker for c or c++ major mode.
;; Turn off Flycheck highlighting, use the RTags one.
;; Turn off automatic Flycheck syntax checking rtags does this manually.
;; (defun my-flycheck-rtags-setup ()
;;   "Configure flycheck-rtags for better experience."
;;   (flycheck-select-checker 'rtags)
;;   ;; (setq-local flycheck-check-syntax-automatically nil)
;;   ;; (setq-local flycheck-highlighting-mode nil)
;;   )
;; (add-hook 'c-mode-hook #'my-flycheck-rtags-setup)
;; (add-hook 'c++-mode-hook #'my-flycheck-rtags-setup)
;; (add-hook 'objc-mode-hook #'my-flycheck-rtags-setup
;;          )


;; (defun setup-flycheck-rtags ()
;;   (interactive)
;;   (flycheck-select-checker 'rtags)
;;   ;; RTags creates more accurate overlays.
;;   (setq-local flycheck-highlighting-mode nil)
;;   (setq-local flycheck-check-syntax-automatically nil))

;; ;; only run this if rtags is installed
;; (when (require 'rtags nil :noerror)
;;   ;; make sure you have company-mode installed
;;   (require 'company)
;;   (define-key c-mode-base-map (kbd "M-.")
;;     (function rtags-find-symbol-at-point))
;;   (define-key c-mode-base-map (kbd "M-,")
;;     (function rtags-find-references-at-point))
;;   ;; disable prelude's use of C-c r, as this is the rtags keyboard prefix
;; ;;  (define-key prelude-mode-map (kbd "C-c r") nil)
;;   ;; install standard rtags keybindings. Do M-. on the symbol below to
;;   ;; jump to definition and see the keybindings.
;;   (rtags-enable-standard-keybindings)
;;   ;; comment this out if you don't have or don't use helm
;;   (setq rtags-use-helm t)
;;   ;; company completion setup
;;   (setq rtags-autostart-diagnostics t)
;;   (rtags-diagnostics)
;;   (setq rtags-completions-enabled t)
;;   (push 'company-rtags company-backends)
;;   (global-company-mode)
;;   (define-key c-mode-base-map (kbd "<C-tab>") (function company-complete))
;;   ;; use rtags flycheck mode -- clang warnings shown inline
;;   (require 'flycheck-rtags)
;;   ;; c-mode-common-hook is also called by c++-mode
;;   (add-hook 'c-mode-common-hook #'setup-flycheck-rtags))



;; cpp / c++ stuff
(setq-default c-basic-offset 4)
(add-hook 'c++-mode-hook
(lambda ()  (define-key c++-mode-map (kbd "C-x c f") 'clang-format-region)))

(add-hook 'c++-mode-hook 'irony-mode)


(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)



(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
