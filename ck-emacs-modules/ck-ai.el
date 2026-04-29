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
;; Ellama — local LLM (Ollama) via GNU ELPA `llm` (declared in init.el)
;; ============================================================================
;;
;; `C-c M-e' runs `ellama'. With `ellama-provider' nil, Ellama uses the first
;; model from `ollama list'. To pin models (and embeddings for context/RAG):
;;
;;   ollama pull qwen2.5:3b
;;   ollama pull nomic-embed-text
;;
;; Then add a `with-eval-after-load' in this file, for example:
;;
;;   (with-eval-after-load 'ellama
;;     (require 'llm-ollama)
;;     (setopt ellama-provider
;;             (make-llm-ollama
;;              :chat-model "qwen2.5:3b"
;;              :embedding-model "nomic-embed-text")))
;;
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

(provide 'ck-ai)
