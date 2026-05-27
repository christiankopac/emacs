;;; ck-system.el --- OS + display-server detection -*- lexical-binding: t -*-

;; Single source of truth for "what kind of machine is this Emacs running
;; on." Used by ck-clipboard, ck-fonts, ck-file-associations, ck-email.
;;
;; Why one module: the previous config detected WSL in 4+ separate
;; places (`ck/wsl-p`, `my/wsl-p`, `getenv "WSL_DISTRO_NAME"` inline,
;; `clipetty :unless ...`). When the rule needed to change (e.g. "treat
;; WSL GUI like WSL TTY for clipboard") it had to be edited in each
;; place, and they drifted.

;; ---------------------------------------------------------------------------
;; Platform
;; ---------------------------------------------------------------------------

(defvar ck/macos-p (eq system-type 'darwin)
  "Running on macOS.")

(defvar ck/linux-p (eq system-type 'gnu/linux)
  "Running on a GNU/Linux kernel (includes WSL).")

(defvar ck/windows-p (eq system-type 'windows-nt)
  "Running on native Windows (NOT WSL).")

(defvar ck/wsl-p
  (and ck/linux-p (getenv "WSL_DISTRO_NAME"))
  "Running under WSL (Windows Subsystem for Linux).")

;; ---------------------------------------------------------------------------
;; Distro detection (only meaningful on Linux/WSL)
;; ---------------------------------------------------------------------------

(defvar ck/distro
  (when ck/linux-p
    (cond
     ;; Nix is identified by /etc/NIXOS or NixOS in os-release; both work
     ;; even on non-NixOS systems where home-manager owns the user env.
     ((or (file-exists-p "/etc/NIXOS")
          (and (file-readable-p "/etc/os-release")
               (with-temp-buffer
                 (insert-file-contents "/etc/os-release")
                 (re-search-forward "^ID=nixos" nil t))))
      'nixos)
     ((file-exists-p "/etc/arch-release") 'arch)
     ((file-exists-p "/etc/debian_version") 'debian)
     ((file-exists-p "/etc/fedora-release") 'fedora)
     (t 'unknown)))
  "Linux distribution: nixos, arch, debian, fedora, or unknown.")

(defvar ck/nix-active-p
  (or (eq ck/distro 'nixos)
      (and (getenv "PATH")
           (string-match-p "/nix/" (getenv "PATH"))))
  "Non-nil if Nix is supplying packages (NixOS or nix-env/home-manager).")

;; ---------------------------------------------------------------------------
;; Display server (only meaningful in GUI mode)
;; ---------------------------------------------------------------------------

(defvar ck/display-server
  (cond
   ((not (display-graphic-p)) 'tty)
   (ck/macos-p                'ns)
   (ck/windows-p              'w32)
   (ck/wsl-p                  'wslg)        ; X11 or pgtk under WSLg
   ((getenv "WAYLAND_DISPLAY") 'wayland)
   ((getenv "DISPLAY")         'x11)
   (t                          'unknown))
  "Display server in use: tty, ns, w32, wslg, wayland, x11, unknown.")

;; ---------------------------------------------------------------------------
;; Convenience predicates
;; ---------------------------------------------------------------------------

(defun ck/has? (program)
  "Return PROGRAM path if executable, else nil. Memoizes per session.
Use this instead of `executable-find' in hot paths."
  (let ((cache (or (get 'ck/has? 'cache)
                   (let ((h (make-hash-table :test #'equal :size 64)))
                     (put 'ck/has? 'cache h)
                     h))))
    (let ((cached (gethash program cache 'unset)))
      (if (eq cached 'unset)
          (let ((found (executable-find program)))
            (puthash program found cache)
            found)
        cached))))

(defun ck/has-any (&rest programs)
  "Return the first executable PROGRAM found, or nil."
  (seq-find #'ck/has? programs))

(defun ck/open-command ()
  "Return the platform-appropriate \"open this file/URL\" command, or nil."
  (cond
   (ck/macos-p   (ck/has? "open"))
   (ck/wsl-p     (or (ck/has? "wslview") (ck/has? "xdg-open")))
   (ck/linux-p   (ck/has? "xdg-open"))
   (ck/windows-p "start")
   (t            nil)))

(defun ck/system-status ()
  "Echo the detected system info — useful when debugging portability."
  (interactive)
  (message "ck: %s/%s display=%s nix=%s open=%s"
           system-type
           (or ck/distro "n/a")
           ck/display-server
           (if ck/nix-active-p "yes" "no")
           (or (ck/open-command) "(none)")))

(provide 'ck-system)
;;; ck-system.el ends here
