;;; init-modular.el --- Modular Emacs configuration
;;
;;;; Commentary:
;;;; My personal modular Emacs configuration for org-mode, note-taking, coding, and writing.
;;
;;;; Code:

;; ----------------------------------------------------------------------------
;; BOILERPLATE: Early Optimizations
;; ----------------------------------------------------------------------------

(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 100 1024 1024)
                  gc-cons-percentage 0.1)))

;; ----------------------------------------------------------------------------
;; BOILERPLATE: Custom Macros
;; ----------------------------------------------------------------------------

;; Define custom-set-faces! macro for Doom-style face configuration
(defmacro custom-set-faces! (&rest faces)
  "Set custom faces with Doom-style syntax.
FACES is a list of face specifications in the format (FACE :attribute value ...)."
  `(custom-set-faces
    ,@(mapcar (lambda (face-spec)
                (let ((face (car face-spec))
                      (attrs (cdr face-spec)))
                  `'(,face ((t ,attrs)))))
              faces)))

;; ----------------------------------------------------------------------------
;; BOILERPLATE: Elpaca Package Manager Configuration
;; ----------------------------------------------------------------------------

(setq org-element-use-cache nil)
(defvar elpaca-installer-version 0.11)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support for elpaca
(elpaca elpaca-use-package (elpaca-use-package-mode))

;; Block until current queue is processed
(elpaca-wait)

;; ----------------------------------------------------------------------------
;; Core Settings and Optimizations
;; ----------------------------------------------------------------------------

;; Performance optimizations
(setq read-process-output-max (* 1024 1024)
      process-adaptive-read-buffering nil)

;; DPI scaling for high-resolution displays
(setq x-gtk-use-system-tooltips nil
      frame-resize-pixelwise t
      frame-inhibit-implied-resize t)

