;;; dashboard.el --- Dashboard startup screen configuration

;; ============================================================================
;; Dashboard Configuration - Startup screen configuration
;; ============================================================================

(defvar my/dashboard-footer-messages
  '("Happy hacking!"
    "GNU Emacs - An extensible, customizable, free text editor"
    "Org-mode: Your life in plain text"
    "Free software, free society!"
    "The journey of a thousand miles begins with a single commit."
    "Nature does not hurry, yet everything is accomplished."
    "He who knows others is wise; he who knows himself is enlightened."
    "In the midst of chaos, there is also opportunity."
    "Appear weak when you are strong, and strong when you are weak."
    "The power of plain text"
    "Productivity through simplicity"
    "Code with passion, create with purpose"
    "Every expert was once a beginner"
    "Turn coffee into code"
    "Programming is an art form")
  "List of motivational messages for dashboard footer.")

(defun my/dashboard-random-banner ()
  "Select a random ASCII art banner from the dashboard directory."
  (let* ((dashboard-dir "~/.config/emacs/banner")
         (banner-files (directory-files dashboard-dir nil "\\.txt$")))
    (if banner-files
        (let ((random-banner (nth (random (length banner-files)) banner-files)))
          (expand-file-name random-banner dashboard-dir))
      nil)))

;; ============================================================================
;; Dashboard Configuration
;; ============================================================================

;; Configure dashboard settings before loading
(setq dashboard-startup-banner (my/dashboard-random-banner)         ; Random ASCII banner
      dashboard-show-shortcuts t                                    ; Show keyboard shortcuts
      dashboard-items `((recents   . 5)   ; Recent files list
                        (bookmarks . 5)   ; Bookmarks list
                        (agenda    . 10)) ; Agenda list
      dashboard-startupify-list '(dashboard-insert-banner          ; Layout order for dashboard
                                  dashboard-insert-newline
                                  dashboard-insert-banner-title
                                  dashboard-insert-newline
                                  dashboard-insert-init-info
                                  dashboard-insert-newline
                                  dashboard-insert-items
                                  dashboard-insert-newline
                                  dashboard-insert-footer)
      dashboard-set-heading-icons t                             ; Show icons for headings
      dashboard-set-file-icons t                                ; Show icons for files
      dashboard-icon-type 'nerd-icons                           ; Use nerd-icons
      dashboard-display-icons-p t                               ; Display icons
      dashboard-heading-icons '((recents   . "nf-oct-history")  ; Heading icon mappings
                                (bookmarks . "nf-oct-bookmark")
                                (agenda    . "nf-oct-calendar")
                                (projects  . "nf-oct-rocket")
                                (registers . "nf-oct-database"))
      dashboard-footer-messages my/dashboard-footer-messages    ; Random footer messages
      dashboard-footer-icon "🦬"                                ; Footer icon
      dashboard-resize-on-hook nil)                             ; Disable problematic resize hook

(with-eval-after-load 'dashboard
  (dashboard-setup-startup-hook)                       ; Initialize dashboard
  (dashboard-modify-heading-icons '((recents . "nf-oct-history")      ; Recent files icon
                                    (bookmarks . "nf-oct-bookmark")    ; Bookmarks icon
                                    (agenda . "nf-oct-calendar")       ; Agenda icon
                                    (projects . "nf-oct-rocket")))     ; Projects icon
  
  ;; Ensure dashboard is properly displayed
  (add-hook 'dashboard-mode-hook
            (lambda ()
              (when (eq (current-buffer) (get-buffer "*dashboard*"))
                (setq-local line-spacing 0)  ; Disable line spacing in dashboard
                (setq-local spacious-padding-mode nil)  ; Disable spacious padding in dashboard
                (redisplay))))
  
  ;; Force dashboard refresh after all packages are loaded
  (add-hook 'after-init-hook
            (lambda ()
              (run-with-timer 0.1 nil
                             (lambda ()
                               (when (get-buffer "*dashboard*")
                                 (with-current-buffer "*dashboard*"
                                   (dashboard-refresh-buffer)
                                   ;; Clear any overlays that might be covering the dashboard
                                   (remove-overlays (point-min) (point-max))
                                   (redisplay))))))
  
  ;; Clear overlays when switching to dashboard
  (add-hook 'window-buffer-change-functions
            (lambda (window)
              (when (and window
                         (windowp window)
                         (eq (window-buffer window) (get-buffer "*dashboard*")))
                (with-current-buffer "*dashboard*"
                  (remove-overlays (point-min) (point-max))
                  (redisplay))))))
)
(provide 'dashboard-config)
