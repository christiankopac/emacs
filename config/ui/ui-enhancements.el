;;; ui-enhancements.el --- UI improvements and visual enhancements

;; Spacious padding - Add breathing room to UI
(with-eval-after-load 'spacious-padding
  (setq line-spacing 3)                                    ; Extra line spacing
  (setq spacious-padding-subtle-frame-lines               ; Subtle mode-line borders
        `( :mode-line-active 'default
           :mode-line-inactive vertical-border))
  (spacious-padding-mode 1))                              ; Enable spacious padding

;; Beacon - Highlight cursor on jump
(with-eval-after-load 'beacon
  (beacon-mode 1)                                         ; Enable beacon
  (setq beacon-color "#ff6c6b"                            ; Red color
        beacon-size 40                                    ; Size of beacon
        beacon-blink-when-point-moves-vertically 10       ; Blink after 10 lines
        beacon-blink-when-window-scrolls t                ; Blink on scroll
        beacon-blink-when-focused t                       ; Blink on window focus
        beacon-dont-blink-commands '(dashboard-refresh-buffer))) ; Don't blink on dashboard refresh

;; Helpful - Better help buffers
(global-set-key (kbd "C-h f") 'helpful-function)          ; Describe function
(global-set-key (kbd "C-h x") 'helpful-command)           ; Describe command
(global-set-key (kbd "C-h k") 'helpful-key)               ; Describe key
(global-set-key (kbd "C-h v") 'helpful-variable)          ; Describe variable

;; Which-key - Show available keybindings
(with-eval-after-load 'which-key
  (which-key-mode)                                        ; Enable which-key
  (setq which-key-idle-delay 0.1)                         ; Show after 0.1s
  (which-key-add-key-based-replacements                   ; Descriptive labels
    "C-c c" "Capture"
    "C-c a" "Agenda"
    "C-c w d" "Daily Workflow"
    "C-c s s" "Search All Notes"
    "C-c x c" "Extract Concept"
    "C-c d" "Denote"))

(provide 'ui-enhancements)
