;;; maintenance.el --- Maintenance functions for note system

;; ============================================================================
;; Finding Files with Missing Metadata
;; ============================================================================

(defun my/find-denote-missing-frontmatter ()
  "Find all denote files missing required front matter.
Shows files that don't have #+title, #+date, or #+filetags."
  (interactive)
  (let ((denote-dirs (if (boundp 'my-denote-silos)
                         (mapcar #'cdr my-denote-silos)
                       (list (expand-file-name "~/org/denote/")
                             (expand-file-name "~/org/nb/")
                             (expand-file-name "~/org/nb/zk/"))))
        (missing-files '()))
    (dolist (dir denote-dirs)
      (when (file-directory-p dir)
        (dolist (file (directory-files-recursively dir "\\.org$"))
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (let ((has-title (re-search-forward "^#\\+title:" nil t))
                  (has-date (re-search-forward "^#\\+date:" nil t))
                  (has-tags (re-search-forward "^#\\+filetags:" nil t)))
              (unless (and has-title has-date has-tags)
                (push (list file
                            (cond
                             ((not has-title) "missing title")
                             ((not has-date) "missing date")
                             ((not has-tags) "missing filetags")
                             (t "missing multiple")))
                      missing-files)))))))
    (if missing-files
        (progn
          (with-output-to-temp-buffer "*Missing Front Matter*"
            (princ (format "Found %d files with missing front matter:\n\n" (length missing-files)))
            (dolist (item missing-files)
              (princ (format "%s - %s\n" (cadr item) (car item))))
            (princ "\nPress 'q' to close this buffer."))
          (message "Found %d files with missing front matter" (length missing-files)))
      (message "All files have required front matter"))))

(defun my/find-org-missing-properties ()
  "Find org headings missing important properties.
Looks for TODO items without CATEGORY or PROJECT properties."
  (interactive)
  (let ((files (org-agenda-files))
        (missing '()))
    (dolist (file files)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (when (org-entry-is-todo-p)
               (let ((category (org-entry-get nil "CATEGORY"))
                     (project (org-entry-get nil "PROJECT"))
                     (heading (org-get-heading t t)))
                 (when (and (not category) (not project))
                   (push (list file heading) missing)))))
           nil 'file)
          (kill-buffer (current-buffer)))))
    (if missing
        (progn
          (with-output-to-temp-buffer "*Missing Properties*"
            (princ (format "Found %d headings with missing properties:\n\n" (length missing)))
            (dolist (item missing)
              (princ (format "%s: %s\n" (car item) (cadr item))))
            (princ "\nPress 'q' to close this buffer."))
          (message "Found %d headings with missing properties" (length missing)))
      (message "All headings have properties"))))

(defun my/find-tasks-without-context ()
  "Find tasks without context tags (@computer, @home, etc.)."
  (interactive)
  (let ((files (org-agenda-files))
        (missing '()))
    (dolist (file files)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (when (org-entry-is-todo-p)
               (let ((tags (org-get-tags))
                     (heading (org-get-heading t t)))
                 (unless (seq-some (lambda (tag) (string-prefix-p "@" tag)) tags)
                   (push (list file heading) missing)))))
           nil 'file)
          (kill-buffer (current-buffer)))))
    (if missing
        (progn
          (with-output-to-temp-buffer "*Tasks Without Context*"
            (princ (format "Found %d tasks without context tags:\n\n" (length missing)))
            (dolist (item missing)
              (princ (format "%s: %s\n" (car item) (cadr item))))
            (princ "\nPress 'q' to close this buffer."))
          (message "Found %d tasks without context tags" (length missing)))
      (message "All tasks have context tags"))))

(defun my/find-unlinked-denote ()
  "Find denote notes with no backlinks (orphaned notes).
Uses org-ql if available, otherwise basic search."
  (interactive)
  (if (and (fboundp 'org-ql-search) (boundp 'my-denote-silos))
      (org-ql-search (mapcar #'cdr my-denote-silos)
        '(tags "denote")
        :action (lambda ()
                  (format "- %s\n" (org-get-heading t t)))
        :title "Denote Notes (check for links manually)")
    (message "org-ql or my-denote-silos not available. Install org-ql for this feature.")))

;; ============================================================================
;; Maintenance Workflows
;; ============================================================================

(defun my/maintenance-check ()
  "Run all maintenance checks.
Checks for missing front matter, missing properties, and tasks without context."
  (interactive)
  (message "Running maintenance checks...")
  (my/find-denote-missing-frontmatter)
  (sleep-for 0.5)
  (my/find-org-missing-properties)
  (sleep-for 0.5)
  (my/find-tasks-without-context)
  (message "Maintenance checks complete. Check buffers for results."))

(defun my/cleanup-old-archives ()
  "Find and suggest archiving old completed items.
Looks for DONE items older than 30 days."
  (interactive)
  (let ((files (org-agenda-files))
        (old-items '()))
    (dolist (file files)
      (when (file-exists-p file)
        (with-current-buffer (find-file-noselect file)
          (org-map-entries
           (lambda ()
             (when (string= (org-get-todo-state) "DONE")
               (let ((closed-time (org-entry-get nil "CLOSED"))
                     (heading (org-get-heading t t)))
                 (when closed-time
                   (let ((closed-date (org-time-string-to-time closed-time))
                         (days-ago (time-to-number-of-days
                                    (time-subtract (current-time) closed-date))))
                     (when (> days-ago 30)
                       (push (list file heading days-ago) old-items)))))))
           nil 'file)
          (kill-buffer (current-buffer)))))
    (if old-items
        (progn
          (with-output-to-temp-buffer "*Old Completed Items*"
            (princ (format "Found %d completed items older than 30 days:\n\n" (length old-items)))
            (dolist (item old-items)
              (princ (format "%s (%d days ago): %s\n" (car item) (caddr item) (cadr item))))
            (princ "\nConsider archiving these items with C-c C-x C-a")
            (princ "\nPress 'q' to close this buffer."))
          (message "Found %d old completed items" (length old-items)))
      (message "No old completed items found"))))

;; ============================================================================
;; Keybindings
;; ============================================================================

(global-set-key (kbd "C-c m f") 'my/find-denote-missing-frontmatter)
(global-set-key (kbd "C-c m p") 'my/find-org-missing-properties)
(global-set-key (kbd "C-c m c") 'my/find-tasks-without-context)
(global-set-key (kbd "C-c m u") 'my/find-unlinked-denote)
(global-set-key (kbd "C-c m a") 'my/maintenance-check)
(global-set-key (kbd "C-c m o") 'my/cleanup-old-archives)

(provide 'ck-maintenance)

