;;; xeft.el --- Xeft configuration for fast note search and creation

;; ============================================================================
;; Xeft Configuration
;; ============================================================================

;; Set the directory where xeft will search for notes
;; This should match your denote directory or notes directory
(setq xeft-directory (expand-file-name "~/org/denote"))

;; Enable recursive search in subdirectories
(setq xeft-recursive t)

;; Customize filename generation for new notes
;; This function creates a filename from the search phrase
(defun my/xeft-filename-fn (phrase)
  "Generate filename from search phrase for xeft."
  (let ((clean-phrase (replace-regexp-in-string "[^a-zA-Z0-9_-]" "-" phrase)))
    (downcase (string-trim clean-phrase "-"))))

(setq xeft-filename-fn #'my/xeft-filename-fn)

;; File filter to include only relevant files
;; This can be customized based on your file types
(setq xeft-file-filter
      (lambda (file)
        "Filter files for xeft indexing."
        (and (file-regular-p file)
             (not (string-match-p "\\.git" file))
             (not (string-match-p "\\.DS_Store" file))
             (or (string-match-p "\\.org$" file)
                 (string-match-p "\\.md$" file)
                 (string-match-p "\\.txt$" file)))))

;; Customize the display format for search results
(setq xeft-display-fn
      (lambda (file)
        "Custom display format for xeft results."
        (let ((basename (file-name-base file))
              (dir (file-name-directory file)))
          (if (string= dir xeft-directory)
              basename
            (format "%s (%s)" basename (file-name-nondirectory (directory-file-name dir)))))))

;; ============================================================================
;; Xeft Keybindings
;; ============================================================================

;; Global keybindings for xeft - using C-c z prefix (no conflicts found)
(global-set-key (kbd "C-c z f") 'xeft)
(global-set-key (kbd "C-c z n") 'xeft-new-note)
(global-set-key (kbd "C-c z s") 'xeft-search)

;; ============================================================================
;; Xeft Hooks and Customization
;; ============================================================================

;; Hook to run after xeft is loaded
(with-eval-after-load 'xeft
  ;; Customize the xeft buffer appearance
  (setq xeft-buffer-name "*xeft*")
  
  ;; Set up custom faces for better visual distinction
  (when (facep 'xeft-match)
    (set-face-attribute 'xeft-match nil
                        :foreground "#88c0d0"
                        :weight 'bold))
  
  (when (facep 'xeft-preview)
    (set-face-attribute 'xeft-preview nil
                        :foreground "#81a1c1"
                        :background "#2e3440")))

;; ============================================================================
;; Integration with other packages
;; ============================================================================

;; Integration with denote (if using denote for note management)
(when (boundp 'denote-directory)
  (setq xeft-directory denote-directory))

;; Integration with org-mode
(with-eval-after-load 'org
  ;; Add xeft search to org-mode keymap
  (define-key org-mode-map (kbd "C-c z f") 'xeft))

;; ============================================================================
;; Custom Functions
;; ============================================================================

(defun my/xeft-quick-search (query)
  "Quick search with xeft using a query string."
  (interactive "sSearch query: ")
  (xeft)
  (insert query))

(defun my/xeft-search-current-word ()
  "Search for the word at point using xeft."
  (interactive)
  (let ((word (thing-at-point 'word)))
    (if word
        (my/xeft-quick-search word)
      (message "No word at point"))))

;; Add keybinding for quick search
(global-set-key (kbd "C-c z w") 'my/xeft-search-current-word)

(provide 'ck-xeft)

