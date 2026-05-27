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
  save-interprogram-paste-before-kill nil ;; Off: triggers a clipboard read on every kill, sluggish across the WSL bridge
  apropos-do-all t ;; Make apropos (help search) search more extensively
  mouse-yank-at-point t ;; Paste at point, not at mouse cursor position
  fast-but-imprecise-scrolling t ;; Enable faster scrolling at the cost of some accuracy
  auto-save-default t ;; Enable auto-save files (#file#) - prevents data loss
  auto-save-interval 100 ;; Auto-save after every 100 keystrokes
  auto-save-timeout 30 ;; Auto-save after 30 seconds of idle time
  auto-save-visited-file-name nil ;; Save to #file# instead of overwriting (safer)
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
  ;; history-length set below in savehist-mode block (200)
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
;; Modern Emacs niceties (free with Emacs 30+)
;; ----------------------------------------------------------------------------

;; Restrict the VC backend probe to Git. Default tries CVS / SVN / Bzr /
;; Hg / Mtn / RCS / SCCS / SRC on every file open — adds 10–30ms per
;; open, more on slow disks (WSL DrvFs).
(setq vc-handled-backends '(Git))

;; `repeat-mode' lets you press the trailing key of a prefix command to
;; repeat it: `C-x o o o' cycles windows, `C-x { { {' resizes, etc.
(when (fboundp 'repeat-mode) (repeat-mode 1))

;; Pixel-precise smooth scrolling (Emacs 29+). WSLg's stock line-by-line
;; scroll feels especially janky; this fixes it. No effect in TTY.
(when (and (display-graphic-p) (fboundp 'pixel-scroll-precision-mode))
  (pixel-scroll-precision-mode 1)
  (setq pixel-scroll-precision-large-scroll-height 40.0
        pixel-scroll-precision-interpolation-factor 30.0))

;; Persist cursor position across file reopens, and minibuffer / M-x
;; history across sessions.
(save-place-mode 1)
(setq save-place-file (expand-file-name "places" user-emacs-directory)
      save-place-limit 400)
(savehist-mode 1)
(setq history-length 200
      savehist-additional-variables
      '(kill-ring search-ring regexp-search-ring))

;; recentf: bigger list, write less often, ignore noisy paths so the
;; recentf list stays useful instead of being 50% elpaca/eln-cache cruft.
(setq recentf-max-saved-items 300
      recentf-max-menu-items 50
      recentf-auto-cleanup 300            ; cleanup every 5 min, not on every save
      recentf-exclude
      '("/elpaca/" "/eln-cache/" "/.git/" "/auto-save-list/" "/backups/"
        "/recentf$" "/bookmarks$" "/transient/" "/COMMIT_EDITMSG$"
        "/.cache/" "/tmp/" "/.local/share/Trash/" "\\.gpg\\'"))
(add-hook 'after-init-hook #'recentf-mode)

;; Perf: assume left-to-right text in code buffers — skips Emacs's
;; expensive bidirectional reorder pass on lines without RTL chars.
(setq-default bidi-paragraph-direction 'left-to-right
              bidi-inhibit-bpa t)

;; Perf: don't case-fold when matching auto-mode-alist regexes (most are
;; already case-sensitive); shaves a tiny but free amount off every open.
(setq auto-mode-case-fold nil)

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

;; Font definitions are in ck-emacs-modules/ck-fonts.el with fallback support
;; These are kept here for backward compatibility but will be overridden by ck-fonts.el
(unless (boundp 'my/font-serif)
  (defvar my/font-serif "Literata" "Default serif font for variable pitch text."))
(provide 'ck-core)