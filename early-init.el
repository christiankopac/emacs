;; Disable built-in package manager
(setq package-enable-at-startup nil)

;; Prevent built-in Org from loading by removing it from load-path
(setq load-path (remove (expand-file-name "lisp/org" data-directory) load-path))
(setq load-path (remove (expand-file-name "lisp/org" installation-directory) load-path))

;; Disable some GUI elements early
(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t)

;; Set frame parameters before display
(setq default-frame-alist
      '((background-color . "#2B3339") 
        (foreground-color . "#D1D3CE")
        (vertical-scroll-bars . nil)
        (horizontal-scroll-bars . nil)))

;; Disable scrollbars globally - NO SCROLLBARS EVER
;; Call the mode functions with -1 to disable (don't use setq on mode functions!)
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'horizontal-scroll-bar-mode)
  (horizontal-scroll-bar-mode -1))

;; Force disable scrollbars on all frames (current and future)
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (set-frame-parameter frame 'vertical-scroll-bars nil)
            (set-frame-parameter frame 'horizontal-scroll-bars nil)))

;; Disable scrollbars on existing frames
(dolist (frame (frame-list))
  (set-frame-parameter frame 'vertical-scroll-bars nil)
  (set-frame-parameter frame 'horizontal-scroll-bars nil))

;; Prevent white flash
(setq frame-inhibit-implied-resize t)