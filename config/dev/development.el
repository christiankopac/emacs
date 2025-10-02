;;; development.el --- Development tools configuration

;; ----------------------------------------------------------------------------
;; Language-Specific Configuration
;; ----------------------------------------------------------------------------

;; Typescript
(with-eval-after-load 'typescript-mode
  (add-hook 'typescript-mode-hook 'eglot))  ; Enable Eglot LSP for TypeScript

;; Web-mode
(setq web-mode-content-types-alist
      '(("jsx" . "\\.js[x]?\\'")))       ; Treat .js and .jsx files as JSX

;; Go-mode
(setq gofmt-command "goimports")         ; Use goimports instead of gofmt (handles imports)
(with-eval-after-load 'go-mode
  (add-hook 'before-save-hook 'gofmt-before-save))  ; Auto-format Go files on save

;; Shell scripting
(setq sh-basic-offset 2                  ; Use 2 spaces for shell script indentation
      sh-indentation 2)                  ; Consistent indentation level

;; ----------------------------------------------------------------------------
;; Development Tools
;; ----------------------------------------------------------------------------

;; Sideline - Show diagnostics and info in margin
(with-eval-after-load 'sideline
  (setq sideline-backends-left '(sideline-flycheck)   ; Show flycheck errors on left
        sideline-backends-right '(sideline-lsp)       ; Show LSP info on right
        sideline-order-left 'down                     ; Top-to-bottom on left
        sideline-order-right 'up)                     ; Bottom-to-top on right
  
  (add-hook 'flycheck-mode-hook 'sideline-mode))      ; Enable sideline with flycheck

;; Project - Built-in project management
(setq project-vc-extra-root-markers '(".project" "Cargo.toml" "package.json" "pyproject.toml"))  ; Additional project root markers

(global-set-key (kbd "C-c p f") 'project-find-file)      ; Find file in project
(global-set-key (kbd "C-c p d") 'project-find-dir)       ; Find directory in project
(global-set-key (kbd "C-c p g") 'project-find-regexp)    ; Search in project
(global-set-key (kbd "C-c p s") 'project-switch-project) ; Switch between projects

;; Flycheck - On-the-fly syntax checking
(with-eval-after-load 'flycheck
  (global-flycheck-mode t)                                           ; Enable flycheck globally
  (setq flycheck-check-syntax-automatically '(save mode-enabled))    ; Check on save and when enabled
  (setq flycheck-display-errors-delay 0.1)                           ; Show errors after 0.1s delay
  (setq flycheck-idle-change-delay 0.3)                              ; Wait 0.3s after typing before checking
  (setq flycheck-highlighting-mode 'lines)                           ; Highlight entire lines with errors
  (setq flycheck-indication-mode 'right-fringe)                      ; Show indicators in right fringe
  (setq flycheck-display-errors-function #'flycheck-display-error-messages-unless-error-list)  ; Smart error display
  (setq flycheck-disabled-checkers '(emacs-lisp-checkdoc))           ; Disable checkdoc for Emacs Lisp

  ;; TypeScript-specific checkers
  (add-hook 'typescript-mode-hook
            (lambda ()
              (setq-local flycheck-checkers '(typescript-tslint))))

  ;; Go-specific checkers
  (add-hook 'go-mode-hook
            (lambda ()
              (setq-local flycheck-checkers '(go-gofmt go-golint go-vet go-build go-test go-errcheck))))

  ;; Shell script checkers
  (add-hook 'sh-mode-hook
            (lambda ()
              (setq-local flycheck-checkers '(sh-bash sh-shellcheck)))))

;; Sideline-flycheck - Display flycheck errors in sideline
(with-eval-after-load 'sideline-flycheck
  (add-hook 'flycheck-mode-hook 'sideline-flycheck-setup))  ; Setup flycheck integration

;; Hl-todo - Highlight TODO keywords in comments
(setq hl-todo-keyword-faces 
      '(("TODO"   . "#FFCC02")   ; Yellow - tasks to do
        ("FIXME"  . "#FF3838")   ; Red - bugs to fix
        ("DEBUG"  . "#9D4EDD")   ; Purple - debug statements
        ("GOTCHA" . "#FF8500")   ; Orange - tricky code
        ("STUB"   . "#06FFA5")   ; Cyan - placeholder code
        ("NOTE"   . "#4CC9F0")   ; Blue - important notes
        ("HACK"   . "#E0AAFF"))) ; Pink - temporary solutions

;; Tree-sitter - Better syntax highlighting and parsing
(with-eval-after-load 'tree-sitter
  (require 'tree-sitter-langs)                               ; Load language definitions
  (global-tree-sitter-mode)                                  ; Enable tree-sitter globally
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))  ; Enable syntax highlighting

;; Treesit-auto - Auto-install tree-sitter parsers
;; (with-eval-after-load 'tree-sitter
;;   (treesit-auto-install-all))

;; ----------------------------------------------------------------------------
;; Formatting
;; ----------------------------------------------------------------------------

;; Format-all - Format buffer with appropriate formatter
(global-set-key (kbd "C-c f f") 'format-all-buffer)  ; Format current buffer

;; Which-key descriptions for development
(with-eval-after-load 'which-key
  (which-key-add-key-based-replacements
    "C-c f f" "󰏧 Format Buffer"))

;; Apheleia - Auto-format on save
(with-eval-after-load 'apheleia
  ;; Disable apheleia for denote-generated network HTML files
  (add-to-list 'apheleia-inhibit-functions
               (lambda ()
                 (and buffer-file-name
                      (string-match-p "denote-network\\.html$" buffer-file-name))))
  
  (apheleia-global-mode 1))  ; Enable automatic formatting on save

;; ----------------------------------------------------------------------------
;; Version Control
;; ----------------------------------------------------------------------------

;; Magit - Git interface
(global-set-key (kbd "C-x g") 'magit-status)  ; Open magit status buffer
(with-eval-after-load 'magit
  (setq magit-repository-directories '(("~/src/projects" . 1)    ; Search for repos in projects (depth 1)
                                        ("~/src/lab" . 1)         ; Search in lab (depth 1)
                                        ("~/src/github.com/" . 2))))  ; Search in github.com (depth 2)

;; Diff-hl - Show git changes in fringe
(with-eval-after-load 'diff-hl
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)  ; Update diff-hl after magit operations
  (global-diff-hl-mode 1))                                          ; Enable diff-hl globally

;; Git-timemachine - Step through git history
(global-set-key (kbd "C-x v t") 'git-timemachine)  ; Browse file's git history

;; Git-messenger - Show commit message at point
(global-set-key (kbd "C-x v p") 'git-messenger:popup-message)  ; Show commit info for current line
(with-eval-after-load 'git-messenger
  (setq git-messenger:show-detail t          ; Show detailed commit info
        git-messenger:use-magit-popup t))    ; Use magit's popup interface

;; ----------------------------------------------------------------------------
;; AI Tools
;; ----------------------------------------------------------------------------

;; Copilot - AI code completion
(with-eval-after-load 'copilot
  (setq copilot-max-char 200000)             ; Maximum characters to send to Copilot
  (add-to-list 'copilot-disable-predicates   ; Disable in apheleia scratch buffers
               (lambda ()
                 (string-match-p "\\*apheleia-" (buffer-name))))

  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)       ; Accept with Tab
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)         ; Accept with TAB
  (define-key copilot-completion-map (kbd "C-<tab>") 'copilot-accept-completion-by-word))  ; Accept word by word

;; ----------------------------------------------------------------------------
;; Terminal
;; ----------------------------------------------------------------------------

;; Eat - Emulate A Terminal
(global-set-key (kbd "C-c t e") 'eat)             ; Open terminal
(global-set-key (kbd "C-c t E") 'eat-other-window)  ; Open terminal in other window

(with-eval-after-load 'eat
  (setq eat-default-shell "fish")                          ; Use fish shell
  (setq eat-kill-buffer-on-exit t)                         ; Close buffer when terminal exits
  (setq eat-enable-yank-to-terminal t)                     ; Allow yanking to terminal
  (setq eat-enable-shell-prompt-annotation t)              ; Show annotations on prompts
  (setq eat-shell-prompt-annotation-position 'after-prompt)  ; Position after prompt
  (setq eat-shell-prompt-annotation-face 'eat-shell-prompt-annotation)  ; Face for annotation
  (setq eat-shell-prompt-annotation-format " [%s]"))       ; Format: [annotation]

;; Exec-path-from-shell - Import PATH from shell
(with-eval-after-load 'exec-path-from-shell
  (when (memq window-system '(mac ns x))     ; Only on macOS and X window systems
    (exec-path-from-shell-initialize)))      ; Import shell environment variables

(provide 'development)