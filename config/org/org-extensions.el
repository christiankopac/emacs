;;; org-extensions.el --- Org mode extensions configuration

                                        ; ----------------------------------------------------------------------------
;; Org Agenda Configuration
;; ----------------------------------------------------------------------------

(setq org-agenda-span 1                            ; Show only 1 day
      org-agenda-start-day "+0d"                   ; Start on today
      org-skip-timestamp-if-done t
      org-agenda-skip-deadline-if-done t           ; Hide completed deadline items
      org-agenda-skip-scheduled-if-done t          ; Hide completed scheduled items
      org-agenda-skip-timestamp-if-deadline-is-shown t
      org-agenda-skip-scheduled-if-deadline-is-shown t
      ;; TODO Review the following
      ;; org-agenda-file-regexp "\\`[^.].*\\.org\\'"  ; Match .org files (not hidden)
      ;; org-agenda-file-regexp-daily "\\`\\(tasks\\|meetings\\|[0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)\\.org\\'"  ; Daily files pattern
      ;; org-agenda-start-on-weekday nil              ; Start on today, not Monday
      ;; org-agenda-show-all-dates t                  ; Show days even without items
      )

;; TODO Add custom type faces to agenda
;; (custom-set-faces!
;;  '(org-agenda-date :inherit outline-1 :height 1.15)
;;  '(org-agenda-date-today :inherit outline-1 :height 1.15)
;;  '(org-agenda-date-weekend :inherit outline-1 :height 1.15)
;;  '(org-agenda-date-weekend-today :inherit outline-1 :height 1.35)
;;  '(org-super-agenda-header :inherit outline-1 :height 1.05)
;;  )

(defun my/org-agenda-toggle-completed ()
  "Toggle completed tasks in the agenda."
  (interactive)
  (setq org-agenda-skip-timestamp-if-done (not org-agenda-skip-timestamp-if-done)
        org-agenda-skip-deadline-if-done (not org-agenda-skip-timestamp-if-done)
        org-agenda-skip-scheduled-if-done (not org-agenda-skip-timestamp-if-done))
  (org-agenda-redo))