;; Basic UI settings
(show-paren-mode t)
;; Only disable scroll bars in GUI environments
(when (and (display-graphic-p) (fboundp 'scroll-bar-mode))
  (condition-case nil
      (scroll-bar-mode -1)
    (error nil)))
(when (fboundp 'menu-bar-mode)
  (menu-bar-mode -1))    ; Also fixed: use -1 instead of nil
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))    ; Also fixed: use -1 instead of nil
(setq inhibit-startup-screen 1)

;; Add config subdirectories to load-path
(add-to-list 'load-path (expand-file-name "config/core" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/ui" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/org" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/email" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/dev" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/writing" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/media" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "config/functions" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Essential Packages
;; ----------------------------------------------------------------------------

(use-package emacs
  :config
  (load-file (expand-file-name "config/core/emacs.el" user-emacs-directory)))

;; ----------------------------------------------------------------------------
;; UI: Themes Packages (no config needed, just ensure)
;; ----------------------------------------------------------------------------

(use-package modus-themes :defer t :ensure t)
(use-package poet-theme :ensure t :defer t)
(use-package doric-themes :ensure t :defer t)
(use-package ef-themes :ensure t :defer t)
(use-package leuven-theme :ensure t :defer t)
;; (use-package standard-themes :ensure t :defer t)
(use-package everforest
  :ensure (:host github 
                 :repo "Theory-of-Everything/everforest-emacs"
                 :files ("*.el"))
  :defer t)


;; ----------------------------------------------------------------------------
;; UI: Completion Packages
;; ----------------------------------------------------------------------------

(use-package vertico :ensure t)
(use-package corfu :ensure t)
(use-package orderless :ensure t)
(use-package marginalia :ensure t)
(use-package embark :ensure t)
(use-package consult :ensure t)
(use-package embark-consult :ensure t :after (consult embark))
(use-package cape :ensure t)

;; Load completion config
(load-file (expand-file-name "config/ui/completion.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; UI: Icons
;; ----------------------------------------------------------------------------

(use-package all-the-icons :ensure t :defer t)
;; NOTE: all-the-icons-dired disabled - conflicts with dirvish icons
;; (use-package all-the-icons-dired :ensure t)
(use-package nerd-icons :ensure t)

(load-file (expand-file-name "config/ui/icons.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; UI: Fonts & Ligatures
;; ----------------------------------------------------------------------------

(use-package fontaine :ensure t :if (display-graphic-p))

;; (use-package ligature :ensure t :after org)

;; (use-package ox-tufte :ensure t)

;; Load font configuration after fontaine is ready (only in graphical mode)
(when (display-graphic-p)
  (with-eval-after-load 'fontaine
    (load-file (expand-file-name "config/ui/fonts-ligatures.el" user-emacs-directory))))

(use-package show-font
  :ensure t
  :bind
  (("C-c s f" . show-font-select-preview)
   ("C-c s t" . show-font-tabulated)))

;; ----------------------------------------------------------------------------
;; UI: Menus & Dashboard
;; ----------------------------------------------------------------------------

(use-package transient :ensure t)
(use-package dashboard :ensure t)
(use-package spacious-padding :ensure t)
(use-package mixed-pitch :ensure t)
(use-package helpful :ensure t)
(use-package smartparens :ensure t)
(use-package expand-region :ensure t)
(use-package which-key :ensure t)
(use-package beacon :ensure t)
(use-package dirvish :ensure t)
(use-package recentf :ensure nil)
(use-package bookmark :ensure nil)
(use-package vundo :ensure t)
(use-package ace-window :ensure t)
(use-package avy :ensure t :after ace-window)
(use-package grip-mode :ensure t :after markdown-mode)
(use-package helm :ensure t)
(use-package helm-org :ensure t :after (helm org))
(use-package multiple-cursors :ensure t)
(use-package mood-line 
  :ensure t
  :config
  (setq mood-line-glyph-alist mood-line-glyphs-fira-code
        mood-line-show-encoding-information nil
        mood-line-show-eol-style nil
        mood-line-show-cursor-point t
        mood-line-right-align nil
        mood-line-percent-position nil)
  ;; Customize faces (only if they exist)
  (when (facep 'mood-line-modified)
    (set-face-attribute 'mood-line-modified nil
                        :foreground "#d08770"
                        :weight 'bold))
  (when (facep 'mood-line-status-neutral)
    (set-face-attribute 'mood-line-status-neutral nil
                        :foreground "#88c0d0"))
  (when (facep 'mood-line-status-info)
    (set-face-attribute 'mood-line-status-info nil
                        :foreground "#81a1c1"))
  (when (facep 'mood-line-status-success)
    (set-face-attribute 'mood-line-status-success nil
                        :foreground "#a3be8c"))
  (when (facep 'mood-line-status-warning)
    (set-face-attribute 'mood-line-status-warning nil
                        :foreground "#ebcb8b"))
  (when (facep 'mood-line-status-error)
    (set-face-attribute 'mood-line-status-error nil
                        :foreground "#bf616a"))
  (when (facep 'mood-line-encoding)
    (set-face-attribute 'mood-line-encoding nil
                        :inherit 'mood-line-unimportant))
  ;; Enable mood-line
  (mood-line-mode 1))
(use-package openwith 
  :ensure t
  :init
  ;; Load openwith eagerly (needs to be active before opening files)
  (add-hook 'after-init-hook 
            (lambda () 
              (require 'openwith)
              (load-file (expand-file-name "config/ui/file-associations.el" user-emacs-directory)))))

;; Load UI configuration files (after Elpaca loads packages)
(with-eval-after-load 'dashboard
  (load-file (expand-file-name "config/ui/dashboard.el" user-emacs-directory)))
(load-file (expand-file-name "config/ui/ui-enhancements.el" user-emacs-directory))
(load-file (expand-file-name "config/ui/navigation.el" user-emacs-directory))
(load-file (expand-file-name "config/ui/editing.el" user-emacs-directory))

;; Load dirvish config after package is ready
(with-eval-after-load 'dirvish
  (load-file (expand-file-name "config/ui/file-associations.el" user-emacs-directory)))

(use-package clipetty
  :ensure t
  :hook (after-init . global-clipetty-mode))

;; Context-menu (GUI only)
(when (display-graphic-p)
  (context-menu-mode))

(setq global-auto-revert-non-file-buffers t) ;; auto-revert non-file buffers
(global-auto-revert-mode 1)  ;; emacs watches for changes to files and updates the buffer
(setq auto-revert-verbose nil       ;; don't show messages
      auto-revert-use-notify nil    ;; don't show notifications
      auto-revert-stop-on-user-input nil) ;; don't stop on user input

;; File Conversion Variables
(defvar my/pandoc-input-formats
  '("org" "markdown-yaml_metadata_block" "plain" "html" "latex")
  "Supported input formats for file conversion.")
(defvar my/pandoc-output-formats
  '("org" "markdown" "html" "latex" "plain")
  "Supported output formats for file conversion.")

;; ----------------------------------------------------------------------------
;; Org Packages
;; ----------------------------------------------------------------------------

(use-package org :ensure t)
(use-package org-agenda :after org)
(use-package org-super-agenda :ensure t :after org-agenda)
(use-package org-habit :after org)
(use-package org-habit-stats :ensure t)
(use-package org-edna :ensure t :after (org seq))

(setq org-gtd-update-ack "3.0.0")
(use-package org-gtd :ensure t :after (org transient))

;; (use-package org-journal :ensure t)

;; Load org configurations
(load-file (expand-file-name "config/org/org-core.el" user-emacs-directory))

;; All remaining org packages (extensions)
(use-package org-appear :ensure t :hook (org-mode . org-appear-mode))
(use-package org-cliplink :ensure t)
(use-package org-download :ensure t :after org)
(use-package toc-org :ensure t :hook (org-mode . toc-org-mode))
(use-package org-transclusion :ensure t :after org)
(use-package org-pomodoro :ensure t)
(use-package org-ql :ensure t :after org)
(use-package org-web-tools :ensure t)
(use-package org-modern :ensure t :hook (org-mode . org-modern-mode))

;; Load org extensions configuration
(with-eval-after-load 'org
  (load-file (expand-file-name "config/org/org-extensions.el" user-emacs-directory)))

;; Export packages
(use-package ox :ensure nil :after org)
(use-package ox-hugo :ensure t :defer t :after ox)
(use-package pandoc-mode :ensure t :hook ((markdown-mode . pandoc-mode) (org-mode . pandoc-mode)))
(use-package ox-pandoc :ensure t :defer t :after pandoc)

;; Load org export configuration
(with-eval-after-load 'org
  (load-file (expand-file-name "config/org/org-export.el" user-emacs-directory)))


;; ----------------------------------------------------------------------------
;; Roam Packages
;; ----------------------------------------------------------------------------

;; (use-package org-roam :ensure t :after org)
;; (use-package org-roam-ui :ensure t :after org-roam)

;; Load org-roam configuration
;; (with-eval-after-load 'org-roam
;;  (load-file (expand-file-name "config/org/org-roam.el" user-emacs-directory)))

;; ----------------------------------------------------------------------------
;; Denote Packages
;; ----------------------------------------------------------------------------

;; Install denote packages first
(use-package denote :ensure t)
(use-package denote-org :ensure t :after denote)
(use-package denote-silo :ensure t :after denote)
(use-package consult-denote :ensure t :after denote)
(use-package denote-markdown :ensure t :after denote)
(use-package denote-menu :ensure t :after denote)
(use-package denote-explore :ensure t :after (denote denote-regexp))
(use-package denote-sequence :ensure t :after denote)
(use-package denote-journal :ensure t :after denote)

;; Load denote configuration after Elpaca initialization
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "config/org/denote.el" user-emacs-directory))))

;; ----------------------------------------------------------------------------
;; Language Specific Packages
;; ----------------------------------------------------------------------------

(use-package typescript-mode :ensure t :mode "\\.ts\\'")
(use-package web-mode :ensure t :mode ("\\.html?\\'" "\\.css\\'" "\\.jsx?\\'" "\\.tsx?\\'"))
(use-package go-mode :ensure t :mode "\\.go\\'")
(use-package fish-mode :ensure t :mode "\\.fish\\'")

;; ----------------------------------------------------------------------------
;; Development Packages
;; ----------------------------------------------------------------------------

(use-package sideline :ensure t :after (lsp flycheck) :defer t)
(use-package project :ensure nil)
(use-package flycheck :ensure t)
(use-package sideline-flycheck :after (sideline flycheck) :ensure t)
(use-package hl-todo :ensure t :hook (prog-mode . hl-todo-mode))
(use-package tree-sitter :ensure t)
(use-package tree-sitter-langs :ensure t :after tree-sitter)
(use-package treesit-auto :ensure t)

;; ----------------------------------------------------------------------------
;; Formatting Packages
;; ----------------------------------------------------------------------------

(use-package format-all :ensure t)
(use-package apheleia :ensure t)

;; ----------------------------------------------------------------------------
;; Version Control Packages
;; ----------------------------------------------------------------------------

(use-package magit :after transient :ensure t :demand t)
(use-package diff-hl :ensure t :after magit)
(use-package git-timemachine :ensure t)
(use-package git-messenger :ensure t :after magit)
(use-package forge :ensure t :after (magit))

;; ----------------------------------------------------------------------------
;; AI Packages
;; ----------------------------------------------------------------------------

(use-package gptel :ensure t)

(use-package copilot
  :ensure t
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main")
  :hook (prog-mode . copilot-mode))

;; Load AI tools configuration
(load-file (expand-file-name "config/ai/ai-tools.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Terminal Packages
;; ----------------------------------------------------------------------------

(use-package eat :ensure t :defer t)
(use-package exec-path-from-shell :ensure t)

;; Load development configuration
(load-file (expand-file-name "config/dev/development.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Writing
;; ----------------------------------------------------------------------------

(use-package markdown-mode :ensure t)
(use-package text-mode :ensure nil)
(use-package dictionary :ensure t)
(use-package pdf-tools :ensure t)
(use-package nov :ensure t :mode ("\\.epub\\'" . nov-mode))
(use-package olivetti :ensure t)
(use-package jinx :ensure t :hook (emacs-startup . global-jinx-mode))

;; Load writing configuration
(load-file (expand-file-name "config/writing/writing.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Media & Music
;; ----------------------------------------------------------------------------

(use-package emms :ensure t :defer t)
(use-package listen :ensure t :defer t)

;; Load media configuration
(with-eval-after-load 'emms
  (load-file (expand-file-name "config/media/music.el" user-emacs-directory)))
(with-eval-after-load 'listen
  (load-file (expand-file-name "config/media/music.el" user-emacs-directory)))

;; ----------------------------------------------------------------------------
;; E-Mail & Contacts
;; ----------------------------------------------------------------------------

(use-package mu4e :ensure nil :defer t :commands (mu4e mu4e-compose-new mu4e-update-index))
(use-package message :ensure nil :defer t)
(use-package smtpmail :ensure nil :defer t)
(use-package bbdb :ensure t :defer t :commands (bbdb bbdb-search-name bbdb-complete-mail))
(use-package consult-mu :ensure nil :after (mu4e consult))

;; Load email configuration
(with-eval-after-load 'mu4e
  (load-file (expand-file-name "config/email/email.el" user-emacs-directory)))

;; ----------------------------------------------------------------------------
;; Machine Specific Configuration
;; ----------------------------------------------------------------------------

;; Clipboard settings
(defvar my/clipboard-wayland-command "wl-copy")
(defvar my/clipboard-wayland-paste-command "wl-paste")
(defvar my/clipboard-x11-command "xclip")

;; Terminal settings
(setq term-file-prefix nil)
(add-to-list 'term-file-aliases `(,"ghostty" . ,"xterm-256color"))

;; Terminal-specific settings (only in terminal mode)
(unless (display-graphic-p)
  (setq xterm-extra-capabilities '(setSelection getSelection))
  (xterm-mouse-mode 1)
  (global-set-key [mouse-4] 'scroll-down-line)
  (global-set-key [mouse-5] 'scroll-up-line))

;; ----------------------------------------------------------------------------
;; Custom Functions
;; ----------------------------------------------------------------------------

(load-file (expand-file-name "config/functions/custom-functions.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Global Keybindings
;; ----------------------------------------------------------------------------

(global-set-key (kbd "C-c b") 'consult-buffer)
;; C-c f f is a non-prefix key, so C-c f cannot be a prefix
;; (global-set-key (kbd "C-c f") 'consult-fd)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c c") 'org-capture)

;; Theme keybindings
(global-set-key (kbd "C-c t t") 'my/toggle-theme)
(global-set-key (kbd "C-c t d") 'my/use-default-theme)
(global-set-key (kbd "C-c t g") 'my/load-gui-theme)
(global-set-key (kbd "C-c t SPC") 'my/toggle-default-theme)
(global-set-key (kbd "C-c t r") 'my/reset-all-themes)
(global-set-key (kbd "C-c t f") 'my/fix-poet-theme-issues)
(global-set-key (kbd "C-c t b") 'my/load-theme-for-current-buffer)

;; Transparency keybindings (GUI only)
(when (display-graphic-p)
  (global-set-key (kbd "C-c t T") 'my/toggle-transparency))

;; Display info keybinding
(global-set-key (kbd "C-c t i") 'my/display-info)

;; ----------------------------------------------------------------------------
;; Final Optimizations
;; ----------------------------------------------------------------------------

;; Load custom file if it exists
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

;; Startup message
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; ============================================================================
;; Force Disable Scrollbars - Final attempt
;; ============================================================================
(add-hook 'elpaca-after-init-hook
          (lambda ()
            ;; Force disable scrollbars (in case something re-enabled them)
            ;; Call the functions, don't use setq on them!
            (when (fboundp 'scroll-bar-mode)
              (scroll-bar-mode -1))
            (when (fboundp 'horizontal-scroll-bar-mode)
              (horizontal-scroll-bar-mode -1))
            ;; Disable on all frames
            (dolist (frame (frame-list))
              (set-frame-parameter frame 'vertical-scroll-bars nil)
              (set-frame-parameter frame 'horizontal-scroll-bars nil))))

;; ============================================================================
;; Load Theme - File-type-specific theme system
;; ============================================================================
(add-hook 'elpaca-after-init-hook
          (lambda ()
            ;; Only load custom theme in GUI, use default theme in terminal
            (load-theme 'poet-dark t)
            (when (display-graphic-p)
              ; (load-theme 'everforest-hard-dark t))))
              (load-theme 'poet-dark t))))

(provide 'init)
;;; init.el ends here
