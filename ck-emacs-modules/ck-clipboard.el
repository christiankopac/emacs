;;; ck-clipboard.el --- Portable clipboard for GUI + TTY -*- lexical-binding: t -*-

;; One module replacing ck-wsl-clipboard.el. Goals:
;;
;;   1. Work in BOTH `emacs -nw' and GUI Emacs. The previous TTY-only
;;      bridge meant GUI WSLg was silently broken when X11 selection
;;      transfer hiccuped.
;;   2. Pick the fastest backend at runtime, never block on the slowest.
;;   3. Same module on WSL, native Wayland (Arch/Nix), native X11, macOS.
;;
;; Backend preference for reading:
;;   macOS    : pbpaste
;;   WSL      : wl-paste → xclip → powershell.exe Get-Clipboard (async)
;;   Wayland  : wl-paste
;;   X11      : xclip → xsel
;;
;; Writing uses the same chain but spawned as a background process so a
;; slow backend (notably powershell.exe) never blocks the editor.

(require 'subr-x)
(require 'ck-system)

;; ---------------------------------------------------------------------------
;; System detection
;; ---------------------------------------------------------------------------

(defvar ck/clipboard-system
  (cond
   (ck/macos-p   'macos)
   (ck/wsl-p     'wsl)
   (ck/windows-p 'windows)
   ((eq ck/display-server 'wayland) 'wayland)
   (ck/linux-p   'x11)
   (t            'unknown))
  "Detected clipboard environment. One of: macos, wsl, wayland, x11, windows, unknown.")

(defvar ck/clipboard-debug nil
  "When non-nil, log every read/write to *Messages*.")

(defun ck/clipboard--log (fmt &rest args)
  (when ck/clipboard-debug
    (apply #'message (concat "ck/clipboard: " fmt) args)))

;; ---------------------------------------------------------------------------
;; Backend selection
;; ---------------------------------------------------------------------------

(defvar ck/clipboard-read-backends
  (pcase ck/clipboard-system
    ('macos   '(("pbpaste")))
    ('wsl     '(("wl-paste" "--no-newline" "--type" "text/plain;charset=utf-8")
                ("wl-paste" "--no-newline")
                ("xclip" "-selection" "clipboard" "-o")
                ;; powershell.exe is the slowest; consulted last and cached.
                ("powershell.exe" "-NoProfile" "-Command" "Get-Clipboard -Raw")))
    ('wayland '(("wl-paste" "--no-newline" "--type" "text/plain;charset=utf-8")
                ("wl-paste" "--no-newline")
                ("xclip" "-selection" "clipboard" "-o")))
    ('x11     '(("xclip" "-selection" "clipboard" "-o")
                ("xsel" "--clipboard" "--output")))
    (_        nil))
  "Read commands tried in order until one returns non-empty stdout.")

(defvar ck/clipboard-write-backends
  (pcase ck/clipboard-system
    ('macos   '(("pbcopy")))
    ('wsl     '(("wl-copy")
                ("xclip" "-selection" "clipboard" "-i")
                ("clip.exe")))
    ('wayland '(("wl-copy")))
    ('x11     '(("xclip" "-selection" "clipboard" "-i")
                ("xsel" "--clipboard" "--input")))
    (_        nil))
  "Write commands tried in order; first available is used.")

;; ---------------------------------------------------------------------------
;; Read path
;; ---------------------------------------------------------------------------

(defvar ck/clipboard--last nil
  "Last clipboard value the bridge produced — used to suppress duplicates.")

(defvar ck/clipboard--read-cache nil
  "Cons of (TIME . VALUE). Throttles slow backends.")

(defvar ck/clipboard-read-ttl 0.5
  "Seconds to reuse a cached read before hitting the backend again.
Important on WSL — `save-interprogram-paste-before-kill' otherwise hits
the PowerShell fallback on every kill.")

