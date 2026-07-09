;;; early-init.el --- Pre-init optimizations -*- lexical-binding: t -*-

;; ----------------------------------------------------------------------------
;; GC + I/O hot-path: defer until after init
;; ----------------------------------------------------------------------------
;; Big GC threshold during startup is half the trick; the other half is
;; suppressing `file-name-handler-alist' so every loaded .el doesn't run
;; through the TRAMP / image / archive handler regex chain.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(defvar ck/early--file-name-handler-alist file-name-handler-alist)
;; Keep jka-compr: built-in libs ship as .el.gz, and with `load-prefer-newer'
;; a newer .el.gz beats its .elc — loading it without the decompression
;; handler reads raw gzip bytes as lisp ("void: \213" startup errors).
(setq file-name-handler-alist
      (list (rassq 'jka-compr-handler file-name-handler-alist)))

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq file-name-handler-alist
                  (delete-dups (append file-name-handler-alist
                                       ck/early--file-name-handler-alist)))))

;; ----------------------------------------------------------------------------
;; Package manager: hand off to Elpaca in init.el
;; ----------------------------------------------------------------------------
(setq package-enable-at-startup nil)

;; Prevent built-in Org from leaking onto load-path before Elpaca's Org wins.
(setq load-path (remove (expand-file-name "lisp/org" data-directory) load-path))
(setq load-path (remove (expand-file-name "lisp/org" installation-directory) load-path))

;; ----------------------------------------------------------------------------
;; Native compilation
;; ----------------------------------------------------------------------------
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (setq native-comp-async-report-warnings-errors 'silent
        native-comp-deferred-compilation t
        native-comp-jit-compilation t))
(setq load-prefer-newer t)

;; ----------------------------------------------------------------------------
;; UI: kill the flash, set frame parameters once
;; ----------------------------------------------------------------------------
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      inhibit-splash-screen t
      frame-inhibit-implied-resize t
      frame-resize-pixelwise t)

;; Single source of truth for default frame parameters. Both the initial
;; frame and any frame made later (incl. emacsclient) inherit this.
(setq default-frame-alist
      '((vertical-scroll-bars   . nil)
        (horizontal-scroll-bars . nil)
        (menu-bar-lines         . 0)
        (tool-bar-lines         . 0)
        (fullscreen             . maximized)
        (internal-border-width  . 0)
        (right-divider-width    . 0)))

;; Tool/menu/scroll bars: turn off via the *-default vars so they never
;; appear in the first place. The mode functions in init.el are then no-ops.
(setq menu-bar-mode nil
      tool-bar-mode nil
      scroll-bar-mode nil)
