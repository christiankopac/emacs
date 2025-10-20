;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("2d035eb93f92384d11f18ed00930e5cc9964281915689fa035719cab71766a15" default))
 '(denote-dired-directories-include-subdirectories t)
 '(org-agenda-files
   '("/home/christian/notes/org/gtd/inbox.org"
     "/home/christian/notes/org/gtd/tasks.org"
     "/home/christian/notes/org/gtd/areas.org"
     "/home/christian/notes/org/gtd/horizons.org"
     "/home/christian/notes/org/gtd/vision.org"))
 '(package-selected-packages '(copilot everforest-theme))
 '(package-vc-selected-packages
   '((copilot :url "https://github.com/copilot-emacs/copilot.el" :branch "main")
     (everforest-theme :url
                       "https://github.com/Theory-of-Everything/everforest-emacs.git")))
 '(warning-suppress-log-types
   '((native-compiler) (native-compiler) (native-compiler) (native-compiler)
     (copilot copilot-no-mode-indent))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "JuliaMono Nerd Font Mono"))))
 '(denote-faces-link ((t (:foreground "#8be9fd" :underline t))))
 '(fixed-pitch ((t (:family "JuliaMono Nerd Font Mono"))))
 '(jinx-misspelled ((t (:underline t :foreground nil))))
 '(org-document-info-keyword ((t (:underline nil))))
 '(org-modern-date-inactive ((t (:inherit org-modern-label :background "gray20" :foreground "gray70" :family "MonoLisa Nerd Font"))))
 '(outline-1 ((t (:weight bold :height 1.1))))
 '(variable-pitch ((t (:family "ETBookOT"))))
 '(xref-line-number ((t (:inherit line-number))))
 '(xref-match ((t (:inherit isearch)))))

;; Font overrides to force custom fonts regardless of theme

