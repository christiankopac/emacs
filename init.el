;;; init.el --- Modular Emacs configuration -*- lexical-binding: t -*-
;;
;;;; Commentary:
;;;; My personal modular Emacs configuration for org-mode, note-taking, coding, and writing.
;;
;;;; Code:

;; ----------------------------------------------------------------------------
;; BOILERPLATE: Post-startup GC strategy
;; ----------------------------------------------------------------------------
;; Startup GC is deferred in early-init.el (most-positive-fixnum). After
;; startup we want a high-but-finite threshold and a GC pass on idle so the
;; collector never fires while you're typing.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 256 1024 1024)
                  gc-cons-percentage 0.2)
            ;; Collect when idle so pauses are invisible.
            (run-with-idle-timer 5 t (lambda () (garbage-collect)))))

;; GC during minibuffer use is the classic stutter source — pause it.
(add-hook 'minibuffer-setup-hook
          (lambda () (setq gc-cons-threshold most-positive-fixnum)))
(add-hook 'minibuffer-exit-hook
          (lambda () (setq gc-cons-threshold (* 256 1024 1024))))

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
;; Must match where clones actually live on disk (upstream default: `sources/`).
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
(setq elpaca-show-process-buffer nil)
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
;; The real value is set in ck-emacs-modules/ck-org-extensions.el; this ensures the symbol exists.
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

