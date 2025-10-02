;;; denote.el --- Denote note-taking system configuration

;; ----------------------------------------------------------------------------
;; Prefer ripgrep, then ugrep, otherwise use grep
;; Prefer ripgrep, then ugrep, and fall back to regular grep.
(setq xref-search-program
      (cond
       ((or (executable-find "ripgrep")
            (executable-find "rg"))
        'ripgrep)
       ((executable-find "ugrep")
        'ugrep)
       (t
        'grep)))

;; ============================================================================
;; Backlinks buffer display helper functions
;; ============================================================================

(defun my-denote-backlink-heading (file)
  "Show only the title, nothing else."
  (or (denote-retrieve-title-or-filename file (denote-filetype-heuristics file))
      "[No title]"))

;; Compatibility shims for different Denote versions
(unless (fboundp 'denote-retrieve-filename-identifier)
  (defalias 'denote-retrieve-filename-identifier 'denote-extract-id-from-string
    "Compatibility shim for older Denote versions."))

(unless (fboundp 'denote-get-backlinks)
  (defalias 'denote-get-backlinks 'denote-backlinks-get
    "Compatibility shim for older Denote versions."))

(unless (fboundp 'denote-retrieve-front-matter-title-value)
  (defalias 'denote-retrieve-front-matter-title-value 'denote-retrieve-title-value
    "Compatibility shim for older Denote versions."))

;; ============================================================================
;; Core Denote Configuration
;; ============================================================================

;; Denote configuration
(setq denote-directory "~/Sync/org/notes/")
(setq denote-infer-keywords t)
(setq denote-sort-keywords t)
(setq denote-file-type 'org)
(setq denote-prompts '(title keywords subdirectory))
(setq denote-allow-multi-word-keywords t)
(setq denote-date-prompt-use-org-read-date t)
(setq denote-save-files t)
(setq denote-known-keywords '("fleeting" "permanent" "literature" "reference" "project" "movie" "daily" "journal"))
(setq denote-subdirectories '("fleeting" "permanent" "literature" "movies"))
(setq denote-query-format-heading-function #'my-denote-backlink-heading)
(setq denote-query-sorting 'last-modified)
(setq denote-backlinks-display-buffer-action
      '(;;(display-buffer-in-side-window)
        (display-buffer-reuse-window display-buffer-in-side-window)
        (side . bottom)
        (dedicated . t)
        (window-width . 45)
        (slot . 0)
        (preserve-size . (t .t))
        (window-parameters . ((no-delete-other-windows . t)))))
;; Hide link paths, show only filenames
(setq denote-backlinks-show-context nil)
(setq denote-backlinks-show-files t)
;; Enable line wrapping in backlinks buffer
(setq denote-backlinks-buffer-major-mode 'org-mode)
;; Clean link descriptions
(setq denote-link-description-format "%t")

;; Denote hooks
(add-hook 'denote-query-mode-hook
          (lambda ()
            (outline-hide-body)
            (setq-local outline-minor-mode-highlight 'override)
            (read-only-mode 1)))

(add-hook 'denote-query-mode-hook
          (lambda ()
            (visual-line-mode 1)
            (setq-local truncate-lines nil)
            (setq-local word-wrap t)))

;; Denote key bindings
(global-set-key (kbd "C-c d n") 'denote)
(global-set-key (kbd "C-c d N") 'denote-subdirectory)
(global-set-key (kbd "C-c d f") 'denote-open-or-create)
(global-set-key (kbd "C-c d l") 'denote-link)
(global-set-key (kbd "C-c d b") 'denote-backlinks)
(global-set-key (kbd "C-c d t") 'denote-backlinks-toggle-context)

(custom-set-faces
 '(outline-1 ((t (:weight bold :height 1.1))))
 '(denote-faces-link ((t (:foreground "#8be9fd" :underline t))))
 '(xref-line-number ((t (:inherit line-number))))
 '(xref-match ((t (:inherit isearch)))))

;; ============================================================================
;; Helper Functions: Date and File Operations
;; ============================================================================

(defun my/denote-date ()
  "Insert current date in Denote format."
  (interactive)
  (insert (format-time-string "%Y%m%d")))

(defun my/denote-datetime ()
  "Insert current datetime in Denote format."
  (interactive)
  (insert (format-time-string "%Y%m%dT%H%M%S")))

(defun my/denote-today ()
  "Open or create today's daily note."
  (interactive)
  (let ((today (format-time-string "%Y%m%d")))
    (denote-open-or-create
     (format "%s--daily-note__daily" today)
     'org)))

;; ============================================================================
;; Denote Menu Integration
;; ============================================================================

;; Denote Menu configuration
(setq denote-menu-file-name-column-width 50)
(setq denote-menu-date-column-width 12)
(setq denote-menu-keywords-column-width 30)
(setq denote-menu-sort-files 'denote-menu-sort-by-modification-date)
(global-set-key (kbd "C-c d m") 'denote-menu)

;; ============================================================================
;; Denote Markdown Support
;; ============================================================================

;; (use-package denote-markdown
;;   :ensure t
;;   :after denote
;;   :config
;;   (when (boundp 'denote-file-types)
;;     (add-to-list 'denote-file-types 'markdown)))

;; ============================================================================
;; Denote Org Support
;; ============================================================================

;; (use-package denote-org
;;   :ensure t
;;   :after denote)

;; ============================================================================
;; Denote Silo Support
;; ============================================================================

;; (use-package denote-silo
;;   :ensure t
;;   :after denote
;;   :config
;;   (when (boundp 'denote-directory)
;;     (setq denote-silo-directory denote-directory)))

;; ============================================================================
;; Consult Integration
;; ============================================================================

;; Consult Denote key bindings
(global-set-key (kbd "C-c d r") 'consult-denote)
(global-set-key (kbd "C-c d R") 'consult-denote-in-context)

;; ============================================================================
;; Key Bindings
;; ============================================================================

;; Additional global key bindings
(global-set-key (kbd "C-c d t") 'my/denote-today)
(global-set-key (kbd "C-c d d") 'my/denote-date)
(global-set-key (kbd "C-c d D") 'my/denote-datetime)

;; ============================================================================
;; Templates and Workflows
;; ============================================================================

;; Daily note template
(defun my/denote-daily-note-template ()
  "Template for daily notes."
  (concat
   "#+title: %^{Title}\n"
   "#+date: " (format-time-string "[%Y-%m-%d %a %H:%M]") "\n"
   "#+filetags: :daily:\n\n"
   "* Morning\n"
   "- \n\n"
   "* Afternoon\n"
   "- \n\n"
   "* Evening\n"
   "- \n\n"
   "* Notes\n"
   "- \n\n"
   "* Tomorrow\n"
   "- \n"))

;; Project note template
(defun my/denote-project-note-template ()
  "Template for project notes."
  (concat
   "#+title: %^{Project Title}\n"
   "#+date: " (format-time-string "[%Y-%m-%d %a %H:%M]") "\n"
   "#+filetags: :project:\n\n"
   "* Overview\n"
   "%?\n\n"
   "* Goals\n"
   "- [ ] \n\n"
   "* Tasks\n"
   "- [ ] \n\n"
   "* Notes\n"
   "- \n\n"
   "* Resources\n"
   "- \n"))

;; ============================================================================
;; Integration with Other Packages
;; ============================================================================

;; Integration with org-roam (if used)
;; (when (featurep 'org-roam)
;;   (setq denote-org-link-description-function
;;         (lambda (file)
;;           (or (denote-retrieve-title-or-filename file)
;;               (file-name-nondirectory file)))))

;; Integration with embark
(when (featurep 'embark)
  (defun my/denote-embark-actions ()
    "Add denote-specific embark actions."
    (add-to-list 'embark-file-actions
                 '(denote-open-or-create . find-file))
    (add-to-list 'embark-file-actions
                 '(denote-link . denote-link))))

;; ============================================================================
;; Customization and Themes
;; ============================================================================

;; Custom faces for denote
(defface denote-faces-link
  '((t (:foreground "#8be9fd" :underline t)))
  "Face for denote links.")

(defface denote-faces-subdirectory
  '((t (:foreground "#50fa7b" :weight bold)))
  "Face for denote subdirectories.")

(defface denote-faces-keyword
  '((t (:foreground "#ffb86c" :weight bold)))
  "Face for denote keywords.")

;; ============================================================================
;; Utility Functions
;; ============================================================================

(defun my/denote-find-recent-notes (n)
  "Find N most recent denote notes."
  (interactive "nNumber of recent notes: ")
  (let ((notes (denote-directory-files)))
    (setq notes (sort notes (lambda (a b)
                              (time-less-p
                               (nth 5 (file-attributes b))
                               (nth 5 (file-attributes a))))))
    (dolist (note (seq-take notes n))
      (find-file note))))

(defun my/denote-archive-old-notes ()
  "Archive notes older than 1 year."
  (interactive)
  (let ((cutoff (time-subtract (current-time) (* 365 24 60 60))))
    (dolist (file (denote-directory-files))
      (when (time-less-p (nth 5 (file-attributes file)) cutoff)
        (denote-archive-file file)))))

;; ============================================================================
;; End of Configuration
;; ============================================================================

(provide 'denote)
;;; denote.el ends here