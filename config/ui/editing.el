;;; editing.el --- Text editing enhancements

;; ============================================================================
;; Smartparens Configuration - Intelligent parenthesis handling
;; ============================================================================

(with-eval-after-load 'smartparens
  (add-hook 'prog-mode-hook #'smartparens-mode)           ; Enable in programming modes
  (require 'smartparens-config))                          ; Load default config

;; ============================================================================
;; Expand region Configuration - Intelligently expand selection
;; ============================================================================

;; Expand region - Intelligently expand selection
(global-set-key (kbd "C-=") 'er/expand-region)            ; Expand selection incrementally

;; Multiple cursors - Edit multiple locations
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)       ; Edit all lines in region
(global-set-key (kbd "C->") 'mc/mark-next-like-this)      ; Mark next occurrence
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)  ; Mark previous occurrence

(provide 'editing)
