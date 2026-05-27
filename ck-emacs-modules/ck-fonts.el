;;; ck-fonts.el --- Fonts and fontaine presets -*- lexical-binding: t -*-

;; Why fonts go wrong on this config:
;;
;;   1. The monospace fallback chain is evaluated ONCE at load time. If
;;      Emacs is started as a daemon BEFORE any GUI frame exists,
;;      `font-family-list' returns an empty (or TTY-only) list and the
;;      defvar caches "Monospace" forever — even after a GUI frame opens.
;;   2. The chain hard-codes "JetBrains Mono" but the JetBrains Nerd font
;;      ships as "JetBrainsMono Nerd Font Mono" (one word). Different
;;      family name → silent fall-through.
;;   3. Material Design Icons used by nerd-icons (and several themes) live
;;      at codepoints U+F0001..U+F1FFF, past the standard PUA range.
;;
;; Fixes here:
;;   - Resolve fonts lazily via `ck/fonts--resolve' that re-queries
;;     `font-family-list' on every call, so daemon frames get the right
;;     answer once a real frame exists.
;;   - Updated fallback chain that lists actual installed family names
;;     (including the JetBrainsMono Nerd Font variants).
;;   - Extended PUA fontset coverage to U+F1FFF for Material Design.
;;   - Re-apply fontaine + face attributes on `server-after-make-frame-hook'.

