;;; fonts-ligatures.el --- Fonts and ligatures configuration

(require 'seq)

;; ============================================================================
;; Font Variables - Ensure they're defined before fontaine configuration
;; ============================================================================

;; Define font variables if not already defined
(unless (boundp 'my/font-serif)
  (defvar my/font-serif "Literata" "Default serif font for variable pitch text."))
  ;;(defvar my/font-serif "ETBookOT" "Default serif font for variable pitch text."))

;; Font fallback function
(defun my/font-first-available (families)
  "Return the first installed font family from FAMILIES, or nil."
  (seq-find (lambda (f) (member f (font-family-list))) families))

;; Monospace font with fallback chain
(unless (boundp 'my/font-monospace)
  (defvar my/font-monospace
    (or (my/font-first-available '("MonoLisa Nerd Font Mono"
                                  "MonoLisa Nerd Font"
                                  "Fira Code"
                                  "JetBrains Mono"
                                  "Source Code Pro"
                                  "DejaVu Sans Mono"
                                  "Liberation Mono"
                                  "Consolas"
                                  "Adwaita Mono"
                                  "Courier New"
                                  "Monospace"))
        "Monospace")  ; Ultimate fallback
    "Default monospace font for fixed pitch text."))

;; Nerd Icons / Symbols fallback font (PUA glyphs used by nerd-icons, dirvish, etc.)
;; Note: In terminal Emacs, fonts are controlled by your terminal emulator.
;; (my/font-first-available is defined above)

(defvar my/font-nerd-symbols
  (or (my/font-first-available '("Symbols Nerd Font Mono"
                                "Symbols Nerd Font"
                                "Nerd Font Symbols"
                                "Noto Sans Symbols2"))
      my/font-monospace)
  "Font family to use as a fallback for Nerd Font symbols / icons.")

;; ============================================================================
;; Fontaine Configuration - Font configuration
;; ============================================================================

