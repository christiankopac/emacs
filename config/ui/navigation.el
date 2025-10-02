;;; navigation.el --- Navigation and movement tools

;; ============================================================================
;; Recentf Configuration - Track recently opened files
;; ============================================================================

(recentf-mode t)                                          ; Enable recentf
(setq recentf-max-saved-items 50)                         ; Remember 50 files
(global-set-key (kbd "C-c w r") 'recentf-open)            ; Open recent file

;; ============================================================================
;; Bookmarks Configuration - Persistent bookmarks
;; ============================================================================

(setq bookmark-save-flag 1)                               ; Save after each bookmark
(global-set-key (kbd "C-x r d") 'bookmark-delete)         ; Delete bookmark

;; ============================================================================
;; Vundo Configuration - Visual undo tree
;; ============================================================================

(global-set-key (kbd "C-x u") 'vundo)                     ; Open undo tree
(with-eval-after-load 'vundo
  (setq vundo-compact-display t                           ; Compact display
        vundo-window-side 'right))                        ; Show on right side

;; ============================================================================
;; Ace window Configuration - Quick window switching
;; ============================================================================

(global-set-key (kbd "M-p") 'ace-window)                  ; Switch window
(with-eval-after-load 'ace-window
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)            ; Home row keys
        aw-background nil                                 ; No background dimming
        aw-dispatch-always t                              ; Always show dispatch menu
        aw-scope 'frame))                                 ; Current frame only

;; ============================================================================
;; Avy Configuration - Jump to visible text
;; ============================================================================

(global-set-key (kbd "C-:") 'avy-goto-char)               ; Jump to character
(global-set-key (kbd "C-'") 'avy-goto-char-2)             ; Jump to 2 characters
(global-set-key (kbd "M-g f") 'avy-goto-line)             ; Jump to line
(global-set-key (kbd "M-g w") 'avy-goto-word-1)           ; Jump to word

(provide 'navigation)
