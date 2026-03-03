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
;; ============================================================================
;; Fullscreen / maximize helpers
;; - `my/toggle-frame-fullscreen' toggles the frame's fullscreen state reliably.
;; - `my/toggle-window-maximize' toggles between a single-window layout and the
;;   previous window configuration (so restore works as expected).
;; ============================================================================

(defvar my/previous-window-configuration nil
  "Saved window configuration for toggling window maximize/restore.")

(defvar my/previous-frame-fullscreen nil
  "Saved previous frame 'fullscreen' parameter for toggling fullscreen.")

(defun my/toggle-frame-fullscreen ()
  "Toggle the current frame's fullscreen state between 'fullboth' and nil.
This stores the previous value so the toggle works both directions." 
  (interactive)
  (let ((cur (frame-parameter nil 'fullscreen)))
    (if (memq cur '(fullboth fullscreen maximized full-screen))
        (progn
          (set-frame-parameter nil 'fullscreen my/previous-frame-fullscreen)
          (setq my/previous-frame-fullscreen nil))
      (setq my/previous-frame-fullscreen cur)
      (set-frame-parameter nil 'fullscreen 'fullboth))))

(defun my/toggle-window-maximize ()
  "Toggle a simple maximize for the current window.
When multiple windows are present the current configuration is saved and
`delete-other-windows' is used. When called again it restores the saved
configuration (if any)." 
  (interactive)
  (if (> (length (window-list)) 1)
      (progn
        (setq my/previous-window-configuration (current-window-configuration))
        (delete-other-windows))
    (when my/previous-window-configuration
      (set-window-configuration my/previous-window-configuration)
      (setq my/previous-window-configuration nil))))

;; Keybindings for toggles
(global-set-key (kbd "<f11>") 'my/toggle-frame-fullscreen)
(global-set-key (kbd "C-c M-<f11>") 'my/toggle-window-maximize)
(provide 'navigation)
