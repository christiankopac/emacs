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

;; Define manual silos
(setq my-denote-silos
      `(("denote" . ,(expand-file-name "~/Sync/org/denote/"))
        ("journal" . ,(expand-file-name "~/Sync/org/journal/"))
        ("gtd" . ,(expand-file-name "~/Sync/org/gtd/"))))

;; Set denote-dired-directories to the list of directories from my-denote-silos
(setq denote-dired-directories (mapcar #'cdr my-denote-silos))

;; Ensure all silo directories exist
(dolist (silo my-denote-silos)
  (let ((dir (cdr silo)))
    (unless (file-directory-p dir)
      (make-directory dir t)
      (message "Created denote directory: %s" dir))))

;; Core Denote settings
(setq denote-rename-buffer-mode 1)
(setq denote-infer-keywords nil)
(setq denote-sort-keywords t)
(setq denote-file-type 'org)
(setq denote-prompts '(title keywords subdirectory))
(setq denote-allow-multi-word-keywords t)
(setq denote-date-prompt-use-org-read-date t)
(setq denote-save-files t)
(setq denote-known-keywords '("fleeting" "permanent" "literature" "reference" "project" )) ;; reference, project, literature can be moved later
(setq denote-subdirectories '("fleeting" "permanent" "literature"))
(setq debug-on-error t)
;; ============================================================================
;; Backlinks buffer display helper functions
;; ============================================================================
(defun my/denote-backlink-heading (file)
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
(setq denote-query-format-heading-function #'my/denote-backlink-heading)
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
(setq denote-templates '(
                         (journal . "* Morning\n\n\n* Afternoon\n\n\n* Evening\n\n\n* denote\n\n\n* Tomorrow\n\n\n")))

;; ============================================================================
;; Denote Journal Configuration
;; ============================================================================
;; Configure denote-journal (if available)
(when (require 'denote-journal nil t)
  (setq denote-journal-directory (expand-file-name "~/Sync/org/journal/"))
  (setq denote-journal-title-format 'day-date-month-year)
  (setq denote-journal-keywords '("journal"))
  (global-set-key (kbd "C-c n j") 'denote-journal-new-entry)
  (global-set-key (kbd "C-c n J") 'denote-journal-open-today))
;; ============================================================================
;; Denote hooks
;; ============================================================================
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
;; Markdown support is already configured in init.el
;; Enable markdown file type if denote-file-types is available
(when (boundp 'denote-file-types)
  (add-to-list 'denote-file-types 'markdown))

;; ============================================================================
;; Denote Org Support
;; ============================================================================
;; Org support is already configured in init.el
;; Additional org-specific configurations can go here
(setq denote-org-front-matter
      "#+title:      %s
#+date:       %s
#+filetags:   %s
#+identifier: %s
\n")

;; ============================================================================
;; Denote Silo Support - Multiple Silos (FIXED)
;; ============================================================================
;; Configure silo directories using the existing my-denote-silos variable
(setq denote-silo-directories (mapcar #'cdr my-denote-silos))

;; Set default silo name (not the path)
(setq denote-silo-default "denote")
(setq denote-silo-current "denote")

;; IMPORTANT: Set the main denote-directory to the default silo
;; This is required for consult-denote and other denote functions to work
(setq denote-directory (cdr (assoc denote-silo-default my-denote-silos)))

;; Verify denote-directory is set correctly
(unless (and denote-directory (file-directory-p denote-directory))
  (error "Denote directory not found or not accessible: %s" denote-directory))

;; Silo switching function
(defun my/denote-switch-silo ()
  "Switch between denote silos interactively."
  (interactive)
  (let ((silo (completing-read "Select silo: " 
                               (mapcar #'car my-denote-silos)
                               nil t)))
    (setq denote-silo-current silo)
    (setq denote-directory (cdr (assoc silo my-denote-silos)))
    (message "Switched to silo: %s (%s)" silo denote-directory)))

;; Helper functions
(defun my/denote-list-silos ()
  "List all available silos and their directories."
  (interactive)
  (with-output-to-temp-buffer "*Denote Silos*"
    (princ "Available Denote Silos:\n\n")
    (dolist (silo my-denote-silos)
      (princ (format "%-12s -> %s\n" (car silo) (cdr silo))))
    (princ (format "\nCurrent silo: %s\n" denote-silo-current))))

(defun my/denote-create-in-silo (silo-name)
  "Create a new note in a specific silo."
  (interactive
   (list (completing-read "Create note in silo:"  
                          (mapcar #'car my-denote-silos)
                          nil t)))
  (let ((original-directory denote-directory)
        (original-silo denote-silo-current))
    (setq denote-directory (cdr (assoc silo-name my-denote-silos)))
    (setq denote-silo-current silo-name)
    (call-interactively 'denote)
    (setq denote-directory original-directory)
    (setq denote-silo-current original-silo)))

;; Keybindings
(global-set-key (kbd "C-c d s") 'my/denote-switch-silo)
(global-set-key (kbd "C-c d L") 'my/denote-list-silos)
(global-set-key (kbd "C-c d c") 'my/denote-create-in-silo)

;; Additional silo keybindings using denote-silo functions
(global-set-key (kbd "C-c d S") 'denote-silo-create-note)
(global-set-key (kbd "C-c d O") 'denote-silo-open-or-create)
(global-set-key (kbd "C-c d F") 'denote-silo-dired)
(global-set-key (kbd "C-c d C") 'denote-silo-select-silo-then-command)
  
;; ============================================================================
;; Journal Migration Functions
;; ============================================================================
(defun my/denote-convert-journal-files ()
  "Convert marked dired files from YYYY-MM-DD.org format to denote journal format.
Extracts date from filename, preserves content, and creates new denote journal files."
  (interactive)
  (unless (eq major-mode 'dired-mode)
    (user-error "This function must be called from dired"))
  
  ;; Ensure denote-journal is loaded (if available)
  (unless (require 'denote-journal nil t)
    (user-error "denote-journal package is not available"))
  
  (let ((marked-files (dired-get-marked-files))
        (converted-count 0)
        (errors '()))
    
    (when (null marked-files)
      (user-error "No files marked in dired"))
    
    (dolist (file marked-files)
      (condition-case err
          (progn
            (when (file-regular-p file)
              (let* ((filename (file-name-nondirectory file))
                     (date-match (string-match "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)\\.org$" filename)))
                (if date-match
                    (let* ((year (string-to-number (match-string 1 filename)))
                           (month (string-to-number (match-string 2 filename)))
                           (day (string-to-number (match-string 3 filename)))
                           (date (encode-time 0 0 0 day month year))
                           (denote-id (format-time-string "%Y%m%dT000000" date))
                           (title (format-time-string "%A, %d %B %Y" date))
                           (new-filename (format "%s--%s__journal.org" denote-id (downcase (replace-regexp-in-string "[^a-zA-Z0-9-]" "-" title))))
                           (new-file (expand-file-name new-filename (file-name-directory file))))
                      ;; Rename the file in place to denote journal format
                      (rename-file file new-file)
                      (setq converted-count (1+ converted-count))
                      (message "Renamed: %s -> %s" filename new-filename)))
                (push (format "Skipped %s (not YYYY-MM-DD.org format)" filename) errors))))
        (error (push (format "Error converting %s: %s" file (error-message-string err)) errors))))
    
    ;; Report results
    (if errors
        (progn
          (message "Conversion completed with %d files converted, %d errors" converted-count (length errors))
          (when errors
            (with-output-to-temp-buffer "*Journal Conversion Errors*"
              (princ "Conversion Errors:\n\n")
              (dolist (error errors)
                (princ (concat error "\n"))))))
      (message "Successfully converted %d journal files to denote format" converted-count))))

;; Keybinding for journal conversion
(global-set-key (kbd "C-c d m") 'my/denote-convert-journal-files)
;; ============================================================================
;; Improved Dired Renaming Functions (Using Denote's Built-in Slugification)
;; ============================================================================
(defun my/denote-normalize-date (date-string)
  "Convert various date formats to denote ID format (YYYYMMDD).
Handles: YYYY-MM-DD, [YYYY-MM-DD ...], <YYYY-MM-DD ...>"
  (when date-string
    (let ((cleaned (replace-regexp-in-string "[]<>[]" "" date-string)))
      (when (string-match "\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)" cleaned)
        (concat (match-string 1 cleaned)
                (match-string 2 cleaned)
                (match-string 3 cleaned))))))
(defun my/denote-deslugify-title (slug)
  "Convert a slug like 'field-recording-guide' to 'Field Recording Guide'."
  (mapconcat #'capitalize (split-string slug "-") " "))

(defun my/denote-extract-frontmatter (file)
  "Extract title, date, and keywords from FILE's frontmatter.
Returns plist: (:title STR :date STR :keywords STR)"
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (let ((title nil)
          (date nil)
          (keywords nil))
      (when (re-search-forward "^#\\+title:\\s-*\\(.*\\)$" nil t)
        (let ((raw-title (string-trim (match-string 1))))
          ;; If title looks like a slug (all lowercase with dashes), de-slugify it
          (setq title (if (string-match-p "^[a-z0-9-]+$" raw-title)
                          (my/denote-deslugify-title raw-title)
                        raw-title))))
      (goto-char (point-min))
      (when (re-search-forward "^#\\+date:\\s-*\\(.*\\)$" nil t)
        (setq date (string-trim (match-string 1))))
      (goto-char (point-min))
      (when (re-search-forward "^#\\+filetags:\\s-*:\\(.*\\):$" nil t)
        (setq keywords (string-trim (match-string 1))))
      (list :title title :date date :keywords keywords))))

(defun my/denote-extract-filename-parts (filename)
  "Extract ID, title, and keywords from denote FILENAME.
Returns plist: (:id STR :title STR :keywords STR)"
  (when (string-match "\\([0-9]\\{8\\}\\)T\\([0-9]\\{6\\}\\)--\\([^_]*\\)__\\(.*\\)\\.org$" filename)
    (list :id (match-string 1 filename)
          :title (match-string 3 filename)
          :keywords (match-string 4 filename))))

(defun my/denote-build-filename (id title keywords)
  "Build denote filename from ID, TITLE, and KEYWORDS using Denote's slugification.
ID should be YYYYMMDD format, title and keywords are strings."
  (let ((slug-title (when title 
                      ;; If title has dashes (from filename), convert to spaces first
                      (let ((clean-title (replace-regexp-in-string "-" " " title)))
                        (denote-sluggify-title clean-title))))
        (slug-keywords (when keywords
                         (mapconcat #'denote-sluggify-keyword
                                    (split-string keywords "_")
                                    "_"))))
    (cond
     ((and id slug-title slug-keywords)
      (format "%sT000000--%s__%s.org" id slug-title slug-keywords))
     ((and id slug-title)
      (format "%sT000000--%s.org" id slug-title))
     (slug-title
      (format "%sT000000--%s.org" (format-time-string "%Y%m%d") slug-title))
     (t nil))))
(defun my/denote-rename-file-smart (file)
  "Intelligently rename FILE based on available metadata.
Handles: complete metadata, partial metadata, no metadata."
  (let* ((frontmatter (my/denote-extract-frontmatter file))
         (filename (file-name-nondirectory file))
         (filename-parts (my/denote-extract-filename-parts filename))
         
         ;; Get best title (frontmatter > filename > nil)
         (fm-title (plist-get frontmatter :title))
         (fn-title (plist-get filename-parts :title))
         (best-title (or fm-title fn-title))
         
         ;; Get best date (frontmatter > filename > today)
         (fm-date (my/denote-normalize-date (plist-get frontmatter :date)))
         (fn-date (plist-get filename-parts :id))
         (best-date (or fm-date fn-date (format-time-string "%Y%m%d")))
         
         ;; Get best keywords (frontmatter > filename > nil)
         (fm-keywords (plist-get frontmatter :keywords))
         (fn-keywords (plist-get filename-parts :keywords))
         (best-keywords (or fm-keywords fn-keywords)))
    
    (if best-title
        (let ((new-filename (my/denote-build-filename best-date best-title best-keywords)))
          (if new-filename
              (list :success t
                    :old filename
                    :new new-filename
                    :reason (format "Title: %s, Date: %s, Keywords: %s"
                                    (if fm-title "frontmatter" "filename")
                                    (if fm-date "frontmatter" 
                                      (if fn-date "filename" "today"))
                                    (if fm-keywords "frontmatter"
                                      (if fn-keywords "filename" "none"))))
            (list :success nil
                  :reason "Failed to build filename")))
      (list :success nil
            :reason "No title found in frontmatter or filename"))))

(defun my/denote-update-frontmatter-title (file title)
  "Update the #+title: line in FILE with TITLE."
  (with-current-buffer (find-file-noselect file)
    (save-excursion
      (goto-char (point-min))
      (when (re-search-forward "^#\\+title:\\s-*.*$" nil t)
        (replace-match (format "#+title: %s" title))))
    (save-buffer)
    (kill-buffer)))

(defun my/denote-rename-marked-files ()
  "Rename all marked files in dired intelligently.
Handles complete metadata, partial metadata, and no metadata cases."
  (interactive)
  (unless (eq major-mode 'dired-mode)
    (user-error "Must be called from dired"))
  
  (let ((marked-files (dired-get-marked-files))
        (results '())
        (renamed-count 0)
        (skipped-count 0))
    
    (when (null marked-files)
      (user-error "No files marked"))
    
    (dolist (file marked-files)
      (when (and (file-regular-p file)
                 (string-match "\\.org$" file))
        (let* ((result (my/denote-rename-file-smart file))
               (success (plist-get result :success))
               (frontmatter (my/denote-extract-frontmatter file))
               (proper-title (plist-get frontmatter :title)))
          
          (if success
              (let* ((new-filename (plist-get result :new))
                     (new-file (expand-file-name new-filename (file-name-directory file))))
                
                ;; First, update the frontmatter with human-readable title
                (when proper-title
                  (my/denote-update-frontmatter-title file proper-title))
                
                ;; Then rename the file
                (if (file-exists-p new-file)
                    (progn
                      (push (format "SKIP: %s (target exists)" 
                                    (file-name-nondirectory file))
                            results)
                      (setq skipped-count (1+ skipped-count)))
                  (rename-file file new-file)
                  (push (format "OK: %s → %s (%s)"
                                (file-name-nondirectory file)
                                new-filename
                                (plist-get result :reason))
                        results)
                  (setq renamed-count (1+ renamed-count))))
            (push (format "FAIL: %s (%s)"
                          (file-name-nondirectory file)
                          (plist-get result :reason))
                  results)
            (setq skipped-count (1+ skipped-count))))))
    
    (with-output-to-temp-buffer "*Denote Rename Results*"
      (princ (format "Renamed: %d | Skipped: %d\n\n" renamed-count skipped-count))
      (dolist (result (reverse results))
        (princ (concat result "\n"))))
    
    (dired-revert)
    (message "Renamed %d files, skipped %d" renamed-count skipped-count)))
;; Use a non-conflicting keybinding
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c d R") 'my/denote-rename-marked-files))
;; Keybinding for renaming from frontmatter
(global-set-key (kbd "C-c d r") 'my/denote-rename-from-frontmatter)
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
  "Template for daily denote."
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
   "* denote\n"
   "- \n\n"
   "* Tomorrow\n"
   "- \n"))

;; Project note template
(defun my/denote-project-note-template ()
  "Template for project denote."
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
   "* denote\n"
   "- \n\n"
   "* Resources\n"
   "- \n"))

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
(defun my/denote-find-recent-denote (n)
  "Find N most recent denote denote."
  (interactive "nNumber of recent denote: ")
  (let ((denote (denote-directory-files)))
    (setq denote (sort denote (lambda (a b)
                              (time-less-p
                               (nth 5 (file-attributes b))
                               (nth 5 (file-attributes a))))))
    (dolist (note (seq-take denote n))
      (find-file note))))

(defun my/denote-archive-old-denote ()
  "Archive denote older than 1 year."
  (interactive)
  (let ((cutoff (time-subtract (current-time) (* 365 24 60 60))))
    (dolist (file (denote-directory-files))
      (when (time-less-p (nth 5 (file-attributes file)) cutoff)
        (denote-archive-file file)))))

;; ============================================================================
;; 🔥🔥🔥🔥🔥🔥🔥 Denote with ORG GTD 🔥🔥🔥🔥🔥🔥🔥  
;; ============================================================================
;; 📝 ✅ Create a denote note AND a GTD task simultaneously
(defun my/denote-with-gtd-action (title keywords)
  "Create denote note and corresponding GTD action"
  (interactive
   (list (denote-title-prompt)
         (denote-keywords-prompt)))
  (let ((file (denote title keywords)))
    (find-file file)
    ;; Create corresponding GTD task
    (org-gtd-single-action-create
     (format "Review note: %s" title))))

;; 💬 ⏩️ Create meeting note with auto-delegate
(defun my/denote-meeting-with-delegate ()
  "Create meeting note and delegate follow-up"
  (interactive)
  (let* ((title (read-string "Meeting title: "))
         (attendees (read-string "Attendees: "))
         (file (denote title '("meeting"))))
    (find-file file)
    (insert (format "* Attendees\n%s\n\n* denote\n\n* Action Items\n" attendees))
    ;; Create delegate task
    (org-gtd-delegate-create
     (format "Follow up: %s" title)
     (car (split-string attendees ","))
     (org-read-date nil nil "+3d"))))

;; ✅ 🔗 📝 Create GTD task with link back to denote note
(defun my/gtd-linked-action-from-denote ()
  "Create GTD action with denote: link"
  (interactive)
  (when (denote-file-is-note-p (buffer-file-name))
    (let* ((file (buffer-file-name))
           (id (denote-retrieve-filename-identifier file))
           (title (denote-retrieve-title-value file 'org))
           (task-title (format "Review [[denote:%s][%s]]" id title)))
      (org-gtd-single-action-create task-title))))

;; 🚜 SILOS 
;; Keep denote for knowledge, org-gtd for actions
;; This function helps convert knowledge → action
;; Use case 
;; --------
;; You're reading a denote note and think "what should I DO with this?" 
;; Run this function, it asks you: "single action? habit? delegate?" 
;; You pick one, it creates the right GTD task type.
(defun my/denote-to-gtd-workflow ()
  "Interactive workflow to process denote note into GTD"
  (interactive)
  (when (denote-file-is-note-p (buffer-file-name))
    (let* ((title (denote-retrieve-title-value (buffer-file-name) 'org))
           (action-type (completing-read
                         "GTD action type: "
                         '("single-action" "habit" "calendar" 
                           "delegate" "incubate" "skip"))))
      (pcase action-type
        ("single-action"
         (org-gtd-single-action-create
          (read-string "Task: " (format "Process: %s" title))))
        ("habit"
         (org-gtd-habit-create
          (read-string "Habit: " (format "Review: %s" title))
          (read-string "Repeater: " "+1w")))
        ("calendar"
         (org-gtd-calendar-create
          (read-string "Event: " title)
          (org-read-date nil nil nil "When: ")))
        ("delegate"
         (org-gtd-delegate-create
          (read-string "Task: " title)
          (read-string "Delegate to: ")
          (org-read-date nil nil "+3d")))
        ("incubate"
         (org-gtd-incubate-create
          (read-string "Idea: " title)
          (org-read-date nil nil "+1m")))
        ("skip" (message "Skipped"))))))

(global-set-key (kbd "C-c d g w") 'my/denote-to-gtd-workflow)
;; If you use denote signatures for workflow stages
(defun my/gtd-from-denote-keywords ()
  "Create GTD tasks based on denote keywords"
  (interactive)
  (when (and (buffer-file-name)  ; Add this check
             (denote-file-is-note-p (buffer-file-name)))
    (let* ((keywords (denote-extract-keywords-from-path (buffer-file-name)))
           (title (denote-retrieve-title-value (buffer-file-name) 'org)))
      (cond
       ((member "action" keywords)
        (org-gtd-single-action-create title))
       ((member "delegate" keywords)
        (org-gtd-delegate-create
         title
         (read-string "Delegate to: ")
         (org-read-date nil nil "+3d")))
       ((member "someday" keywords)
        (org-gtd-incubate-create
         title
         (org-read-date nil nil "+1m")))
       ((member "habit" keywords)
        (org-gtd-habit-create
         title
         (read-string "Repeater: " ".+1d")))))))(defun my/gtd-habit-from-journal-pattern ()
  "Analyze journal entries and suggest habits"
  (interactive)
  (let* ((journal-files (denote-directory-files-matching-regexp "_journal"))
         (common-themes (my/extract-common-themes journal-files)))
    (dolist (theme common-themes)
      (when (y-or-n-p (format "Create habit for '%s'? " theme))
        (org-gtd-habit-create
         theme
         (read-string "Repeater: " ".+1d"))))))

;; Helper to extract themes (simplified)
(defun my/extract-common-themes (files)
  "Extract common keywords from FILES"
  (let ((all-keywords '()))
    (dolist (file files)
      (setq all-keywords 
            (append all-keywords 
                    (denote-extract-keywords-from-path file))))
    (delete-dups all-keywords)))

;; ----------------------------------------------------------------------------
;; ⚡️ QUICK ACTIONS (2 min)
;; ----------------------------------------------------------------------------
;; ????
;; ----------------------------------------------------------------------------
;; 🤖 AUTOMATION
;; ----------------------------------------------------------------------------
;; 🗒️ ✅ Create multiple tasks from a list
;;
;; Use case 
;; --------
;; You have a list in a buffer:
;; - Fix the door
;; - Call dentist
;; - Review budget proposal
;; Select it, run this function → creates 3 separate GTD tasks.
(defun my/gtd-batch-create-from-region ()
  "Create single actions from each line in region"
  (interactive)
  (let ((tasks (split-string 
                (buffer-substring-no-properties 
                 (region-beginning) 
                 (region-end))
                "\n" t)))
    (dolist (task tasks)
      (org-gtd-single-action-create (string-trim task)))
    (message "Created %d tasks" (length tasks))))

;; 🤖 🦷 Create habits for regular maintenance
(defun my/setup-gtd-maintenance-habits ()
  "Set up recurring maintenance tasks"
  (interactive)
  (org-gtd-habit-create "Review weekly goals" "+1w")
  (org-gtd-habit-create "Clean email inbox" ".+1d")
  (org-gtd-habit-create "Update system packages" "+2w")
  (org-gtd-habit-create "Backup important files" "+1w")
  (message "Maintenance habits created"))

;; 🗃️ ✅ Import tasks from a project plan
(defun my/gtd-import-project-tasks (file)
  "Import tasks from FILE as single actions"
  (interactive "fProject file: ")
  (with-temp-buffer
    (insert-file-contents file)
    (goto-char (point-min))
    (while (re-search-forward "^[-*] \\(.+\\)$" nil t)
      (org-gtd-single-action-create (match-string 1))))
  (message "Imported tasks from %s" file))

;; 🔍️ 🏷️ Auto-create tasks for denote with specific keywords
;; Use case 
;; --------
;; Your denote file is named:
;; 20251002T120000--learn-rust__programming_action.org
;; Because it has _action keyword, this function auto-creates a GTD task when you run it.
;; Keywords: ACTION / DELEGATE / SOMEDAY / HABIT
(defun my/gtd-from-denote-keywords ()
  "Create GTD tasks based on denote keywords"
  (interactive)
  (when (denote-file-is-note-p (buffer-file-name))
    (let* ((keywords (denote-extract-keywords-from-path (buffer-file-name)))
           (title (denote-retrieve-title-value (buffer-file-name) 'org)))
      (cond
       ((member "action" keywords)
        (org-gtd-single-action-create title))
       ((member "delegate" keywords)
        (org-gtd-delegate-create
         title
         (read-string "Delegate to: ")
         (org-read-date nil nil "+3d")))
       ((member "someday" keywords)
        (org-gtd-incubate-create
         title
         (org-read-date nil nil "+1m")))
       ((member "habit" keywords)
        (org-gtd-habit-create
         title
         (read-string "Repeater: " ".+1d")))))))
;; Hook it to run when you add keywords
;;(add-hook 'denote-after-rename-file-hook 'my/gtd-from-denote-keywords)
;; 🏭️ Create tasks from all denote files matching a pattern
;; Use case 
;; --------
;; You have 20 denote denote with _meeting in the filename. 
;; Run this, type "meeting", boom - 20 GTD tasks created at once.
(defun my/gtd-from-denote-search (regexp)
  "Create GTD tasks from denote files matching REGEXP"
  (interactive "sSearch denote files: ")
  (let ((files (denote-directory-files-matching-regexp regexp)))
    (dolist (file files)
      (let ((title (denote-retrieve-title-value file 'org)))
        (org-gtd-single-action-create 
         (format "Process: %s" title))))
    (message "Created %d tasks from denote search" (length files))))

;; Create tasks for all unprocessed meeting denote
(defun my/gtd-from-meeting-denote ()
  "Create tasks for meeting denote tagged 'unprocessed'"
  (interactive)
  (my/gtd-from-denote-search "_meeting.*_unprocessed"))

;; ----------------------------------------------------------------------------
;; ✅ SINGLE TASK - org-gtd-single-action-create
;; ----------------------------------------------------------------------------
;; Single action from current denote file
(defun my/action-from-denote-with-link ()
  "Create GTD action WITH LINK back to denote note"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((file (buffer-file-name))
             (denote-id (denote-retrieve-filename-identifier file))
             (title (denote-retrieve-title-value file 'org))
             (task (format "Review [[denote:%s][%s]]" denote-id title)))
        (org-gtd-single-action-create task)
        (message "Created linked GTD action"))
    (message "Not in a denote file")))

;; 📂 📌 Hook into dired - create task from marked files
(defun my/dired-process-files-to-gtd ()
  "Create GTD task with clickable links to marked files"
  (interactive)
  (let* ((files (dired-get-marked-files))
         (file-links (mapcar (lambda (f) 
                               (format "- [[file:%s][%s]]" 
                                       f 
                                       (file-name-nondirectory f)))
                             files))
         (task-title (format "Process %d files in %s\n%s" 
                             (length files)
                             (abbreviate-file-name default-directory)
                             (string-join file-links "\n"))))
    (org-gtd-single-action-create task-title)
    (message "Created GTD task with %d file links" (length files))))

;; ----------------------------------------------------------------------------
;; 🦷 HABITS - org-gtd-habit-create
;; ----------------------------------------------------------------------------
;; Creating habit from denote file  
(defun my/habit-from-denote ()
  "Create a GTD habit from current denote note"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((file (buffer-file-name))
             (denote-id (denote-retrieve-filename-identifier file))
             (title (denote-retrieve-title-value file 'org))
             (task (format "Review [[denote:%s][%s]]" denote-id title))
             ;; Prompt for how often
             (repeater (read-string "Repeater (e.g. .+1d, +1w, +2w): " ".+1d")))
        (org-gtd-habit-create task repeater)
        (message "Created habit: %s" title))
    (message "Not in a denote file")))

;; ----------------------------------------------------------------------------
;; 📅 CALENDAR - org-gtd-calendar-create
;; ----------------------------------------------------------------------------
(defun my/calendar-from-denote ()
  "Create a GTD calendar item from denote note"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((file (buffer-file-name))
             (denote-id (denote-retrieve-filename-identifier file))
             (title (denote-retrieve-title-value file 'org))
             (event (read-string "Event name: " title))
             ;; org-read-date gives nice date picker
             (when (org-read-date nil nil nil "When: ")))
        (org-gtd-calendar-create event when)
        (message "Created calendar event: %s" event))
    (message "Not in a denote file")))

;; ----------------------------------------------------------------------------
;; 🧊 INCUBATE - org-gtd-incubate-create
;; ----------------------------------------------------------------------------
(defun my/incubate-from-denote ()
  "Incubate an idea from denote note (someday/maybe)"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((file (buffer-file-name))
             (denote-id (denote-retrieve-filename-identifier file))
             (title (denote-retrieve-title-value file 'org))
             (idea (format "Explore [[denote:%s][%s]]" denote-id title))
             (review-date (org-read-date nil nil nil "Review on: " nil "+1m")))
        (org-gtd-incubate-create idea review-date)
        (message "Incubated: %s" title))
    (message "Not in a denote file")))


;; ----------------------------------------------------------------------------
;; ⏩️ DELEGATE - org-gtd-delegate-create
;; ----------------------------------------------------------------------------
(defun my/delegate-from-denote ()
  "Create a delegated task from denote note"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((file (buffer-file-name))
             (denote-id (denote-retrieve-filename-identifier file))
             (title (denote-retrieve-title-value file 'org))
             (task (format "[[denote:%s][%s]]" denote-id title))
             (person (read-string "Delegate to: "))
             (reminder (org-read-date nil nil nil "Remind me on: " nil "+3d")))
        (org-gtd-delegate-create task person reminder)
        (message "Delegated to %s: %s" person title))
    (message "Not in a denote file")))

;; ----------------------------------------------------------------------------
;; 📂 PROJECTS - ?
;; ----------------------------------------------------------------------------
(defun my/project-from-denote ()
  "Create a project skeleton in org-gtd from denote note"
  (interactive)
  (if (denote-file-is-note-p (buffer-file-name))
      (let* ((title (denote-retrieve-title-value (buffer-file-name) 'org))
             (denote-id (denote-retrieve-filename-identifier (buffer-file-name)))
             ;; Use tasks.org instead of actionable.org
             (project-file (expand-file-name "tasks.org" org-gtd-directory)))
        ;; Open the tasks file
        (find-file project-file)
        ;; Find or create Projects heading
        (goto-char (point-min))
        (unless (re-search-forward "^\\* Projects$" nil t)
          (goto-char (point-max))
          (insert "\n* Projects\n:PROPERTIES:\n:ORG_GTD: Projects\n:END:\n"))
        ;; Go to end of Projects section (but before next top-level heading)
        (org-end-of-subtree)
        ;; Insert project structure
        (insert (format "\n** TODO [[denote:%s][%s]]\n" denote-id title))
        (insert "*** NEXT First step\n")
        (insert "*** TODO Second step\n")
        (insert "*** TODO Third step\n")
        (save-buffer)
        (message "Created project: %s" title))
    (message "Not in a denote file")))

;; ----------------------------------------------------------------------------
;; 🌈 TRANSIENT DENOTE + ORG GTD MENU
;; ----------------------------------------------------------------------------
(with-eval-after-load 'transient
  (require 'transient)
  (transient-define-prefix my/denote-gtd-menu ()
    "Denote + org-gtd integration menu"
    ["Denote → GTD"
     ("a" "Action from note" my/action-from-denote-with-link)
     ("h" "Habit from note" my/habit-from-denote)
     ("c" "Calendar event" my/calendar-from-denote)
     ("d" "Delegate" my/delegate-from-denote)
     ("i" "Incubate" my/incubate-from-denote)
     ("p" "Project" my/project-from-denote)]))


;; ----------------------------------------------------------------------------
;; ⌨️ Keybindings - loads after org/dired is available
;; ----------------------------------------------------------------------------
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c d g l") 'my/action-from-denote-with-link)
  (define-key org-mode-map (kbd "C-c d g h") 'my/habit-from-denote)
  (define-key org-mode-map (kbd "C-c d g c") 'my/calendar-from-denote)
  (define-key org-mode-map (kbd "C-c d g d") 'my/delegate-from-denote)
  (define-key org-mode-map (kbd "C-c d g i") 'my/incubate-from-denote)
  (define-key org-mode-map (kbd "C-c d g p") 'my/project-from-denote)
  (define-key org-mode-map (kbd "C-c d g m") 'my/denote-gtd-menu))

(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c g f") 'my/dired-process-files-to-gtd))

;; ============================================================================
;; End of Configuration
;; ============================================================================
(provide 'denote)
;;; denote.el ends here
