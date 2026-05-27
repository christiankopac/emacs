;;; ui-enhancements.el --- UI improvements and visual enhancements

 ;; ============================================================================
;; Spacious Padding Configuration - Add breathing room to UI
;; ============================================================================

(with-eval-after-load 'spacious-padding
  (setq line-spacing 3)                                    ; Extra line spacing
  (setq spacious-padding-subtle-frame-lines               ; Subtle mode-line borders
        `( :mode-line-active 'default
           :mode-line-inactive vertical-border))
  (spacious-padding-mode 1))                              ; Enable spacious padding

;; Beacon - Highlight cursor on jump.
;; beacon-mode is enabled in init.el (deferred 2s). Here we just tune it.
;; Smaller size + bigger jump threshold cut the redraw cost on every motion.
(with-eval-after-load 'beacon
  (setq beacon-color "#ff6c6b"
        beacon-size 20
        beacon-blink-when-point-moves-vertically 15
        beacon-blink-when-point-moves-horizontally nil
        beacon-blink-when-window-scrolls nil
        beacon-blink-when-window-changes t
        beacon-blink-when-focused nil
        beacon-dont-blink-commands '(dashboard-refresh-buffer next-line previous-line)))

;; ============================================================================
;; Helpful Configuration - Better help buffers
;; ============================================================================

(global-set-key (kbd "C-h f") 'helpful-function)          ; Describe function
(global-set-key (kbd "C-h x") 'helpful-command)           ; Describe command
(global-set-key (kbd "C-h k") 'helpful-key)               ; Describe key
(global-set-key (kbd "C-h v") 'helpful-variable)          ; Describe variable

;; ============================================================================
;; Which-key Configuration - Show available keybindings
;; ============================================================================

(with-eval-after-load 'which-key
  (which-key-mode)                                        ; Enable which-key
  (setq which-key-idle-delay 0.1)                         ; Show after 0.1s
  (which-key-add-key-based-replacements                   ; Descriptive labels
    "C-c c" "Capture"
    "C-c a" "Agenda"
    "C-c w d" "Daily Workflow"
    "C-c s s" "Search All denote"
    "C-c x c" "Extract Concept"
    "C-c d" "Denote"))

;; ============================================================================
;; Mood-line Configuration - Moved to init.el
;; ============================================================================

(provide 'ck-ui)