;; Add module and lisp directories to load-path
(add-to-list 'load-path (expand-file-name "ck-emacs-modules" user-emacs-directory))
(add-to-list 'load-path (expand-file-name "ck-lisp" user-emacs-directory))

;; System detection — provides ck/wsl-p, ck/macos-p, ck/distro,
;; ck/display-server, ck/has?, ck/open-command. Loaded early so every
;; later module can use these instead of re-implementing detection.
(require 'ck-system)

;; ----------------------------------------------------------------------------
;; Essential Packages
;; ----------------------------------------------------------------------------

(use-package emacs
  :config
  (load-file (expand-file-name "ck-emacs-modules/ck-core.el" user-emacs-directory)))

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

(use-package vertico
  :ensure (vertico :depth 1))
(use-package corfu :ensure t)
(use-package orderless
  :ensure (orderless :host github :repo "oantolin/orderless" :depth 1))
(use-package marginalia :ensure t)
(use-package embark :ensure t)
(use-package consult :ensure t)
(use-package embark-consult :ensure t :after (consult embark))
(use-package cape :ensure t)

;; Load completion config
(load-file (expand-file-name "ck-emacs-modules/ck-completion.el" user-emacs-directory))

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

(load-file (expand-file-name "ck-emacs-modules/ck-icons.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; UI: Fonts & Ligatures
;; ----------------------------------------------------------------------------

(use-package fontaine :ensure t :if (display-graphic-p))

;; (use-package ligature :ensure t :after org)

;; (use-package ox-tufte :ensure t)

;; Load font configuration after fontaine is ready (only in graphical mode)
(when (display-graphic-p)
  (with-eval-after-load 'fontaine
    (load-file (expand-file-name "ck-emacs-modules/ck-fonts.el" user-emacs-directory))))

(use-package show-font
  :ensure t
  :bind
  (("C-c s f" . show-font-select-preview)
   ("C-c s t" . show-font-tabulated)))

;; ----------------------------------------------------------------------------
;; UI: Menus & Dashboard
;; ----------------------------------------------------------------------------

(use-package transient :ensure t :defer t)
(use-package dashboard :ensure t :after (nerd-icons)
  :config
  ;; Ensure nerd-icons is loaded before dashboard initializes
  (unless (featurep 'nerd-icons)
    (require 'nerd-icons nil t)))
(use-package spacious-padding :ensure t :defer t
  :hook (after-init . spacious-padding-mode))
(use-package mixed-pitch :ensure t :defer t
  :commands (mixed-pitch-mode))
(use-package helpful :ensure t :defer t
  :commands (helpful-function helpful-command helpful-key helpful-variable
             helpful-callable helpful-symbol helpful-macro))
(use-package smartparens
  :ensure (smartparens :host github :repo "Fuco1/smartparens" :depth 1)
  :defer t
  :hook (prog-mode . smartparens-mode))
(use-package expand-region :ensure t :defer t
  :bind ("C-=" . er/expand-region))
(use-package which-key :ensure t :defer 1
  :config (which-key-mode))
(use-package hyperbole :ensure t :defer t
  :commands (hyperbole hkey-either action-key))
(use-package beacon :ensure t :defer 2
  :config (beacon-mode 1))

(use-package dirvish
  :ensure t
  :defer t
  :commands (dirvish dirvish-side dirvish-dwim dirvish-override-dired-mode)
  :hook (dired-mode . (lambda ()
                        (when (fboundp 'dirvish-override-dired-mode)
                          (dirvish-override-dired-mode))))
  :config
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
(use-package helm :ensure t :defer t
  :commands (helm-M-x helm-find-files helm-buffers-list helm-imenu))
(use-package helm-org :ensure t :defer t :after (helm org))
(use-package multiple-cursors :ensure t :defer t
  :commands (mc/edit-lines mc/mark-next-like-this mc/mark-previous-like-this
             mc/mark-all-like-this))
(use-package mood-line :ensure t :defer 0.5
  :config (mood-line-mode))

;; Mood-line + emoji mode-line configuration lives in ck-modeline.el.
;; Loading after mood-line ensures the segment libraries are available
;; before we wire in the format and the emoji segment.
(with-eval-after-load 'mood-line
  (load-file (expand-file-name "ck-emacs-modules/ck-modeline.el" user-emacs-directory)))

(use-package openwith 
  :ensure t
  :init
  ;; Load openwith eagerly (needs to be active before opening files)
  (add-hook 'after-init-hook 
            (lambda () 
              (require 'openwith)
              (load-file (expand-file-name "ck-emacs-modules/ck-file-associations.el" user-emacs-directory)))))

;; Load UI configuration files (after Elpaca loads packages)
;; Load dashboard.el after dashboard package is available
(with-eval-after-load 'dashboard
  (condition-case err
      (load-file (expand-file-name "ck-emacs-modules/ck-dashboard.el" user-emacs-directory))
    (error (message "Warning: Could not load dashboard.el - %s" (error-message-string err)))))
(load-file (expand-file-name "ck-emacs-modules/ck-ui.el" user-emacs-directory))
(load-file (expand-file-name "ck-emacs-modules/ck-navigation.el" user-emacs-directory))
(load-file (expand-file-name "ck-emacs-modules/ck-editing.el" user-emacs-directory))

;; Load Hyperbole configuration after Elpaca initialization (ensures package is installed).
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "ck-emacs-modules/ck-hyperbole.el" user-emacs-directory))))

;; Load dirvish config after package is ready
(with-eval-after-load 'dirvish
  (load-file (expand-file-name "ck-emacs-modules/ck-file-associations.el" user-emacs-directory)))

;; Skip clipetty on WSL — ck-clipboard already bridges to Windows via
;; wl-copy/xclip/clip.exe. Running both pays OSC52 + clipboard work on
;; every kill. On macOS clipetty isn't needed either (pbcopy is wired by
;; ck-clipboard). Only useful on plain Linux TTY without a Wayland/X11
;; clipboard tool available.
(use-package clipetty
  :ensure t
  :unless (or ck/wsl-p ck/macos-p)
  :hook (after-init . global-clipetty-mode))

;; Context-menu (GUI only)
(when (display-graphic-p)
  (context-menu-mode))

;; Auto-revert: use inotify (not polling) and only on file-visiting buffers.
;; The previous setup (`use-notify nil` + `non-file-buffers t`) polled every
;; live buffer every 5s, which is a major source of typing latency on
;; large projects. inotify is push-based and effectively free.
(setq auto-revert-verbose nil
      auto-revert-use-notify t
      auto-revert-avoid-polling t
      auto-revert-interval 5
      global-auto-revert-non-file-buffers nil
      auto-revert-stop-on-user-input nil)
(global-auto-revert-mode 1)

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

(setq org-gtd-update-ack "4.0.0")
(use-package org-gtd :ensure t :defer t :after (org transient))

;; (use-package org-journal :ensure t)

;; Load org configurations
(load-file (expand-file-name "ck-emacs-modules/ck-org-core.el" user-emacs-directory))

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
(use-package gnuplot :ensure t :defer t)  ;; needed by ob-gnuplot for ck-org-graphs
;; org-modern is configured in ck-emacs-modules/ck-org-extensions.el to only enable in GUI mode

;; Load org extensions configuration
(with-eval-after-load 'org
  (load-file (expand-file-name "ck-emacs-modules/ck-org-extensions.el" user-emacs-directory)))

;; Gnuplot graphs over org/gtd + journal (M-x ck-org-graphs-generate)
(with-eval-after-load 'org
  (load-file (expand-file-name "ck-emacs-modules/ck-org-graphs.el" user-emacs-directory)))

;; Export packages
(use-package ox :ensure nil :after org)
(use-package ox-hugo :ensure t :defer t :after ox)
;; pandoc-mode lazy-loads via its hooks; the hooks themselves don't fire
;; until you actually open a markdown/org file.
(use-package pandoc-mode :ensure t :defer t
  :hook ((markdown-mode . pandoc-mode) (org-mode . pandoc-mode)))
(use-package ox-pandoc :ensure t :defer t :after pandoc)

;; Load org export configuration
(with-eval-after-load 'org
  (load-file (expand-file-name "ck-emacs-modules/ck-org-export.el" user-emacs-directory)))

;; Load ox-hugo configuration for Hugo website workflow
(with-eval-after-load 'ox-hugo
  (load-file (expand-file-name "ck-emacs-modules/ck-ox-hugo.el" user-emacs-directory)))


;; ----------------------------------------------------------------------------
;; Roam Packages
;; ----------------------------------------------------------------------------

;; (use-package org-roam :ensure t :after org)
;; (use-package org-roam-ui :ensure t :after org-roam)

;; Load org-roam configuration
;; (with-eval-after-load 'org-roam
;;  (load-file (expand-file-name "ck-emacs-modules/ck-org-roam.el" user-emacs-directory)))

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
            (load-file (expand-file-name "ck-emacs-modules/ck-denote.el" user-emacs-directory))))

;; Load xeft configuration after Elpaca initialization
(add-hook 'elpaca-after-init-hook
          (lambda ()
            (load-file (expand-file-name "ck-emacs-modules/ck-xeft.el" user-emacs-directory))))

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
;; Tree-sitter: use ONLY the modern built-in `treesit' via treesit-auto.
;; Emacs 30 ships treesit; the legacy `tree-sitter' + `tree-sitter-langs'
;; packages duplicated the work and parsed every buffer twice. Dropped.
(use-package treesit-auto
  :ensure t
  :defer 1
  :custom (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; ----------------------------------------------------------------------------
;; Formatting Packages
;; ----------------------------------------------------------------------------

(use-package format-all :ensure t)
(use-package apheleia :ensure t)

;; ----------------------------------------------------------------------------
;; Version Control Packages
;; ----------------------------------------------------------------------------

(use-package magit
  :ensure (magit :depth 1)
  :defer t
  :commands (magit magit-status magit-blame magit-log magit-dispatch
             magit-file-dispatch))
(use-package diff-hl :ensure t :defer t
  :hook ((prog-mode . diff-hl-mode)
         (dired-mode . diff-hl-dired-mode)))
(use-package git-timemachine :ensure t :defer t
  :commands (git-timemachine git-timemachine-toggle))
(use-package git-messenger :ensure t :defer t
  :commands (git-messenger:popup-message))
(use-package forge :ensure t :defer t :after magit)

;; ----------------------------------------------------------------------------
;; AI Packages
;; ----------------------------------------------------------------------------

(use-package gptel :ensure t :defer t
  :commands (gptel gptel-menu gptel-send))

;; Ellama requires yaml >= 1.2.3; pin explicitly so Elpaca fetches the right
;; tag rather than the stale 1.2.1 cached in its local clone.
(use-package yaml
  :ensure (:host github :repo "zkry/yaml.el" :ref "v1.2.3"))

;; Local LLMs via Ollama; `M-x ellama` or `C-c M-e` (see ck-emacs-modules/ck-ai.el).
;; Install Ollama and pull a model, e.g. `ollama pull qwen2.5:3b`.
;; Explicit :main avoids Elpaca "Unable to find main elisp file" when the MELPA cache is wrong.
(use-package ellama
  :ensure (:host github :repo "s-kostyaev/ellama" :main "ellama.el")
  :after yaml
  :defer t
  :bind (("C-c M-e" . ellama))
  :hook (org-ctrl-c-ctrl-c-hook . ellama-chat-send-last-message)
  :config
  (setopt ellama-auto-scroll t))

;; copilot.el requires `track-changes' (GNU ELPA). Drop :demand so it
;; only loads when copilot itself does — there's no other consumer.
(use-package track-changes :ensure t :defer t)

(use-package copilot
  :ensure (:host github :repo "copilot-emacs/copilot.el"
                 :branch "main")
  :defer t
  :after track-changes
  :commands (copilot-mode copilot-complete copilot-accept-completion)
  :hook (prog-mode . ck/copilot-maybe-enable)
  :init
  ;; Skip internal buffers (*scratch*, *Messages*, *Org Src*, etc.) so
  ;; copilot doesn't fire up its node server at startup just because
  ;; `lisp-interaction-mode' derives from `prog-mode'. Real source files
  ;; have a `buffer-file-name'; scratch and other transient buffers do not.
  (defun ck/copilot-maybe-enable ()
    "Enable `copilot-mode' if this buffer is a real on-disk source file."
    (when (and buffer-file-name
               (not (string-prefix-p "*" (buffer-name)))
               (ignore-errors (copilot-server-executable)))
      (copilot-mode 1))))

(use-package claudemacs
  :ensure (:host github
                 :repo "cpoile/claudemacs"
                 :branch "main"
                 :main "claudemacs.el")
  :defer t
  :commands (claudemacs claudemacs-start))

(use-package ollama-buddy
  :ensure t
  :defer t
  :bind
  ("C-c o" . ollama-buddy-role-transient-menu)
  ("C-c O" . ollama-buddy-transient-menu)
  :config
  (require 'savehist)
  (require 'color)
  (require 'ollama-buddy-provider)
  (ollama-buddy-provider-create
   :name "Ollama Cloud"
   :prefix "c:"
   :api-type 'claude
   :api-key (lambda () (auth-source-pick-first-password
                        :host "ollama-buddy-claude" :user "apikey"))
   :endpoint "https://api.anthropic.com/v1/messages"
   :models-endpoint "https://api.anthropic.com/v1/models")
  (setq ollama-buddy-cloud-api-key
        (auth-source-pick-first-password :host "ollama-buddy-cloud" :user "apikey"))
  (setq ollama-buddy-default-model "minimax-m2.7:cloud")
  (setq ollama-buddy-host "localhost")
  (setq ollama-buddy-port 11434))

;; Load AI tools configuration
(load-file (expand-file-name "ck-emacs-modules/ck-ai.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Terminal Packages
;; ----------------------------------------------------------------------------

(use-package eat :ensure t :defer t)
;; exec-path-from-shell is expensive (~1s spawning a login shell). Only
;; auto-install it; the call to `exec-path-from-shell-initialize' is
;; gated in ck-development.el so terminal-launched Emacs on
;; WSL/Arch/Nix skips it entirely.
(use-package exec-path-from-shell
  :ensure t
  :defer t
  :commands (exec-path-from-shell-initialize exec-path-from-shell-copy-env))
(when (or (memq window-system '(mac ns))
          (daemonp))
  (require 'exec-path-from-shell nil t))

;; Load development configuration
(load-file (expand-file-name "ck-emacs-modules/ck-development.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Writing
;; ----------------------------------------------------------------------------

(use-package markdown-mode :ensure t)
(use-package text-mode :ensure nil)
(use-package dictionary :ensure t)
(use-package pdf-tools :ensure t)
(use-package nov :ensure t :mode ("\\.epub\\'" . nov-mode))
(use-package olivetti :ensure t)
(use-package compat :ensure t)
;; Jinx scans every text buffer on first activation; defer past startup so
;; opening the first file isn't blocked by enchant initialisation. Only
;; enabled when `enchant-2' is actually installed (Arch: `enchant',
;; Debian/WSL: `libenchant-2-2', Nix: `enchant').
(use-package jinx
  :ensure (:depth nil)
  :defer 3
  :commands (jinx-mode global-jinx-mode jinx-correct)
  :config
  (when (executable-find "enchant-2")
    (global-jinx-mode 1)))

;; Load writing configuration
(load-file (expand-file-name "ck-emacs-modules/ck-writing.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Media & Music
;; ----------------------------------------------------------------------------

(use-package emms :ensure t :defer t)
(use-package listen :ensure t :defer t)

;; Load media configuration
(with-eval-after-load 'emms
  (load-file (expand-file-name "ck-emacs-modules/ck-music.el" user-emacs-directory)))
(with-eval-after-load 'listen
  (load-file (expand-file-name "ck-emacs-modules/ck-music.el" user-emacs-directory)))

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
(load-file (expand-file-name "ck-emacs-modules/ck-email.el" user-emacs-directory))

;; ----------------------------------------------------------------------------
;; Machine Specific Configuration
;; ----------------------------------------------------------------------------

;; Clipboard: ck-clipboard.el detects WSL / Wayland / X11 / macOS, wires
;; `interprogram-*-function' for TTY (and WSL GUI, which is flaky), and
;; spawns the write command asynchronously so the slow PowerShell fallback
;; never blocks. `M-x ck/clipboard-status' to inspect, `ck/clipboard-paste-force'
;; if WSLg gets out of sync.
(load-file (expand-file-name "ck-emacs-modules/ck-clipboard.el" user-emacs-directory))

;; Terminal settings
(setq term-file-prefix nil)
(add-to-list 'term-file-aliases '("ghostty" . "xterm-256color"))

;; Terminal-specific settings (only in terminal mode)
(unless (display-graphic-p)
  (xterm-mouse-mode 1)
  (global-set-key [mouse-4] 'scroll-down-line)
  (global-set-key [mouse-5] 'scroll-up-line)
  ;; Enable 24-bit truecolor when the terminal advertises it (ghostty,
  ;; wezterm, kitty, alacritty all set COLORTERM=truecolor). Without
  ;; this, ef-symbiosis degrades to nearest-256 and looks washed out.
  (when (member (getenv "COLORTERM") '("truecolor" "24bit"))
    (tty-run-terminal-initialization (selected-frame) "xterm-direct" t)))

;; ----------------------------------------------------------------------------
;; Custom Functions
;; ----------------------------------------------------------------------------

(load-file (expand-file-name "ck-lisp/ck-functions.el" user-emacs-directory))
(load-file (expand-file-name "ck-lisp/ck-maintenance.el" user-emacs-directory))

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
            (if (display-graphic-p)
                (load-theme 'poet-dark t)
              (load-theme 'ef-elea-dark t))))

;; ============================================================================
;; Daemon Frame Initialization
;; ============================================================================
;; Most of what used to live here is now handled elsewhere:
;;   - Frame parameters come from `default-frame-alist' in early-init.el.
;;   - Font resolution / fontset / fontaine preset are re-applied by
;;     ck-fonts.el on `after-make-frame-functions' and
;;     `server-after-make-frame-hook' — synchronously, no 0.3s timer.
;; All that's left is loading the theme on the first GUI frame.
(add-hook 'server-after-make-frame-hook
          (lambda ()
            (when (and (display-graphic-p)
                       (not (member 'poet-dark custom-enabled-themes)))
              (load-theme 'poet-dark t))))

(provide 'init)
;;; init.el ends here
