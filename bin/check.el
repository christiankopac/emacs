;;; check.el --- Smoke-test ck-system loads cleanly -*- lexical-binding: t -*-

(add-to-list 'load-path (expand-file-name "ck-emacs-modules"))
(require 'ck-system)
(message "ck-system loaded: %s / %s / display=%s"
         system-type ck/distro ck/display-server)
