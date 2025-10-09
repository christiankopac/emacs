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

;; TODO Change the category icons
;; Only set icons if all-the-icons is loaded
;; (when (fboundp 'all-the-icons-faicon)
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
  "Archive to ~/Sync/org/archive/gtd instead of org-gtd-directory."
  (let* ((year (number-to-string (caddr (calendar-current-date))))
         (filename (format org-gtd-archive-file-format year))
         (filepath (f-join "~/Sync/org/archive/gtd" filename)))
    (string-join `(,filepath "::" "datetree/"))))

(setq org-gtd-directory "~/Sync/org/gtd"
      org-gtd-default-file-name "inbox"
      org-gtd-areas-of-focus '("Finance" "Health" "Relationships" "Career"
                               "Creative" "Learning" "Growth" "Home")
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

;; (setq org-journal-dir "~/Sync/org/journal/"
;;       org-journal-file-type 'daily
;;       org-journal-file-format "%Y-%m-%d.org"
;;       org-journal-enable-agenda-integration t
;;       org-journal-carryover-items "TODO=\"TODO\"|TODO=\"NEXT\""
;;       org-journal-file-header "#+TITLE: %Y-%m-%d (%A)\n#+FILETAGS: :journal:\n#+STARTUP: showall\n\n" ;; Blank template with no tags
;;       org-journal-time-prefix "* "
;;       org-journal-time-format "%H:%M - "
;;       )

;; ;; Keybindings
;; (with-eval-after-load 'org-journal
;;   (global-set-key (kbd "C-c j j") 'org-journal-new-entry)
;;   (global-set-key (kbd "C-c j s") 'org-journal-search))

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

(with-eval-after-load 'org-modern
  (setq org-modern-timestamp t
        org-modern-priority '((?A . "🔥") (?B . "🌶️") (?C . "🫑"))
        org-modern-priority-align '(t . t)                       ; Align priority symbols
        org-modern-keyword '((t . "▶"))
        ;; ("date" . "\uf455")                 ; Date symbol
        ;; ("filetags" . "\uea66")             ; File tags symbol
        ;; ("identifier" . "\ueb11")           ; Identifier symbol
        ;; Heading stars - use invisible stars for clean appearance
        org-modern-star '("" "" "" "" "" "")
        ;; Fold indicators (collapsed/expanded)
        org-modern-fold-stars '(("◈" . "◇")
                                ("⦿" . "◦")
                                ("⊙" . "•")
                                ("▸" . "▹")
                                ("▪" . "▫"))
        org-modern-table nil
        org-modern-block-name nil
        )

  (add-hook 'org-mode-hook 'org-modern-mode))  ; Enable org-modern for org buffers

(provide 'org-extensions)
