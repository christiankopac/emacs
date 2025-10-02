;;; org-export.el --- Org export configuration

;; ============================================================================
;; Enable multiple export backends
;; ============================================================================

;; (setq org-export-backends '(ascii html icalendar latex md odt org))  ; Available export formats
(setq org-export-backends '(html icalendar md odt org))  ; Available export formats

;; ============================================================================
;; Global export settings
;; ============================================================================

(setq org-export-with-smart-quotes t             ; Convert straight quotes to curly quotes
      org-export-with-sub-superscripts '{}       ; Only use _{} and ^{} for sub/superscripts
      org-export-with-toc t                      ; Include table of contents
      org-export-with-section-numbers t          ; Number sections
      org-export-with-author t                   ; Include author name
      org-export-with-email t                    ; Include email address
      org-export-with-date t                     ; Include date
      org-export-with-timestamps t               ; Include timestamps
      org-export-preserve-breaks nil             ; Don't preserve line breaks
      org-export-with-drawers nil                ; Don't export drawers
      org-export-with-priority t                 ; Export priority cookies
      org-export-with-tags 'not-in-toc           ; Include tags but not in TOC
      org-export-with-todo-keywords t            ; Export TODO keywords
      org-export-with-planning t)                ; Export planning info (SCHEDULED, DEADLINE)

;; ============================================================================
;; HTML Export settings
;; ============================================================================

(setq org-html-validation-link nil               ; Don't add validation link
      org-html-doctype "html5"                   ; Use HTML5 doctype
      org-html-html5-fancy t                     ; Use HTML5 semantic elements
      org-html-head-include-default-style nil    ; Don't include default CSS
      org-html-head-include-scripts nil          ; Don't include default JS
      org-html-head "<style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
               max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }
        h1, h2, h3 { color: #333; }
        pre { background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto; }
        code { background: #f0f0f0; padding: 2px 4px; border-radius: 3px; }
        blockquote { border-left: 4px solid #ddd; margin: 0; padding-left: 20px; }
        .todo { color: #d73a49; font-weight: bold; }
        .done { color: #28a745; font-weight: bold; }
        .priority { color: #e36209; font-weight: bold; }
      </style>")                                

;; ============================================================================
;; Ensure export directory exists
;; ============================================================================

;; (unless (file-directory-p org-export-directory)
  ;; (make-directory org-export-directory t))

;; ============================================================================
;; Custom export function to save in export directory
;; ============================================================================

;; (defun my/org-export-to-directory (backend)
;;   "Export current org file to specified BACKEND in export directory."
;;   (let ((org-export-output-directory org-export-directory))
;;     (org-export-to-file backend (concat org-export-directory
;;                                         (file-name-sans-extension
;;                                          (file-name-nondirectory buffer-file-name))
;;                                         (pcase backend
;;                                           ('html ".html")
;;                                           ('md ".md")
;;                                           (_ ".export"))))))

;; ============================================================================
;; Additional export settings
;; ============================================================================

;; (setq org-export-date-timestamp-format "%e %B %Y")  ; Date format: "1 January 2024"

;; ============================================================================
;; Export keybindings
;; ============================================================================

(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c e h") (lambda () (interactive) (my/org-export-to-directory 'html)))  ; Export to HTML
  (define-key org-mode-map (kbd "C-c e m") (lambda () (interactive) (my/org-export-to-directory 'md)))    ; Export to Markdown
  (define-key org-mode-map (kbd "C-c e e") 'org-export-dispatch))                                          ; Open export menu

;; ============================================================================
;; Pandoc Configuration - Universal document converter
;; ============================================================================

(setq org-pandoc-options '((standalone . t)))  ; Generate standalone documents

(provide 'org-export-config)
