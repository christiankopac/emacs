;;; ai-tools.el --- AI tools configuration

;; ============================================================================
;; GPTel Configuration - AI chat interface
;; ============================================================================

(with-eval-after-load 'gptel
  ;; Configure API keys using pass command
  (gptel-make-anthropic "Claude"
    :stream t
    :key (lambda () (string-trim (shell-command-to-string "pass api-keys/anthropic")))
    :host "api.anthropic.com")
  
  (gptel-make-openai "OpenAI"
    :stream t
    :key (lambda () (string-trim (shell-command-to-string "pass api-keys/openai")))
    :host "api.openai.com")
  
  (gptel-make-perplexity "Perplexity"
    :stream t
    :key (lambda () (string-trim (shell-command-to-string "pass api-keys/perplexity")))
    :host "api.perplexity.ai")
  
  ;; Set default model
  (setq gptel-default-provider "Claude")
  
  ;; Keybindings
  (global-set-key (kbd "C-c g g") 'gptel)
  (global-set-key (kbd "C-c g s") 'gptel-send)
  (global-set-key (kbd "C-c g r") 'gptel-regenerate)
  (global-set-key (kbd "C-c g c") 'gptel-clear-context))

;; ============================================================================
;; Copilot Configuration - AI code completion
;; ============================================================================

(with-eval-after-load 'copilot
  (setq copilot-max-char 200000)             ; Maximum characters to send to Copilot
  (add-to-list 'copilot-disable-predicates   ; Disable in apheleia scratch buffers
               (lambda ()
                 (string-match-p "\\*apheleia-" (buffer-name))))

  (define-key copilot-completion-map (kbd "<tab>") 'copilot-accept-completion)       ; Accept with Tab
  (define-key copilot-completion-map (kbd "TAB") 'copilot-accept-completion)         ; Accept with TAB
  (define-key copilot-completion-map (kbd "C-<tab>") 'copilot-accept-completion-by-word))  ; Accept word by word

(provide 'ai-tools)