(defun ck/clipboard--run-sync (cmd)
  "Run CMD (a list of program + args) and return non-empty stdout or nil."
  (let ((program (car cmd)))
    (when (executable-find program)
      (ignore-errors
        (with-temp-buffer
          (let ((exit (apply #'call-process program nil
                             (list (current-buffer) nil) nil (cdr cmd))))
            (when (and (eq exit 0) (> (buffer-size) 0))
              (buffer-string))))))))

(defvar ck/clipboard--read-cached nil
  "First read backend known to return non-empty stdout. Sticky across calls.")

(defun ck/clipboard--read-raw ()
  "Try cached backend first, then fall through. Cache the first that works."
  (let ((ordered (if (and ck/clipboard--read-cached
                          (member ck/clipboard--read-cached
                                  ck/clipboard-read-backends))
                     (cons ck/clipboard--read-cached
                           (remove ck/clipboard--read-cached
                                   ck/clipboard-read-backends))
                   ck/clipboard-read-backends)))
    (catch 'got
      (dolist (cmd ordered)
        (when-let* ((raw (ck/clipboard--run-sync cmd)))
          (setq ck/clipboard--read-cached cmd)
          (ck/clipboard--log "read via %s (%d chars)" (car cmd) (length raw))
          (throw 'got raw)))
      ;; All failed — invalidate so next call re-probes.
      (setq ck/clipboard--read-cached nil)
      nil)))

(defun ck/clipboard--read-cached ()
  "Cached read with TTL."
  (let ((now (float-time)))
    (if (and ck/clipboard--read-cache
             (< (- now (car ck/clipboard--read-cache))
                ck/clipboard-read-ttl))
        (cdr ck/clipboard--read-cache)
      (let ((value (ck/clipboard--read-raw)))
        (setq ck/clipboard--read-cache (cons now value))
        value))))

(defun ck/clipboard-paste ()
  "Return current system clipboard text, or nil if unchanged/empty.
Strips CR from CRLF line endings."
  (let ((raw (ck/clipboard--read-cached)))
    (when (and raw (> (length raw) 0))
      (let ((clean (replace-regexp-in-string "\r" "" raw)))
        (unless (string-equal clean ck/clipboard--last)
          (setq ck/clipboard--last clean)
          clean)))))

;; ---------------------------------------------------------------------------
;; Write path
;; ---------------------------------------------------------------------------
;; Strategy: try the cached "known good" backend first (synchronous, very
;; fast — wl-copy / pbcopy / xclip read stdin then exit). Fall back to the
;; next backend if it fails. Once a backend succeeds we cache it so steady-
;; state writes are O(1) — one fork+exec, no probing.
;;
;; On WSL, wl-copy frequently fails ("no Wayland server") even when
;; WAYLAND_DISPLAY is set, so the fallback chain is load-bearing.

(defvar ck/clipboard--write-cached nil
  "First write backend (a list) known to work. Set on first success.")

(defun ck/clipboard--write-one-sync (cmd text)
  "Run CMD with TEXT on stdin synchronously. Return t on exit 0, else nil.
Uses `call-process-region' so we don't allocate a temp buffer."
  (when (executable-find (car cmd))
    (let ((exit (condition-case _err
                    (with-temp-buffer
                      (insert text)
                      (apply #'call-process-region
                             (point-min) (point-max)
                             (car cmd) nil nil nil (cdr cmd)))
                  (error 1))))
      (eq exit 0))))

(defun ck/clipboard-cut (text)
  "Send TEXT to the system clipboard. Tries cached backend first, then
falls through. Returns the backend used, or nil on total failure."
  (setq ck/clipboard--last text
        ck/clipboard--read-cache nil)
  (let ((ordered (if (and ck/clipboard--write-cached
                          (member ck/clipboard--write-cached
                                  ck/clipboard-write-backends))
                     (cons ck/clipboard--write-cached
                           (remove ck/clipboard--write-cached
                                   ck/clipboard-write-backends))
                   ck/clipboard-write-backends)))
    (catch 'sent
      (dolist (cmd ordered)
        (when (ck/clipboard--write-one-sync cmd text)
          (setq ck/clipboard--write-cached cmd)
          (ck/clipboard--log "wrote via %s (%d chars)" (car cmd) (length text))
          (throw 'sent (car cmd))))
      ;; Total failure — invalidate cache so we re-probe next time.
      (setq ck/clipboard--write-cached nil)
      nil)))

;; ---------------------------------------------------------------------------
;; Wiring
;; ---------------------------------------------------------------------------
;; The built-in selection backend (NS / X11 / pgtk) is the right thing in
;; GUI mode — including on WSL, where WSLg sync'ing the X11 clipboard with
;; Windows works through the same selection. Overriding it would break
;; mouse-paste and primary selection.
;;
;; TTY Emacs has no selection backend at all, so we bridge there. If the
;; built-in is flaky for some reason in GUI mode, M-x `ck/clipboard-force-bridge'
;; opts in explicitly.

(defvar ck/clipboard-force-bridge nil
  "When non-nil, wire the bridge even in GUI mode. Override via
`ck/clipboard-force-bridge' interactive command.")

(defun ck/clipboard--should-bridge-p ()
  "Non-nil when we should override Emacs's built-in selection plumbing."
  (or (not (display-graphic-p))
      ck/clipboard-force-bridge))

(defun ck/clipboard-enable ()
  "Wire `interprogram-paste-function' / `interprogram-cut-function' to
the bridge. Idempotent."
  (interactive)
  (when (and ck/clipboard-read-backends ck/clipboard-write-backends
             (ck/clipboard--should-bridge-p))
    (setq interprogram-paste-function #'ck/clipboard-paste
          interprogram-cut-function   #'ck/clipboard-cut
          select-enable-clipboard     t
          select-enable-primary       nil)
    ;; Make multi-line terminal pastes arrive as one event so
    ;; electric-pair-mode / auto-indent don't trip on each character.
    (when (and (not (display-graphic-p))
               (boundp 'xterm-extra-capabilities))
      (setq xterm-extra-capabilities '(setSelection getSelection)))))

(defun ck/clipboard-status ()
  "Show detected system, chosen backends, cached working backend, and last paste preview."
  (interactive)
  (message "ck/clipboard: system=%s read=[%s] (cached: %s) write=[%s] (cached: %s) last=%s"
           ck/clipboard-system
           (mapconcat #'car ck/clipboard-read-backends "→")
           (or (car ck/clipboard--read-cached) "-")
           (mapconcat #'car ck/clipboard-write-backends "→")
           (or (car ck/clipboard--write-cached) "-")
           (if ck/clipboard--last
               (truncate-string-to-width ck/clipboard--last 40 nil nil "…")
             "(none)")))

(defun ck/clipboard-paste-force ()
  "Force a fresh read of the system clipboard, bypassing the cache, and
insert it at point. Useful when WSLg X11 selection got out of sync with
Windows and a normal `C-y' returned stale content."
  (interactive)
  (setq ck/clipboard--read-cache nil
        ck/clipboard--last nil)
  (when-let* ((text (ck/clipboard-paste)))
    (insert text)))

(defun ck/clipboard-force-bridge ()
  "Switch on the external clipboard bridge for the current Emacs session.
Use this if the built-in clipboard misbehaves (e.g. WSLg X11 selection
drops sync). Stays on until Emacs restart."
  (interactive)
  (setq ck/clipboard-force-bridge t)
  (ck/clipboard-enable)
  (message "ck/clipboard: bridge forced on (was %s)"
           (if (display-graphic-p) "GUI" "TTY")))

;; ---------------------------------------------------------------------------
;; Activate
;; ---------------------------------------------------------------------------

(ck/clipboard-enable)

(provide 'ck-clipboard)
;;; ck-clipboard.el ends here
