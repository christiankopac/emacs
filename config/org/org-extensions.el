;;; org-extensions.el --- Org mode extensions configuration

;; ----------------------------------------------------------------------------
;; Org Agenda Configuration
;; ----------------------------------------------------------------------------

(setq org-agenda-file-regexp "\\`[^.].*\\.org\\'"  ; Match .org files (not hidden)
      org-agenda-file-regexp-daily "\\`\\(tasks\\|meetings\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)\\.org\\'"  ; Daily files pattern
      org-agenda-start-on-weekday nil              ; Start on today, not Monday
      org-agenda-show-all-dates t                  ; Show days even without items
      org-agenda-skip-scheduled-if-done t          ; Hide completed scheduled items
      org-agenda-skip-deadline-if-done t)          ; Hide completed deadline items

;; Custom agenda views
(setq org-agenda-custom-commands
      '(("d" "Daily Review"                        ; Daily view with priorities and deadlines
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-start-day "+0d")
                      (org-agenda-start-with-log-mode t)))
          (tags-todo "PRIORITY=\"A\""
                     ((org-agenda-overriding-header "High Priority Tasks")))
          (tags-todo "DEADLINE<=\"<+7d>\""
                     ((org-agenda-overriding-header "Due This Week")))
          (todo "WAITING"
                ((org-agenda-overriding-header "Waiting For")))))
        
        ("w" "Weekly Review"                       ; Weekly overview with stuck projects
         ((agenda "" ((org-agenda-span 'week)
                      (org-agenda-start-with-log-mode t)))
          (stuck "" ((org-agenda-overriding-header "Stuck Projects")))
          (tags-todo "DEADLINE<=\"<+14d>\""
                     ((org-agenda-overriding-header "Coming Deadlines")))
          (todo "DELEGATED"
                ((org-agenda-overriding-header "Delegated Tasks")))))
        
        ("p" "Projects Overview"                   ; All projects, goals, and areas
         ((tags "project+LEVEL=2"
                ((org-agenda-overriding-header "Active Projects")))
          (tags "goal+LEVEL=2"
                ((org-agenda-overriding-header "Current Goals")))
          (tags "area+LEVEL=2"
                ((org-agenda-overriding-header "Life Areas")))))
        
        ("h" "Horizons Review"                     ; GTD horizons of focus
         ((tags "LEVEL=1+vision"
                ((org-agenda-overriding-header "󰍉 Vision (3-5 Years)")))
          (tags "LEVEL=2+goal"
                ((org-agenda-overriding-header "󰅐 Goals (1-2 Years)")))
          (tags "LEVEL=2+area"
                ((org-agenda-overriding-header "󰉋 Areas of Focus")))
          (tags "LEVEL=2+project+CATEGORY=\"active\""
                ((org-agenda-overriding-header "󰏧 Active Projects")))
          (todo ""
                ((org-agenda-overriding-header "󰅐 Next Actions"))))
         ((org-agenda-dim-blocked-tasks nil)))))

;; ----------------------------------------------------------------------------
;; Org Super Agenda Configuration - Enhanced agenda grouping
;; ----------------------------------------------------------------------------

(with-eval-after-load 'org-super-agenda
  (org-super-agenda-mode)                            ; Enable super agenda mode
  (setq org-super-agenda-groups
      '((:name "󰅐 Today"                          ; Today's items first
               :time-grid t
               :scheduled today
               :order 1)
        (:name "󰀧 Next Actions"                   ; NEXT tasks
               :todo "NEXT"
               :order 2)
        (:name "󰅐 Calendar"                       ; Calendar items
               :property ("ORG_GTD" "Calendar")
               :order 3)
        (:name "󰅐 Overdue"                        ; Past deadline
               :deadline past
               :order 4)
        (:name "󰅐 Due Today"                      ; Due today
               :deadline today
               :order 5)
        (:name "󰨟 Due Soon"                       ; Upcoming deadlines
               :deadline future
               :scheduled future
               :order 6)
        (:name "󰅐 Projects"                       ; Project items
               :property ("ORG_GTD" "Projects")
               :order 7)
        (:name "󰅐 Waiting/Delegated"              ; Blocked tasks
               :todo "WAIT"
               :order 8)
        (:name "󰗊 Incubated"                      ; Future/maybe items
               :property ("ORG_GTD" "Incubated")
               :order 9)
        (:name "󰏧 Actions"                        ; Action items
               :property ("ORG_GTD" "Actions")
               :order 10)
        (:name "󰅐 Important"                      ; Priority A
               :priority "A"
               :order 11)
        (:name "󰽰 Inbox"                          ; Unprocessed items
               :file-path "inbox"
               :order 12)
        (:name "󰅐 Done"                           ; Completed tasks
               :todo "DONE"
               :order 13))))

