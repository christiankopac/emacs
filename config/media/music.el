;;; music.el --- Music and multimedia configuration (EMMS & listen.el)
;;
;;;; Commentary:
;;;; Configuration for EMMS (Emacs Multimedia System) and listen.el
;;
;;;; Code:

;; ============================================================================
;; EMMS (Emacs Multimedia System) Configuration
;; ============================================================================

(with-eval-after-load 'emms
  ;; Setup EMMS with all features
  (require 'emms-setup)
  (emms-all)
  (emms-default-players)

  ;; Set music directory
  (setq emms-source-file-default-directory "/mnt/media/Music")

  ;; Player configuration - prefer mpv if available, fallback to others
  (setq emms-player-list '(emms-player-mpv
                           emms-player-vlc
                           emms-player-mplayer))

  ;; Show track info in mode line
  (require 'emms-mode-line)
  (emms-mode-line 1)

  ;; Show current track time
  (require 'emms-playing-time)
  (emms-playing-time 1)

  ;; Enable playlist mode
  (require 'emms-playlist-mode)
  (setq emms-playlist-buffer-name "*EMMS Playlist*")

  ;; Enable track info display
  (require 'emms-info)
  (setq emms-info-functions '(emms-info-tinytag))

  ;; Browser configuration
  (when (require 'emms-browser nil t)
    (setq emms-browser-covers 'emms-browser-cache-thumbnail-async))

  ;; Cache for better performance
  (setq emms-cache-file (expand-file-name "emms-cache" user-emacs-directory))
  
  ;; Keybindings
  (global-set-key (kbd "C-c m p") 'emms-pause)
  (global-set-key (kbd "C-c m n") 'emms-next)
  (global-set-key (kbd "C-c m b") 'emms-previous)
  (global-set-key (kbd "C-c m s") 'emms-stop)
  (global-set-key (kbd "C-c m a") 'emms-add-directory-tree)
  (global-set-key (kbd "C-c m l") 'emms-playlist-mode-go)
  (global-set-key (kbd "C-c m r") 'emms-browser))

;; ============================================================================
;; listen.el Configuration
;; ============================================================================

(with-eval-after-load 'listen
  ;; Set music directory
  (setq listen-music-directory "/mnt/media/Music")

  ;; Keybindings
  (global-set-key (kbd "C-c m m") 'listen))

(provide 'music)
;;; music.el ends here

