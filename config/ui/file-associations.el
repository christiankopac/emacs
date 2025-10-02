;;; file-associations.el --- External program associations and file managers

;;; Dired

;; ============================================================================
;; Dired - File manager for Emacs
;; ============================================================================

;; Define C-c SPC as quick jump prefix with nerd font icons
(define-prefix-command 'my-quick-jump-map)
(global-set-key (kbd "C-c SPC") 'my-quick-jump-map)

;; Quick directory jumps with icons
(define-key my-quick-jump-map (kbd "a") 
  (lambda () (interactive) (dired "~/Sync/org/agenda/")))
(define-key my-quick-jump-map (kbd "g") 
  (lambda () (interactive) (dired "~/Sync/org/agenda/gtd/")))
(define-key my-quick-jump-map (kbd "j") 
  (lambda () (interactive) (dired "~/Sync/org/agenda/journal/daily/")))

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

;; ============================================================================
;; OpenWith - Open files with external programs
;; ============================================================================
;; IMPORTANT: Must be configured and enabled BEFORE dired/dirvish loads

(with-eval-after-load 'openwith
  ;; Configure file associations
  (setq openwith-associations
        '(;; Video files - MPV
          ("\\.\\(?:mp4\\|mkv\\|avi\\|mov\\|wmv\\|flv\\|webm\\|m4v\\)\\'" "mpv" (file))
          ;; Audio files - MPV
          ("\\.\\(?:mp3\\|flac\\|ogg\\|wav\\|m4a\\|opus\\|aac\\)\\'" "mpv" (file))
          ;; Images - feh (excluding SVG, which Emacs handles natively)
          ("\\.\\(?:png\\|jpg\\|jpeg\\|gif\\|bmp\\|webp\\)\\'" "feh" (file))
          ;; Microsoft Office - LibreOffice
          ("\\.\\(?:docx?\\|xlsx?\\|pptx?\\)\\'" "libreoffice" (file))
          ;; PDF - zathura (or okular/evince as fallback)
          ("\\.pdf\\'" "zathura" (file))
          ;; Archives - file-roller/xarchiver
          ("\\.\\(?:zip\\|tar\\.gz\\|tgz\\|tar\\.bz2\\|tbz2\\|7z\\|rar\\)\\'" "xarchiver" (file))))
  
  ;; Enable openwith mode globally
  (openwith-mode 1)
  
  ;; Make openwith work with dired
  (put 'dired-find-alternate-file 'disabled nil))

;; ============================================================================
;; Dirvish - Modern file manager for dired
;; ============================================================================

(setq dirvish-use-header-line t                         ; Use header line
      dirvish-human-readable t                          ; Human-readable sizes
      dirvish-group-sort t                              ; Group by type
      dirvish-sort t                                    ; Enable sorting
      dirvish-sort-function 'dirvish-sort-dirs-first    ; Directories first
      dirvish-use-mode-line t                           ; Use mode line
      dirvish-fd-default-dir-buffer t                   ; Use fd for directory buffer
      dirvish-fd-default-dir-switches "-H -L -E .git -E node_modules")  ; Exclude git and node_modules

(with-eval-after-load 'dirvish
  (dirvish-override-dired-mode)                         ; Replace dired with dirvish
  
  ;; Header and mode-line format
  (setq dirvish-header-line-format '(:left (path) :right (free-space)))
  (setq dirvish-mode-line-format '(:left (sort symlink) :right (omit yank index))))

;; NOTE: mixed-pitch configuration moved to org-core.el

;; Grip mode - Live preview markdown in browser
(with-eval-after-load 'markdown-mode
  (define-key markdown-mode-command-map (kbd "g") 'grip-mode))  ; Toggle grip preview

;; Helm - Alternative completion framework
(global-set-key (kbd "C-c M-h") 'helm-command-prefix)     ; Helm command prefix
(with-eval-after-load 'helm
  (setq helm-split-window-inside-p t                      ; Split inside current window
        helm-move-to-line-cycle-in-source t))             ; Cycle through candidates

(provide 'file-associations)
