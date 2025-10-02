;;; email.el --- Email configuration (mu4e, message, smtpmail, bbdb, consult-mu)

;; Mu4e init
(when (file-exists-p "/usr/local/bin/mu")
  (setq mu4e-mu-binary "/usr/local/bin/mu"))

;; Mu4e keybindings
(global-set-key (kbd "C-c m") 'mu4e)
(global-set-key (kbd "C-c M") 'mu4e-compose-new)

;; Mu4e which-key descriptions
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c m" "󰇮 Mu4e Email"
    "C-c M" "󰞌 Compose New Email"
    "C-c c b" "󰀸 BBDB Contacts"))

;; Basic mu4e settings
(setq mu4e-maildir "~/.mail"
      mu4e-get-mail-command "offlineimap"
      mu4e-update-interval 1800  ; 30 minutes
      mu4e-view-show-images t
      mu4e-view-show-addresses t
      mu4e-compose-format-flowed t
      mu4e-date-format "%Y-%m-%d"
      mu4e-headers-date-format "%Y-%m-%d"
      mu4e-change-filenames-when-moving t
      mu4e-attachment-dir "~/Downloads"
      ;; Force mu4e to handle composition and sending
      mail-user-agent 'mu4e-user-agent
      message-send-mail-function 'smtpmail-send-it

      ;; Contexts for switching between accounts
      mu4e-contexts
      `(,(make-mu4e-context
          :name "Gmail"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/Gmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "christian.kopac@gmail.com")
                  (user-full-name . "Christian Kopac")
                  (mu4e-drafts-folder . "/Gmail/[Gmail].Drafts")
                  (mu4e-sent-folder . "/Gmail/[Gmail].Sent Mail")
                  (mu4e-trash-folder . "/Gmail/[Gmail].Trash")
                  (mu4e-refile-folder . "/Gmail/[Gmail].All Mail")
                  (mu4e-sent-messages-behavior . delete)
                  (smtpmail-smtp-server . "smtp.gmail.com")
                  (smtpmail-smtp-service . 587)
                  (smtpmail-stream-type . starttls)
                  (smtpmail-smtp-user . "christian.kopac@gmail.com")))

        ,(make-mu4e-context
          :name "Fastmail"
          :match-func (lambda (msg)
                        (when msg
                          (string-prefix-p "/Fastmail" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "hello@christiankopac.com")
                  (user-full-name . "Christian Kopac")
                  (mu4e-drafts-folder . "/Fastmail/Drafts")
                  (mu4e-sent-folder . "/Fastmail/Sent")
                  (mu4e-trash-folder . "/Fastmail/Trash")
                  (mu4e-refile-folder . "/Fastmail/Archive")
                  (mu4e-sent-messages-behavior . sent)
                  (smtpmail-smtp-server . "smtp.fastmail.com")
                  (smtpmail-smtp-service . 465)
                  (smtpmail-stream-type . ssl)
                  (smtpmail-smtp-user . "hello@christiankopac.com"))))

      ;; default context
      mu4e-context-policy 'pick-first
      mu4e-compose-context-policy 'ask

      ;; bookmarks for quick access
      mu4e-bookmarks
      '(("flag:unread AND NOT flag:trashed" "Unread messages" ?u)
        ("maildir:/Gmail/INBOX" "Gmail Inbox" ?g)
        ("maildir:/Fastmail/INBOX" "Fastmail Inbox" ?f)
        ("date:today..now" "Today's messages" ?t)
        ("date:7d..now" "Last 7 days" ?w)
        ("mime:image/*" "Messages with images" ?p)))

;; Enable mu4e menu
(mu4e t)

;; Mu4e to global menu bar
(define-key global-map [menu-bar tools mu4e]
            (cons "Mu4e" (make-sparse-keymap "Mu4e")))

(define-key global-map [menu-bar tools mu4e mu4e-main]
            '("Mu4e Main" . mu4e))
(define-key global-map [menu-bar tools mu4e mu4e-compose]
            '("Compose New" . mu4e-compose-new))
(define-key global-map [menu-bar tools mu4e separator1]
            '("--" . nil))

;; Consult-mu to global menu
(when (file-exists-p "~/.config/emacs/elpa/consult-mu")
  (define-key global-map [menu-bar tools mu4e consult-mu]
              (cons "Consult-Mu" (make-sparse-keymap "Consult-Mu")))

  (define-key global-map [menu-bar tools mu4e consult-mu search-everywhere]
              '("Search Everywhere" . consult-mu-search-everywhere))
  (define-key global-map [menu-bar tools mu4e consult-mu search-dynamic]
              '("Dynamic Search" . consult-mu-dynamic))
  (define-key global-map [menu-bar tools mu4e consult-mu search-async]
              '("Async Search" . consult-mu-async))
  (define-key global-map [menu-bar tools mu4e consult-mu search-contacts]
              '("Search Contacts" . consult-mu-contacts))
  (define-key global-map [menu-bar tools mu4e consult-mu separator1]
              '("--" . nil))
  (define-key global-map [menu-bar tools mu4e consult-mu search-unread]
              '("Search Unread" . consult-mu-search-unread))
  (define-key global-map [menu-bar tools mu4e consult-mu search-today]
              '("Search Today" . consult-mu-search-today))
  (define-key global-map [menu-bar tools mu4e consult-mu search-week]
              '("Search This Week" . consult-mu-search-this-week))
  (define-key global-map [menu-bar tools mu4e consult-mu separator2]
              '("--" . nil))
  (define-key global-map [menu-bar tools mu4e consult-mu search-gmail]
              '("Search Gmail" . consult-mu-search-gmail))
  (define-key global-map [menu-bar tools mu4e consult-mu search-fastmail]
              '("Search Fastmail" . consult-mu-search-fastmail)))

;; Add custom menu items for consult-mu
(when (file-exists-p "~/.config/emacs/elpa/consult-mu")
  (with-eval-after-load 'mu4e
    (define-key mu4e-main-mode-map [menu-bar consult-mu]
                (cons "Consult-Mu" (make-sparse-keymap "Consult-Mu")))

    (define-key mu4e-main-mode-map [menu-bar consult-mu search-everywhere]
                '("Search Everywhere" . consult-mu-search-everywhere))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-dynamic]
                '("Dynamic Search" . consult-mu-dynamic))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-async]
                '("Async Search" . consult-mu-async))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-contacts]
                '("Search Contacts" . consult-mu-contacts))
    (define-key mu4e-main-mode-map [menu-bar consult-mu separator1]
                '("--" . nil))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-unread]
                '("Search Unread" . consult-mu-search-unread))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-today]
                '("Search Today" . consult-mu-search-today))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-week]
                '("Search This Week" . consult-mu-search-this-week))
    (define-key mu4e-main-mode-map [menu-bar consult-mu separator2]
                '("--" . nil))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-gmail]
                '("Search Gmail" . consult-mu-search-gmail))
    (define-key mu4e-main-mode-map [menu-bar consult-mu search-fastmail]
                '("Search Fastmail" . consult-mu-search-fastmail))))

;; Message mode configuration
(setq message-send-mail-function 'smtpmail-send-it
      message-kill-buffer-on-exit t
      send-mail-function 'smtpmail-send-it)

;; SMTP configuration with pass integration
(setq smtpmail-auth-credentials
      `(("smtp.gmail.com" 587 "christian.kopac@gmail.com"
         ,(lambda () (string-trim (shell-command-to-string "pass show email/gmail"))))
        ("smtp.fastmail.com" 465 "hello@christiankopac.com"
         ,(lambda () (string-trim (shell-command-to-string "pass show email/fastmail"))))))

