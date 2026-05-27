;;; compile.el --- Byte-compile ck-emacs-modules + ck-lisp -*- lexical-binding: t -*-

(setq byte-compile-warnings t)

(let ((modules-dir (expand-file-name "ck-emacs-modules"))
      (lisp-dir    (expand-file-name "ck-lisp"))
      (elpaca-builds (expand-file-name "~/.emacs.d/elpaca/builds")))
  (add-to-list 'load-path modules-dir)
  (add-to-list 'load-path lisp-dir)
  (when (file-directory-p elpaca-builds)
    (dolist (d (directory-files elpaca-builds t "^[^.]"))
      (when (file-directory-p d)
        (add-to-list 'load-path d))))
  (byte-recompile-directory modules-dir 0 t)
  (byte-recompile-directory lisp-dir 0 t))
