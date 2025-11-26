;; ----------------------------------------------------------------------------
;; Fixed-pitch font for Org blocks (code, quote, comment, etc.)
;; ----------------------------------------------------------------------------
(with-eval-after-load 'org
  (defface org-block-fixed-pitch
    '((t (:inherit fixed-pitch)))
    "Face for Org blocks using fixed-pitch font.")

  (dolist (face '(org-block org-block-begin-line org-block-end-line org-quote org-comment))
    (when (facep face)
      (set-face-attribute face nil :inherit 'org-block-fixed-pitch)))
  )
;;; org-core.el --- Core Org mode configuration

;; Custom setup function for org-mode buffers
(defun my/setup-org-mode ()
  "Custom configurations for org-mode."
  (setq-local visual-line-fringe-indicators '(nil nil))  ; No fringe indicators for wrapped lines
  (visual-line-mode 1)                                   ; Wrap lines at word boundaries
  (setq line-spacing 0.1)                                ; Add slight spacing between lines

  ;; Apply custom org-reading preset (only if fontaine is loaded)
  (when (and (boundp 'fontaine-presets) (fboundp 'fontaine-set-preset))
    (fontaine-set-preset 'org-reading))

  ;; Configure mixed-pitch to preserve font sizes
  (setq-local mixed-pitch-set-height t)  ; Let mixed-pitch use face heights

  ;; Configure which faces should remain fixed-pitch
  (setq-local mixed-pitch-fixed-pitch-faces
              '(org-block
                org-block-begin-line
                org-block-end-line
                org-code
                org-comment
                org-quote
                org-table
                org-verbatim
                org-drawer
                org-property-value
                org-meta-line
                org-document-info-keyword
                org-special-keyword
                org-sexp-date
                line-number
                line-number-current-line))

  ;; Enable mixed-pitch-mode (variable-pitch for prose, fixed-pitch for code/tables)
  (mixed-pitch-mode 1)

  ;; Hide various markers for cleaner appearance
  (setq-local org-hide-emphasis-markers t)  ; Hide *, /, _, = markers
  (setq-local org-hide-macro-markers t)     ; Hide macro markers
  (setq-local org-hide-drawer-startup t)    ; Hide drawer markers on startup

  ;; Set custom heading sizes (subtle scale - variable-pitch is already large)
  ;; Headings inherit from variable-pitch, so they're already bigger than monospace
  (dolist (level (number-sequence 1 6))
    (let ((height (nth (- level 1) '(1.35 1.25 1.15 1.08 1.04 1.00)))
          (face (intern (format "org-level-%d" level))))
      (when (facep face)
        (set-face-attribute face nil
                            :weight 'regular
                            :height height
                            :family my/font-serif  ; Inherit from variable-pitch
                            :foreground 'unspecified))))  ; Don't override theme colors

  (set-face-attribute 'org-sexp-date nil
                      :family my/font-monospace
                      :height 90)
  ;; Document title styling
  (when (facep 'org-document-title)
    (set-face-attribute 'org-document-title nil
                        :weight 'bold
                        :height 1.1     ; Prominent but not overwhelming
                        :underline nil
                        :family my/font-monospace
                        :foreground 'unspecified))

  ;; Fix org-drawer face to use fixed-pitch font
  (my/apply-org-drawer-face)

  ;; Ensure fixed-pitch font for code and technical elements
  ;; These should always use monospace, regardless of theme
  (dolist (face '(org-block
                  org-block-begin-line
                  org-block-end-line
                  org-code
                  org-comment
                  org-quote
                  org-document-info
                  org-document-info-keyword
                  org-meta-line
                  org-property-value
                  org-special-keyword
                  org-table
                  org-verbatim))
    (when (facep face)
      (set-face-attribute face nil
                          :family my/font-monospace
                          :inherit 'fixed-pitch
                          :foreground 'unspecified  ; Let theme handle colors
                          :background 'unspecified)))

  ;; Make org-priority face match heading height
  (when (facep 'org-priority)
    (set-face-attribute 'org-priority nil
                        :height 1.0  ; Match the base heading height
                        :inherit 'default))

  ;; Remove underline from org-ellipsis face
  (when (facep 'org-ellipsis)
    (set-face-attribute 'org-ellipsis nil
                        :underline nil
                        :inherit 'default))

  ;; Enable visual line mode for better text wrapping
  (visual-line-mode 1))

;; Prevent themes from overriding our font settings
(defun my/reapply-org-fonts-after-theme ()
  "Reapply font settings after loading a theme."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
        (my/setup-org-mode)))))

;; Use modern hook instead of deprecated defadvice
(add-hook 'after-load-theme-hook 'my/reapply-org-fonts-after-theme)

;; Force org-drawer face to use fixed-pitch font globally
;; This must be applied after themes to override any theme settings
(defun my/apply-org-drawer-face ()
  "Apply org-drawer face with fixed-pitch font."
  (when (facep 'org-drawer)
    (set-face-attribute 'org-drawer nil
                        :family my/font-monospace
                        :height 90
                        :inherit nil
                        :foreground (face-attribute 'font-lock-comment-face :foreground))))

;; Apply after org is loaded
(with-eval-after-load 'org
  (my/apply-org-drawer-face))

;; Reapply after theme loading
(add-hook 'after-load-theme-hook 'my/apply-org-drawer-face)

;; Apply setup function to all org-mode buffers
(add-hook 'org-mode-hook 'my/setup-org-mode)

;; Enable file path completion in org-mode
(defun my/org-mode-setup-completion ()
  "Setup completion-at-point for org-mode with file path completion."
  ;; Enable pcomplete for org-mode (handles #+include:, #+setupfile:, etc.)
  (require 'pcomplete)
  
  ;; Add cape-file for file path completion (requires cape package)
  (when (fboundp 'cape-file)
    ;; Add cape-file to completion-at-point functions
    (add-hook 'completion-at-point-functions #'cape-file -10 t))
  
  ;; Ensure Corfu works in org-mode if enabled
  (when (fboundp 'corfu-mode)
    (corfu-mode 1)))

(add-hook 'org-mode-hook 'my/org-mode-setup-completion)

;; Ensure fonts are applied immediately for existing org buffers
(defun my/apply-org-fonts-to-existing-buffers ()
  "Apply font settings to all existing \='org-mode\=' buffers."
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (when (derived-mode-p 'org-mode)
        (my/setup-org-mode)
        (my/apply-org-drawer-face)))))

;; Apply fonts after a short delay to ensure all packages are loaded
(run-with-timer 1 nil 'my/apply-org-fonts-to-existing-buffers)

;; Test function to verify font loading
(defun my/test-fonts ()
  "Test function to verify that fonts are loading correctly."
  (interactive)
  (message "Testing font configuration...")
  (message "Serif font variable: %s" my/font-serif)
  (message "Monospace font variable: %s" my/font-monospace)
  (message "Fontaine loaded: %s" (boundp 'fontaine-presets))
  (message "Mixed-pitch loaded: %s" (fboundp 'mixed-pitch-mode))
  (when (boundp 'fontaine-presets)
    (message "Current fontaine preset: %s" fontaine-current-preset))
  (message "Variable-pitch face family: %s" (face-attribute 'variable-pitch :family))
  (message "Fixed-pitch face family: %s" (face-attribute 'fixed-pitch :family))
  (message "Default face family: %s" (face-attribute 'default :family)))

;; Keybinding for font test
(global-set-key (kbd "C-c f t") 'my/test-fonts)

;; ----------------------------------------------------------------------------
;; Core Org Settings
;; ----------------------------------------------------------------------------

(modify-all-frames-parameters
 '((right-divider-width . 40)
   (internal-border-width . 40)))
(dolist (face '(window-divider
                window-divider-first-pixel
                window-divider-last-pixel))
  (face-spec-reset-face face)
  (set-face-foreground face (face-attribute 'default :background)))
(set-face-background 'fringe (face-attribute 'default :background))

(setq org-directory "~/notes/org/"
      org-startup-indented t                     ; Indent according to heading level
      org-startup-folded 'content                ; Show only top-level headings on open
      org-hide-emphasis-markers t                ; Hide markup characters (*bold*, /italic/, etc.)
      org-pretty-entities t                      ; Show LaTeX symbols as unicode
      org-ellipsis "…"                           ; Custom folding indicator
      org-startup-with-inline-images t           ; Display images by default
      org-cycle-separator-lines 2                ; Blank lines before visible heading
      org-src-fontify-natively t                 ; Syntax highlighting in code blocks
      org-src-tab-acts-natively t                ; Tab indents in code blocks
      org-confirm-babel-evaluate nil             ; Don't ask before evaluating code
      org-edit-src-content-indentation 0         ; Don't indent code block contents
      org-src-preserve-indentation nil           ; Don't preserve leading whitespace
      org-log-done 'time                         ; Log completion time for tasks
      org-deadline-warning-days 14               ; Warn 14 days before deadline

      org-agenda-files '("~/notes/org/journal" "~/notes/org/gtd/")  ; Directories for agenda
      
      ;; Attachment settings
      org-attach-id-dir "~/notes/org/attachments"        ; Directory for ID-based attachments
      org-attach-dir-relative t                          ; Use relative paths for portability
      org-attach-use-inheritance t                       ; Inherit attachments from parent headings
      org-attach-method 'mv                              ; Move files (avoid duplication)
      org-attach-preferred-new-method 'dir               ; Use DIR property (simpler than ID)
      org-attach-auto-tag "attach"                       ; Auto-tag headings with attachments
      org-attach-store-link-p 'attached                  ; Store link to attachment location
      org-attach-archive-delete 'query                   ; Ask before deleting attachments on archive
      org-log-into-drawer t
      org-auto-align-tags nil
      org-tags-column 0
      org-catch-invisible-edits 'show-and-error
      org-special-ctrl-a/e t
      org-insert-heading-respect-content t
      org-agenda-tags-column 0
      org-hide-leading-stars t
      org-todo-keywords '((sequence "NEXT(n)" "TODO(t)" "WAIT(w@)" "SOMEDAY(s)" "|" "DONE(d)" "CNCL(c@)"))
      org-tag-alist '(
                      ;; ===== CONTEXTS =====
                      (:startgrouptag)
                      ("context" . ?x)
                      (:grouptags)
                      ;; DEVICES
                      ("@computer"     . ?c)    ;; Any computer
                      ("@desktop"      . ?d)    ;; Geekom A8 specifically
                      ("@laptop"       . ?l)    ;; Lenovo X1 specifically  
                      ("@nas"          . ?n)    ;; NAS specifically
                      ("@phone"        . ?p)    ;; Calls, messages
                      ;; WHERE
                      ("@errands"      . ?e)    ;; Outside tasks
                      ("@home"         . ?h)    ;; Home (non-computer)
                      ("@music"        . ?m)    ;; With instrument/studio
                      ("@reading"      . ?r)    ;; Reading (ereader/books)
                      ("@anywhere"     . ?a)    ;; Can do anywhere
                      (:endgrouptag)
                      ;; ===== ENERGY & TIME =====
                      (:startgrouptag)
                      ("energy" . ?E)
                      (:grouptags)
                      ("@quick"        . ?q)    ;; <15 min, low energy
                      ("@focus"        . ?f)    ;; >30 min, high energy  
                      ("@low"          . ?w)    ;; >60 min, low energy (using ?w for "when tired")
                      (:endgrouptag)
                      
                      ;; ===== SPECIAL =====
                      ("@idea"         . ?i)    ;; Future ideas
                )
)

;; Babel - Execute code in source blocks (wrapped to load after Org)
;; (with-eval-after-load 'org
;;   (org-babel-do-load-languages
;;    'org-babel-load-languages
;;    '((shell . t)           ; Enable shell execution (built-in)
;;      (emacs-lisp . t)      ; Enable Elisp execution (built-in)
;;      (python . t)))        ; Enable Python execution (built-in)

;;   ;; Babel settings
;;   (setq org-babel-sh-command "bash"                    ; Use bash for shell blocks
;;         org-babel-shell-names '("bash" "sh" "fish")     ; Supported shell names
;;         org-babel-shell-results-default-format "output" ; Show output by default
;;         org-confirm-babel-evaluate nil))                ; Don't confirm before execution

;; Terminal/EAT settings
;;(setq org-babel-terminal-command "eat"               ; Use eat terminal forV
;;                                                     ; interactive commands
;;      org-babel-shell-command "bash"                 ; Use bash for shell commands
;;      org-babel-shell-prompt "\\$ "                  ; Shell prompt pattern
;;      org-babel-shell-results-default-format "output")) ; Show output by default

;; Archive settings
(setq org-archive-save-context-info '(time category itags)  ; Save when, where, and tags
      org-archive-location "~/notes/org/~archive/%s_archive.org::* Archived from %s\n")  ; Archive location pattern

;; Refile targets - where to move/copy headings
;; (setq org-refile-targets
;;       '((nil :maxlevel . 3)        ; Current file up to 3 levels
;;         (agenda :maxlevel . 3)     ; Agenda files up to 2 levels
;;         (notes :maxlevel . 2)      ; Notes files up to 2 levels
;;         (gtd :maxlevel . 2)        ; GTD files up to 2 levels
;;         (archive :maxlevel . 2)))  ; Archive files up to 2 levels

;; Refile to any agenda file at most 2 levels deep
(setq org-refile-targets '((nil :maxlevel . 2)              ; Current file
                           (org-agenda-files :maxlevel . 2))) ; All agenda files

;; generate refile tarets and show them at once
(setq org-outline-path-complete-in-steps nil)
;; ask to confirm creating parent nodes
(setq org-refile-allow-creating-parent-nodes 'confirm)

;; Modules - additional org features
(setq org-modules '(org-habit))    ; Enable habit tracking

;; ----------------------------------------------------------------------------
;; Org Capture Templates
;; ----------------------------------------------------------------------------

;; Helper function to open journal for a specific date
(defun my/open-journal-for-date (date-string)
  "Open journal file for DATE-STRING (YYYYMMDD format).
Creates it if needed. Ensures ONE file per day."
  (let* ((journal-dir (expand-file-name "~/notes/org/journal/"))
         ;; Ensure journal directory exists
         (_ (unless (file-directory-p journal-dir)
              (make-directory journal-dir t)))
         ;; Look for existing journal file for this date
         (existing-file (car (directory-files 
                              journal-dir 
                              t 
                              (concat "^" date-string "T.*__journal\\.org$")))))
    (if existing-file
        ;; File exists - open it and go to the end
        (progn
          (find-file existing-file)
          (goto-char (point-max))
          (message "Opened journal for %s" date-string))
      ;; File doesn't exist - create it
      (let* ((time (org-parse-time-string (concat date-string "T000000")))
             (title (format-time-string "%A, %d %B %Y" (encode-time time)))
             (slug (downcase (replace-regexp-in-string "[^a-zA-Z0-9-]" "-" title)))
             (filename (format "%sT000000--%s__journal.org" date-string slug))
             (filepath (expand-file-name filename journal-dir)))
        (find-file filepath)
        (insert (format "#+title: %s\n" title))
        (insert (format "#+date: %s\n" 
                        (format-time-string "[%Y-%m-%d %a]" (encode-time time))))
        (insert "#+filetags: :journal:\n")
        (insert (format "#+identifier: %sT000000\n\n" date-string))
        (insert "* Morning\n\n\n* Afternoon\n\n\n* Evening\n\n\n* Notes\n\n\n* Tomorrow\n\n\n")
        (goto-char (point-max))
        (save-buffer)
        (message "Created journal for %s" date-string)))))

;; Helper function to get or create today's journal entry and OPEN IT
(defun my/open-todays-journal ()
  "Open today's journal file, creating it if needed.
Ensures ONE file per day - no duplicates.
Always opens the file directly for editing."
  (interactive)
  (my/open-journal-for-date (format-time-string "%Y%m%d")))

;; Function to open journal from calendar
(defun my/open-journal-from-calendar ()
  "Open journal for the date at point in calendar."
  (interactive)
  (let* ((date (calendar-cursor-to-date))
         (date-string (format "%04d%02d%02d" 
                              (nth 2 date)  ; year
                              (nth 0 date)  ; month
                              (nth 1 date)))) ; day
    (my/open-journal-for-date date-string)))

;; Add keybinding to calendar mode
(with-eval-after-load 'calendar
  (define-key calendar-mode-map (kbd "j") 'my/open-journal-from-calendar))

;; Note: org-capture-templates are defined in org-extensions.el
;; This file only provides the helper functions used by those templates

;; Configure capture to use full window (no split)
(setq org-capture-window-setup 'current-window)

;; Alternative: use display-buffer-alist for more control
(add-to-list 'display-buffer-alist
             '("\\*Org Select\\*"
               (display-buffer-in-side-window)
               (side . bottom)
               (window-height . 0.3)))

;; ----------------------------------------------------------------------------
;; Capture Keybindings
;; ----------------------------------------------------------------------------

;; Global capture shortcuts
(global-set-key (kbd "C-c c") 'org-capture)  ; Opens capture menu: j=journal, d=denote
(global-set-key (kbd "C-c j") 'my/open-todays-journal)  ; Quick access to today's journal

(provide 'org-core)