;; TODO Add keybinding to trigger `my/org-agenda-toggle-completed'
(global-set-key (kbd "C-c n a") 'my/org-agenda-toggle-completed)
(setq org-agenda-current-time-string "")        ;; TODO Add a custom time string for the agenda
(setq org-agenda-time-grid '((daily) () "" "")) ;; TODO Add a custom time grid for the agenda
(setq org-agenda-prefix-format '(
                                 (agenda . " %?-2i %t ")
                                 (todo . " %i %-12:c")
                                 (tags . " %i %-12:c")
                                 (search . " %i %-12:c")))

;; TODO Setup org-agenda category icons
;;   (setq org-agenda-category-icon-alist
;;         `(("Family.s", (list (all-the-icons-faicon "home" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Work.s", (list (all-the-icons-faicon "briefcase" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Personal.s", (list (all-the-icons-faicon "user" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Health.s", (list (all-the-icons-faicon "heart" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Finance.s", (list (all-the-icons-faicon "money-bill-alt" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Education.s", (list (all-the-icons-faicon "graduation-cap" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Travel.s", (list (all-the-icons-faicon "plane" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Hobbies.s", (list (all-the-icons-faicon "gamepad" :v-adjust 0.005)) nil nil :ascent center)
;;           ("Misc.s", (list (all-the-icons-faicon "question" :v-adjust 0.005)) nil nil :ascent center))))

;; TODO Setup org-agenda commands
;; Ideas:
;; - Daily Review
;; - Weekly Review
;; - Projects Review
;; - Horizons Review
(setq org-agenda-custom-commands
      '(;; Daily view with priorities and deadlines
        ("d" "Daily Review"                       
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-start-day "+0d")
                      (org-agenda-start-with-log-mode t)))
          (tags-todo "PRIORITY=\"A\""
                     ((org-agenda-overriding-header "High Priority Tasks")))
          (tags-todo "DEADLINE<=\"<+7d>\""
                     ((org-agenda-overriding-header "Due This Week")))
          (todo "WAITING"
                ((org-agenda-overriding-header "Waiting For")))))

        ;; Weekly overview with stuck projects
        ("w" "Weekly Review"                  
         ((agenda "" ((org-agenda-span 'week)
                      (org-agenda-start-with-log-mode t)))
          (stuck "" ((org-agenda-overriding-header "Stuck Projects")))
          (tags-todo "DEADLINE<=\"<+14d>\""
                     ((org-agenda-overriding-header "Coming Deadlines")))
          (todo "DELEGATED"
                ((org-agenda-overriding-header "Delegated Tasks")))))

        ;; All projects, goals, and areas
        ("p" "Projects Overview"         
         ((tags "project+LEVEL=2"
                ((org-agenda-overriding-header "Active Projects")))
          (tags "goal+LEVEL=2"
                ((org-agenda-overriding-header "Current Goals")))
          (tags "area+LEVEL=2"
                ((org-agenda-overriding-header "Life Areas")))))

        ;; GTD horizons of focus
        ("h" "Horizons Review"                     
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

;; TODO Setup org-super-agenda groups
;; Ideas: ! Overdue / Personal / Family / Work
(with-eval-after-load 'org-super-agenda
  (org-super-agenda-mode)                            ; Enable super agenda mode
  (setq org-super-agenda-groups
        '(;; Today's items first
          (:name "󰅐 Today"                         
                 :time-grid t
                 :scheduled today
                 :order 1)
          ;; NEXT tasks
          (:name "󰀧 Next Actions"                  
                 :todo "NEXT"
                 :order 2)
          ;; Calendar items
          (:name "󰅐 Calendar"
                 :property ("ORG_GTD" "Calendar")
                 :order 3)
          ;; Overdue items - 🔴
          (:name "󰅐 Overdue"   
                 :deadline past
                 :order 4)
          ;; Due today
          (:name "󰅐 Due Today"
                 :deadline today
                 :order 5)
          ;; Deaslines ... Due soon
          (:name "󰨟 Due Soon"
                 :deadline future
                 :scheduled future
                 :order 6)
          ;; Projects
          (:name "󰅐 Projects"
                 :property ("ORG_GTD" "Projects")
                 :order 7)
          ;; Waiting/Delegated tasks
          (:name "󰅐 Waiting/Delegated" 
                 :todo "WAIT"
                 :order 8)
          ;; Incubated items
          (:name "󰗊 Incubated"
                 :property ("ORG_GTD" "Incubated")
                 :order 9)
          ;; Actions Items
          (:name "󰏧 Actions"
                 :property ("ORG_GTD" "Actions")
                 :order 10)
          ;; Important items - 🔥
          (:name "󰅐 Important"                    
                 :priority "A"
                 :order 11)
          ;; Unprocessed items - 📥
          (:name "󰽰 Inbox"                          
                 :file-path "inbox"
                 :order 12)
          ;; Completed tasks
          (:name "󰅐 Done"                           
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
  "Archive to ~/org/gtd/archive instead of org-gtd-directory."
  (let* ((year (number-to-string (caddr (calendar-current-date))))
         (filename (format org-gtd-archive-file-format year))
         (filepath (f-join "~/org/gtd/archive" filename)))
    (string-join `(,filepath "::" "datetree/"))))

;; Simplified GTD structure:
;; - ~/org/gtd/inbox.org (capture everything here)
;; - ~/org/gtd/tasks.org (processed tasks from inbox)
(setq org-gtd-directory "~/org/gtd"
      org-gtd-inbox (expand-file-name "inbox.org" org-gtd-directory)
      org-gtd-areas-of-focus '(
            "Health"         ;; Physical and Mental Well-being
            "Finance"        ;; Financial Management
            "Home"           ;; Household Management
            ;; --- Personal ---
            "Relationships"  ;; Friends and Relationships
            "Growth"         ;; Personal Growth and Self-Improvement - Admin/System stuff
            "Legal"          ;; Anything 
            ;; --- Professional ---
            "Programming"   
            "Work"           ;; Professional and Job-Related
            ;; --- Creative/Leisure
            "Music"          ;; Musical Pursuits
            "Recreation"     ;; Travel, Leisure and Hobbies
      )
      org-gtd-archive-location #'my/org-gtd-archive-location
      org-gtd-mode t)

;; Processed items go to ~/org/gtd/tasks.org (override package default org-gtd-tasks.org)
(with-eval-after-load 'org-gtd
  (setq org-gtd-default-file-name "tasks"))

(defun org-gtd-set-area-of-focus ()
  "Use as a hook when decorating items after clarifying them.

This function requires that the user input find a match among the options.
If a new re of focus pops-up that is not in the list, it will not be set."
  (unless (org-gtd-organize-type-member-p '(project-task trash knowledge quick-action))
    (org-gtd-area-of-focus-set-on-item-at-point)))

;; (setq org-gtd-organize-hooks '(org-gtd-set-area-of-focus))

;; (org-gtd-organize-type-member-p LIST)
;; Valid HOOK members for org-gtd-organize-hooks:
;; 'quick-action (done in less than 2 minutes)
;; 'single-action (do when possible)
;; 'calendar (do at a given time)
;; 'delegted (done by someone else)
;; 'habit (a recurring action)
;; 'incubated (remind me later)
;; 'knowledge (stored as reference)
;; 'trash
;; 'project-heading (top-level project heading, e.g. area of focus)
;; 'project-task (task specific info, similiar to single-action)
;; 'everything (if this is in the list, it will always 

;; ============================================================================
;; Org Capture Templates - Simplified GTD Workflow
;; Helper function for denote capture - opens full screen
(defun my/denote-capture-fullscreen ()
  "Create a new denote note and maximize the window (saves previous layout)."
  (call-interactively 'denote)
  ;; If the frame currently has multiple windows, save the configuration then
  ;; maximize so the user can restore the layout afterwards by toggling.
  (when (> (length (window-list)) 1)
    (setq my/previous-window-configuration (current-window-configuration))
    (delete-other-windows)))

;; ============================================================================
;; SIMPLIFIED CAPTURE WORKFLOW:
;; All captures go to inbox.org - no distinction between "task" and "capture entry"
;; Process everything later with org-gtd-process-inbox (C-c g p)
;;
;; CAPTURE OPTIONS:
;; - C-c c i  → Inbox item (general capture, no TODO)
;; - C-c c t  → Task (with TODO keyword)
;; - C-c c p  → Project (with subtasks)
;; - C-c c s  → Someday/Maybe (future ideas)
;; - C-c c r  → Reference (reference material)
;; - C-c c j  → Journal entry (opens today's journal)
;; - C-c c d  → Denote entry (create new denote note)
;;
;; ALTERNATIVE: C-c g c → Direct GTD inbox capture (no template selection)
;;
(setq org-capture-templates
      `(
        ;; Inbox - General capture (no TODO, just a note)
        ("i" "Inbox" entry
         (file ,org-gtd-inbox)
         "* %?\n%U\n%a\n%i"
         :empty-lines 1)

        ;; Task - Actionable item with TODO
        ("t" "Task" entry
         (file ,org-gtd-inbox)
         "* TODO %?\n%U\n%a\n%i"
         :empty-lines 1)

        ;; Project - Multi-step project with initial subtasks
        ("p" "Project" entry
         (file ,org-gtd-inbox)
         "* TODO %? [/]\n%U\n%a\n%i\n** TODO First step\n** TODO Second step"
         :empty-lines 1)

        ;; Someday/Maybe - Future ideas and incubation
        ("s" "Someday/Maybe" entry
         (file ,org-gtd-inbox)
         "* SOMEDAY %?\n%U\n%a\n%i"
         :empty-lines 1)

        ;; Reference - Reference material (no action needed)
        ("r" "Reference" entry
         (file ,org-gtd-inbox)
         "* %? :reference:\n%U\n%a\n%i"
         :empty-lines 1)

        ;; Journal - Personal journal
        ("j" "Journal - Personal" plain
         (function my/open-todays-personal-journal)
         ""
         :jump-to-captured t
         :immediate-finish t)

        ;; Journal - Work journal
        ("J" "Journal - Work" plain
         (function my/open-todays-work-journal)
         ""
         :jump-to-captured t
         :immediate-finish t)

        ;; Denote - Create new denote entry (opens full screen)
        ("d" "Denote" plain
         (function my/denote-capture-fullscreen)
         ""
         :immediate-finish nil)
        ))

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
      org-download-image-dir "attach/images"      ; Image directory
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
;; (defun my/org-ql-insert-src-block (query &optional title)
;;   "Insert org-ql query results in a source block at point.
;; QUERY is the org-ql query string.
;; TITLE is an optional title for the source block."
;;   (interactive "sOrg-QL Query: \nsTitle (optional): ")
;;   (let* ((results (org-ql-select (org-agenda-files) query
;;                     :action (lambda ()
;;                               (format "- %s %s"
;;                                       (org-get-heading t t t t)
;;                                       (when-let ((todo (org-get-todo-state))
;;                                                  (todo (not (string= todo ""))))
;;                                         (format "(%s)" todo))))))
;;          (block-title (if (string-empty-p title) "Org-QL Results" title))
;;          (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
;;                             query
;;                             (string-join results "\n"))))
;;     (insert (format "\n* %s\n\n%s\n" block-title src-block))))

;; (defun my/org-ql-insert-src-block-at-point (query)
;;   "Insert org-ql query results in a source block at point.
;; QUERY is the org-ql query string."
;;   (interactive "sOrg-QL Query: ")
;;   (let* ((results (org-ql-select (org-agenda-files) query
;;                     :action (lambda ()
;;                               (format "- %s %s"
;;                                       (org-get-heading t t t t)
;;                                       (when-let ((todo (org-get-todo-state))
;;                                                  (todo (not (string= todo ""))))
;;                                         (format "(%s)" todo))))))
;;          (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
;;                             query
;;                             (string-join results "\n"))))
;;     (insert src-block)))

;; (defun my/org-ql-insert-src-block-with-details (query &optional title)
;;   "Insert detailed org-ql query results in a source block at point.
;; QUERY is the org-ql query string.
;; TITLE is an optional title for the source block."
;;   (interactive "sOrg-QL Query: \nsTitle (optional): ")
;;   (let* ((results (org-ql-select (org-agenda-files) query
;;                     :action (lambda ()
;;                               (let* ((heading (org-get-heading t t t t))
;;                                      (todo (org-get-todo-state))
;;                                      (priority (org-get-priority-string))
;;                                      (deadline (org-get-deadline-time))
;;                                      (scheduled (org-get-scheduled-time))
;;                                      (tags (org-get-tags))
;;                                      (file (file-name-nondirectory (buffer-file-name))))
;;                                 (format "- %s %s %s %s %s %s %s"
;;                                         heading
;;                                         (if todo (format "(%s)" todo) "")
;;                                         (if priority (format "[%s]" priority) "")
;;                                         (if deadline (format "DEADLINE: %s" (format-time-string "%Y-%m-%d" deadline)) "")
;;                                         (if scheduled (format "SCHEDULED: %s" (format-time-string "%Y-%m-%d" scheduled)) "")
;;                                         (if tags (format ":%s:" (string-join tags ":")) "")
;;                                         (format "[[file:%s]]" file))))))
;;          (block-title (if (string-empty-p title) "Org-QL Results" title))
;;          (src-block (format "#+begin_src org-ql :query \"%s\"\n%s\n#+end_src"
;;                             query
;;                             (string-join results "\n"))))
;;     (insert (format "\n* %s\n\n%s\n" block-title src-block))))

;; Keybindings for org-ql source block functions
;; (global-set-key (kbd "C-c q i") 'my/org-ql-insert-src-block)           ; Insert with title
;; (global-set-key (kbd "C-c q I") 'my/org-ql-insert-src-block-at-point)  ; Insert at point
;; (global-set-key (kbd "C-c q D") 'my/org-ql-insert-src-block-with-details) ; Insert with details

;; Org QL Source Block Execution
;; (defun my/org-ql-execute-src-block ()
;;   "Execute org-ql query in current source block and replace results."
;;   (interactive)
;;   (let* ((element (org-element-at-point))
;;          (query (org-element-property :parameters element))
;;          (query (when query (string-trim query)))
;;          (query (if (string-prefix-p ":query" query)
;;                     (string-trim (substring query 6))
;;                   query))
;;     (when query
;;       (let* ((results (org-ql-select (org-agenda-files) (read query)
;;                         :action (lambda ()
;;                                   (format "- %s %s"
;;                                           (org-get-heading t t t t)
;;                                           (when-let ((todo (org-get-todo-state))
;;                                                      (todo (not (string= todo ""))))
;;                                             (format "(%s)" todo))))))
;;              (new-content (string-join results "\n")))
;;         (org-babel-remove-result)
;;         (org-babel-insert-result new-content)))))

;; (defun my/org-ql-execute-src-block-detailed ()
;;   "Execute org-ql query with detailed results in current source block."
;;   (interactive)
;;   (let* ((element (org-element-at-point))
;;          (query (org-element-property :parameters element))
;;          (query (when query (string-trim query)))
;;          (query (if (string-prefix-p ":query" query)
;;                     (string-trim (substring query 6))
;;                   query)))
;;     (when query
;;       (let* ((results (org-ql-select (org-agenda-files) (read query)
;;                         :action (lambda ()
;;                                   (let* ((heading (org-get-heading t t t t))
;;                                          (todo (org-get-todo-state))
;;                                          (priority (org-get-priority-string))
;;                                          (deadline (org-get-deadline-time))
;;                                          (scheduled (org-get-scheduled-time))
;;                                          (tags (org-get-tags))
;;                                          (file (file-name-nondirectory (buffer-file-name))))
;;                                     (format "- %s %s %s %s %s %s %s"
;;                                             heading
;;                                             (if todo (format "(%s)" todo) "")
;;                                             (if priority (format "[%s]" priority) "")
;;                                             (if deadline (format "DEADLINE: %s" (format-time-string "%Y-%m-%d" deadline)) "")
;;                                             (if scheduled (format "SCHEDULED: %s" (format-time-string "%Y-%m-%d" scheduled)) "")
;;                                             (if tags (format ":%s:" (string-join tags ":")) "")
;;                                             (format "[[file:%s]]" file))))))
;;              (new-content (string-join results "\n")))
;;         (org-babel-remove-result)
;;         (org-babel-insert-result new-content)))))

;; Keybindings for executing org-ql source blocks
;; (global-set-key (kbd "C-c q e") 'my/org-ql-execute-src-block)         ; Execute basic
;; (global-set-key (kbd "C-c q E") 'my/org-ql-execute-src-block-detailed) ; Execute detailed

;; ============================================================================
;; Org Web Tools Configuration - Insert web page content
;; ============================================================================

(global-set-key (kbd "C-c w w") 'org-web-tools-insert-link-for-url)  ; Insert link with title

;; ============================================================================
;; Ox-Tufte Configuration - Tufte-style HTML export
;; ============================================================================

;; Ox-Tufte - Tufte CSS export backend for Org mode
;; (with-eval-after-load 'ox-tufte
;;   (setq org-tufte-include-footdenote-at-bottom t) ;; Include footdenote at bottom for better mobile compatibility
;;   (setq org-tufte-margin-note-symbol "⊕")    ;; Custom margin note symbol (default is ⊕)
;;   (add-to-list 'org-export-backends 'tufte-html) ;; Enable Tufte export backend

;; ;; Keybindings for Tufte export
;; (global-set-key (kbd "C-c e t") 'org-tufte-export-to-html)  ; Export to Tufte HTML
;; (global-set-key (kbd "C-c e T") 'org-tufte-export-to-html-and-open)  ; Export and open
;; )
;; ============================================================================
;; Org Modern Configuration - Modern UI elements for org
;; ============================================================================

;; Configure org-modern - only enable in GUI mode
(if (display-graphic-p)
    ;; GUI mode - configure and enable org-modern
    (progn
      ;; Set priority icons early so they're available
      (setq org-modern-priority '((?A . "🔥") (?B . "🌶️") (?C . "🫑")))
      (with-eval-after-load 'org-modern
        (setq org-modern-timestamp t
              org-modern-priority '((?A . "🔥") (?B . "🌶️") (?C . "🫑"))
              org-modern-priority-align '(t . t)
              org-modern-keyword '((t . "▶"))
              org-modern-star '("" "" "" "" "" "")
              org-modern-fold-stars '(("◈" . "◇")
                                      ("⦿" . "◦")
                                      ("⊙" . "•")
                                      ("▸" . "▹")
                                      ("▪" . "▫"))
              org-modern-table nil
              org-modern-block-name nil)
        ;; Enable org-modern-mode for new org buffers
        (add-hook 'org-mode-hook 'org-modern-mode)
        ;; Also enable for existing org buffers
        (dolist (buffer (buffer-list))
          (with-current-buffer buffer
            (when (derived-mode-p 'org-mode)
              (org-modern-mode 1))))))
  ;; Terminal mode - ensure org-modern is never enabled
  (add-hook 'org-mode-hook
            (lambda ()
              (when (bound-and-true-p org-modern-mode)
                (org-modern-mode -1)))
            t))

(provide 'org-extensions)
