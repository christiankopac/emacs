;;; hyperbole-config.el --- Hyperbole configuration  -*- lexical-binding: t; -*-

;; ----------------------------------------------------------------------------
;; Hyperbole - Smart buttons, implicit links, and actionable text
;; ----------------------------------------------------------------------------
;;
;; This follows the existing pattern in this config:
;; - Package is declared in init.el via use-package
;; - This file is loaded from init.el after Elpaca has initialized
;;
;; Hyperbole upstream entry points vary a bit across versions, so this file
;; avoids hard failures by checking for functions before calling them.

(defvar my/hyperbole-prefix-key (kbd "C-c h")
  "Prefix key used for Hyperbole-related commands.")

(defvar my/hyperbole-map
  (let ((map (make-sparse-keymap)))
    map)
  "Keymap for Hyperbole commands under `my/hyperbole-prefix-key`. ")

;; Make C-c h a prefix for Hyperbole in a way that is easy to discover.
(define-key global-map my/hyperbole-prefix-key my/hyperbole-map)

(with-eval-after-load 'which-key
  (when (fboundp 'which-key-add-key-based-replacements)
    (which-key-add-key-based-replacements
      "C-c h" "Hyperbole")))

(when (require 'hyperbole nil t)
  ;; Enable Hyperbole globally if a mode is provided.
  (when (fboundp 'hyperbole-mode)
    (hyperbole-mode 1))

  ;; Common, stable entry points.
  (when (commandp 'hui-act)
    (define-key my/hyperbole-map (kbd "a") #'hui-act)
    (define-key my/hyperbole-map (kbd "RET") #'hui-act))

  ;; If Hyperbole provides an interactive dispatcher, expose it.
  (when (commandp 'hyperbole)
    (define-key my/hyperbole-map (kbd "h") #'hyperbole))

  ;; Path / link helpers (function names differ between versions; bind only if present).
  (when (commandp 'hpath:find)
    (define-key my/hyperbole-map (kbd "f") #'hpath:find))

  ;; Button helpers (optional).
  (when (commandp 'hbut:report)
    (define-key my/hyperbole-map (kbd "r") #'hbut:report))
  (when (commandp 'hbut:create)
    (define-key my/hyperbole-map (kbd "c") #'hbut:create))
  (when (commandp 'hbut:delete)
    (define-key my/hyperbole-map (kbd "d") #'hbut:delete)))

(provide 'hyperbole-config)
;;; hyperbole-config.el ends here
