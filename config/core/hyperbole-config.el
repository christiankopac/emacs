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
;;
;; Creative uses with Org and Markdown:
;; - Activate any implicit button (URL, path, email, org link, markdown link)
;;   with {C-c h a} or {C-c h RET} from any buffer.
;; - In Org/MD: pathnames like gtd/inbox.org or denote/20250101...org resolve
;;   via hpath:auto-variable-alist (org-directory and .md → org).
;; - C-c h o g: grep across org files (hsys-org-consult-grep).
;; - C-c h o t: tags view across org headlines.
;; - C-c h f: find file with Hyperbole path resolution (supports variables).
;; - C-c h z: Xeft note search; C-c h n: Denote new note (quick from anywhere).
;; - In markdown: same implicit buttons (URLs, paths, mailto) work; use Action
;;   Key on [[link](url)] or [text](path) to follow.
;; - Bare Denote IDs (e.g. 20250101T120000) in Org/MD/any buffer: put point on
;;   the ID and use {C-c h a} to open that note (custom implicit button).

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
      "C-c h a" "Activate button / follow link"
      "C-c h z" "Xeft note search"
      "C-c h n" "Denote (new note)"
      "C-c h f" "Find path (hpath:find)"
      "C-c h o" "Hyperbole (Org)"
      "C-c h o g" "Org grep (consult)"
      "C-c h o t" "Org tags view"
      "C-c h b" "Hyperbole (BBDB)"
      "C-c h m" "Hyperbole (Mail)")))

;; Org integration: avoid taking over `org-meta-return' globally.
;; Hyperbole uses {M-RET} as an Action Key; this setting keeps it constrained
;; to Hyperbole button contexts inside Org buffers.
(setq hsys-org-enable-smart-keys 'buttons)

(when (require 'hyperbole nil t)
  ;; Load core subsystems that provide user-facing commands we bind below.
  (require 'hycontrol nil t)
  (require 'hpath nil t)

  ;; Path resolution for Markdown: .md files under org (e.g. nb/foo.md) resolve
  ;; via org-directory so Hyperbole's pathname implicit button opens them.
  (when (boundp 'hpath:auto-variable-alist)
    (add-to-list 'hpath:auto-variable-alist
                 '("\\.md\\'" . org-directory) t))

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

  ;; Notes (Org/Denote/Xeft): quick access from any buffer.
  (when (fboundp 'xeft)
    (define-key my/hyperbole-map (kbd "z") #'xeft))
  (when (fboundp 'denote)
    (define-key my/hyperbole-map (kbd "n") #'denote))

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

;; ----------------------------------------------------------------------------
;; Custom implicit button: bare Denote ID (e.g. 20250101T120000) opens that note
;; ----------------------------------------------------------------------------
;; In Org, Markdown, or any buffer, put point on a Denote-style timestamp ID
;; and press {C-c h a} (or Hyperbole Action Key) to open that note.
(with-eval-after-load 'denote
  (when (and (featurep 'hyperbole) (fboundp 'denote-get-path-by-id))
    (require 'hbut nil t)
    (require 'hpath nil t)
    (require 'hactypes nil t)
    (when (fboundp 'defib)
      (defib denote-id ()
        "Open the Denote note with the date identifier at point (e.g. 20250101T120000)."
        (let (id start end path)
          (when (save-excursion
                  (skip-chars-backward "0-9T")
                  (setq start (point))
                  (when (looking-at "\\([0-9]\\{8\\}T[0-9]\\{6\\}\\)")
                    (setq id (match-string-no-properties 1))
                    (setq end (match-end 1))
                    id))
            (when (and id (setq path (denote-get-path-by-id id)))
              (ibut:label-set id start end)
              (hact 'link-to-file path)))))))

(provide 'hyperbole-config)
;;; hyperbole-config.el ends here
