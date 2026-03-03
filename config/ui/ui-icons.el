;;; ui-icons.el --- Icons configuration

;; ============================================================================
;; All The Icons Configuration - Icon set for Emacs
;; ============================================================================

(setq all-the-icons-scale-factor 0.8)               ; Scale icons to 80% size

;; NOTE: all-the-icons-dired is DISABLED when using dirvish

;; ============================================================================
;; Nerd Icons Configuration - Icon set for dirvish and modern UI
;; ============================================================================

(with-eval-after-load 'dirvish
  ;; Use nerd-icons for both GUI and terminal (requires nerd-fonts in terminal)
  (setq dirvish-mode-line-format              ; Simplified mode-line
         '(:left (sort symlink) :right (omit yank index)))
  
  ;; Keep the main file list minimal: icon + name only.
  ;; (Dirvish preview/peek can still show richer info when needed.)
  (setq dirvish-attributes '(nerd-icons))
  
  ;; Nerd icons configuration
  (setq dirvish-nerd-icons-offset 0.0         ; No horizontal offset for icons
         dirvish-nerd-icons-height 1.0         ; Icon height relative to text (1.0 for terminal)
         dirvish-nerd-icons-palette 'nerd-icons ; Use nerd-icons palette
         dirvish-icon-delimiter " "))          ; Space between icon and text

(provide 'ui-icons)
;;; ui-icons.el ends here
