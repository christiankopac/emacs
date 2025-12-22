;;; ox-hugo.el --- Hugo workflow configuration

;; ============================================================================
;; ox-hugo Configuration
;; ============================================================================

(require 'ox-hugo)

;; Set Hugo base directory (where the Hugo site lives)
;; Customize this path to point to your Hugo site
(setq org-hugo-base-dir (expand-file-name "~/src/my_domains/kopac_ch/"))

;; Set directory where org source files are stored
;; Customize this path to point to your org notes directory
(setq my/hugo-org-dir (expand-file-name "~/org/blog/"))

;; Default frontmatter format (TOML for your site)
(setq org-hugo-front-matter-format "toml")

;; Auto-set lastmod to current date when exporting
(setq org-hugo-auto-set-lastmod t)

;; Use property drawers for frontmatter
(setq org-hugo-use-code-for-kbd t)

;; ============================================================================
;; Hugo Helper Functions
;; ============================================================================

(defun my/hugo-new-post (title)
  "Create a new Hugo blog post in Org format with TITLE."
  (interactive "sPost title: ")
  (let* ((slug (replace-regexp-in-string
                "[^a-z0-9]+" "-"
                (downcase title)))
         (date (format-time-string "%Y-%m-%d"))
         (org-dir (expand-file-name "posts/" my/hugo-org-dir))
         (filename (expand-file-name (format "%s-%s.org" date slug) org-dir)))

    ;; Create directory if it doesn't exist
    (unless (file-directory-p org-dir)
      (make-directory org-dir t))

    ;; Create and open the file
    (find-file filename)

    ;; Insert template
    (insert (format "#+TITLE: %s
#+DATE: %s
#+HUGO_BASE_DIR: %s
#+HUGO_SECTION: posts
#+HUGO_CATEGORIES:
#+HUGO_TAGS:
#+HUGO_DRAFT: true
#+HUGO_AUTO_SET_LASTMOD: t
#+DESCRIPTION:

* %s

" title date org-hugo-base-dir title))

    ;; Position cursor
    (goto-char (point-min))
    (search-forward "#+HUGO_CATEGORIES: " nil t)
    (message "Created new post: %s" filename)))

(defun my/hugo-new-page (section title)
  "Create a new Hugo page in SECTION with TITLE."
  (interactive
   (list
    (completing-read "Section: "
                     '("about" "now" "picks" "consumed" "playlists" "log"))
    (read-string "Page title: ")))
  (let* ((slug (replace-regexp-in-string
                "[^a-z0-9]+" "-"
                (downcase title)))
         (date (format-time-string "%Y-%m-%d"))
         (org-dir (expand-file-name (format "%s/" section) my/hugo-org-dir))
         (filename (expand-file-name (format "%s.org" slug) org-dir)))

    ;; Create directory if it doesn't exist
    (unless (file-directory-p org-dir)
      (make-directory org-dir t))

    ;; Create and open the file
    (find-file filename)

    ;; Insert template
    (insert (format "#+TITLE: %s
#+DATE: %s
#+HUGO_BASE_DIR: %s
#+HUGO_SECTION: %s
#+HUGO_DRAFT: false
#+HUGO_AUTO_SET_LASTMOD: t
#+DESCRIPTION:

* %s

" title date org-hugo-base-dir section title))

    ;; Position cursor
    (goto-char (point-min))
    (search-forward "#+DESCRIPTION: " nil t)
    (end-of-line)
    (message "Created new page: %s" filename)))

(defun my/hugo-export-and-build ()
  "Export current org file to Hugo and build the site."
  (interactive)
  (when (eq major-mode 'org-mode)
    (org-hugo-export-to-md)
    (message "Exported to Hugo markdown")
    (when (y-or-n-p "Build Hugo site? ")
      (let ((default-directory org-hugo-base-dir))
        (async-shell-command "hugo" "*hugo-build*")
        (message "Building Hugo site...")))))

(defun my/hugo-export-and-serve ()
  "Export current org file to Hugo and start Hugo server."
  (interactive)
  (when (eq major-mode 'org-mode)
    (org-hugo-export-to-md)
    (message "Exported to Hugo markdown")
    (let ((default-directory org-hugo-base-dir))
      (async-shell-command "hugo server -D" "*hugo-server*")
      (message "Hugo server started at http://localhost:1313"))))

(defun my/hugo-open-site ()
  "Open Hugo site directory in dired."
  (interactive)
  (dired org-hugo-base-dir))

(defun my/hugo-open-content ()
  "Open Hugo org source directory in dired."
  (interactive)
  (unless (file-directory-p my/hugo-org-dir)
    (make-directory my/hugo-org-dir t))
  (dired my/hugo-org-dir))

(defun my/hugo-publish ()
  "Export all org files in ~/org/blog/ to Hugo markdown."
  (interactive)
  (let ((org-files (directory-files-recursively my/hugo-org-dir "\\.org$")))
    (if (null org-files)
        (message "No org files found in %s" my/hugo-org-dir)
      (dolist (file org-files)
        (with-current-buffer (find-file-noselect file)
          (org-hugo-export-to-md)))
      (message "Exported %d org files to Hugo" (length org-files)))))

;; ============================================================================
;; Hugo Keybindings
;; ============================================================================

;; Global keybindings (available everywhere)
(global-set-key (kbd "C-c h n") 'my/hugo-new-post)      ; New post
(global-set-key (kbd "C-c h p") 'my/hugo-new-page)      ; New page
(global-set-key (kbd "C-c h o") 'my/hugo-open-content)  ; Open org-content dir
(global-set-key (kbd "C-c h s") 'my/hugo-open-site)     ; Open site dir
(global-set-key (kbd "C-c h P") 'my/hugo-publish)       ; Publish all

;; Org-mode specific keybindings
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c h e") 'org-hugo-export-to-md)          ; Export to markdown
  (define-key org-mode-map (kbd "C-c h b") 'my/hugo-export-and-build)       ; Export and build
  (define-key org-mode-map (kbd "C-c h v") 'my/hugo-export-and-serve))      ; Export and serve

;; ============================================================================
;; Auto-export on save (optional - uncomment to enable)
;; ============================================================================

;; Automatically export to Hugo markdown when saving org files in ~/org/blog/
;; (defun my/hugo-auto-export ()
;;   "Auto-export to Hugo if file is in Hugo org directory."
;;   (when (and (eq major-mode 'org-mode)
;;              (string-prefix-p my/hugo-org-dir (buffer-file-name)))
;;     (org-hugo-export-to-md)))
;;
;; (add-hook 'after-save-hook #'my/hugo-auto-export)

(provide 'ox-hugo-config)
;;; ox-hugo.el ends here
