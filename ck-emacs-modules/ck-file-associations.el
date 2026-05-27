;;; ck-file-associations.el --- External program associations and file managers -*- lexical-binding: t -*-

(require 'ck-system)

;; WSL preview dispatchers — exclude ones that need external binaries the
;; WSL environment typically doesn't have.
(when ck/wsl-p
  (setq dirvish-preview-dispatchers '(image gif pdf font)))

(setq dirvish-sidecar nil) ; Disable left sidecar/tree column

;; ============================================================================
;; Dired - File manager for Emacs
;; ============================================================================

;; Define C-c SPC as quick jump prefix with nerd font icons
(define-prefix-command 'my-quick-jump-map)
(global-set-key (kbd "C-c SPC") 'my-quick-jump-map)

;; Quick directory jumps with icons
(define-key my-quick-jump-map (kbd "g") 
  (lambda () (interactive) (dired "~/org/gtd/")))
(define-key my-quick-jump-map (kbd "j") 
  (lambda () (interactive) (dired "~/org/")))

;; Set better descriptions using which-key
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c SPC"   "󰉋 Quick Jump"
    "C-c SPC a" "󰅐 Agenda"
    "C-c SPC g" "󰨟 GTD"
    "C-c SPC j" "󰽰 Journal"))

;; Yazi like bindings
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "h") 'dired-up-directory)    ; like yazi
  (define-key dired-mode-map (kbd "l") 'dired-find-file))      ; like yazi

(add-hook 'dired-mode-hook
          (lambda ()
            (hl-line-mode 1)                             ; Highlight current line
            (dired-hide-details-mode 1)))                ; Hide details by default

;; ============================================================================
;; OpenWith - Open files with external programs
;; ============================================================================
;; IMPORTANT: Must be configured and enabled BEFORE dired/dirvish loads
;; ============================================================================


(with-eval-after-load 'openwith
  ;; Pick the right "open this file" command per platform:
  ;;   macOS  : open
  ;;   WSL    : wslview if installed (Windows-aware), else xdg-open
  ;;   Linux  : xdg-open
  ;; Media files prefer mpv when installed (fast, scriptable). If mpv is
  ;; missing we fall back to the generic opener so the rule still does
  ;; something useful instead of silently failing.
  (let* ((opener (ck/open-command))
         (media-player (or (ck/has? "mpv") opener)))
    (when opener
      (setq openwith-associations
            `(("\\.\\(?:mp4\\|mkv\\|avi\\|mov\\|wmv\\|flv\\|webm\\|m4v\\)\\'" ,media-player (file))
              ("\\.\\(?:mp3\\|flac\\|ogg\\|wav\\|m4a\\|opus\\|aac\\)\\'"     ,media-player (file))
              ("\\.\\(?:png\\|jpg\\|jpeg\\|gif\\|bmp\\|webp\\)\\'"           ,opener (file))
              ("\\.\\(?:docx?\\|xlsx?\\|pptx?\\)\\'"                         ,opener (file))
              ("\\.pdf\\'"                                                   ,opener (file))
              ("\\.\\(?:zip\\|tar\\.gz\\|tgz\\|tar\\.bz2\\|tbz2\\|7z\\|rar\\)\\'" ,opener (file))))
      (openwith-mode 1)
      (put 'dired-find-alternate-file 'disabled nil))))

;; ============================================================================
;; Dirvish - Modern file manager for dired
;; ============================================================================

;; Custom sort: directories first, then dotfiles, then regular files
;; Improved custom sort: directories first, then dotfiles, then regular files
(defun my-dirvish-custom-sort (a b)
  "Sort directories first, then dotfiles, then regular files."
  (let* ((a-dir (eq (car a) :directory))
         (b-dir (eq (car b) :directory))
         (a-name (cdr a))
         (b-name (cdr b))
         (a-dot (and (not a-dir) (string-prefix-p "." a-name)))
         (b-dot (and (not b-dir) (string-prefix-p "." b-name))))
    (cond
     ((and a-dir (not b-dir)) t)
     ((and b-dir (not a-dir)) nil)
     ;; Both are directories
     ((and a-dir b-dir) (string< a-name b-name))
     ;; Both are files
     ((and (not a-dir) (not b-dir))
      (cond
       ((and a-dot (not b-dot)) t)
       ((and b-dot (not a-dot)) nil)
       ((and a-dot b-dot) (string< a-name b-name))
       ((and (not a-dot) (not b-dot)) (string< a-name b-name))))
     (t (string< a-name b-name)))))


(setq dirvish-use-header-line t                         ; Use header line
      dirvish-human-readable t                          ; Human-readable sizes
      dirvish-group-sort nil                            ; Disable default grouping
      dirvish-sort t                                    ; Enable sorting
      dirvish-sort-function #'my-dirvish-custom-sort    ; Custom sort function
      dirvish-use-mode-line t                           ; Use mode line
      dirvish-fd-default-dir-buffer t                   ; Use fd for directory buffer
      dirvish-fd-default-dir-switches "-H -L -E .git -E node_modules")  ; Exclude git and node_modules

;; Ensure custom sort is applied to all Dirvish buffers
(add-hook 'dirvish-directory-view-mode-hook
          (lambda ()
            (setq-local dirvish-sort-function #'my-dirvish-custom-sort)))

(with-eval-after-load 'dirvish
  (dirvish-override-dired-mode)                         ; Replace dired with dirvish
  
  ;; Header and mode-line format
  (setq dirvish-header-line-format '(:left (path) :right (free-space)))
  (setq dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index)))

  ;; Keep the main listing minimal (icon + filename).
  ;; This complements `ck-emacs-modules/ck-icons.el` and also acts as a safe override
  ;; in case this file is loaded later.
  (setq dirvish-attributes '(nerd-icons)))

;; NOTE: mixed-pitch configuration moved to org-core.el

;; ============================================================================
;; Grip mode Configuration - Live preview markdown in browser
;; ============================================================================

(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-command-map (kbd "g") 'grip-mode))  ; Toggle grip preview

;; ============================================================================
;; Helm Configuration - Alternative completion framework
;; ============================================================================

(global-set-key (kbd "C-c M-h") 'helm-command-prefix)     ; Helm command prefix
(with-eval-after-load 'helm
  (setq helm-split-window-inside-p t                      ; Split inside current window
        helm-move-to-line-cycle-in-source t))             ; Cycle through candidates

(provide 'ck-file-associations)
