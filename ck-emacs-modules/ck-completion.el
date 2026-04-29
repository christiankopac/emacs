;;; completion.el --- Completion system configuration

;; ============================================================================
;; Vertico Configuration - Vertical completion UI
;; ============================================================================
;; Vertico is the vetical compeltion UI framework that provides a minimalistic
;; interface for narrowing and selecting completion candidates.
(with-eval-after-load 'vertico
  (vertico-mode)                      ; Enable vertico
  (setq vertico-cycle t               ; Cycle from bottom to top
        vertico-resize t              ; Resize minibuffer to fit candidates
        vertico-count 5               ; Show 20 candidates by default
        vertico-scroll-margin 0       ; No scroll margin
        vertico-resize nil            ; FIXME: Don't resize vertically
  )
  ;; Tidy up directory listings
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
)
  
;; ============================================================================
;; Corfu Configuration - In-buffer completion popup
;; ============================================================================

(with-eval-after-load 'corfu
  (global-corfu-mode 1)               ; Enable corfu globally
  (setq corfu-auto t                  ; Enable automatic completion
        corfu-auto-delay 0.2          ; Delay before showing completion (seconds)
        corfu-auto-prefix 2           ; Minimum prefix length for auto completion
        corfu-cycle t                 ; Cycle through candidates
        corfu-preselect 'prompt))     ; Preselect the prompt

;; ============================================================================
;; Cape Configuration - Completion At Point Extensions
;; ============================================================================

(with-eval-after-load 'cape
  ;; Add useful cape backends globally
  ;; Note: Specific modes may add additional backends via their hooks
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)  ; Dynamic abbreviations
  (add-to-list 'completion-at-point-functions #'cape-file))    ; File paths

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
;; Marginalia adds annotations to minibuffer completions, providing additional
;; context about each candidate (e.g., file size, function signatures).
(with-eval-after-load 'marginalia
  (marginalia-mode))                  ; Enable annotations for completions

;; ==========================================================================
;; Minimal file candidates (find-file / project-find-file)
;; - Keep icons, drop the noisy file metadata annotations.
;; ==========================================================================

(use-package nerd-icons-completion
  :ensure t
  :after (marginalia nerd-icons)
  :config
  (nerd-icons-completion-mode 1)

  ;; Enable icons in Marginalia annotations (Vertico shows them nicely in the margin).
  (with-eval-after-load 'marginalia
    (when (fboundp 'nerd-icons-completion-marginalia-setup)
      (nerd-icons-completion-marginalia-setup))

    (defun my/marginalia-annotate-file-icon (cand)
      "Return a minimal annotation for file candidate CAND (icon only)."
      (when-let* ((icon-fn (cond
                            ((fboundp 'nerd-icons-completion-get-icon)
                             #'nerd-icons-completion-get-icon)
                            ((fboundp 'nerd-icons-completion--get-icon)
                             #'nerd-icons-completion--get-icon)))
                  (icon (condition-case _err
                            ;; Newer `nerd-icons-completion' expects 2 args.
                            (funcall icon-fn cand 'file)
                          (wrong-number-of-arguments
                           ;; Older variants sometimes take a single arg.
                           (funcall icon-fn cand)))))
        (concat " " icon)))

    ;; Override Marginalia's file annotator list with a minimal one.
    ;; Structure: (CATEGORY ANNOTATOR FALLBACK ...)
    (when (boundp 'marginalia-annotators)
      (setf (alist-get 'file marginalia-annotators)
            '(my/marginalia-annotate-file-icon nil)))))


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

(provide 'ck-completion)
