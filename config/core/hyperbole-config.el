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

(defvar my/hyperbole-org-map (make-sparse-keymap)
  "Keymap for Org-related Hyperbole commands.")

(defvar my/hyperbole-bbdb-map (make-sparse-keymap)
  "Keymap for BBDB/contact-related Hyperbole commands.")

(defvar my/hyperbole-mail-map (make-sparse-keymap)
  "Keymap for mail-related Hyperbole commands.")

;; Make C-c h a prefix for Hyperbole in a way that is easy to discover.
(define-key global-map my/hyperbole-prefix-key my/hyperbole-map)

;; Sub-prefixes.
(define-key my/hyperbole-map (kbd "o") my/hyperbole-org-map)
(define-key my/hyperbole-map (kbd "b") my/hyperbole-bbdb-map)
(define-key my/hyperbole-map (kbd "m") my/hyperbole-mail-map)

(with-eval-after-load 'which-key
  (when (fboundp 'which-key-add-key-based-replacements)
    (which-key-add-key-based-replacements
      "C-c h" "Hyperbole"
      "C-c h o" "Hyperbole (Org)"
      "C-c h b" "Hyperbole (BBDB)"
      "C-c h m" "Hyperbole (Mail)")))

;; Org integration: avoid taking over `org-meta-return' globally.
;; Hyperbole uses {M-RET} as an Action Key; this setting keeps it constrained
;; to Hyperbole button contexts inside Org buffers.
(setq hsys-org-enable-smart-keys 'buttons)

(when (require 'hyperbole nil t)
  ;; Load core subsystems that provide user-facing commands we bind below.
  (require 'hycontrol nil t)

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

  ;; Window/screen control (Hyperbole ships `hycontrol').
  (when (commandp 'hycontrol-enable-windows-mode)
    (define-key my/hyperbole-map (kbd "w") #'hycontrol-enable-windows-mode))
  (when (commandp 'hycontrol-windows-grid)
    (define-key my/hyperbole-map (kbd "g") #'hycontrol-windows-grid))

  ;; Search/web helpers.
  (when (commandp 'hui-search-web)
    (define-key my/hyperbole-map (kbd "/") #'hui-search-web))

  ;; Path / link helpers (function names differ between versions; bind only if present).
  (when (commandp 'hpath:find)
    (define-key my/hyperbole-map (kbd "f") #'hpath:find))

  ;; Button helpers (optional).
  (when (commandp 'hbut:report)
    (define-key my/hyperbole-map (kbd "r") #'hbut:report))
  (when (commandp 'hbut:create)
    (define-key my/hyperbole-map (kbd "c") #'hbut:create))
  (when (commandp 'hbut:delete)
    (define-key my/hyperbole-map (kbd "d") #'hbut:delete))

  ;; Optional subsystems that enable richer behavior in specific areas.
  ;; Load them lazily and only if present in the installed Hyperbole version.
  (with-eval-after-load 'org
    (require 'hsys-org nil t)
    (when (commandp 'hsys-org-consult-grep)
      (define-key my/hyperbole-org-map (kbd "g") #'hsys-org-consult-grep))
    (when (commandp 'hsys-org-tags-view)
      (define-key my/hyperbole-org-map (kbd "t") #'hsys-org-tags-view)))

  (with-eval-after-load 'bbdb
    (require 'hyrolo nil t)
    ;; Use HyRolo as a Hyperbole-friendly contact/search UI over BBDB.
    (when (commandp 'hyrolo-bbdb-grep)
      (define-key my/hyperbole-bbdb-map (kbd "g") #'hyrolo-bbdb-grep))
    (when (commandp 'hyrolo-bbdb-fgrep)
      (define-key my/hyperbole-bbdb-map (kbd "f") #'hyrolo-bbdb-fgrep)))

  ;; Mail composition (mu4e uses `message-mode' for composing).
  (with-eval-after-load 'message
    (require 'hsmail nil t)
    (when (commandp 'hmail:compose)
      (define-key my/hyperbole-mail-map (kbd "c") #'hmail:compose))))

(provide 'hyperbole-config)
;;; hyperbole-config.el ends here
