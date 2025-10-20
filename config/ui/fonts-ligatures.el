;;; fonts-ligatures.el --- Fonts and ligatures configuration

;; ============================================================================
;; Font Variables - Ensure they're defined before fontaine configuration
;; ============================================================================

;; Define font variables if not already defined
(unless (boundp 'my/font-serif)
  (defvar my/font-serif "Literata" "Default serif font for variable pitch text."))
  ;;(defvar my/font-serif "ETBookOT" "Default serif font for variable pitch text."))

(unless (boundp 'my/font-monospace)
  (defvar my/font-monospace "MonoLisa Nerd Font Mono" "Default monospace font for fixed pitch text."))

;; ============================================================================
;; Fontaine Configuration - Font configuration
;; ============================================================================

(with-eval-after-load 'fontaine
  (setq fontaine-presets
        '((regular                            
           :default-family my/font-monospace
           :default-weight normal
           :default-height 90
           :variable-pitch-family my/font-serif
           :variable-pitch-weight normal
           :variable-pitch-height 1.0
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 1.0
           :bold-weight bold
           :italic-slant italic
           :line-spacing nil)
          
          (writing
           :default-family my/font-monospace 
           :default-weight normal
           :default-height 90                   
           :variable-pitch-family my/font-serif 
           :variable-pitch-weight normal
           :variable-pitch-height 140           
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 90
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (org-reading                          
           :default-family my/font-monospace 
           :default-weight normal
           :default-height 90                   
           :variable-pitch-family my/font-serif      
           :variable-pitch-weight normal
           :variable-pitch-height 1.4  
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 90
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (presentation
           :default-family my/font-monospace 
           :default-weight normal
           :default-height 110   
           :variable-pitch-family my/font-serif      
           :variable-pitch-weight normal
           :variable-pitch-height 220           
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 110
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (compact
           :default-family my/font-monospace
           :default-weight normal
           :default-height 85
           :variable-pitch-family my/font-serif
           :variable-pitch-weight normal
           :variable-pitch-height 0.9
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 1.0
           :bold-weight bold
           :italic-slant italic
           :line-spacing nil)
          
          (large
           :default-family my/font-monospace 
           :default-weight normal
           :default-height 90                  
           :variable-pitch-family my/font-serif       
           :variable-pitch-weight normal
           :variable-pitch-height 180           
           :fixed-pitch-family my/font-monospace
           :fixed-pitch-height 90
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.15)))

  (fontaine-set-preset 'regular)

  ;; Fontaine keybindings
  (global-set-key (kbd "C-c M-f r") (lambda () (interactive) (fontaine-set-preset 'regular)))
  (global-set-key (kbd "C-c M-f o") (lambda () (interactive) (fontaine-set-preset 'org-reading)))
  (global-set-key (kbd "C-c M-f w") (lambda () (interactive) (fontaine-set-preset 'writing)))
  (global-set-key (kbd "C-c M-f p") (lambda () (interactive) (fontaine-set-preset 'presentation)))
  (global-set-key (kbd "C-c M-f c") (lambda () (interactive) (fontaine-set-preset 'compact)))
  (global-set-key (kbd "C-c M-f l") (lambda () (interactive) (fontaine-set-preset 'large)))
  (global-set-key (kbd "C-c M-f t") 'fontaine-set-preset))

;; ============================================================================
;; Ligatures Variables - Define before packages load
;; ============================================================================

;; Ligatures variables (define before packages load)
;; (defvar my/ligatures-general '("www")
;;   "General ligatures for all modes.")

;; (defvar my/ligatures-prog-mode
;;   '("|||>" "<||>" "<|||" "<|>" "|>" "<|" "::" ":::" "==" "===" "=/=" "!==" "<==" "<=>" "=>" "->" "<-" "<<-" "->>" "<<" ">>" "<<<" ">>>" "<~" "~>" "-<" ">-" "=<<" ">>=" "<=<" ">=>" "<*" "*>" ":-" "-:" "++" "+++" "**" "***" "~~" "~~>" "::=" ":=" ".." "..." "//" "/*" "*/" "##" "###" "&&" "||")
;;   "Programming mode ligatures.")

;; (with-eval-after-load 'ligature
;;   (ligature-set-ligatures 't my/ligatures-general)
;;   (ligature-set-ligatures 'prog-mode my/ligatures-prog-mode)
;;   ;; Don't apply ligatures to org-mode to avoid conflicts with org-hide-leading-stars
;;   (global-ligature-mode t))

(provide 'fonts-ligatures)
