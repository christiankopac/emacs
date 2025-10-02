;; Disable built-in package manager
(setq package-enable-at-startup nil)

;; Prevent built-in Org from loading by removing it from load-path
(setq load-path (remove (expand-file-name "lisp/org" data-directory) load-path))
(setq load-path (remove (expand-file-name "lisp/org" installation-directory) load-path))
