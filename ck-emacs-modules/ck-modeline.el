;;; ck-modeline.el --- Mode-line configuration  -*- lexical-binding: t; -*-

;;; Commentary:
;; Mood-line based mode-line with a small emoji segment for the major mode
;; and buffer state.  Pulls the segment files in eagerly so that the advice
;; and flycheck hooks mood-line installs cannot end up referencing functions
;; that haven't been loaded yet (which is what produced
;; `(void-function mood-line-segment-vc--update)` and
;; `(void-function mood-line-segment-checker--flycheck-update)`).

;;; Code:

(require 'mood-line)

;; Eagerly load the segment libraries.  Mood-line installs advice on
;; `vc-refresh-state' and adds entries to `flycheck-status-changed-functions'
;; from inside these files; if the byte-compiled cache gets out of sync
;; with the source, those hooks can dangle.  Pulling the libraries in here
;; ensures the functions exist before any hook can fire.
(require 'mood-line-segment-vc nil t)
(require 'mood-line-segment-checker nil t)

;; Defensive stubs.  If a stale advice still somehow points at a missing
;; symbol (e.g. across a session resumed after an elpaca rebuild), the stub
;; turns the void-function error into a no-op until the real definition
;; supersedes it.
(unless (fboundp 'mood-line-segment-vc--update)
  (defun mood-line-segment-vc--update (&rest _) nil))
(unless (fboundp 'mood-line-segment-checker--flycheck-update)
  (defun mood-line-segment-checker--flycheck-update (&rest _) nil))

(setq mood-line-glyph-alist mood-line-glyphs-fira-code
      mood-line-show-encoding-information nil
      mood-line-show-eol-style nil
      mood-line-show-cursor-point t
      mood-line-right-align nil
      mood-line-percent-position nil)

(dolist (face '((mood-line-modified         :foreground "#d08770" :weight bold)
                (mood-line-status-neutral   :foreground "#88c0d0")
                (mood-line-status-info      :foreground "#81a1c1")
                (mood-line-status-success   :foreground "#a3be8c")
                (mood-line-status-warning   :foreground "#ebcb8b")
                (mood-line-status-error     :foreground "#bf616a")
                (mood-line-encoding         :inherit mood-line-unimportant)))
  (when (facep (car face))
    (apply #'set-face-attribute (car face) nil (cdr face))))

;; Prefer Noto Color Emoji when available so the emoji segment renders in
;; colour rather than as monochrome glyphs from the default font.
(when (and (display-graphic-p)
           (member "Noto Color Emoji" (font-family-list)))
  (set-fontset-font t 'emoji (font-spec :family "Noto Color Emoji") nil 'prepend))

(defface ck-modeline-emoji-face
  '((t :inherit mode-line))
  "Face for the emoji segment in the mode-line.")

(defvar ck-modeline-mode-emoji-alist
  '((emacs-lisp-mode        . "λ")
    (lisp-interaction-mode  . "λ")
    (python-mode            . "🐍")
    (org-mode               . "📝")
    (org-agenda-mode        . "📅")
    (markdown-mode          . "📰")
    (js-mode                . "✨")
    (typescript-mode        . "🟦")
    (rust-mode              . "🦀")
    (go-mode                . "🐹")
    (sh-mode                . "🐚")
    (eshell-mode            . "🐚")
    (vterm-mode             . "🖥")
    (term-mode              . "🖥")
    (eat-mode               . "🖥")
    (dired-mode             . "📁")
    (magit-status-mode      . "🔀")
    (magit-log-mode         . "🔀")
    (help-mode              . "❓")
    (helpful-mode           . "❓")
    (compilation-mode       . "⚙")
    (sql-mode               . "🗄")
    (mu4e-main-mode         . "✉")
    (mu4e-headers-mode      . "✉")
    (pdf-view-mode          . "📕"))
  "Alist mapping `derived-mode-p' parents to an emoji.")

(defconst ck-modeline-default-emoji "📄")

(defun ck-modeline--emoji-for-mode ()
  "Return an emoji for the current major mode (via `derived-mode-p')."
  (or (catch 'found
        (dolist (pair ck-modeline-mode-emoji-alist)
          (when (and (symbolp (car pair)) (derived-mode-p (car pair)))
            (throw 'found (cdr pair))))
        nil)
      ck-modeline-default-emoji))

(defun ck-modeline-emoji-segment ()
  "Render the emoji + buffer-state indicator for the mode-line."
  (let ((emoji (ck-modeline--emoji-for-mode))
        (state (cond (buffer-read-only "🔒")
                     ((buffer-modified-p) "✏")
                     (t "✅"))))
    (concat " " (propertize emoji 'face 'ck-modeline-emoji-face) " " state " ")))

(unless (member '(:eval (ck-modeline-emoji-segment)) mode-line-format)
  (setq-default mode-line-format
                (cons '(:eval (ck-modeline-emoji-segment)) mode-line-format)))

(mood-line-mode 1)

(provide 'ck-modeline)
;;; ck-modeline.el ends here
