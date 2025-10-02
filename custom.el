;;; -*- lexical-binding: t -*-
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files
   '("/home/christian/Sync/org/gtd/inbox.org"      ;; unprocessed tasks
     "/home/christian/Sync/org/gtd/tasks.org"      ;; processed tasks -> actions/habits/projects/calendar
     "/home/christian/Sync/org/gtd/areas.org"      ;; areas of focus -> goals
     "/home/christian/Sync/org/gtd/horizons.org"   ;; horizons of focus -> vision
     "/home/christian/Sync/org/gtd/vision.org"))
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
 '(denote-faces-link ((t (:foreground "#8be9fd" :underline t))))
 '(jinx-misspelled ((t (:underline t :foreground nil))))
 '(org-document-info-keyword ((t (:underline nil))))
 '(org-modern-date-inactive ((t (:inherit org-modern-label :background "gray20" :foreground "gray70" :family "MonoLisa Nerd Font"))))
 '(outline-1 ((t (:weight bold :height 1.1))))
 '(xref-line-number ((t (:inherit line-number))))
 '(xref-match ((t (:inherit isearch)))))

;; Font overrides to force custom fonts regardless of theme
(custom-set-faces
 '(default ((t (:family "JuliaMono Nerd Font Mono"))))
 '(variable-pitch ((t (:family "ETBookOT"))))
 '(fixed-pitch ((t (:family "JuliaMono Nerd Font Mono")))))
