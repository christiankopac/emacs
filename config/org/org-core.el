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

  ;; Enable mixed-pitch-mode (variable-pitch for prose, fixed-pitch for code/tables)
  (mixed-pitch-mode 1)

  ;; Hide various markers for cleaner appearance
  (setq-local org-hide-emphasis-markers t)  ; Hide *, /, _, = markers
  (setq-local org-hide-macro-markers t)     ; Hide macro markers
  (setq-local org-hide-drawer-startup t)    ; Hide drawer markers on startup

  ;; Set custom heading sizes (subtle scale - variable-pitch is already large)
  ;; Headings inherit from variable-pitch, so they're already bigger than monospace
  ;; -
  (dolist (level (number-sequence 1 6))
    (let ((height (nth (- level 1) '(1.35 1.25 1.15 1.08 1.04 1.00)))
          (face (intern (format "org-level-%d" level))))
      (when (facep face)
        (set-face-attribute face nil
                            :weight 'regular
                            :height height
                            :family 'unspecified  ; Inherit from variable-pitch
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
                        :family 'unspecified
                        :foreground 'unspecified))

  ;; Fix org-drawer face to use fixed-pitch font
  (my/apply-org-drawer-face)

  ;; Define tag hierarchy and shortcuts
  (setq org-tag-alist
        '(;; Life areas (grouped)
          (:startgrouptag)
          ("area"          . ?a)
          (:grouptags)
          ("finance"       . ?f)  ;; sleep, meditation, journaling
          ("health"        . ?h)  ;; budgeting, investing, debt
          ("relationships" . ?r)  ;; friends, family, partner
          ("career"        . ?c)  ;; job, promotion, side hustle
          ("learning"      . ?l)  ;; reading, courses, podcasts
          ("creative"      . ?C)  ;; art, writing, music
          ("growth"        . ?g)  ;; journaling, self-reflection, personal development
          ("home"          . ?o)  ;; cleaning, organizing, cooking
          (:endgrouptag)
          ;; Contexts
          ("@home"         . ?h)  ;; personal, home, family
          ("@errands"      . ?e)  ;; errands, shopping, running
          ("@waiting"      . ?W)  ;; waiting, delegated, blocked
          ;; Energy levels
          ("@quick"         . ?q)  ;; FAST TASKS: low-energy, short tasks (<15 min)
          ("@focus"         . ?z)  ;; DEEP WORK: high-energy, deep work (>30 min)
          ("@low"           . ?L)  ;; WHEN TIRED: low-energy, long tasks (>60 min)
          ))

  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "ACTIVE(a)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)")))  ; Habit states

  ;; Ensure fixed-pitch font for code and technical elements
  ;; These should always use monospace, regardless of theme
  (dolist (face '(org-block
                  org-code
                  org-document-info
                  org-document-info-keyword
                  org-meta-line
                  org-property-value
                  org-special-keyword
                  org-table
                  org-verbatim))
    (when (facep face)
      (set-face-attribute face nil
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
                        :family "MonoLisa Nerd Font"
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

(setq org-directory "~/Sync/org/denote/"
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
      org-agenda-files '("~/Sync/org/journal" "~/Sync/org/gtd/")  ; Directories for agenda
      ;; org-modern settings
      org-auto-align-tags nil
      org-tags-column 0
      org-catch-invisible-edits 'show-and-error
      org-special-ctrl-a/e t
      org-insert-heading-respect-content t
      org-agenda-tags-column 0
      org-hide-leading-stars t
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
        org-archive-location "~/Sync/org/archive/org/%s_archive.org::* Archived from %s\n")  ; Archive location pattern

  ;; Refile targets - where to move/copy headings
                                        ; (setq org-refile-targets
                                        ;       '((nil :maxlevel . 3)        ; Current file up to 3 levels
                                        ;         (agenda :maxlevel . 3)     ; Agenda files up to 2 levels
                                        ;         (denote :maxlevel . 2)      ; denote files up to 2 levels
                                        ;         (gtd :maxlevel . 2)        ; GTD files up to 2 levels
                                        ;         (archive :maxlevel . 2)))  ; Archive files up to 2 levels

  ;; destination for refile any agenda file 3 levels deep
  (setq org-refile-targets '(
                             ("~/Sync/org/gtd/inbox.org" :maxlevel . 1)
                             ("~/Sync/org/gtd/tasks.org" :maxlevel . 1)
                             ("~/Sync/org/gtd/areas.org" :maxlevel . 1)
                             ("~/Sync/org/gtd/vision.org" :maxlevel . 1)
                             ("~/Sync/org/gtd/horizons.org" :maxlevel . 1)
                             ))

  ;; generate refile tarets and show them at once
  (setq org-outline-path-complete-in-steps nil)
  ;; ask to confirm creating parent nodes
  (setq org-refile-allow-creating-parent-nodes 'confirm)

  ;; Modules - additional org features
  (setq org-modules '(org-habit))    ; Enable habit tracking

  (provide 'org-core)
