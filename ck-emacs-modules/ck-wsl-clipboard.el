;;; ck-wsl-clipboard.el --- Clipboard bridge for terminal Emacs on WSL -*- lexical-binding: t -*-

;; In `emacs -nw' Emacs has no GUI clipboard backend, so C-y / M-w / C-w
;; are isolated from the Windows clipboard. This module wires
;; `interprogram-paste-function' and `interprogram-cut-function' to
;; external tools, preferring fast in-WSL utilities and falling back to
;; PowerShell when nothing else is available.
;;
;; Read order:  wl-paste (WSLg)  →  xclip  →  powershell.exe Get-Clipboard
;; Write order: wl-copy          →  xclip  →  clip.exe
;;
;; CRLF from Windows is collapsed to LF on the way in. The last value
;; produced (either read or written) is cached so back-to-back C-y or
;; the `save-interprogram-paste-before-kill' probe on every kill don't
;; keep returning the same string to the kill ring.

(defvar ck/wsl-p (and (eq system-type 'gnu/linux) (getenv "WSL_DISTRO_NAME"))
  "Non-nil when running under WSL.")

(defvar ck/wsl-clipboard--last nil
  "Last clipboard value seen by the paste/cut bridge.")

(defvar ck/wsl-clipboard--read-cache nil
  "Cons of (TIME . VALUE) used to throttle slow backends.")

(defvar ck/wsl-clipboard-read-ttl 0.5
  "Seconds to reuse a cached read result before hitting the backend again.
Protects against the per-kill probe done by
`save-interprogram-paste-before-kill' when the slow PowerShell fallback
is in use.")

(defun ck/wsl-clipboard--run (program &rest args)
  "Run PROGRAM ARGS, return non-empty stdout or nil. Never signals."
  (when (executable-find program)
    (ignore-errors
      (with-temp-buffer
        (let ((exit (apply #'call-process program nil
                           (list (current-buffer) nil) nil args)))
          (when (and (eq exit 0) (> (buffer-size) 0))
            (buffer-string)))))))

(defun ck/wsl-clipboard--read-raw ()
  "Read clipboard text via the first backend that returns something."
  (or
   ;; WSLg Wayland clipboard — mirrors the Windows clipboard when sync works.
   (ck/wsl-clipboard--run "wl-paste" "--no-newline"
                          "--type" "text/plain;charset=utf-8")
   (ck/wsl-clipboard--run "wl-paste" "--no-newline")
   ;; X11 fallback (also available under WSLg).
   (ck/wsl-clipboard--run "xclip" "-selection" "clipboard" "-o")
   ;; PowerShell: always works while WSL interop is enabled, but ~300ms.
   (ck/wsl-clipboard--run "powershell.exe" "-NoProfile" "-Command"
                          "Get-Clipboard -Raw")))

(defun ck/wsl-clipboard--read ()
  "Cached read with TTL to avoid hammering slow backends."
  (let ((now (float-time)))
    (if (and ck/wsl-clipboard--read-cache
             (< (- now (car ck/wsl-clipboard--read-cache))
                ck/wsl-clipboard-read-ttl))
        (cdr ck/wsl-clipboard--read-cache)
      (let ((value (ck/wsl-clipboard--read-raw)))
        (setq ck/wsl-clipboard--read-cache (cons now value))
        value))))

(defun ck/wsl-clipboard--write (text)
  "Push TEXT to the Windows clipboard via the first available backend."
  (catch 'done
    (dolist (cmd '(("wl-copy")
                   ("xclip" "-selection" "clipboard" "-i")
                   ("clip.exe")))
      (when (executable-find (car cmd))
        (when (ignore-errors
                (let ((proc (apply #'start-process "ck/wsl-clip" nil cmd)))
                  (process-send-string proc text)
                  (process-send-eof proc)
                  t))
          (throw 'done t))))
    nil))

(defun ck/wsl-clipboard-paste ()
  "Return current Windows clipboard text, or nil if unchanged or empty.
Strips CR so CRLF line endings paste as LF."
  (let ((raw (ck/wsl-clipboard--read)))
    (when (and raw (> (length raw) 0))
      (let ((clean (replace-regexp-in-string "\r" "" raw)))
        (unless (string-equal clean ck/wsl-clipboard--last)
          (setq ck/wsl-clipboard--last clean)
          clean)))))

(defun ck/wsl-clipboard-cut (text)
  "Send TEXT to the Windows clipboard."
  (setq ck/wsl-clipboard--last text
        ;; Invalidate read cache so an immediate paste reflects the write.
        ck/wsl-clipboard--read-cache nil)
  (ck/wsl-clipboard--write text))

(when (and ck/wsl-p (not (display-graphic-p)))
  (setq interprogram-paste-function #'ck/wsl-clipboard-paste
        interprogram-cut-function   #'ck/wsl-clipboard-cut
        select-enable-clipboard     t
        select-enable-primary       nil)
  ;; Ensure the terminal's bracketed-paste path is active so a multi-line
  ;; terminal paste arrives as a single event instead of one keystroke per
  ;; character (which would trip electric-pair-mode, auto-indent, etc.).
  ;; `xterm-mouse-mode' (already enabled in init.el) wires `xterm-paste';
  ;; we just make sure the OSC selection caps are declared.
  (setq xterm-extra-capabilities '(setSelection getSelection)))

(provide 'ck-wsl-clipboard)
;;; ck-wsl-clipboard.el ends here
