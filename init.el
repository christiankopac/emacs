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
;; Must match `doc/installer.el' in your Elpaca checkout (see *Warnings* if it drifts).
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
;; Must match where clones live (Elpaca default: `elpaca/sources/`). Using `repos/`
;; here breaks startup if packages were installed under `sources/` (typical after Elpaca updates).
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
;; If MELPA's sparse clone failed, `cache/melpa/recipes' is missing and Elpaca errors.
(let* ((melpa-dir (expand-file-name "cache/melpa" elpaca-directory))
       (recipes-dir (expand-file-name "recipes" melpa-dir)))
  (when (and (file-exists-p melpa-dir) (not (file-directory-p recipes-dir)))
    (delete-directory melpa-dir t)))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
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
;; Early Stub Functions - Prevent errors during package loading
;; ----------------------------------------------------------------------------

;; Stub function to prevent errors if icons--register is called before icons are loaded
;; This prevents "void function icons--register" errors during startup
;; Must be defined BEFORE any config files are loaded
(when (not (fboundp 'icons--register))
  (defun icons--register (&rest _args)
    "Stub function for icons--register to prevent errors during initialization.
This will be replaced by the actual function when icon packages are loaded."
    nil))

;; Compatibility stub for org-with-undo-amalgamate
;; This function was removed in newer versions of Org mode, but some code still calls it
;; We provide a compatibility macro that just executes the body normally
(when (not (fboundp 'org-with-undo-amalgamate))
  (defmacro org-with-undo-amalgamate (&rest body)
    "Compatibility stub for org-with-undo-amalgamate.
This macro was removed in newer Org versions. It now just executes BODY normally."
    `(progn ,@body)))

;; Define org-gtd-inbox early so configs that reference it (hyperbole, org, etc.) don't error
;; The real value is set in config/org/org-extensions.el; this ensures the symbol exists.
(when (not (boundp 'org-gtd-inbox))
  (defvar org-gtd-inbox nil "Path to GTD inbox file. Set in org-extensions.el."))

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
(use-package all-the-icons-dired
  :ensure t
  :commands (all-the-icons-dired-mode)
  :hook (dired-mode . (lambda ()
                        ;; Don't enable if `dirvish' is managing icons in dired buffers
                        (unless (featurep 'dirvish)
                          (all-the-icons-dired-mode 1)))))
(use-package nerd-icons :ensure t)

(load-file (expand-file-name "config/ui/ui-icons.el" user-emacs-directory))

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
(use-package dashboard :ensure t :after (nerd-icons)
  :config
  ;; Ensure nerd-icons is loaded before dashboard initializes
  (unless (featurep 'nerd-icons)
    (require 'nerd-icons nil t)))
(use-package spacious-padding :ensure t)
(use-package mixed-pitch :ensure t)
(use-package helpful :ensure t)
(use-package smartparens :ensure t)
(use-package expand-region :ensure t)
(use-package which-key :ensure t)
(use-package hyperbole :ensure t)
(use-package beacon :ensure t)

(use-package dirvish
  :ensure t
  :config
  ;; Replace vanilla dired with dirvish for an improved UX, if available
  (when (fboundp 'dirvish-override-dired-mode)
    (dirvish-override-dired-mode))
  ;; NOTE: Do NOT enable `dirvish-peek-mode` globally.
  ;; It previews while narrowing in the minibuffer (e.g. `find-file`) and can
  ;; steal the main window away from Vertico.
  ;; Useful quick-access bookmarks
  (setq dirvish-quick-access-entries
        '(("h" "~/" "Home")
          ("e" "~/.config/emacs/" "Emacs config"))))

(use-package dired
  :ensure nil
  :defer t
  :init
  (setq dired-recursive-copies 'always
        dired-recursive-deletes 'always
        delete-by-moving-to-trash t
        ;; Show long ISO timestamps and human-readable sizes in listings
        ;; Note: if your `ls` (e.g., eza) doesn't support --time-style this may be ignored.
        dired-listing-switches "-Alh --time-style=long-iso"
        dired-dwim-target t
        dired-auto-revert-buffer #'dired-directory-changed-p
        dired-make-directory-clickable t
        dired-free-space nil
        dired-mouse-drag-files t
        dired-guess-shell-alist-user
        '(("\\.\\(png\\|jpe?g\\|tiff\\)\\'" "feh" "xdg-open")
          ("\\.\\(svg\\|gif\\)\\'" "xdg-open")
          ("\\.\\(pdf\\|epub\\)\\'" "xdg-open")
          ("\\.\\(mp[34]\\|m4a\\|ogg\\|flac\\|webm\\|mkv\\)\\'" "mpv" "xdg-open")
          ("\\.\\(zip\\|tar\\.gz\\|tar\\.xz\\|tgz\\)\\'" "xdg-open")
          ("\\.\\(docx?\\|xlsx?\\|pptx?\\)\\'" "xdg-open")
          (".*" "xdg-open")))
  :config
  (add-hook 'dired-mode-hook #'dired-hide-details-mode)
  (add-hook 'dired-mode-hook #'hl-line-mode)
  ;; Keep Dired visually minimal in the *main buffer*.
  ;; We still generate long `ls -l` output for Dired internals, but hide it by default.
  (setq dired-hide-details-hide-symlink-targets nil
        ;; Hide the leading “total …” line for extra minimalism.
        dired-hide-details-hide-information-lines t))

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

;; Minimal emoji mode-line enhancements (modern, minimal)
(with-eval-after-load 'mood-line
  ;; Prefer Noto Color Emoji if available for colorful emoji support
  (when (member "Noto Color Emoji" (font-family-list))
    (set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji") nil 'prepend))

  (defface my/mode-line-emoji-face
    '((t :inherit mode-line :weight bold))
    "Face for the emoji in the mode-line.")

  (defvar my/mode-line-emoji-alist
    '((emacs-lisp-mode . "λ")
      (python-mode . "🐍")
      (org-mode . "📝")
      (org-agenda-mode . "📅")
      (markdown-mode . "📰")
      (js-mode . "✨")
      (typescript-mode . "🟦")
      (rust-mode . "🦀")
      (go-mode . "🐹")
      (sh-mode . "🐚")
      (eshell-mode . "🐚")
      (vterm-mode . "🖥️")
      (term-mode . "🖥️")
      (dired-mode . "📁")
      (magit-status-mode . "🔀")
      (help-mode . "❓")
      (compilation-mode . "⚙️")
      (sql-mode . "🗄️")
      (default . "📄"))
    "Alist mapping major-mode to an emoji.")

  (defvar my/messages-unread-count 0
    "Count of unread messages since the last view of the *Messages* buffer.")

  (defun my/_increment-messages-unread (&rest _args)
    "Increment the unread messages counter when `message' is called."
    (setq my/messages-unread-count (1+ (or my/messages-unread-count 0))))

  (defun my/reset-messages-unread (&rest _args)
    "Reset messages unread counter (called when user views messages)."
    (setq my/messages-unread-count 0))

  ;; Hook into message generation and message viewing
  (advice-add 'message :after #'my/_increment-messages-unread)
  (advice-add 'view-echo-area-messages :after #'my/reset-messages-unread)
  ;; Also reset when *Messages* is displayed
  (defun my/reset-if-messages-buffer-showing (&rest args)
    (let ((buf (if (bufferp (car args)) (car args) (get-buffer (car args)))))
      (when (and buf (string= (buffer-name buf) "*Messages*"))
        (my/reset-messages-unread))))
  (advice-add 'switch-to-buffer :after #'my/reset-if-messages-buffer-showing)
  (advice-add 'display-buffer :after (lambda (buf &rest _) (my/reset-if-messages-buffer-showing buf)))

  (defun my/mode-line-emoji-for-mode ()
    "Return an emoji for the current buffer.
Checks for *Messages* / notification buffers first, then major mode (using derived-mode-p).")

  (defun my/mode-line-emoji-for-mode ()
    (cond
     ;; Messages or notification buffers (show count when > 0)
     ((or (> (or my/messages-unread-count 0) 0)
          (string-match-p "\*Messages?\*\|\*Notifications?\*\|\*alerts?\*" (buffer-name)))
      (let ((count (or my/messages-unread-count 0)))
        (if (> count 0)
            (format "🔔%d" count)
          "🔔")))
     ;; Match by derived major mode
     (t
      (let ((res (catch 'found
                   (dolist (pair my/mode-line-emoji-alist)
                     (when (and (symbolp (car pair)) (derived-mode-p (car pair)))
                       (throw 'found (cdr pair))))
                   nil)))
        (or res (cdr (assoc 'default my/mode-line-emoji-alist)))))))

  (defun my/mode-line-emoji ()
    (let* ((emoji (my/mode-line-emoji-for-mode))
           (state (cond (buffer-read-only "🔒")
                        ((buffer-modified-p) "✏️")
                        (t "✅"))))
      (concat " " (propertize emoji 'face 'my/mode-line-emoji-face) " " state " ")))

  ;; Only add once
  (unless (member '(:eval (my/mode-line-emoji)) mode-line-format)
    (setq-default mode-line-format
                  (cons '(:eval (my/mode-line-emoji)) mode-line-format))))

(use-package openwith 
  :ensure t
  :init
  ;; Load openwith eagerly (needs to be active before opening files)
  (add-hook 'after-init-hook 
            (lambda () 
              (require 'openwith)
              (load-file (expand-file-name "config/ui/file-associations.el" user-emacs-directory)))))

;; Load UI configuration files (after Elpaca loads packages)
;; Load dashboard.el after dashboard package is available
(with-eval-after-load 'dashboard
  (condition-case err
      (load-file (expand-file-name "config/ui/dashboard.el" user-emacs-directory))
    (error (message "Warning: Could not load dashboard.el - %s" (error-message-string err)))))
(load-file (expand-file-name "config/ui/ui-enhancements.el" user-emacs-directory))
(load-file (expand-file-name "config/ui/navigation.el" user-emacs-directory))
(load-file (expand-file-name "config/ui/editing.el" user-emacs-directory))

;; Load Hyperbole configuration after Elpaca initialization (ensures package is installed).
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "config/core/hyperbole-config.el" user-emacs-directory))))

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
(setq org-gtd-update-ack "4.0.0")
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
(use-package org-modern :ensure t :defer t)
;; org-modern is configured in config/org/org-extensions.el to only enable in GUI mode

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

;; Load ox-hugo configuration for Hugo website workflow
(with-eval-after-load 'ox-hugo
  (load-file (expand-file-name "config/org/ox-hugo.el" user-emacs-directory)))


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

;; ----------------------------------------------------------------------------
;; Xeft Package - Fast note search and creation
;; ----------------------------------------------------------------------------

(use-package xeft :ensure t)

;; Load denote configuration after Elpaca initialization
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "config/org/denote.el" user-emacs-directory))))

;; Load xeft configuration after Elpaca initialization
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "config/org/xeft.el" user-emacs-directory))))

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

;; Local LLMs via Ollama; `M-x ellama` or `C-c M-e` (see config/ai/ai-tools.el).
;; Install Ollama and pull a model, e.g. `ollama pull qwen2.5:3b`.
;; Explicit :main avoids Elpaca "Unable to find main elisp file" when the MELPA cache is wrong.
(use-package ellama
  :ensure (:host github :repo "s-kostyaev/ellama" :main "ellama.el")
  :defer t
  :bind (("C-c M-e" . ellama))
  :hook (org-ctrl-c-ctrl-c-hook . ellama-chat-send-last-message)
  :config
  (setopt ellama-auto-scroll t))

;; copilot.el requires `track-changes' (GNU ELPA); install before copilot.
(use-package track-changes
  :ensure t
  :demand t)

(use-package copilot
  :ensure (:host github :repo "copilot-emacs/copilot.el"
                 :branch "main")
  :after track-changes
  :hook (prog-mode . (lambda ()
                       (when (ignore-errors (copilot-server-executable))
                         (copilot-mode 1)))))

(use-package claudemacs
  :ensure (:host github 
                 :repo "cpoile/claudemacs" 
                 :branch "main"
                 :main "claudemacs.el"))

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

;; mu4e is installed system-wide with the mu package
;; It's not available via elpaca/MELPA - install via system package manager:
;;   Arch Linux: sudo pacman -S mu
;;   Debian/Ubuntu: sudo apt install mu
;;   macOS: brew install mu
(use-package bbdb
  :ensure t
  :defer t
  :commands (bbdb bbdb-search-name bbdb-complete-mail))
(use-package mu4e
  :ensure nil
  :defer t
  :commands (mu4e mu4e-compose-new mu4e-update-index)
  :config
  ;; Check if mu binary exists
  (unless (executable-find "mu")
    (warn "mu binary not found. Please install mu (e.g., 'sudo pacman -S mu' on Arch Linux)")))
(use-package message :ensure nil :defer t)
(use-package smtpmail :ensure nil :defer t)
(use-package consult-mu
  ;; consult-mu isn't on GNU ELPA; install from source.
  :ensure (:host github :repo "armindarvish/consult-mu" :files ("*.el"))
  :defer t
  :after consult
  :commands (consult-mu consult-mu-dynamic consult-mu-async consult-mu-contacts))

;; Load email configuration early (safe to load even when mu4e isn't installed).
(load-file (expand-file-name "config/email/email.el" user-emacs-directory))

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
(load-file (expand-file-name "config/functions/maintenance.el" user-emacs-directory))

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
            (when (display-graphic-p)
              (load-theme 'poet-dark t))))

;; ============================================================================
;; Daemon Frame Initialization - Ensure daemon-created frames match regular frames
;; ============================================================================
(defun my/initialize-daemon-frame (frame)
  "Initialize a frame created from daemon with all settings.
This ensures daemon frames have the same appearance as regular frames."
  (condition-case err
      (when (and frame (frame-live-p frame) (display-graphic-p frame))
        ;; Apply frame parameters
        (set-frame-parameter frame 'vertical-scroll-bars nil)
        (set-frame-parameter frame 'horizontal-scroll-bars nil)
        (set-frame-parameter frame 'fullscreen 'maximized)
        (set-frame-parameter frame 'internal-border-width 0)
        (set-frame-parameter frame 'right-divider-width 0)
        
        ;; Load theme if not already loaded (only once globally)
        (unless (member 'poet-dark custom-enabled-themes)
          (load-theme 'poet-dark t))
        
        ;; Reapply fonts and fontaine preset (with frame selected)
        (with-selected-frame frame
          ;; Reapply fonts (function is always defined, but only works in GUI)
          (condition-case err
              (my/set-variable-fixed-pitch-faces)
            (error (message "Warning: Could not set fonts: %s" (error-message-string err))))
          
          ;; Reapply fontaine preset if available
          (when (and (boundp 'fontaine-current-preset) 
                     fontaine-current-preset
                     (fboundp 'fontaine-set-preset))
            (condition-case err
                (fontaine-set-preset fontaine-current-preset)
              (error (message "Warning: Could not set fontaine preset: %s" (error-message-string err)))))))
    (error (message "Error initializing daemon frame: %s" (error-message-string err)))))

;; Apply initialization to all frames created from daemon
;; Keep it simple to avoid crashes - just run once after a small delay
(add-hook 'after-make-frame-functions 
          (lambda (new-frame)
            (when (and new-frame (frame-live-p new-frame))
              ;; Capture frame in closure to avoid void variable error
              (let ((frame-to-init new-frame))
                ;; Delay slightly to ensure packages are loaded
                (run-with-timer 0.3 nil
                               (lambda ()
                                 (condition-case err
                                     (when (and frame-to-init (frame-live-p frame-to-init))
                                       (my/initialize-daemon-frame frame-to-init))
                                   (error (message "Warning: Could not initialize daemon frame: %s" 
                                                   (error-message-string err))))))))))

(provide 'init)
;;; init.el ends here
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-vc-selected-packages
   '((claudemacs :url "https://github.com/cpoile/claudemacs" :branch "main"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
