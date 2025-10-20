;;; custom-functions.el --- Custom utility functions

;; ----------------------------------------------------------------------------
;; Theme Functions
;; ----------------------------------------------------------------------------

;; File-type-specific theme configuration
(defvar my/file-type-themes
  '((org-mode . doric-water)
    (markdown-mode . poet)
    (default . misterioso))
  "Alist mapping major modes to their preferred themes.")

(defun my/load-theme-for-mode (mode)
  "Load the appropriate theme for MODE.
If MODE is not found in my/file-type-themes, use the default theme."
  (let ((theme (or (cdr (assq mode my/file-type-themes))
                   (cdr (assq 'default my/file-type-themes)))))
    (when theme
      ;; Disable all current themes
      (mapc #'disable-theme custom-enabled-themes)
      ;; Load the new theme
      (load-theme theme t)
      (message "Loaded theme %s for %s" theme mode))))

(defun my/load-theme-for-current-buffer ()
  "Load the appropriate theme for the current buffer's major mode."
  (my/load-theme-for-mode major-mode))

(defun my/setup-file-type-themes ()
  "Set up hooks to automatically load themes based on file type."
  ;; Hook for org-mode
  (add-hook 'org-mode-hook
            (lambda () (my/load-theme-for-mode 'org-mode)))
  
  ;; Hook for markdown-mode
  (add-hook 'markdown-mode-hook
            (lambda () (my/load-theme-for-mode 'markdown-mode)))
  
  ;; Hook for other modes (fallback to default)
  (add-hook 'after-change-major-mode-hook
            (lambda ()
              (unless (memq major-mode '(org-mode markdown-mode))
                (my/load-theme-for-mode 'default)))))

;; ----------------------------------------------------------------------------
;; Original Theme Functions
;; ----------------------------------------------------------------------------

(defvar my/theme-list '(modus-vivendi-tinted
                        misterioso
                        tango-dark
                        leuven
                        adwaita)
  "List of themes to toggle through.")

(defvar my/current-theme-index 0
  "Current theme index in my/theme-list.")

(defun my/toggle-theme ()
  "Toggle between a predefined list of themes."
  (interactive)
  (let ((theme-count (length my/theme-list)))
    (setq my/current-theme-index (% (1+ my/current-theme-index) theme-count))
    (let ((new-theme (nth my/current-theme-index my/theme-list)))
      ;; Disable all other themes
      (mapc #'disable-theme custom-enabled-themes)
      ;; Load the new theme
      (disable-theme (nth (% (1- my/current-theme-index) theme-count) my/theme-list))
      (load-theme new-theme t)
      (message "Switched to theme: %s" new-theme))))

(defun my/use-default-theme ()
  "Disable all custom themes and use Emacs default theme."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (message "Using default Emacs theme"))

(defun my/load-gui-theme ()
  "Load the preferred GUI theme (leuven)."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme ' t)
  (message "Loaded leuven theme"))

(defun my/toggle-default-theme ()
  "Toggle between default theme and custom theme."
  (interactive)
  (if custom-enabled-themes
      (my/use-default-theme)
    (if (display-graphic-p)
        (my/load-gui-theme)
      (message "In terminal - using default theme"))))

(defun my/reset-all-themes ()
  "Completely reset all themes and face customizations."
  (interactive)
  ;; Disable all custom themes
  (mapc #'disable-theme custom-enabled-themes)
  ;; Reset theme toggle index
  (setq my/current-theme-index 0)
  ;; Force a complete face reset (this reloads default faces)
  (when (fboundp 'face-spec-recalc)
    (mapc #'face-spec-recalc (face-list)))
  (message "All themes reset to default"))

(defun my/fix-poet-theme-issues ()
  "Fix any issues caused by poet theme and ensure clean state."
  (interactive)
  ;; First, disable all themes
  (my/reset-all-themes)
  ;; Remove poet from enabled themes if somehow active
  (when (memq 'poet custom-enabled-themes)
    (disable-theme 'poet))
  ;; Reload the appropriate theme based on display type
  (if (display-graphic-p)
      (my/load-gui-theme)
    (message "Using default theme in terminal")))

;; ----------------------------------------------------------------------------
;; Display Detection Functions
;; ----------------------------------------------------------------------------

(defun my/display-info ()
  "Display information about the current display type and settings."
  (interactive)
  (let ((display-type (if (display-graphic-p) "GUI" "Terminal"))
        (terminal-type (getenv "TERM"))
        (emacs-version emacs-version)
        (frame-params (frame-parameters)))
    (message "Display Type: %s" display-type)
    (message "Terminal: %s" (or terminal-type "Not set"))
    (message "Emacs Version: %s" emacs-version)
    (when (display-graphic-p)
      (let ((alpha (frame-parameter nil 'alpha-background)))
        (message "Transparency: %s" (if alpha (format "%d%%" alpha) "100% (opaque)"))))
    (message "Current theme: %s" (if custom-enabled-themes 
                                    (mapconcat 'symbol-name custom-enabled-themes ", ")
                                  "default"))))

;; ----------------------------------------------------------------------------
;; Transparency Functions
;; ----------------------------------------------------------------------------

(defvar my/transparency-level 85
  "Default transparency level (0-100).")

(defun my/set-transparency (value)
  "Set transparency to VALUE (0-100)."
  (interactive "nTransparency (0-100): ")
  (if (display-graphic-p)
      ;; GUI mode - use alpha-background only (modern method)
      (progn
        (set-frame-parameter nil 'alpha-background value)
        (add-to-list 'default-frame-alist `(alpha-background . ,value))
        (message "GUI transparency set to %d%%" value))
    ;; Terminal mode - inform user about terminal emulator transparency
    (progn
      (message "Terminal mode: Set transparency in your terminal emulator")
      (message "Emacs transparency parameters don't work in most terminals"))))

(defun my/toggle-transparency ()
  "Toggle between transparent and opaque."
  (interactive)
  (let ((current-alpha (or (frame-parameter nil 'alpha-background) 100)))
    (if (< current-alpha 100)
        (my/set-transparency 100)
      (my/set-transparency my/transparency-level))))

;; ----------------------------------------------------------------------------
;; Format Conversion Functions
;; ----------------------------------------------------------------------------

(defun my/convert-yaml-table-to-org-properties (content)
  "Convert CONTENT frontmatter table to Org mode properties.
Converts tables like | title: \"README\" | to #+title: README
ONLY processes tables at the very beginning of the file (before any content)."
  (with-temp-buffer
    (insert content)
    (goto-char (point-min))

    ;; Skip any leading blank lines
    (while (and (not (eobp)) (looking-at "^\\s-*$"))
      (forward-line 1))

    ;; Check if the first non-blank line is a table with key: value pattern
    (when (looking-at "^\\s-*| \\([^:]+:\\)\\s-*\\(.*\\)\\s-*|$")
      (let ((properties '())
            (start-pos (point)))
        
        ;; Only process if this is truly at the beginning (no headings before it)
        (save-excursion
          (goto-char (point-min))
          (when (not (re-search-forward "^\\*+ " start-pos t))
            ;; No headings found before table, safe to process
            
            ;; Collect all property lines
            (goto-char start-pos)
            (while (looking-at "^\\s-*| \\([^:]+:\\)\\s-*\\(.*\\)\\s-*|$")
              (let ((key (match-string 1))
                    (value (match-string 2)))
                ;; Clean up key (remove colon and extra spaces)
                (setq key (replace-regexp-in-string "\\s-*:$" "" key))
                (setq key (string-trim key))
                ;; Clean up value (remove quotes, brackets, backslashes, and extra spaces)
                (setq value (string-trim value))
                (setq value (replace-regexp-in-string "^\"\\(.*\\)\"$" "\\1" value))
                (setq value (replace-regexp-in-string "^\\[\\(.*\\)\\]$" "\\1" value))
                (setq value (replace-regexp-in-string "\\\\" "" value))
                (setq value (string-trim value))
                (push (cons key value) properties))
              (forward-line 1))
            
            ;; If we found properties, replace the table with Org properties
            (when properties
              (let ((end-pos (point)))
                ;; Delete the table
                (delete-region start-pos end-pos)
                
                ;; Insert Org properties at beginning
                (goto-char start-pos)
                (dolist (prop (reverse properties))
                  (insert (format "#+%s: %s\n" (string-trim (car prop)) (string-trim (cdr prop)))))
                (insert "\n")))))))

    (buffer-string)))

(defun my/markdown-region-to-org ()
  "Convert selected region from Markdown to Org mode using pandoc.
Handles frontmatter conversion and fixes common formatting issues.
Replaces the original content with the converted org."
  (interactive)
  (if (use-region-p)
      (let* ((start (region-beginning))
             (end (region-end))
             (markdown-content (buffer-substring-no-properties start end))
             (original-buffer (current-buffer)))
        (let ((temp-file-md (make-temp-file "md-convert" nil ".md"))
              (temp-file-org (make-temp-file "md-convert" nil ".org")))
          (unwind-protect
              (progn
                ;; Write markdown content to temp file
                (with-temp-buffer
                  (insert markdown-content)
                  (write-region (point-min) (point-max) temp-file-md))

                ;; Convert using pandoc without auto-identifiers
                (if (zerop (call-process "pandoc" nil nil nil
                                         "-f" "markdown"
                                         "-t" "org"
                                         "--wrap=none"
                                         "--strip-comments"
                                         temp-file-md
                                         "-o" temp-file-org))
                    (progn
                      ;; Read and fix converted content
                      (let ((org-content 
                      (with-temp-buffer
                        (insert-file-contents temp-file-org)
                               
                               ;; Remove PROPERTIES drawers
                               (goto-char (point-min))
                               (while (re-search-forward "^:PROPERTIES:\n\\(?:.*\n\\)*?:END:\n" nil t)
                                 (replace-match ""))
                               
                               ;; Fix citations
                               (goto-char (point-min))
                               (while (re-search-forward "\\[\\[?cite[^]]+:@\\([a-zA-Z0-9_-]+\\)\\]\\]?" nil t)
                                 (replace-match "@\\1"))
                               
                               ;; Fix lists on single line
                               (goto-char (point-min))
                               (while (not (eobp))
                                 (let ((line (buffer-substring-no-properties 
                                             (line-beginning-position) 
                                             (line-end-position))))
                                   
                                   ;; Handle lines like "*Tool-based:* - item - item - item"
                                   (when (string-match "^\\(\\*[^*]+\\*\\)\\s-*\\(- .+\\)" line)
                                     (let ((bold-prefix (match-string 1 line))
                                           (list-part (match-string 2 line)))
                                       (when (string-match-p " - " list-part)
                                         (delete-region (line-beginning-position) (line-end-position))
                                         (insert bold-prefix "\n"
                                                 (mapconcat (lambda (item)
                                                             (concat "- " (string-trim item)))
                                                           (split-string list-part " - " t)
                                                           "\n"))
                                         (goto-char (line-beginning-position)))))
                                   
                                   ;; Handle numbered lists like "text: 1. item 2. item 3. item"
                                   (when (string-match "^\\([^:]+:\\)\\s-*\\([0-9]+\\. .+\\)" line)
                                     (let ((prefix (match-string 1 line))
                                           (list-part (match-string 2 line)))
                                       (when (string-match-p "[0-9]+\\. .+[0-9]+\\. " list-part)
                                         (let* ((items (split-string list-part " *[0-9]+\\. " t))
                                                (counter 1))
                                           (delete-region (line-beginning-position) (line-end-position))
                                           (insert prefix "\n"
                                                   (mapconcat (lambda (item)
                                                               (prog1
                                                                   (format "%d. %s" counter (string-trim item))
                                                                 (setq counter (1+ counter))))
                                                             items
                                                             "\n"))
                                           (goto-char (line-beginning-position)))))))
                                 
                                 (forward-line 1))
                               
                               (buffer-string))))
                        
                        ;; Replace original region
                          (with-current-buffer original-buffer
                            (goto-char start)
                            (delete-region start end)
                          (insert org-content))))
                  (error "Pandoc conversion failed")))
            ;; Clean up temp files
            (when (file-exists-p temp-file-md)
              (delete-file temp-file-md))
            (when (file-exists-p temp-file-org)
              (delete-file temp-file-org)))))
    (message "No region selected")))

;; Which-key descriptions
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c k c r m" "󰏧 Convert Org Region to Markdown"
    "C-c k c r o" "󰏧 Convert Markdown Region to Org"
    "C-c k f c" "󰏧 Convert File Format in Dired"))

(provide 'custom-functions)
