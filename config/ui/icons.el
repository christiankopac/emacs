;;; icons.el --- Icons configuration

;; All The Icons - Icon set for Emacs
(setq all-the-icons-scale-factor 0.8)               ; Scale icons to 80% size

;; NOTE: all-the-icons-dired is DISABLED when using dirvish
;; Dirvish uses nerd-icons instead for better compatibility

;; Nerd Icons - Icon set for dirvish and modern UI
(with-eval-after-load 'dirvish
  ;; Use nerd-icons for both GUI and terminal (requires nerd-fonts in terminal)
  (setq dirvish-mode-line-format              ; Simplified mode-line
        '(:left (sort symlink) :right (omit yank index)))
  
  (setq dirvish-attributes '(nerd-icons file-size file-time)) ; Show icons, size, time
  
  ;; Nerd icons configuration
  (setq dirvish-nerd-icons-offset 0.0         ; No horizontal offset for icons
        dirvish-nerd-icons-height 1.0         ; Icon height relative to text (1.0 for terminal)
        dirvish-nerd-icons-palette 'nerd-icons ; Use nerd-icons palette
        dirvish-icon-delimiter " "))          ; Space between icon and text

(provide 'icons)