;; Disable built-in package manager
(setq package-enable-at-startup nil)

;; Prevent built-in Org from loading by removing it from load-path
(setq load-path (remove (expand-file-name "lisp/org" data-directory) load-path))
(setq load-path (remove (expand-file-name "lisp/org" installation-directory) load-path))

;; Disable some GUI elements early
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;; Set frame parameters before display - only in GUI mode
;; In terminal mode, let the terminal handle colors
(when (display-graphic-p)
  (setq default-frame-alist
        '((vertical-scroll-bars . nil)
          (horizontal-scroll-bars . nil)
          ;; Start maximized (use 'fullboth for true fullscreen)
          (fullscreen . maximized)
          ;; Hide title bar and window decorations (may cause issues on some systems)
          ;; (undecorated . t)  ; Commented out - can cause cropping issues
          ;; Set minimal borders to prevent cropping
          (internal-border-width . 0)
          (right-divider-width . 0))))

;; Disable scrollbars globally - NO SCROLLBARS EVER
;; Only attempt to disable scroll bars if we're in a GUI environment
(when (display-graphic-p)
  (when (fboundp 'scroll-bar-mode)
    (condition-case nil
        (scroll-bar-mode -1)
      (error nil)))
  (when (fboundp 'horizontal-scroll-bar-mode)
    (condition-case nil
        (horizontal-scroll-bar-mode -1)
      (error nil))))

;; Force disable scrollbars, maximize, and set borders on all frames (current and future)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (set-frame-parameter frame 'vertical-scroll-bars nil)
              (set-frame-parameter frame 'horizontal-scroll-bars nil)
              (set-frame-parameter frame 'fullscreen 'maximized)
              ;; (set-frame-parameter frame 'undecorated t)  ; Commented out - can cause cropping
              (set-frame-parameter frame 'internal-border-width 0)
              (set-frame-parameter frame 'right-divider-width 0))))

;; Disable scrollbars and set borders on existing frames
(when (display-graphic-p)
  (dolist (frame (frame-list))
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'vertical-scroll-bars nil)
      (set-frame-parameter frame 'horizontal-scroll-bars nil)
      ;; (set-frame-parameter frame 'undecorated t)  ; Commented out - can cause cropping
      (set-frame-parameter frame 'internal-border-width 0)
      (set-frame-parameter frame 'right-divider-width 0))))

;; Prevent white flash
(setq frame-inhibit-implied-resize t)

;; Maximize frame and set borders on startup (GUI only)
(when (display-graphic-p)
  (add-hook 'window-setup-hook
            (lambda ()
              (set-frame-parameter nil 'fullscreen 'maximized)
              ;; (set-frame-parameter nil 'undecorated t)  ; Commented out - can cause cropping
              (set-frame-parameter nil 'internal-border-width 0)
              (set-frame-parameter nil 'right-divider-width 0))))