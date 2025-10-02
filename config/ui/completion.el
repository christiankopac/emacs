;;; completion.el --- Completion system configuration

;; ============================================================================
;; Vertico Configuration - Vertical completion UI
;; ============================================================================

(with-eval-after-load 'vertico
  (vertico-mode)                      ; Enable vertico
  (setq vertico-cycle t               ; Cycle from bottom to top
        vertico-resize t              ; Resize minibuffer to fit candidates
        vertico-count 25))            ; Show 25 candidates

;; ============================================================================
;; Corfu Configuration - In-buffer completion popup
;; ============================================================================

(with-eval-after-load 'corfu
  (setq corfu-auto t                  ; Enable automatic completion
        corfu-cycle t))               ; Cycle through candidates

;; ============================================================================
;; Orderless Configuration - Flexible completion style
;; ============================================================================

(with-eval-after-load 'orderless
  ;; More flexible matching styles
  (setq completion-styles '(orderless basic)              ; Use orderless and basic styles
        completion-category-defaults nil                  ; Don't use category defaults
        completion-category-overrides 
        '((file (styles basic partial-completion orderless))  ; More flexible file completion
          (buffer (styles orderless basic))               ; Buffer names
          (command (styles orderless basic))              ; M-x commands
          (variable (styles orderless basic))             ; Variables
          (symbol (styles orderless basic)))              ; Symbols
        
        ;; Orderless matching styles (in order of priority)
        orderless-matching-styles 
        '(orderless-literal                               ; Exact substring match (fastest)
          orderless-prefixes                              ; Match each component as prefix
          orderless-initialism                            ; Match initials (e.g., "fb" matches "FooBar")
          orderless-regexp                                ; Full regexp support
          orderless-flex)                                 ; Flex matching (e.g., "abc" matches "aXbXc")
        
        ;; More forgiving matching
        orderless-component-separator "[ &]"              ; Split on space or &
        orderless-smart-case t)                           ; Case-insensitive unless uppercase used
  
  ;; Allow leading wildcards
  (setq completion-pcm-leading-wildcard t))

;; ============================================================================
;; Marginalia Configuration - Rich annotations in minibuffer
;; ============================================================================

(with-eval-after-load 'marginalia
  (marginalia-mode))                  ; Enable annotations for completions


;; ============================================================================
;; Consult Configuration - Consulting completing-read
;; ============================================================================

(with-eval-after-load 'consult
  (setq consult-line-start-from-top t))  ; Start consult-line from top of buffer

;; ============================================================================
;; Embark-Consult Configuration - Integration between embark and consult
;; ============================================================================

(with-eval-after-load 'embark
  (add-hook 'embark-collect-mode-hook 'consult-preview-at-point-mode))  ; Enable preview in embark collect

(provide 'completion)