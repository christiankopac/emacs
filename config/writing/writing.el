;;; writing.el --- Writing and documentation configuration

;; ----------------------------------------------------------------------------
;; Markdown Mode
;; ----------------------------------------------------------------------------

;; Note: LSP is not configured, so we don't enable it for markdown
(setq markdown-command "multimarkdown"                   ; Use multimarkdown for preview
      markdown-fontify-code-blocks-natively t            ; Syntax highlight code blocks
      markdown-hide-urls t)                              ; Show link text, hide URLs

;; ----------------------------------------------------------------------------
;; Text Mode
;; ----------------------------------------------------------------------------

(add-hook 'text-mode-hook 'visual-line-mode)             ; Wrap lines at word boundaries
(delete-selection-mode t)                                ; Replace selection when typing
(setq sentence-end-double-space nil                      ; Single space ends sentence
      scroll-error-top-bottom t                          ; Wrap at top/bottom of buffer
      save-interprogram-paste-before-kill t)             ; Save clipboard before kill

;; ----------------------------------------------------------------------------
;; Document Viewing
;; ----------------------------------------------------------------------------

;; Doc-view - View PDFs and documents
(setq doc-view-resolution 300                            ; High resolution (300 DPI)
      large-file-warning-threshold (* 50 (expt 2 20)))   ; Warn at 50MB

;; Dictionary - Word definitions
(setq dictionary-server "dict.org")                      ; Dictionary server
(global-set-key (kbd "C-c w s d") 'dictionary-lookup-definition)  ; Look up word

;; PDF tools - Enhanced PDF viewing
(with-eval-after-load 'pdf-tools
  (pdf-tools-install)                                    ; Install PDF tools
  (setq pdf-view-incompatible-modes                      ; Remove line numbers from incompatible modes
        (delq 'display-line-numbers-mode pdf-view-incompatible-modes)))

;; ----------------------------------------------------------------------------
;; Distraction-Free Writing
;; ----------------------------------------------------------------------------

;; Olivetti - Centered text for focused writing
(setq olivetti-body-width 80                             ; Text width (80 columns)
      olivetti-minimum-body-width 50                     ; Minimum width
      olivetti-style 'fancy                              ; Fancy margins
      olivetti-recall-visual-line-mode-entry-state t)    ; Remember visual-line-mode state

(global-set-key (kbd "C-c w o") 'olivetti-mode)          ; Toggle olivetti mode
(global-set-key (kbd "C-c w c") 'olivetti-set-width)     ; Set text width

;; Which-key labels for olivetti
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c w o" "󰞌 Olivetti Mode"
    "C-c w c" "󰞌 Set Width"))

;; ----------------------------------------------------------------------------
;; Spell Checking
;; ----------------------------------------------------------------------------

;; Jinx - Modern spell checker using enchant
(setq jinx-languages "en_US es_any sl_SI de_DE"          ; Languages: English, Spanish, Slovenian, German
      jinx-camel-case t)                                 ; Check camelCase words

(global-set-key (kbd "M-$") 'jinx-correct)               ; Correct word at point
(global-set-key (kbd "C-M-$") 'jinx-languages)           ; Change language

;; Enable jinx in appropriate modes
(with-eval-after-load 'jinx
  (add-hook 'prog-mode-hook #'jinx-mode)                 ; Spell check in comments/strings
  (add-hook 'text-mode-hook #'jinx-mode)                 ; Spell check text files
  (add-hook 'org-mode-hook #'jinx-mode))                 ; Spell check org files

;; Custom face for misspelled words (use 'unspecified' if theme face not yet set)
(custom-set-faces
 `(jinx-misspelled ((t (:underline t :foreground ,(or (face-foreground 'font-lock-warning-face nil t) 'unspecified))))))

(provide 'writing)