;;; emacs.el --- Core Emacs settings

;; ----------------------------------------------------------------------------
;; Basic Editing Settings
;; ----------------------------------------------------------------------------

(setq-default
  tab-width 4 ;; Set tab width to 4 spaces for display
  indent-tabs-mode nil ;; Use spaces instead of tabs for indentation
  fill-column 80 ;; Default line width for text wrapping (M-q)
  scroll-conservatively 10000 ;; Scroll smoothly without jumping
  auto-window-vscroll nil ;; Disable automatic vertical scrolling adjustments (improves performance)
  save-interprogram-paste-before-kill t ;; Save clipboard contents before killing text in Emacs
  apropos-do-all t ;; Make apropos (help search) search more extensively
  mouse-yank-at-point t ;; Paste at point, not at mouse cursor position
  fast-but-imprecise-scrolling t ;; Enable faster scrolling at the cost of some accuracy
  auto-save-default nil ;; Disable auto-save files (#file#)
  create-lockfiles nil ;; Disable lockfiles (.#file)
  make-backup-files t ;; Create backup files (file~)
  kept-new-versions 5 ;; Keep 6 newest versions of backup files
  kept-old-versions 5 ;; Keep 2 oldest versions of backup files
  require-final-newline t ;; Always add newline at end of file
  scroll-margin 0 ;; No margin when scrolling (cursor can reach top/bottom)
  scroll-preserve-screen-position 1 ;; Keep cursor position when scrolling
  backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))) ;; Store all backup files in one directory instead of cluttering directories
  version-control t ;; Enable versioned backups
  delete-old-versions t ;; Delete old backup versions without asking
  history-length 50 ;; Remember last 50 commands
  ; save-place-mode 1 ;; Remember last cursor position in a file
  )

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
      ring-bell-function 'ignore       ;; Disable the annoying bell sound
      use-dialog-box nil               ;; Disable popup dialogs, use minibuffer instead
      use-file-dialog nil              ;; Disable file selection dialogs
      inhibit-compacting-font-caches t ;; Don't compact font caches during GC (improves performance with many fonts)
      highlight-nonselected-windows nil;; Don't highlight text in non-selected windows (improves performance)
      )

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
;; Reload and Restart Emacs
;; ----------------------------------------------------------------------------

;; Reload Emacs configuration
(defun my/reload-emacs-config ()
  "Reload Emacs configuration file."
  (interactive)
  (load-file user-init-file)
  (message "Emacs configuration reloaded!"))

(global-set-key (kbd "C-c e r") 'my/reload-emacs-config)

;; Restart Emacs
(defun my/restart-emacs ()
  "Restart Emacs."
  (interactive)
  (when (yes-or-no-p "Really restart Emacs? ")
    (save-some-buffers)
    (kill-emacs)
    (start-process "emacs" nil "emacs")))

(global-set-key (kbd "C-c e R") 'my/restart-emacs)

;; ----------------------------------------------------------------------------
;; Default Fonts
;; ----------------------------------------------------------------------------

;; (defvar my/font-sans-serif "Open Sans" "Sans Serif font GUI.")

(defvar my/font-serif "ETBookOT" "Default serif font for variable pitch text.")
;; (defvar my/font-serif "Literata" "Default serif font for variable pitch text.")

;; (defvar my/font-monospace "MonoLisa Nerd Font Mono" "Default monospace font for fixed pitch text.")
(defvar my/font-monospace "JuliaMono Nerd Font Mono" "Default monospace font for fixed pitch text.")


(when (display-graphic-p)
  (set-face-attribute 'default nil :family my/font-monospace)
  (set-face-attribute 'variable-pitch nil :family my/font-serif)
  (set-face-attribute 'fixed-pitch nil :family my/font-monospace))

(provide 'emacs-config)
