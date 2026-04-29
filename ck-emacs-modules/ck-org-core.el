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
  
  ;; In terminal mode, ensure stars are properly hidden
  (unless (display-graphic-p)
    (setq-local org-hide-leading-stars t)
    (setq-local org-indent-indentation-per-level 2)
    ;; Force enable org-indent-mode to hide stars
    (org-indent-mode 1)
    ;; Disable org-modern if it somehow got enabled
    (when (bound-and-true-p org-modern-mode)
      (org-modern-mode -1)))

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
  ;; Show drawers (including LOGBOOK with clock data) by default
  (setq-local org-hide-drawer-startup nil)

  ;; Set custom heading sizes (subtle scale - variable-pitch is already large)
  ;; Headings inherit from variable-pitch, so they're already bigger than monospace
  (when (boundp 'my/font-serif)
    (dolist (level (number-sequence 1 6))
      (let ((height (nth (- level 1) '(1.35 1.25 1.15 1.08 1.04 1.00)))
            (face (intern (format "org-level-%d" level))))
        (when (facep face)
          (set-face-attribute face nil
                              :weight 'regular
                              :height height
                              :family my/font-serif  ; Inherit from variable-pitch
                              :foreground 'unspecified)))))  ; Don't override theme colors

  ;; Only set font families if font variables are defined
  (when (boundp 'my/font-monospace)
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
                            :background 'unspecified))))

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
  (when (and (facep 'org-drawer) (boundp 'my/font-monospace))
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

;; Load modus-vivendi theme for org-mode in terminal
(unless (display-graphic-p)
  (add-hook 'org-mode-hook
            (lambda ()
              (unless (member 'modus-vivendi custom-enabled-themes)
                (condition-case err
                    (progn
                      (modus-themes-load-vivendi)
                      (message "Loaded modus-vivendi theme for org-mode (terminal)"))
                  (error
                   ;; Fallback to load-theme if modus-themes-load-vivendi doesn't exist
                   (load-theme 'modus-vivendi t)
                   (message "Loaded modus-vivendi theme for org-mode (terminal)")))))
            t))

;; In terminal mode, force org-indent-mode early and hide stars
(unless (display-graphic-p)
  (add-hook 'org-mode-hook
            (lambda ()
              (setq-local org-hide-leading-stars t)
              (org-indent-mode 1)
              ;; Make stars invisible by setting their face
              (set-face-attribute 'org-hide nil :foreground (face-background 'default))
              (when (bound-and-true-p org-modern-mode)
                (org-modern-mode -1)))
            t))  ; Append to hook

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
  (message "Serif font variable: %s" (if (boundp 'my/font-serif) my/font-serif "NOT DEFINED"))
  (message "Monospace font variable: %s" (if (boundp 'my/font-monospace) my/font-monospace "NOT DEFINED"))
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
 '((right-divider-width . 0)
   (internal-border-width . 0)))
(dolist (face '(window-divider
                window-divider-first-pixel
                window-divider-last-pixel))
  (face-spec-reset-face face)
  (set-face-foreground face (face-attribute 'default :background)))
(set-face-background 'fringe (face-attribute 'default :background))

(setq org-directory "~/org/"
      org-startup-indented t                     ; Indent according to heading level
      ;; In terminal, always use indentation mode
      org-indent-mode-turns-on-hiding-stars t    ; Hide stars when indentation is on
      ;; Force hide stars globally in terminal mode
      org-hide-leading-stars t                    ; Hide leading stars
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

      org-agenda-files '("~/org/journal"              ; All ~/org/journal/*.org
                         "~/org/gtd/inbox.org"
                         "~/org/gtd/tasks.org"
                         "~/org/gtd/routines.org")   ; Files for agenda (routines for time-bound recurring tasks)
      
      ;; Attachment settings
      org-attach-id-dir "~/org/attachments"        ; Directory for ID-based attachments
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
      org-archive-location "~/org/archive/%s_archive.org::* Archived from %s\n")  ; Archive location pattern

;; Refile targets - where to move/copy headings
;; (setq org-refile-targets
;;       '((nil :maxlevel . 3)        ; Current file up to 3 levels
;;         (agenda :maxlevel . 3)     ; Agenda files up to 2 levels
;;         (notes :maxlevel . 2)      ; Notes files up to 2 levels
;;         (gtd :maxlevel . 2)        ; GTD files up to 2 levels
;;         (archive :maxlevel . 2)))  ; Archive files up to 2 levels

;; Refile targets: inbox, current file, and all agenda files
(setq org-refile-targets '((nil :maxlevel . 1)              ; Current file up to level 2
                           ("~/org/gtd/inbox.org" :maxlevel . 1))); Inbox file
                           ;(org-agenda-files :maxlevel . 1))) ; All agenda files up to level 2

;; generate refile tarets and show them at once
(setq org-outline-path-complete-in-steps nil)
;; ask to confirm creating parent nodes
(setq org-refile-allow-creating-parent-nodes 'confirm)

;; ----------------------------------------------------------------------------
;; Time tracking (clock) - automatic on state change, pause, total per task
;; ----------------------------------------------------------------------------
;; - Switching to NEXT or IN_PROGRESS starts the clock; switching away stops it.
;;   (IN_PROGRESS for files that use it, e.g. DEWESoft journal.) Manual: C-c C-x C-i / C-c C-x C-o.
;; - All clock intervals are stored in the LOGBOOK drawer; Org sums them.
;; - View total: column view %CLOCKSUM (or :CLOCK_SUM_T:), or agenda clock report.
(setq org-clock-into-drawer "LOGBOOK"          ; Store clock entries in LOGBOOK drawer
      org-clock-drawers-up-to-last-state t     ; Only one drawer open at a time
      org-clock-out-remove-zero-time-clocks t ; Remove 0-length clocks
      org-clock-out-when-done t                ; Auto clock out when task set to DONE
      org-clock-persist t                      ; Persist clock across Emacs sessions
      org-clock-persist-query-save nil         ; Save without asking
      org-clock-auto-clock-out nil             ; Optional: set to 30 to auto-stop after 30 min idle
      org-clock-mode-line-total 'current)      ; Mode line: show current clock or today total

(defvar my/org-clock-in-states '("NEXT" "IN_PROGRESS")
  "TODO states that start the clock when entered. NEXT and IN_PROGRESS (e.g. agenda/journal).")

(defun my/org-clock-in-when-working (&optional new-state)
  "When entering NEXT or IN_PROGRESS, clock in on this task.
NEW-STATE is passed by org-after-todo-state-change-hook when available;
otherwise we read the current TODO state at point."
  (require 'org-clock nil t)
  (let ((state (or new-state (nth 2 (org-heading-components)))))
    (when (and state (member state my/org-clock-in-states))
      (org-clock-in))))

(defun my/org-clock-out-when-leaving-working (&optional new-state)
  "When leaving a clocked-in state (NEXT/IN_PROGRESS), clock out if this task is clocked.
NEW-STATE is passed by org-after-todo-state-change-hook when available;
otherwise we read the current TODO state at point."
  (require 'org-clock nil t)
  (let ((state (or new-state (nth 2 (org-heading-components)))))
    (unless (and state (member state my/org-clock-in-states))
      (when (and (org-clock-is-active)
                 (fboundp 'org-clock-get-clock-task)
                 (org-clock-get-clock-task)
                 (let ((clock-pos (marker-position (org-clock-get-clock-task)))
                       (here (save-excursion (org-back-to-heading t) (point))))
                   (eq clock-pos here)))
        (org-clock-out)))))

(add-hook 'org-after-todo-state-change-hook #'my/org-clock-in-when-working)
(add-hook 'org-after-todo-state-change-hook #'my/org-clock-out-when-leaving-working)

;; Modules - additional org features
(setq org-modules '(org-habit))    ; Enable habit tracking (org-clock is core)

;; ----------------------------------------------------------------------------
;; Org Capture Templates
;; ----------------------------------------------------------------------------

;; Simple journal: single file ~/org/journal.org with date headings
(defun my/open-journal-for-date (date-string)
  "Open journal.org and navigate to DATE-STRING entry (YYYYMMDD format).
Creates the date entry if needed. Simple structure: just date headings."
  (let* ((journal-file (expand-file-name "~/org/journal.org"))
         (year (string-to-number (substring date-string 0 4)))
         (month (string-to-number (substring date-string 4 6)))
         (day (string-to-number (substring date-string 6 8)))
         (date-obj (encode-time 0 0 0 day month year))
         (date-heading (format-time-string "%Y-%m-%d %A" date-obj)))
    ;; Create file if needed
    (unless (file-exists-p journal-file)
      (with-temp-file journal-file
        (insert "#+title: Journal\n#+filetags: :journal:\n\n")))
    ;; Open and navigate
    (find-file journal-file)
    (goto-char (point-min))
    (if (re-search-forward (concat "^\\* " (regexp-quote date-heading)) nil t)
        ;; Found - go to end of entry
        (progn
          (org-end-of-subtree)
          (unless (bolp) (insert "\n")))
      ;; Not found - create at end
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert (format "* %s\n\n" date-heading)))
    (message "Journal: %s" date-heading)))

;; Helper function to get or create today's journal entry and OPEN IT
(defun my/open-todays-journal ()
  "Open journal.org file and navigate to today's entry.
Uses a single journal.org file with datetree structure.
Always opens the file directly for editing."
  (interactive)
  (my/open-journal-for-date (format-time-string "%Y%m%d")))

;; Helper functions for personal and work journals
(defun my/open-journal-for-date-and-type (date-string journal-type)
  "Open journal file (personal.org or work.org) and navigate to DATE-STRING entry.
JOURNAL-TYPE should be 'personal' or 'work'."
  (let* ((journal-file (expand-file-name (format "~/org/journal/%s.org" journal-type)))
         (year (string-to-number (substring date-string 0 4)))
         (month (string-to-number (substring date-string 4 6)))
         (day (string-to-number (substring date-string 6 8)))
         (date-obj (encode-time 0 0 0 day month year))
         (date-heading (format-time-string "%Y-%m-%d %A" date-obj)))
    ;; Create directory if needed
    (unless (file-directory-p (file-name-directory journal-file))
      (make-directory (file-name-directory journal-file) t))
    ;; Create file if needed
    (unless (file-exists-p journal-file)
      (with-temp-file journal-file
        (insert (format "#+title: %s Journal\n#+filetags: :journal:%s:\n\n" 
                        (capitalize journal-type) journal-type))))
    ;; Open and navigate
    (find-file journal-file)
    (goto-char (point-min))
    (if (re-search-forward (concat "^\\* " (regexp-quote date-heading)) nil t)
        ;; Found - go to end of entry
        (progn
          (org-end-of-subtree)
          (unless (bolp) (insert "\n")))
      ;; Not found - create at end
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert (format "* %s\n\n" date-heading)))
    (message "%s Journal: %s" (capitalize journal-type) date-heading)))

(defun my/open-todays-personal-journal ()
  "Open personal journal file and navigate to today's entry."
  (interactive)
  (my/open-journal-for-date-and-type (format-time-string "%Y%m%d") "personal"))

(defun my/open-todays-work-journal ()
  "Open work journal file and navigate to today's entry."
  (interactive)
  (my/open-journal-for-date-and-type (format-time-string "%Y%m%d") "work"))

;; Function to open journal from calendar (prompts for personal or work)
(defun my/open-journal-from-calendar ()
  "Open journal for the date at point in calendar.
Prompts to choose between personal or work journal."
  (interactive)
  (let* ((date (calendar-cursor-to-date))
         (date-string (format "%04d%02d%02d" 
                              (nth 2 date)  ; year
                              (nth 0 date)  ; month
                              (nth 1 date))) ; day
         (journal-type (completing-read "Journal type: " '("personal" "work") nil t)))
    (my/open-journal-for-date-and-type date-string journal-type)))

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
(global-set-key (kbd "C-c c") 'org-capture)  ; Opens capture menu: j=personal journal, J=work journal, d=denote
(global-set-key (kbd "C-c j") 'my/open-todays-personal-journal)  ; Quick access to today's personal journal
(global-set-key (kbd "C-c J") 'my/open-todays-work-journal)  ; Quick access to today's work journal

(provide 'ck-org-core)
