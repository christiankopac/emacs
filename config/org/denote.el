;;; denote.el --- Denote note-taking system configuration

;; ============================================================================
;; Core Denote Configuration
;; ============================================================================

(use-package denote
  :ensure t
  :custom
  (denote-directory "~/Sync/org/notes/")              ; Main directory for notes
  (denote-infer-keywords t)                           ; Auto-suggest keywords from file names
  (denote-sort-keywords t)                            ; Sort keywords alphabetically
  (denote-file-type 'org)                             ; Use Org format for notes
  (denote-prompts '(title keywords subdirectory))     ; Prompt for title, keywords, and subdirectory
  (denote-allow-multi-word-keywords t)                ; Allow spaces in keywords
  (denote-date-prompt-use-org-read-date t)            ; Use org-mode date picker
  (denote-backlinks-show-context t)                   ; Show surrounding text in backlinks
  (denote-save-files t)                               ; Auto-save after operations
  (denote-known-keywords '("fleeting" "permanent" "literature" "reference" "project" "movie" "daily" "journal"))
  (denote-subdirectories '("fleeting-notes" "permanent-notes" "literature-notes" "movies"))
  :bind
  (("C-c d n" . denote)                           ; Create new note
   ("C-c d N" . denote-subdirectory)              ; Create note in subdirectory
   ("C-c d f" . denote-open-or-create)            ; Open or create note
   ("C-c d l" . denote-link)                      ; Insert link to note
   ("C-c d b" . denote-backlinks)))               ; Show backlinks

;; ============================================================================
;; Helper Functions: Date and File Operations
;; ============================================================================

(defun my/denote-get-file-creation-date (file)
  "Get file creation date as time object.
Falls back to modification time if creation time not available."
  (let ((attrs (file-attributes file)))
    (or (file-attribute-creation-time attrs)
        (file-attribute-modification-time attrs))))

;; ============================================================================
;; Custom Functions: Dired Operations
;; ============================================================================

;; Bind dired conversion function to dired-mode
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-c d C") 'my/dired-convert-date-files-to-denote-daily-journal)
  (define-key dired-mode-map (kbd "C-c d s") 'my/dired-denote-add-signature-to-marked)
  (define-key dired-mode-map (kbd "C-c d k") 'my/dired-denote-add-keywords-to-marked)
  (define-key dired-mode-map (kbd "C-c d d") 'my/dired-denote-move-marked-to-subdirectory)
  (define-key dired-mode-map (kbd "C-c d r") 'my/dired-denote-rename-marked-with-date)
  (define-key dired-mode-map (kbd "C-c d R") 'my/dired-denote-rename-with-de-slugified-title)
  ;; Relationship functions - use different prefix to avoid conflicts
  (define-key dired-mode-map (kbd "C-c d l c") 'my/denote-dired-add-child-relationship)
  (define-key dired-mode-map (kbd "C-c d l p") 'my/denote-dired-add-parent-relationship)
  (define-key dired-mode-map (kbd "C-c d l s") 'my/denote-dired-add-sibling-relationships)
  (define-key dired-mode-map (kbd "C-c d l r") 'my/denote-dired-add-relationship-with-prompt))

(defun my/dired-denote-add-signature-to-marked ()
  "Add signature to marked files using Denote's rename function."
  (interactive nil dired-mode)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (if-let* ((marks (dired-get-marked-files))
            (signature (read-string "Enter signature: ")))
      (progn
        (dolist (file marks)
          (denote-rename-file file nil nil signature nil))
        (revert-buffer)
        (message "Added signature to %d files" (length marks)))
    (user-error "No marked files")))

(defun my/dired-denote-add-keywords-to-marked ()
  "Add or modify keywords for all marked files using Denote's rename function."
  (interactive nil dired-mode)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (if-let* ((marks (dired-get-marked-files))
            (keywords-str (read-string "Enter keywords (comma-separated): ")))
      (let ((keywords (mapcar 'string-trim (split-string keywords-str "," t))))
        (dolist (file marks)
          (let* ((existing-keywords (denote-retrieve-filename-keywords file))
                 (all-keywords (delete-dups (append existing-keywords keywords))))
            (denote-rename-file file nil all-keywords nil nil)))
        (revert-buffer)
        (message "Added keywords to %d files" (length marks)))
    (user-error "No marked files")))

(defun my/dired-denote-move-marked-to-subdirectory ()
  "Move all marked files to a subdirectory using Denote's rename function."
  (interactive nil dired-mode)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (if-let* ((marks (dired-get-marked-files))
            (subdir (read-string "Enter subdirectory name: ")))
      (progn
        (dolist (file marks)
          (denote-rename-file file nil nil nil subdir))
        (revert-buffer)
        (message "Moved %d files to subdirectory '%s'" (length marks) subdir))
    (user-error "No marked files")))

(defun my/dired-denote-rename-marked-with-date ()
  "Rename marked files using date from frontmatter or file creation date."
  (interactive nil dired-mode)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (if-let* ((marks (dired-get-marked-files)))
      (progn
        (dolist (file marks)
          (let* ((frontmatter-date (denote-retrieve-front-matter file 'date))
                 (file-date (or frontmatter-date (my/denote-get-file-creation-date file)))
                 (new-id (if file-date
                            (format "%sT120000" (format-time-string "%Y%m%d" file-date))
                          (denote-retrieve-filename-identifier file))))
            (denote-rename-file file new-id nil nil nil)))
        (revert-buffer)
        (message "Renamed %d files with date" (length marks)))
    (user-error "No marked files")))

(defun my/dired-denote-rename-with-de-slugified-title ()
  "Rename marked files using de-slugified title as input."
  (interactive nil dired-mode)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (if-let* ((marks (dired-get-marked-files)))
      (progn
        (dolist (file marks)
          (let* ((title (denote-retrieve-filename-title file))
                 (de-slugified-title (my/denote-de-slugify-title title)))
            (denote-rename-file file nil nil de-slugified-title nil)))
        (revert-buffer)
        (message "Renamed %d files with de-slugified titles" (length marks)))
    (user-error "No marked files")))

(defun my/denote-de-slugify-title (slugified-title)
  "Convert a slugified title back to a readable title.
Converts hyphens to spaces and capitalizes words properly."
  (when slugified-title
    (let ((de-slugified (replace-regexp-in-string "-" " " slugified-title)))
      ;; Capitalize each word
      (mapconcat 'capitalize (split-string de-slugified " " t) " "))))

;; ============================================================================
;; Denote Relationship Functions for Dired
;; ============================================================================

(defun my/denote-dired-add-child-relationship ()
  "Add child relationship to all marked files in Dired.
Creates a child relationship from the first marked file to all others."
  (interactive nil dired-mode)
  (if-let* ((marks (dired-get-marked-files))
            (parent (car marks))
            (children (cdr marks)))
      (progn
        (message "Adding child relationships from %s to %d files..." 
                 (file-name-nondirectory parent) (length children))
        (dolist (child children)
          (when (and (file-exists-p parent) (file-exists-p child))
            (with-current-buffer (find-file-noselect parent)
              (denote-link child)
              (save-buffer))
            (message "Added child relationship: %s -> %s" 
                     (file-name-nondirectory parent) (file-name-nondirectory child))))
        (message "Successfully added child relationships to %d files" (length children)))
    (user-error "Need at least 2 marked files; aborting")))

(defun my/denote-dired-add-parent-relationship ()
  "Add parent relationship to all marked files in Dired.
Creates a parent relationship from all marked files to the first one."
  (interactive nil dired-mode)
  (if-let* ((marks (dired-get-marked-files))
            (child (car marks))
            (parents (cdr marks)))
        (progn
        (message "Adding parent relationships from %d files to %s..." 
                 (length parents) (file-name-nondirectory child))
        (dolist (parent parents)
          (when (and (file-exists-p parent) (file-exists-p child))
            (with-current-buffer (find-file-noselect parent)
              (denote-link child)
              (save-buffer))
            (message "Added parent relationship: %s -> %s" 
                     (file-name-nondirectory parent) (file-name-nondirectory child))))
        (message "Successfully added parent relationships from %d files" (length parents)))
    (user-error "Need at least 2 marked files; aborting")))

(defun my/denote-dired-add-sibling-relationships ()
  "Add sibling relationships between all marked files in Dired.
Creates bidirectional links between all marked files."
  (interactive nil dired-mode)
  (if-let* ((marks (dired-get-marked-files))
            (files marks))
      (progn
        (message "Adding sibling relationships between %d files..." (length files))
        (let ((count 0))
          (dolist (file1 files)
            (dolist (file2 files)
              (when (and (not (equal file1 file2))
                         (file-exists-p file1) 
                         (file-exists-p file2))
                (denote-add-links file1 file2)
                (setq count (1+ count)))))
          (message "Successfully added %d sibling relationships" count)))
    (user-error "Need at least 2 marked files; aborting")))

(defun my/denote-dired-add-relationship-with-prompt ()
  "Add relationship between marked files with user choice.
Prompts for relationship type: child, parent, or sibling."
  (interactive nil dired-mode)
  (if-let* ((marks (dired-get-marked-files)))
      (let ((choice (completing-read "Relationship type: " 
                                     '("child" "parent" "sibling") 
                                     nil t)))
        (cond
         ((string= choice "child")
          (my/denote-dired-add-child-relationship))
         ((string= choice "parent")
          (my/denote-dired-add-parent-relationship))
         ((string= choice "sibling")
          (my/denote-dired-add-sibling-relationships))
         (t (user-error "Invalid choice: %s" choice))))
    (user-error "No marked files; aborting")))

;; ============================================================================
;; Utility Functions: File Conversion
;; ============================================================================

(defun my/convert-date-files-to-denote-daily-journal ()
  "Convert files in format YYYY-MM-DD.org to Denote daily journal format.
Searches in denote-directory for files matching YYYY-MM-DD.org pattern
and renames them to Denote format with 'journal' and 'daily' keywords."
  (interactive)
  (let* ((denote-dir (expand-file-name denote-directory))
         (files (directory-files denote-dir t "^[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org$"))
         (converted-count 0))
    
    (if (null files)
        (message "No files matching YYYY-MM-DD.org pattern found in %s" denote-dir)
      
      (when (yes-or-no-p (format "Found %d daily journal file(s) to convert. Proceed? " (length files)))
        (dolist (old-file files)
          (when (my/convert-date-file-to-denote-daily-journal old-file)
            (setq converted-count (1+ converted-count))))
        
        (message "Converted %d/%d files to Denote daily journal format" converted-count (length files))))))

(defun my/dired-convert-date-files-to-denote-daily-journal ()
  "Convert marked (or current) files in dired from YYYY-MM-DD.org to Denote daily journal format.
Works with marked files in dired, or the file at point if none marked.
Files are converted in-place (in the current directory)."
  (interactive)
  (unless (derived-mode-p 'dired-mode)
    (user-error "This command only works in dired"))
  
  (let* ((files (dired-get-marked-files nil nil))  ; Get marked files or file at point
         (matching-files (seq-filter
                         (lambda (f)
                           (and (file-regular-p f)  ; Make sure it's a regular file
                                (string-match "^[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\.org$"
                                            (file-name-nondirectory f))))
                         files))
         (converted-count 0))
    
    (message "DEBUG: Found %d marked files, %d matching pattern" (length files) (length matching-files))
    
    (if (null files)
        (message "No files marked or at point")
      (if (null matching-files)
          (message "No files matching YYYY-MM-DD.org pattern in %d selected file(s). Selected: %s" 
                   (length files)
                   (mapconcat #'file-name-nondirectory files ", "))
        
        (when (yes-or-no-p (format "Convert %d marked file(s) to Denote daily journal format? " (length matching-files)))
          (dolist (file matching-files)
            (message "Converting: %s" file)
            (when (my/convert-date-file-to-denote-daily-journal file)
              (setq converted-count (1+ converted-count))))
          
          (revert-buffer)  ; Refresh dired to show new filenames
          (message "Converted %d/%d files to Denote daily journal format" converted-count (length matching-files)))))))

;; ============================================================================
;; Custom Functions: Note Creation
;; ============================================================================

;; Custom function: Create fleeting note (quick capture)
(defun my/denote-fleeting ()
  "Create a new fleeting note in fleeting-notes subdirectory."
  (interactive)
  (let ((denote-directory (expand-file-name "fleeting-notes/" denote-directory)))
    (denote (read-string "Fleeting note title: ")
            '("fleeting"))))

(global-set-key (kbd "C-c d F") 'my/denote-fleeting)  ; Quick fleeting note

;; Custom function: Create movie note with template
(defun my/denote-movie ()
  "Create a movie note with pre-filled metadata."
  (interactive)
  (let* ((title (read-string "Movie title: "))
         (year (read-string "Year: "))
         (director (read-string "Director: "))
         (genre (read-string "Genre: "))
         (rating (read-string "Rating (1-10): "))
         (denote-directory (expand-file-name "movies/" denote-directory))
         (keywords '("movie")))
    ;; Create the note
    (denote title keywords)
    ;; Insert template
    (goto-char (point-max))
    (insert "\n* Movie Information\n\n")
    (insert (format "- Year: %s\n" year))
    (insert (format "- Director: %s\n" director))
    (insert (format "- Genre: %s\n" genre))
    (insert (format "- Rating: %s/10\n" rating))
    (insert (format "- Watched: %s\n" (format-time-string "[%Y-%m-%d %a]")))
    (insert "\n* Summary\n\n")
    (insert "\n* Notes\n\n")
    (insert "\n* Quotes\n\n")
    (insert "\n* Related Movies\n\n")
    (save-buffer)))

(global-set-key (kbd "C-c d v") 'my/denote-movie)  ; Create movie note (v = video/movie)

;; ============================================================================
;; Denote-org Configuration - Org integration for denote
;; ============================================================================

(use-package denote-org
  :after denote
  :ensure t
  :commands
  ( denote-org-link-to-heading
    denote-org-backlinks-for-heading
    denote-org-extract-org-subtree
    denote-org-convert-links-to-file-type
    denote-org-convert-links-to-denote-type
    denote-org-dblock-insert-files
    denote-org-dblock-insert-links
    denote-org-dblock-insert-backlinks
    denote-org-dblock-insert-missing-links
    denote-org-dblock-insert-files-as-headings))

;; ============================================================================
;; Denote-silo Configuration - Silo management for denote
;; ============================================================================

(use-package denote-silo
  :after denote
  :ensure t
  :custom
  (denote-silo-directories
   (list denote-directory
         "~/Sync/org/notes/"
         "~/Sync/org/programming/"
         "~/Sync/org/music"))
  :bind
  (("C-c d S" . denote-silo-create-note)           ; Create note in silo
   ("C-c d s o" . denote-silo-open-or-create)      ; Open or create in silo
   ("C-c d s s" . denote-silo-select-silo-then-command) ; Select silo then command
   ("C-c d s d" . denote-silo-dired)               ; Open silo in dired
   ("C-c d s c" . denote-silo-cd)))                ; Change to silo directory

;; ============================================================================
;; Consult-denote Configuration - Search notes with consult
;; ============================================================================

(use-package consult-denote
  :after denote
  :ensure t
  :bind
  (("C-c s d" . consult-denote-find)   ; Find note with preview
   ("C-c s g" . consult-denote-grep)))  ; Grep in notes

;; ============================================================================
;; Denote-markdown Configuration - Markdown support for denote
;; ============================================================================

(use-package denote-markdown
  :after denote
  :ensure t
  :bind
  (("C-c d C-m" . denote-markdown-convert-to-markdown)))  ; Convert to markdown (rarely used)

;; ============================================================================
;; Denote-menu Configuration - List notes in a buffer
;; ============================================================================

(use-package denote-menu
  :after denote
  :ensure t
  :bind
  (("C-c d M" . denote-menu-list-notes)))  ; Show all notes in menu

;; ============================================================================
;; Denote-explore Configuration - Visualize note connections
;; ============================================================================

(use-package denote-explore
  :after denote
  :ensure t
  :bind
  (("C-c x c" . denote-explore-count-notes)         ; Count all notes
   ("C-c x k" . denote-explore-count-keywords)      ; Count keywords
   ("C-c x d" . denote-explore-duplicate-notes)     ; Find duplicates
   ("C-c x z" . denote-explore-zero-keywords)       ; Notes without keywords
   ("C-c x s" . denote-explore-single-keywords)     ; Notes with one keyword
   ("C-c x o" . denote-explore-sync-metadata)       ; Sync metadata
   ("C-c x r" . denote-explore-rename-keyword)      ; Rename keyword
   ("C-c x n" . denote-explore-network)             ; Generate network graph
   ("C-c x w" . denote-explore-random-walk)         ; Random walk through notes
   ("C-c x l" . denote-explore-random-links)        ; Random linked notes
   ("C-c x t" . denote-explore-barchart-timeline)   ; Timeline chart
   ("C-c x b" . denote-explore-barchart-backlinks)  ; Backlinks chart
   ("C-c x g" . denote-explore-barchart-degree)     ; Degree chart
   ("C-c x i" . denote-explore-isolated-notes)      ; Find isolated notes
   ("C-c x m" . denote-explore-missing-links))      ; Find broken links
  :config
  ;; Which-key descriptions for denote-explore
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements
      "C-c x" "Denote Explore"
      "C-c x c" "󰊫 Count Notes"
      "C-c x k" "󰏫 Count Keywords"
      "C-c x d" "󰆐 Find Duplicates"
      "C-c x z" "󰅖 Zero Keywords"
      "C-c x s" "󰎽 Single Keywords"
      "C-c x o" "󰆐 Sync Metadata"
      "C-c x r" "󰆐 Rename Keyword"
      "C-c x n" "󰘦 Network View"
      "C-c x w" "󰖟 Random Walk"
      "C-c x l" "󰖟 Random Links"
      "C-c x t" "󰊫 Timeline Chart"
      "C-c x b" "󰊫 Backlinks Chart"
      "C-c x g" "󰊫 Degree Chart"
      "C-c x i" "󰅖 Isolated Notes"
      "C-c x m" "󰆐 Missing Links")))

;; ============================================================================
;; Denote Sequence - Sequential numbering for notes
;; ============================================================================

(use-package denote-sequence
  :ensure t
  :after denote
  :bind
  ( :map global-map
    ;; "C-c d s" prefix for denote [s]equence commands
    ;; Additional commands available:
    ;; - `denote-sequence-new-parent'
    ;; - `denote-sequence-new-sibling'
    ;; - `denote-sequence-new-child'
    ;; - `denote-sequence-new-child-of-current'
    ;; - `denote-sequence-new-sibling-of-current'
    ("C-c d s s" . denote-sequence)
    ("C-c d s f" . denote-sequence-find)
    ("C-c d s l" . denote-sequence-link)
    ("C-c d s d" . denote-sequence-dired)
    ("C-c d s r" . denote-sequence-reparent)
    ("C-c d s c" . denote-sequence-convert))
  :config
  ;; The default sequence scheme is `numeric'; can also use `alphanumeric'
  (setq denote-sequence-scheme 'alphanumeric))

(provide 'denote-config)