;; ----------------------------------------------------------------------------
;; Org Habit Configuration - Habit tracking
;; ----------------------------------------------------------------------------

(setq org-habit-show-habits-only-for-today nil    ; Show habits for all days in agenda
      org-habit-show-all-today t                   ; Show all habits even if done
      org-habit-graph-column 50)                   ; Position of habit graph

;; ----------------------------------------------------------------------------
;; Org Extensions - Additional packages
;; ----------------------------------------------------------------------------

;; Org Habit Stats - Statistics for habits
(global-set-key (kbd "C-c n h") 'org-habit-stats-view-habit-at-point)  ; View habit statistics

;; ============================================================================
;; Org Edna Configuration - Dependencies between tasks
;; ============================================================================

;; Org Edna - Dependencies between tasks
(setq org-edna-use-inheritance t)                  ; Inherit Edna properties
(with-eval-after-load 'org-edna
  (org-edna-mode 1))                                ; Enable Edna globally

;; ============================================================================
;; Org GTD Configuration - Getting Things Done workflow
;; ============================================================================

;; Org GTD - Getting Things Done workflow
(defun my/org-gtd-archive-location ()
  "Archive to ~/Sync/archives/ instead of org-gtd-directory."
  (let* ((year (number-to-string (caddr (calendar-current-date))))
         (filename (format org-gtd-archive-file-format year))
         (filepath (f-join "~/Sync/archives" filename)))
    (string-join `(,filepath "::" "datetree/"))))

(setq org-gtd-directory (expand-file-name "gtd/" org-directory)
      org-gtd-default-file-name "inbox"
      org-gtd-areas-of-focus '("Health" "Relationships" "Career"
                                "Finance" "Learning" "Creative")
      org-gtd-archive-location #'my/org-gtd-archive-location
      org-gtd-mode t
)

;; Org GTD keybindings (use C-c g prefix to avoid conflicts with denote C-c d)
(global-set-key (kbd "C-c g c") 'org-gtd-capture)                      ; Capture to GTD inbox
(global-set-key (kbd "C-c g p") 'org-gtd-process-inbox)                ; Process inbox items
(global-set-key (kbd "C-c g e") 'org-gtd-engage)                       ; Engage with tasks
(global-set-key (kbd "C-c g n") 'org-gtd-show-all-next)                ; Show all next actions
(global-set-key (kbd "C-c g s") 'org-gtd-clarify-switch-to-buffer)     ; Switch to clarify buffer
(global-set-key (kbd "C-c g a") 'org-gtd-clarify-agenda-item)          ; Clarify from agenda
(global-set-key (kbd "C-c g i") 'org-gtd-clarify-item)                 ; Clarify item
(global-set-key (kbd "C-c g g") 'org-gtd-engage-grouped-by-context)    ; Engage by context

(with-eval-after-load 'org-gtd
  (define-key org-gtd-clarify-map (kbd "C-c c") #'org-gtd-organize))  ; Organize during clarify

;; ============================================================================
;; Org-journal Configuration
;; ============================================================================

(setq org-journal-dir "~/Sync/org/agenda/journal/"
      org-journal-file-type 'daily
      org-journal-file-format "%Y-%m-%d.org"
      org-journal-enable-agenda-integration t
      org-journal-carryover-items "TODO=\"TODO\"|TODO=\"NEXT\""
      org-journal-file-header "#+TITLE: %Y-%m-%d (%A)\n#+FILETAGS: :journal:\n#+STARTUP: showall\n\n" ;; Blank template with no tags
      org-journal-time-prefix "* "
      org-journal-time-format "%H:%M - "
      )

;; Keybindings
(with-eval-after-load 'org-journal
  (global-set-key (kbd "C-c j j") 'org-journal-new-entry)
  (global-set-key (kbd "C-c j s") 'org-journal-search))

;; ============================================================================
;; Org Appear Configuration - Show hidden markup when cursor is on element
;; ============================================================================

;; Org Appear - Show hidden markup when cursor is on element
(setq org-appear-autolinks t          ; Show link markup
      org-appear-autosubmarkers t     ; Show sub/superscript markup
      org-appear-autoentities t       ; Show entity markup
      org-appear-autokeywords t)      ; Show keyword markup

;; ============================================================================
;; Org Cliplink Configuration - Insert web page title as link
;; ============================================================================

;; Org Cliplink - Insert web page title as link
(global-set-key (kbd "C-c n u") 'org-cliplink)  ; Insert URL with title from clipboard

;; ============================================================================
;; Org Download Configuration - Download and insert images
;; ============================================================================

;; Org Download - Download and insert images
(setq org-download-method 'directory              ; Save to directory
      org-download-image-dir "assets/images"      ; Image directory
      org-download-heading-lvl nil                ; Don't create heading for image
      org-download-timestamp "%Y%m%d-%H%M%S_")    ; Timestamp format

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c n s") 'org-download-screenshot)  ; Take screenshot
  (define-key org-mode-map (kbd "C-c n y") 'org-download-yank))       ; Paste image

;; ============================================================================
;; TOC Org Configuration - Generate table of contents
;; ============================================================================

(setq toc-org-hrefify-default "gh")  ; Use GitHub-style links

;; ============================================================================
;; Org Transclusion Configuration - Include content from other files
;; ============================================================================

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c n t") 'org-transclusion-add)   ; Add transclusion
  (define-key org-mode-map (kbd "C-c n T") 'org-transclusion-mode)) ; Toggle transclusion mode

;; ============================================================================
;; Org Pomodoro Configuration - Pomodoro technique timer
;; ============================================================================

(global-set-key (kbd "C-c n p") 'org-pomodoro)  ; Start pomodoro

;; ============================================================================
;; Org QL Configuration - Query language for org files
;; ============================================================================

(global-set-key (kbd "C-c q q") 'org-ql-search)         ; Search with query
(global-set-key (kbd "C-c q s") 'org-ql-sparse-tree)    ; Sparse tree view
(global-set-key (kbd "C-c q b") 'org-ql-search-buffer)  ; Search current buffer
(global-set-key (kbd "C-c q t") 'org-ql-tags)           ; Search by tags
(global-set-key (kbd "C-c q p") 'org-ql-projects)       ; Show projects
(global-set-key (kbd "C-c q d") 'org-ql-due-today)      ; Due today
(global-set-key (kbd "C-c q w") 'org-ql-due-this-week)  ; Due this week
(global-set-key (kbd "C-c q n") 'org-ql-todo-next)      ; Next actions
(global-set-key (kbd "C-c q a") 'org-ql-agenda)         ; QL agenda

;; Org QL Source Block Functions
(defun my/org-ql-insert-src-block (query &optional title)
  "Insert org-ql query results in a source block at point.
QUERY is the org-ql query string.
TITLE is an optional title for the source block."
  (interactive "sOrg-QL Query: \nsTitle (optional): ")
  (let* ((results (org-ql-select (org-agenda-files) query
                    :action (lambda ()
                              (format "- %s %s"
                                      (org-get-heading t t t t)
                                      (when-let ((todo (org-get-todo-state))
                                                 (todo (not (string= todo ""))))
                                        (format "(%s)" todo))))))
         (block-title (if (string-empty-p title) "Org-QL Results" title))
         (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
                            query
                            (string-join results "\n"))))
    (insert (format "\n* %s\n\n%s\n" block-title src-block))))

(defun my/org-ql-insert-src-block-at-point (query)
  "Insert org-ql query results in a source block at point.
QUERY is the org-ql query string."
  (interactive "sOrg-QL Query: ")
  (let* ((results (org-ql-select (org-agenda-files) query
                    :action (lambda ()
                              (format "- %s %s"
                                      (org-get-heading t t t t)
                                      (when-let ((todo (org-get-todo-state))
                                                 (todo (not (string= todo ""))))
                                        (format "(%s)" todo))))))
         (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
                            query
                            (string-join results "\n"))))
    (insert src-block)))

(defun my/org-ql-insert-src-block-with-details (query &optional title)
  "Insert detailed org-ql query results in a source block at point.
QUERY is the org-ql query string.
TITLE is an optional title for the source block."
  (interactive "sOrg-QL Query: \nsTitle (optional): ")
  (let* ((results (org-ql-select (org-agenda-files) query
                    :action (lambda ()
                              (let* ((heading (org-get-heading t t t t))
                                     (todo (org-get-todo-state))
                                     (priority (org-get-priority-string))
                                     (deadline (org-get-deadline-time))
                                     (scheduled (org-get-scheduled-time))
                                     (tags (org-get-tags))
                                     (file (file-name-nondirectory (buffer-file-name))))
                                (format "- %s %s %s %s %s %s %s"
                                        heading
                                        (if todo (format "(%s)" todo) "")
                                        (if priority (format "[%s]" priority) "")
                                        (if deadline (format "DEADLINE: %s" (format-time-string "%Y-%m-%d" deadline)) "")
                                        (if scheduled (format "SCHEDULED: %s" (format-time-string "%Y-%m-%d" scheduled)) "")
                                        (if tags (format ":%s:" (string-join tags ":")) "")
                                        (format "[[file:%s]]" file))))))
         (block-title (if (string-empty-p title) "Org-QL Results" title))
         (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
                            query
                            (string-join results "\n"))))
    (insert (format "\n* %s\n\n%s\n" block-title src-block))))

;; Keybindings for org-ql source block functions
(global-set-key (kbd "C-c q i") 'my/org-ql-insert-src-block)           ; Insert with title
(global-set-key (kbd "C-c q I") 'my/org-ql-insert-src-block-at-point)  ; Insert at point
(global-set-key (kbd "C-c q D") 'my/org-ql-insert-src-block-with-details) ; Insert with details

;; Org QL Source Block Execution
(defun my/org-ql-execute-src-block ()
  "Execute org-ql query in current source block and replace results."
  (interactive)
  (let* ((element (org-element-at-point))
         (query (org-element-property :parameters element))
         (query (when query (string-trim query)))
         (query (if (string-prefix-p ":query" query)
                    (string-trim (substring query 6))
                  query)))
    (when query
      (let* ((results (org-ql-select (org-agenda-files) (read query)
                      :action (lambda ()
                                (format "- %s %s"
                                        (org-get-heading t t t t)
                                        (when-let ((todo (org-get-todo-state))
                                                   (todo (not (string= todo ""))))
                                          (format "(%s)" todo))))))
             (new-content (string-join results "\n")))
        (org-babel-remove-result)
        (org-babel-insert-result new-content)))))

(defun my/org-ql-execute-src-block-detailed ()
  "Execute org-ql query with detailed results in current source block."
  (interactive)
  (let* ((element (org-element-at-point))
         (query (org-element-property :parameters element))
         (query (when query (string-trim query)))
         (query (if (string-prefix-p ":query" query)
                    (string-trim (substring query 6))
                  query)))
    (when query
      (let* ((results (org-ql-select (org-agenda-files) (read query)
                      :action (lambda ()
                                (let* ((heading (org-get-heading t t t t))
                                       (todo (org-get-todo-state))
                                       (priority (org-get-priority-string))
                                       (deadline (org-get-deadline-time))
                                       (scheduled (org-get-scheduled-time))
                                       (tags (org-get-tags))
                                       (file (file-name-nondirectory (buffer-file-name))))
                                  (format "- %s %s %s %s %s %s %s"
                                          heading
                                          (if todo (format "(%s)" todo) "")
                                          (if priority (format "[%s]" priority) "")
                                          (if deadline (format "DEADLINE: %s" (format-time-string "%Y-%m-%d" deadline)) "")
                                          (if scheduled (format "SCHEDULED: %s" (format-time-string "%Y-%m-%d" scheduled)) "")
                                          (if tags (format ":%s:" (string-join tags ":")) "")
                                          (format "[[file:%s]]" file))))))
             (new-content (string-join results "\n")))
        (org-babel-remove-result)
        (org-babel-insert-result new-content)))))


;; Keybindings for executing org-ql source blocks
(global-set-key (kbd "C-c q e") 'my/org-ql-execute-src-block)         ; Execute basic
(global-set-key (kbd "C-c q E") 'my/org-ql-execute-src-block-detailed) ; Execute detailed

;; ============================================================================
;; Org Web Tools Configuration - Insert web page content
;; ============================================================================

(global-set-key (kbd "C-c w w") 'org-web-tools-insert-link-for-url)  ; Insert link with title

;; ============================================================================
;; Org Modern Configuration - Modern UI elements for org
;; ============================================================================

(with-eval-after-load 'org-modern
  (setq org-modern-timestamp t                                ; Style timestamps
        org-modern-priority '((?A . "󰅐") (?B . "󰅐") (?C . "󰅐"))  ; Priority indicators
        org-modern-priority-align '(t . t)                    ; Align priority symbols
        org-modern-keyword '(("date" . "\uf455")                 ; Date symbol
                             ("filetags" . "\uea66")             ; File tags symbol
                             ("identifier" . "\ueb11")           ; Identifier symbol
                             (t . "▶"))                      ; Default keyword symbol
        org-modern-fold-stars '(("󰅐" . "󰅐")   ; Level 1: Solid diamond / hollow diamond
                               ("󰅐" . "󰅐")   ; Level 2: White square / black square
                               ("󰅐" . "󰅐")    ; Level 3: Half-filled circle / half-filled circle (opposite)
                               ("󰅐" . "󰅐")    ; Level 4: Empty diamond / solid diamond
                               ("󰅐" . "󰅐"))   ; Level 5: Empty circle / solid circle
        org-modern-table nil)                 ; Disable table styling
  
  (add-hook 'org-mode-hook 'org-modern-mode))  ; Enable org-modern for org buffers

(provide 'org-extensions)