;;; music.el --- Music and multimedia configuration (EMMS & listen.el)
;;
;;;; Commentary:
;;;; Configuration for EMMS (Emacs Multimedia System) with MPD and listen.el
;;
;;;; Code:

;; ============================================================================
;; EMMS (Emacs Multimedia System) Configuration with MPD
;; ============================================================================

(with-eval-after-load 'emms
  ;; Setup EMMS with all features
  (require 'emms-setup)
  (emms-all)

  ;; Set music directory (must match MPD's music_directory)
  (setq emms-source-file-default-directory "/mnt/media/Music")

  ;; ---------------------------------------------------------------------------
  ;; MPD Configuration
  ;; ---------------------------------------------------------------------------
  (require 'emms-player-mpd)

  ;; MPD connection settings (matching your mpd.conf)
  (setq emms-player-mpd-server-name "localhost")
  (setq emms-player-mpd-server-port "6660")
  (setq emms-player-mpd-music-directory "/mnt/media/Music")

  ;; Use MPD as the primary player
  (setq emms-player-list '(emms-player-mpd))

  ;; Get track info from MPD
  (add-to-list 'emms-info-functions 'emms-info-mpd)

  ;; Update EMMS state when MPD status changes
  (add-to-list 'emms-player-started-hook 'emms-player-mpd-connect)

  ;; ---------------------------------------------------------------------------
  ;; Display Configuration
  ;; ---------------------------------------------------------------------------

  ;; Show track info in mode line
  (require 'emms-mode-line)
  (emms-mode-line 1)

  ;; Show current track time
  (require 'emms-playing-time)
  (emms-playing-time 1)

  ;; Enable playlist mode
  (require 'emms-playlist-mode)
  (setq emms-playlist-buffer-name "*EMMS Playlist*")

  ;; Browser configuration
  (when (require 'emms-browser nil t)
    (setq emms-browser-covers 'emms-browser-cache-thumbnail-async))

  ;; Cache for better performance
  (setq emms-cache-file (expand-file-name "emms-cache" user-emacs-directory))

  ;; ---------------------------------------------------------------------------
  ;; MPD Helper Functions
  ;; ---------------------------------------------------------------------------

  (defun my/emms-mpd-connect ()
    "Connect EMMS to MPD and sync the database."
    (interactive)
    (emms-player-mpd-connect)
    (message "Connected to MPD"))

  (defun my/emms-mpd-update-db ()
    "Update MPD database and sync with EMMS cache."
    (interactive)
    (emms-player-mpd-update-all)
    (message "Updating MPD database..."))

  (defun my/emms-mpd-sync-cache ()
    "Sync EMMS cache with MPD database."
    (interactive)
    (emms-cache-set-from-mpd-all)
    (message "Syncing EMMS cache from MPD..."))

  ;; ---------------------------------------------------------------------------
  ;; Playlist and Rating Functions
  ;; ---------------------------------------------------------------------------

  (defun my/mpd-get-current-file ()
    "Get the current playing file path from MPD."
    (let ((mpd-socket (expand-file-name "~/.config/mpd/socket")))
      (if (file-exists-p mpd-socket)
          (string-trim (shell-command-to-string
                        (format "mpc -h %s current -f '%%file%%'" mpd-socket)))
        (string-trim (shell-command-to-string
                      (format "mpc -h localhost -p %s current -f '%%file%%'"
                              emms-player-mpd-server-port))))))

  (defun my/mpd-get-full-file-path ()
    "Get the full file path of the currently playing song."
    (let ((relative-path (my/mpd-get-current-file)))
      (if (string-empty-p relative-path)
          nil
        (expand-file-name relative-path emms-player-mpd-music-directory))))

  (defun my/save-rating-to-file (file-path rating)
    "Save rating to file tags using kid3-cli, id3v2, or metaflac.
RATING should be 1-5. Returns t if successful, nil otherwise."
    (when (and file-path (file-exists-p file-path))
      (let ((ext (downcase (file-name-extension file-path))))
        (cond
         ;; Use kid3-cli for universal support (MP3, FLAC, OGG, etc.)
         ;; kid3-cli syntax: -c "set frame_name value" file
         ((executable-find "kid3-cli")
          (let ((command (format "kid3-cli -c \"set RATING %d\" \"%s\""
                                 rating (shell-quote-argument file-path))))
            (zerop (shell-command command))))
         ;; Fallback: id3v2 for MP3 files (POPM frame)
         ((and (string= ext "mp3") (executable-find "id3v2"))
          ;; Convert 1-5 rating to POPM frame (Windows Media Player standard)
          ;; Scale: 1=1, 2=64, 3=128, 4=196, 5=255
          (let ((popm-values '(1 64 128 196 255))
                (popm-value (nth (1- rating) popm-values))
                (command (format "id3v2 --POPM \"%s\" %d" 
                                 (shell-quote-argument file-path) popm-value)))
            (zerop (shell-command command))))
         ;; Fallback: metaflac for FLAC files
         ((and (string= ext "flac") (executable-find "metaflac"))
          (let ((command (format "metaflac --set-tag=\"RATING=%d\" \"%s\""
                                 rating (shell-quote-argument file-path))))
            (zerop (shell-command command))))
         (t nil)))))

  (defun my/read-music-groups ()
    "Read predefined music groups from config file.
Returns a list of group names (comments and empty lines filtered)."
    (let ((groups-file (expand-file-name "ck-emacs-modules/music-groups.txt" user-emacs-directory)))
      (if (file-exists-p groups-file)
          (with-temp-buffer
            (insert-file-contents groups-file)
            (delete-matching-lines "^#")
            (delete-matching-lines "^$")
            (split-string (buffer-string) "\n" t))
        (user-error "Music groups file not found: %s" groups-file))))

  (defun my/save-grouping-to-file (file-path grouping)
    "Save grouping to file tags using kid3-cli, id3v2, or metaflac.
Returns t if successful, nil otherwise."
    (when (and file-path (file-exists-p file-path))
      (let ((ext (downcase (file-name-extension file-path))))
        (cond
         ;; Use kid3-cli for universal support
         ((executable-find "kid3-cli")
          (let ((command (format "kid3-cli -c \"set GROUPING %s\" \"%s\""
                                 grouping (shell-quote-argument file-path))))
            (zerop (shell-command command))))
         ;; Fallback: id3v2 for MP3 files (TXXX frame for custom tags)
         ((and (string= ext "mp3") (executable-find "id3v2"))
          (let ((command (format "id3v2 --TXXX \"GROUPING:%s\" \"%s\""
                                 grouping (shell-quote-argument file-path))))
            (zerop (shell-command command))))
         ;; Fallback: metaflac for FLAC files
         ((and (string= ext "flac") (executable-find "metaflac"))
          (let ((command (format "metaflac --set-tag=\"GROUPING=%s\" \"%s\""
                                 grouping (shell-quote-argument file-path))))
            (zerop (shell-command command))))
         (t nil)))))

  (defun my/mpd-set-grouping (grouping)
    "Set grouping for currently playing song.
GROUPING should be a string from the predefined list."
    (interactive
     (list (completing-read "Select grouping: " (my/read-music-groups)
                            nil t)))
    (let* ((current-file (my/mpd-get-current-file))
           (full-path (my/mpd-get-full-file-path))
           (mpd-socket (expand-file-name "~/.config/mpd/socket")))
      (if (string-empty-p current-file)
          (message "No song is currently playing")
        ;; Save to MPD sticker
        (let ((sticker-cmd (if (file-exists-p mpd-socket)
                               (format "mpc -h %s sticker \"%s\" set grouping %s"
                                       mpd-socket current-file grouping)
                             (format "mpc -h localhost -p %s sticker \"%s\" set grouping %s"
                                     emms-player-mpd-server-port current-file grouping))))
          (shell-command sticker-cmd))
        ;; Save to file tags
        (if (my/save-grouping-to-file full-path grouping)
            (message "Set grouping to: %s (saved to MPD sticker and file tags)" grouping)
          (message "Set grouping to: %s (saved to MPD sticker; file tags may not be supported for this format)" grouping)))))

  (defun my/mpd-add-to-monthly-picks ()
    "Add currently playing song to monthly picks playlist (format: YYYYMM-picks)."
    (interactive)
    (let* ((current-file (my/mpd-get-current-file))
           (playlist-name (format-time-string "%Y%m-picks"))
           (mpd-socket (expand-file-name "~/.config/mpd/socket")))
      (if (string-empty-p current-file)
          (message "No song is currently playing")
        (let ((command (if (file-exists-p mpd-socket)
                           (format "mpc -h %s add \"%s\" && mpc -h %s save \"%s\""
                                   mpd-socket current-file mpd-socket playlist-name)
                         (format "mpc -h localhost -p %s add \"%s\" && mpc -h localhost -p %s save \"%s\""
                                 emms-player-mpd-server-port current-file
                                 emms-player-mpd-server-port playlist-name))))
          (shell-command command)
          (message "Added to playlist: %s" playlist-name)))))

  (defun my/mpd-set-rating (rating)
    "Set rating (1-5) for currently playing song.
Saves to both MPD stickers and file tags."
    (interactive "nRating (1-5): ")
    (unless (and (>= rating 1) (<= rating 5))
      (user-error "Rating must be between 1 and 5"))
    (let* ((current-file (my/mpd-get-current-file))
           (full-path (my/mpd-get-full-file-path))
           (mpd-socket (expand-file-name "~/.config/mpd/socket")))
      (if (string-empty-p current-file)
          (message "No song is currently playing")
        ;; Save to MPD sticker
        (let ((sticker-cmd (if (file-exists-p mpd-socket)
                               (format "mpc -h %s sticker \"%s\" set rating %d"
                                       mpd-socket current-file rating)
                             (format "mpc -h localhost -p %s sticker \"%s\" set rating %d"
                                     emms-player-mpd-server-port current-file rating))))
          (shell-command sticker-cmd))
        ;; Save to file tags
        (if (my/save-rating-to-file full-path rating)
            (message "Set rating to %d/5 (saved to MPD sticker and file tags)" rating)
          (message "Set rating to %d/5 (saved to MPD sticker; file tags may not be supported for this format)" rating)))))

  (defun my/mpd-add-to-rating-playlist (rating)
    "Add currently playing song to rating-based playlist (rating-1, rating-2, etc.)."
    (interactive "nRating (1-5): ")
    (unless (and (>= rating 1) (<= rating 5))
      (user-error "Rating must be between 1 and 5"))
    (let* ((current-file (my/mpd-get-current-file))
           (playlist-name (format "rating-%d" rating))
           (mpd-socket (expand-file-name "~/.config/mpd/socket")))
      (if (string-empty-p current-file)
          (message "No song is currently playing")
        (let ((command (if (file-exists-p mpd-socket)
                           (format "mpc -h %s add \"%s\" && mpc -h %s save \"%s\""
                                   mpd-socket current-file mpd-socket playlist-name)
                         (format "mpc -h localhost -p %s add \"%s\" && mpc -h localhost -p %s save \"%s\""
                                 emms-player-mpd-server-port current-file
                                 emms-player-mpd-server-port playlist-name))))
          (shell-command command)
          (message "Added to playlist: %s" playlist-name)))))

  ;; Quick rating functions (1-5)
  (defun my/mpd-rate-1 () (interactive) (my/mpd-set-rating 1))
  (defun my/mpd-rate-2 () (interactive) (my/mpd-set-rating 2))
  (defun my/mpd-rate-3 () (interactive) (my/mpd-set-rating 3))
  (defun my/mpd-rate-4 () (interactive) (my/mpd-set-rating 4))
  (defun my/mpd-rate-5 () (interactive) (my/mpd-set-rating 5))

  ;; Quick add to rating playlist functions (1-5)
  (defun my/mpd-add-to-rating-1 () (interactive) (my/mpd-add-to-rating-playlist 1))
  (defun my/mpd-add-to-rating-2 () (interactive) (my/mpd-add-to-rating-playlist 2))
  (defun my/mpd-add-to-rating-3 () (interactive) (my/mpd-add-to-rating-playlist 3))
  (defun my/mpd-add-to-rating-4 () (interactive) (my/mpd-add-to-rating-playlist 4))
  (defun my/mpd-add-to-rating-5 () (interactive) (my/mpd-add-to-rating-playlist 5))

  ;; ---------------------------------------------------------------------------
  ;; Keybindings
  ;; ---------------------------------------------------------------------------

  ;; Playback controls
  (global-set-key (kbd "C-c m p") 'emms-pause)
  (global-set-key (kbd "C-c m n") 'emms-next)
  (global-set-key (kbd "C-c m b") 'emms-previous)
  (global-set-key (kbd "C-c m s") 'emms-stop)
  (global-set-key (kbd "C-c m SPC") 'emms-pause)

  ;; Playlist/Browser
  (global-set-key (kbd "C-c m l") 'emms-playlist-mode-go)
  (global-set-key (kbd "C-c m r") 'emms-browser)
  (global-set-key (kbd "C-c m a") 'emms-add-directory-tree)

  ;; MPD specific
  (global-set-key (kbd "C-c m c") 'my/emms-mpd-connect)
  (global-set-key (kbd "C-c m u") 'my/emms-mpd-update-db)
  (global-set-key (kbd "C-c m y") 'my/emms-mpd-sync-cache)

  ;; Volume controls (if MPD handles volume)
  (global-set-key (kbd "C-c m +") 'emms-volume-raise)
  (global-set-key (kbd "C-c m -") 'emms-volume-lower)

  ;; Playlist and rating controls
  (global-set-key (kbd "C-c m P") 'my/mpd-add-to-monthly-picks)
  (global-set-key (kbd "C-c m 1") 'my/mpd-rate-1)
  (global-set-key (kbd "C-c m 2") 'my/mpd-rate-2)
  (global-set-key (kbd "C-c m 3") 'my/mpd-rate-3)
  (global-set-key (kbd "C-c m 4") 'my/mpd-rate-4)
  (global-set-key (kbd "C-c m 5") 'my/mpd-rate-5)
  (global-set-key (kbd "C-c m M-1") 'my/mpd-add-to-rating-1)
  (global-set-key (kbd "C-c m M-2") 'my/mpd-add-to-rating-2)
  (global-set-key (kbd "C-c m M-3") 'my/mpd-add-to-rating-3)
  (global-set-key (kbd "C-c m M-4") 'my/mpd-add-to-rating-4)
  (global-set-key (kbd "C-c m M-5") 'my/mpd-add-to-rating-5)
  (global-set-key (kbd "C-c m g") 'my/mpd-set-grouping))

;; ============================================================================
;; listen.el Configuration
;; ============================================================================

(with-eval-after-load 'listen
  ;; Set music directory
  (setq listen-music-directory "/mnt/media/Music")

  ;; Keybindings
  (global-set-key (kbd "C-c m m") 'listen))

(provide 'ck-music)
;;; music.el ends here
