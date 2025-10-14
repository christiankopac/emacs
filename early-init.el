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
          (horizontal-scroll-bars . nil))))

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

;; Force disable scrollbars on all frames (current and future)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (set-frame-parameter frame 'vertical-scroll-bars nil)
              (set-frame-parameter frame 'horizontal-scroll-bars nil))))

;; Disable scrollbars on existing frames
(when (display-graphic-p)
  (dolist (frame (frame-list))
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'vertical-scroll-bars nil)
      (set-frame-parameter frame 'horizontal-scroll-bars nil))))

;; Prevent white flash
(setq frame-inhibit-implied-resize t)