;; BBDB configuration
(setq bbdb-file "~/.bbdb"
      bbdb-offer-save 1
      bbdb-use-pop-up nil
      bbdb-electric-p t
      bbdb-popup-target-lines 1
      bbdb-complete-mail-allow-cycling t)

(global-set-key (kbd "C-c c b") 'bbdb)
(with-eval-after-load 'bbdb
  (add-hook 'mu4e-view-mode-hook 'bbdb-mua-auto-update))

;; Consult-mu configuration
(when (and (require 'consult-mu nil t) (file-exists-p "~/.config/emacs/elpa/consult-mu"))
  ;; Keybindings
  (global-set-key (kbd "C-c m s") 'consult-mu)
  (global-set-key (kbd "C-c m d") 'consult-mu-dynamic)
  (global-set-key (kbd "C-c m a") 'consult-mu-async)
  (global-set-key (kbd "C-c m c") 'consult-mu-contacts)

  ;; Settings
  (setq consult-mu-default-command 'consult-mu-dynamic
        consult-mu-dynamic-results-limit 50
        consult-mu-dynamic-sort-field 'date
        consult-mu-dynamic-sort-direction 'desc
        consult-mu-async-results-limit 100
        consult-mu-async-sort-field 'date
        consult-mu-async-sort-direction 'desc
        consult-mu-preview-function 'consult-mu-preview
        consult-mu-preview-key "M-."
        consult-mu-contacts-results-limit 50)

  ;; Enable embark integration
  (when (require 'consult-mu-embark nil t)
    (require 'consult-mu-embark))

  ;; Custom search functions
  (defun consult-mu-search-unread ()
    "Search for unread messages."
    (interactive)
    (consult-mu-dynamic "flag:unread AND NOT flag:trashed"))

  (defun consult-mu-search-today ()
    "Search for today's messages."
    (interactive)
    (consult-mu-dynamic "date:today..now"))

  (defun consult-mu-search-this-week ()
    "Search for this week's messages."
    (interactive)
    (consult-mu-dynamic "date:7d..now"))

  (defun consult-mu-search-gmail ()
    "Search Gmail messages."
    (interactive)
    (consult-mu-dynamic "maildir:/Gmail/INBOX"))

  (defun consult-mu-search-fastmail ()
    "Search Fastmail messages."
    (interactive)
    (consult-mu-dynamic "maildir:/Fastmail/INBOX"))

  (defun consult-mu-search-everywhere ()
    "Search all messages across all accounts."
    (interactive)
    (consult-mu-dynamic ""))

  ;; Add custom search functions to mu4e keymap
  (with-eval-after-load 'mu4e
    (define-key mu4e-headers-mode-map (kbd "C-c s u") 'consult-mu-search-unread)
    (define-key mu4e-headers-mode-map (kbd "C-c s t") 'consult-mu-search-today)
    (define-key mu4e-headers-mode-map (kbd "C-c s w") 'consult-mu-search-this-week)
    (define-key mu4e-headers-mode-map (kbd "C-c s g") 'consult-mu-search-gmail)
    (define-key mu4e-headers-mode-map (kbd "C-c s f") 'consult-mu-search-fastmail)
    (define-key mu4e-headers-mode-map (kbd "C-c s e") 'consult-mu-search-everywhere))

  ;; Global keybindings
  (global-set-key (kbd "C-c m u") 'consult-mu-search-unread)
  (global-set-key (kbd "C-c m t") 'consult-mu-search-today)
  (global-set-key (kbd "C-c m w") 'consult-mu-search-this-week)
  (global-set-key (kbd "C-c m g") 'consult-mu-search-gmail)
  (global-set-key (kbd "C-c m f") 'consult-mu-search-fastmail)
  (global-set-key (kbd "C-c m e") 'consult-mu-search-everywhere)

  ;; Which-key descriptions
  (with-eval-after-load 'which-key
    (which-key-add-key-based-replacements
      "C-c m s" "󰇮 Main Search"
      "C-c m d" "󰀧 Dynamic Search"
      "C-c m a" "󰀧 Async Search"
      "C-c m c" "󰀸 Search Contacts"
      "C-c m u" "󰇮 Search Unread"
      "C-c m t" "󰅐 Search Today"
      "C-c m w" "󰅐 Search This Week"
      "C-c m g" "󰇮 Search Gmail"
      "C-c m f" "󰇮 Search Fastmail"
      "C-c m e" "󰉋 Search Everywhere")))

(provide 'email)
