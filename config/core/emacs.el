;;; emacs.el --- Core Emacs settings

;; ----------------------------------------------------------------------------
;; Basic Editing Settings
;; ----------------------------------------------------------------------------

(setq-default
  ;; Set tab width to 4 spaces for display
  tab-width 4
  ;; Use spaces instead of tabs for indentation
  indent-tabs-mode nil
  ;; Default line width for text wrapping (M-q)
  fill-column 80
  ;; Scroll smoothly without jumping
  scroll-conservatively 10000
  ;; Disable automatic vertical scrolling adjustments (improves performance)
  auto-window-vscroll nil
  ;; Save clipboard contents before killing text in Emacs
  save-interprogram-paste-before-kill t
  ;; Make apropos (help search) search more extensively
  apropos-do-all t
  ;; Paste at point, not at mouse cursor position
  mouse-yank-at-point t
  ;; Enable faster scrolling at the cost of some accuracy
  fast-but-imprecise-scrolling t
  ;; Disable auto-save files (#file#)
  auto-save-default nil
  ;; Disable lockfiles (.#file)
  create-lockfiles nil
  ;; Create backup files (file~)
  make-backup-files t
  ;; Keep 6 newest versions of backup files
  kept-new-versions 6
  ;; Keep 2 oldest versions of backup files
  kept-old-versions 2
  ;; Always add newline at end of file
  require-final-newline t
  ;; No margin when scrolling (cursor can reach top/bottom)
  scroll-margin 0
  ;; Keep cursor position when scrolling
  scroll-preserve-screen-position 1
  ;; Store all backup files in one directory instead of cluttering directories
  backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
  ;; Enable versioned backups
  version-control t
  ;; Delete old backup versions without asking
  delete-old-versions t)

;; ----------------------------------------------------------------------------
;; UI Elements
;; ----------------------------------------------------------------------------

;; Disable tool bar and menu bar
(tool-bar-mode -1)
(menu-bar-mode -1)

;; ----------------------------------------------------------------------------
;; Better Search
;; ----------------------------------------------------------------------------

;; Highlight search matches
(setq search-highlight t
      ;; Allow whitespace to match any sequence of whitespace in searches
      search-whitespace-regexp ".*?")
;; Enable flexible whitespace matching in incremental search
(setq isearch-lax-whitespace t
      ;; Disable flexible whitespace matching in regexp search (for precision)
      isearch-regexp-lax-whitespace nil)

;; ----------------------------------------------------------------------------
;; Better Defaults
;; ----------------------------------------------------------------------------

;; Use 'y' and 'n' instead of 'yes' and 'no'
(setq use-short-answers t
      ;; Disable the annoying bell sound
      ring-bell-function 'ignore
      ;; Disable popup dialogs, use minibuffer instead
      use-dialog-box nil
      ;; Disable file selection dialogs
      use-file-dialog nil
      ;; Don't compact font caches during GC (improves performance with many fonts)
      inhibit-compacting-font-caches t
      ;; Don't highlight text in non-selected windows (improves performance)
      highlight-nonselected-windows nil)

;; ----------------------------------------------------------------------------
;; Useful Modes
;; ----------------------------------------------------------------------------

;; Automatically insert matching closing brackets, quotes, etc.
(electric-pair-mode t)
;; Highlight the current line
(global-hl-line-mode t)
;; Replace selected text when typing
(delete-selection-mode t)

;; ----------------------------------------------------------------------------
;; Default Fonts
;; ----------------------------------------------------------------------------

;; NOTE: Fonts are now managed by fontaine (see config/ui/fonts-ligatures.el)
;; This section is kept for reference but commented out to avoid conflicts.
;; 
(when (display-graphic-p)
  (set-face-attribute 'default nil :family my/font-mono)
  (set-face-attribute 'variable-pitch nil :family my/font-serif)
  (set-face-attribute 'fixed-pitch nil :family my/font-mono))

(provide 'emacs-config)
