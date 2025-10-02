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
        (horizontal-scroll-bars . nil)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)))

;; Prevent white flash
(setq frame-inhibit-implied-resize t)