;; Detect WSL for HiDPI font scaling
(defvar my/wsl-p (and (eq system-type 'gnu/linux) (getenv "WSL_DISTRO_NAME"))
  "Non-nil if running on WSL.")

;; Font height multiplier for WSL/HiDPI (2x for better readability)
(defvar my/font-height-multiplier (if my/wsl-p 2.0 1.0)
  "Multiplier for font heights. Increased for WSL/HiDPI displays.")

;; Compute font heights based on WSL detection (must be integers for fontaine)
(defvar my/font-regular-height (round (* 90 my/font-height-multiplier)))
(defvar my/font-writing-height (round (* 90 my/font-height-multiplier)))
(defvar my/font-org-reading-height (round (* 90 my/font-height-multiplier)))
(defvar my/font-presentation-height (round (* 110 my/font-height-multiplier)))
(defvar my/font-compact-height (round (* 85 my/font-height-multiplier)))
(defvar my/font-large-height (round (* 90 my/font-height-multiplier)))

(with-eval-after-load 'fontaine
  (setq fontaine-presets
        `((regular                            
           :default-family ,my/font-monospace
           :default-weight normal
           :default-height ,my/font-regular-height
           :variable-pitch-family ,my/font-serif
           :variable-pitch-weight normal
           :variable-pitch-height 1.0
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height 1.0
           :bold-weight bold
           :italic-slant italic
           :line-spacing nil)
          
          (writing
           :default-family ,my/font-monospace 
           :default-weight normal
           :default-height ,my/font-writing-height                   
           :variable-pitch-family ,my/font-serif 
           :variable-pitch-weight normal
           :variable-pitch-height 140           
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height ,my/font-writing-height
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (org-reading                          
           :default-family ,my/font-monospace 
           :default-weight normal
           :default-height ,my/font-org-reading-height                   
           :variable-pitch-family ,my/font-serif      
           :variable-pitch-weight normal
           :variable-pitch-height 1.4  
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height ,my/font-org-reading-height
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (presentation
           :default-family ,my/font-monospace 
           :default-weight normal
           :default-height ,my/font-presentation-height   
           :variable-pitch-family ,my/font-serif      
           :variable-pitch-weight normal
           :variable-pitch-height 220           
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height ,my/font-presentation-height
           :bold-weight bold
           :italic-slant italic
           :line-spacing 0.2)
          
          (compact
           :default-family ,my/font-monospace
           :default-weight normal
           :default-height ,my/font-compact-height
           :variable-pitch-family ,my/font-serif
           :variable-pitch-weight normal
           :variable-pitch-height 0.9
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height 1.0
           :bold-weight bold
           :italic-slant italic
           :line-spacing nil)
          
          (large
           :default-family ,my/font-monospace 
           :default-weight normal
           :default-height ,my/font-large-height                  
           :variable-pitch-family ,my/font-serif       
           :variable-pitch-weight normal
           :variable-pitch-height 180           
           :fixed-pitch-family ,my/font-monospace
           :fixed-pitch-height ,my/font-large-height
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

;; -----------------------------------------------------------------------------
;; Ensure icon glyphs can be rendered (GUI frames)
;; -----------------------------------------------------------------------------

(when (display-graphic-p)
  ;; Private Use Areas (PUA) where Nerd Font glyphs live.
  ;; Append ensures we don't clobber your main text fonts.
  (when (and my/font-nerd-symbols (member my/font-nerd-symbols (font-family-list)))
    (set-fontset-font t '(#xE000 . #xF8FF) (font-spec :family my/font-nerd-symbols) nil 'append)
    (set-fontset-font t '(#xF0000 . #xFFFFD) (font-spec :family my/font-nerd-symbols) nil 'append)))

;; Configure nerd-icons to use the symbols font when available.
(with-eval-after-load 'nerd-icons
  (when (boundp 'nerd-icons-font-family)
    (setq nerd-icons-font-family my/font-nerd-symbols))
  (when (fboundp 'nerd-icons-set-fontset-font)
    (nerd-icons-set-fontset-font)))

;; ============================================================================
;; Explicitly set variable-pitch and fixed-pitch faces
;; ============================================================================
;; Ensure variable-pitch and fixed-pitch faces use the correct fonts
;; This is critical for mixed-pitch-mode in org-mode

;; Define function early to prevent void function errors
(defun my/set-variable-fixed-pitch-faces ()
  "Set variable-pitch and fixed-pitch faces to use configured fonts.
Heights are managed by fontaine, so we only set the font families here.
Only applies in graphical displays."
  (when (display-graphic-p)
    ;; Verify fonts are available
    (let ((serif-font (if (and (boundp 'my/font-serif)
                               (member my/font-serif (font-family-list)))
                          my/font-serif
                        (my/font-first-available '("Literata" "Serif" "Times New Roman" "Times"))))
          (mono-font (if (and (boundp 'my/font-monospace)
                              (member my/font-monospace (font-family-list)))
                         my/font-monospace
                       (my/font-first-available '("Adwaita Mono" "Monospace" "Courier New")))))
      ;; Set variable-pitch face to use serif font (for prose)
      ;; Don't set height - let fontaine manage it
      (set-face-attribute 'variable-pitch nil
                          :family serif-font)
      ;; Set fixed-pitch face to use monospace font (for code/tables)
      ;; Don't set height - let fontaine manage it
      (set-face-attribute 'fixed-pitch nil
                          :family mono-font)
      ;; Also set default face to use monospace (fontaine will set the height)
      (set-face-attribute 'default nil
                          :family mono-font))))

;; Only apply configuration in graphical mode
(when (display-graphic-p)
  
  ;; Apply after fontaine loads (fontaine may override, so we apply after)
  (with-eval-after-load 'fontaine
    (my/set-variable-fixed-pitch-faces)
    ;; Reapply after fontaine sets a preset
    (advice-add 'fontaine-set-preset :after
                (lambda (&rest _args)
                  (my/set-variable-fixed-pitch-faces))))
  
  ;; Also apply immediately if fontaine is already loaded
  (when (boundp 'fontaine-presets)
    (my/set-variable-fixed-pitch-faces))
  
  ;; Apply on frame creation (important for daemon mode)
  (add-hook 'after-make-frame-functions
            (lambda (frame)
              (when (display-graphic-p frame)
                (my/set-variable-fixed-pitch-faces)))))

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

(provide 'ck-fonts)