(require 'seq)
(require 'ck-system)

;; ---------------------------------------------------------------------------
;; Preference chains
;; ---------------------------------------------------------------------------
;; In order of preference. Family names must match `fc-list' output exactly
;; — that's where the old chain's "JetBrains Mono" → "JetBrainsMono Nerd
;; Font" mismatch came from.

(defvar ck/fonts-monospace-chain
  '("MonoLisa Nerd Font Mono"
    "MonoLisa Nerd Font"
    "MonoLisa"
    "JetBrainsMono Nerd Font Mono"
    "JetBrainsMono Nerd Font"
    "JetBrains Mono"
    "FiraCode Nerd Font Mono"
    "FiraCode Nerd Font"
    "Fira Code"
    "Source Code Pro"
    "DejaVu Sans Mono"
    "Liberation Mono"
    "Consolas"
    "Adwaita Mono"
    "Courier New"
    "monospace")
  "Preferred monospace families, first installed wins.")

(defvar ck/fonts-serif-chain
  '("Literata"
    "ETBookOT"
    "Iowan Old Style"
    "Charter"
    "Source Serif Pro"
    "DejaVu Serif"
    "Times New Roman"
    "Times"
    "serif")
  "Preferred serif (variable-pitch) families.")

(defvar ck/fonts-nerd-symbols-chain
  '("Symbols Nerd Font Mono"
    "Symbols Nerd Font"
    "Noto Sans Symbols2"
    "Noto Color Emoji")
  "Preferred Nerd Font symbol family for PUA glyphs.")

;; ---------------------------------------------------------------------------
;; Lazy resolution
;; ---------------------------------------------------------------------------

(defun ck/fonts--resolve (chain)
  "Return the first installed family in CHAIN, or nil. Re-queries every
call so daemon frames pick up GUI fonts once a real frame exists."
  (when (display-graphic-p)
    (let ((available (font-family-list)))
      (seq-find (lambda (f) (member f available)) chain))))

(defvar ck/fonts-monospace nil "Resolved monospace family, set lazily.")
(defvar ck/fonts-serif nil     "Resolved serif family, set lazily.")
(defvar ck/fonts-nerd-symbols nil "Resolved Nerd Font symbol family, set lazily.")

(defun ck/fonts-refresh ()
  "Resolve the actual font families from the chains. Idempotent."
  (when (display-graphic-p)
    (setq ck/fonts-monospace    (or (ck/fonts--resolve ck/fonts-monospace-chain)
                                    "monospace")
          ck/fonts-serif        (or (ck/fonts--resolve ck/fonts-serif-chain)
                                    "serif")
          ck/fonts-nerd-symbols (or (ck/fonts--resolve ck/fonts-nerd-symbols-chain)
                                    ck/fonts-monospace))))

;; Back-compat aliases — old code reads these.
(defvar my/font-monospace nil)
(defvar my/font-serif nil)
(defvar my/font-nerd-symbols nil)

(defun ck/fonts--sync-back-compat ()
  (setq my/font-monospace    ck/fonts-monospace
        my/font-serif        ck/fonts-serif
        my/font-nerd-symbols ck/fonts-nerd-symbols))

;; ---------------------------------------------------------------------------
;; HiDPI scaling
;; ---------------------------------------------------------------------------
;; WSLg currently reports a logical DPI that needs ~2x scaling for Emacs to
;; look right at common laptop resolutions. Override with M-x customize or
;; just (setq my/font-height-multiplier 1.5) before this loads if you want
;; something different.

(defvar my/wsl-p ck/wsl-p
  "Non-nil if running on WSL. Kept for back-compat — prefer `ck/wsl-p'.")

(defvar my/font-height-multiplier (if ck/wsl-p 2.0 1.0)
  "Multiplier for font heights. 2x on WSL to compensate for WSLg's logical
DPI. Override in custom.el or before loading this file.")

(defvar my/font-regular-height      (round (* 90  my/font-height-multiplier)))
(defvar my/font-writing-height      (round (* 90  my/font-height-multiplier)))
(defvar my/font-org-reading-height  (round (* 90  my/font-height-multiplier)))
(defvar my/font-presentation-height (round (* 110 my/font-height-multiplier)))
(defvar my/font-compact-height      (round (* 85  my/font-height-multiplier)))
(defvar my/font-large-height        (round (* 90  my/font-height-multiplier)))

;; ---------------------------------------------------------------------------
;; Fontaine presets
;; ---------------------------------------------------------------------------

(defun ck/fonts--build-presets ()
  "Build the fontaine preset alist from currently-resolved families."
  `((regular
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-regular-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 1.0
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height 1.0
     :bold-weight bold
     :italic-slant italic
     :line-spacing nil)

    (writing
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-writing-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 140
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height ,my/font-writing-height
     :bold-weight bold
     :italic-slant italic
     :line-spacing 0.2)

    (org-reading
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-org-reading-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 1.4
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height ,my/font-org-reading-height
     :bold-weight bold
     :italic-slant italic
     :line-spacing 0.2)

    (presentation
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-presentation-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 220
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height ,my/font-presentation-height
     :bold-weight bold
     :italic-slant italic
     :line-spacing 0.2)

    (compact
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-compact-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 0.9
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height 1.0
     :bold-weight bold
     :italic-slant italic
     :line-spacing nil)

    (large
     :default-family ,ck/fonts-monospace
     :default-weight normal
     :default-height ,my/font-large-height
     :variable-pitch-family ,ck/fonts-serif
     :variable-pitch-weight normal
     :variable-pitch-height 180
     :fixed-pitch-family ,ck/fonts-monospace
     :fixed-pitch-height ,my/font-large-height
     :bold-weight bold
     :italic-slant italic
     :line-spacing 0.15)))

;; ---------------------------------------------------------------------------
;; PUA fontset — make Nerd Font glyphs render
;; ---------------------------------------------------------------------------

(defun ck/fonts--register-pua ()
  "Map the Nerd Font private use areas to the resolved symbol font.
Covers the standard PUA (#xE000–#xF8FF) and the supplementary PUA-A
range used by modern Nerd Font / Material Design glyphs
(#xF0000–#xF1AFF — that's enough for every current Nerd Font glyph
without paying the cost of mapping the full 1M-codepoint Plane 16)."
  (when (and (display-graphic-p)
             ck/fonts-nerd-symbols
             (member ck/fonts-nerd-symbols (font-family-list)))
    (let ((spec (font-spec :family ck/fonts-nerd-symbols)))
      (set-fontset-font t '(#xE000  . #xF8FF)  spec nil 'append)
      (set-fontset-font t '(#xF0000 . #xF1AFF) spec nil 'append))))

;; ---------------------------------------------------------------------------
;; Face setup
;; ---------------------------------------------------------------------------

(defun my/set-variable-fixed-pitch-faces ()
  "Set variable-pitch and fixed-pitch faces to the resolved families.
Heights stay under fontaine's control."
  (when (display-graphic-p)
    (when ck/fonts-serif
      (set-face-attribute 'variable-pitch nil :family ck/fonts-serif))
    (when ck/fonts-monospace
      (set-face-attribute 'fixed-pitch nil :family ck/fonts-monospace)
      (set-face-attribute 'default     nil :family ck/fonts-monospace))))

;; ---------------------------------------------------------------------------
;; Apply — runs every time a GUI frame becomes available
;; ---------------------------------------------------------------------------

(defun ck/fonts-apply (&optional force)
  "Resolve fonts, rebuild fontaine presets, register PUA, set faces.
Idempotent — uses the `ck/fonts-applied' frame parameter so repeat calls
on the same frame become no-ops. Pass non-nil FORCE to override.

Previously this function ran 2-3x at GUI startup because it was wired
to `after-make-frame-functions', `server-after-make-frame-hook' AND
`with-eval-after-load fontaine'. The work it does (rebuilding presets,
registering 3 fontset ranges, setting faces) is expensive enough that
running it 3x burnt about 1s of startup."
  (when (and (display-graphic-p)
             (or force (not (frame-parameter nil 'ck/fonts-applied))))
    (ck/fonts-refresh)
    (ck/fonts--sync-back-compat)
    (when (boundp 'fontaine-presets)
      (setq fontaine-presets (ck/fonts--build-presets)))
    (when (fboundp 'fontaine-set-preset)
      (ignore-errors (fontaine-set-preset 'regular)))
    (ck/fonts--register-pua)
    (my/set-variable-fixed-pitch-faces)
    (when (boundp 'nerd-icons-font-family)
      (setq nerd-icons-font-family ck/fonts-nerd-symbols))
    (set-frame-parameter nil 'ck/fonts-applied t)))

;; Apply immediately if we already have a GUI frame.
(when (display-graphic-p)
  (with-eval-after-load 'fontaine
    (ck/fonts-apply)
    ;; If fontaine sets a preset later (e.g., via a saved state), re-apply
    ;; face families because fontaine clobbers `default'.
    (advice-add 'fontaine-set-preset :after
                (lambda (&rest _) (my/set-variable-fixed-pitch-faces)))))

;; Re-apply once per new frame (per-frame guard handles idempotency).
(add-hook 'after-make-frame-functions
          (lambda (frame)
            (when (display-graphic-p frame)
              (with-selected-frame frame (ck/fonts-apply)))))
;; Some Emacs builds fire server-after-make-frame-hook *before*
;; after-make-frame-functions sees the new frame as graphic, so hook both.
;; The per-frame guard makes the duplicate hook free.
(when (boundp 'server-after-make-frame-hook)
  (add-hook 'server-after-make-frame-hook #'ck/fonts-apply))

;; ---------------------------------------------------------------------------
;; Keybindings
;; ---------------------------------------------------------------------------

(with-eval-after-load 'fontaine
  (global-set-key (kbd "C-c M-f r") (lambda () (interactive) (fontaine-set-preset 'regular)))
  (global-set-key (kbd "C-c M-f o") (lambda () (interactive) (fontaine-set-preset 'org-reading)))
  (global-set-key (kbd "C-c M-f w") (lambda () (interactive) (fontaine-set-preset 'writing)))
  (global-set-key (kbd "C-c M-f p") (lambda () (interactive) (fontaine-set-preset 'presentation)))
  (global-set-key (kbd "C-c M-f c") (lambda () (interactive) (fontaine-set-preset 'compact)))
  (global-set-key (kbd "C-c M-f l") (lambda () (interactive) (fontaine-set-preset 'large)))
  (global-set-key (kbd "C-c M-f t") 'fontaine-set-preset))

(defun ck/fonts-status ()
  "Show which fonts actually resolved on this frame."
  (interactive)
  (message "ck/fonts: monospace=%s  serif=%s  nerd=%s"
           ck/fonts-monospace ck/fonts-serif ck/fonts-nerd-symbols))

(provide 'ck-fonts)
;;; ck-fonts.el ends here
