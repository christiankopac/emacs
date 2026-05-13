;;; ck-org-graphs.el --- Gnuplot graphs over org/gtd + journal -*- lexical-binding: t; -*-

;; Generates an org file with named tables + gnuplot src blocks. Open it,
;; then C-c C-v C-b (org-babel-execute-buffer) to render all graphs inline,
;; or C-c C-c on a single block.

;;; Code:

(require 'cl-lib)
(require 'subr-x)

(defgroup ck-org-graphs nil
  "Gnuplot graphs over org files."
  :group 'org)

(defcustom ck-org-graphs-dirs '("~/org/gtd" "~/org/journal")
  "Directories scanned recursively for .org/.org_archive files."
  :type '(repeat directory)
  :group 'ck-org-graphs)

(defcustom ck-org-graphs-output-file "~/org/org-graphs.org"
  "Where the generated graphs org file is written."
  :type 'file
  :group 'ck-org-graphs)

(defcustom ck-org-graphs-open-states
  '("TODO" "NEXT" "IN_PROGRESS" "WAIT" "REVIEW" "TEST")
  "Heading states considered open/in-flight."
  :type '(repeat string)
  :group 'ck-org-graphs)

(defcustom ck-org-graphs-closed-states '("DONE" "CNCL")
  "Heading states considered terminal."
  :type '(repeat string)
  :group 'ck-org-graphs)

;;;; Internal helpers

(defun ck-org-graphs--files ()
  "All org/org_archive files under `ck-org-graphs-dirs'."
  (cl-loop for d in ck-org-graphs-dirs
           for dir = (expand-file-name d)
           when (file-directory-p dir)
           append (directory-files-recursively
                   dir "\\.\\(org\\|org_archive\\)\\'")))

(defun ck-org-graphs--iso-week (date-string)
  "Convert YYYY-MM-DD to ISO YYYY-Www."
  (when (and date-string
             (string-match "\\`\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)"
                           date-string))
    (let ((y (string-to-number (match-string 1 date-string)))
          (m (string-to-number (match-string 2 date-string)))
          (d (string-to-number (match-string 3 date-string))))
      (format-time-string "%G-W%V" (encode-time 0 0 12 d m y)))))

(defun ck-org-graphs--scan-dates (regex)
  "Collect group 1 of REGEX (a YYYY-MM-DD) across all data files."
  (let (results)
    (dolist (f (ck-org-graphs--files))
      (with-temp-buffer
        (insert-file-contents f)
        (goto-char (point-min))
        (while (re-search-forward regex nil t)
          (push (match-string-no-properties 1) results))))
    results))

(defun ck-org-graphs--bucket-by-week (date-strings)
  "Return sorted alist (week . count) for DATE-STRINGS (YYYY-MM-DD)."
  (let ((h (make-hash-table :test 'equal)))
    (dolist (d date-strings)
      (when-let ((w (ck-org-graphs--iso-week d)))
        (puthash w (1+ (gethash w h 0)) h)))
    (cl-sort (cl-loop for k being the hash-keys of h using (hash-value v)
                      collect (cons k v))
             #'string< :key #'car)))

(defun ck-org-graphs--state-regex ()
  (concat "^\\*+ +\\("
          (mapconcat #'regexp-quote ck-org-graphs-open-states "\\|")
          "\\)\\b"))

;;;; Datasets

(defun ck-org-graphs--closes ()
  "Alist of (iso-week . count) of CLOSED timestamps."
  (ck-org-graphs--bucket-by-week
   (ck-org-graphs--scan-dates
    "^[ \t]*CLOSED:[ \t]*\\[\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)")))

(defun ck-org-graphs--captures ()
  "Alist of (iso-week . count) of capture timestamps.
A capture is an inactive bracket timestamp on its own line, which is
the default org-capture footer."
  (ck-org-graphs--bucket-by-week
   (ck-org-graphs--scan-dates
    "^[ \t]*\\[\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)[^]\n]*\\][ \t]*$")))

(defun ck-org-graphs--weekday-counts ()
  "Alist (weekday . count) of CLOSED timestamps, Mon..Sun order."
  (let ((dates (ck-org-graphs--scan-dates
                "^[ \t]*CLOSED:[ \t]*\\[\\([0-9]\\{4\\}-[0-9]\\{2\\}-[0-9]\\{2\\}\\)"))
        (h (make-hash-table :test 'equal))
        (order '("Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun")))
    (dolist (d dates)
      (when (string-match "\\`\\([0-9]\\{4\\}\\)-\\([0-9]\\{2\\}\\)-\\([0-9]\\{2\\}\\)" d)
        (let* ((y (string-to-number (match-string 1 d)))
               (m (string-to-number (match-string 2 d)))
               (day (string-to-number (match-string 3 d)))
               ;; %a is locale-dependent; force C locale via abbreviated names.
               (dow (nth (string-to-number
                          (format-time-string "%u" (encode-time 0 0 12 day m y)))
                         '(nil "Mon" "Tue" "Wed" "Thu" "Fri" "Sat" "Sun"))))
          (puthash dow (1+ (gethash dow h 0)) h))))
    (cl-loop for d in order
             for n = (gethash d h 0)
             collect (cons d n))))

(defun ck-org-graphs--tag-counts-for-states (states)
  "Alist (tag . count) of :@context: tags on headings whose state is in STATES."
  (let ((re (concat "^\\*+ +\\("
                    (mapconcat #'regexp-quote states "\\|")
                    "\\)\\b"))
        (h (make-hash-table :test 'equal)))
    (dolist (f (ck-org-graphs--files))
      (with-temp-buffer
        (insert-file-contents f)
        (goto-char (point-min))
        (while (re-search-forward re nil t)
          (let ((eol (line-end-position)))
            (save-excursion
              (beginning-of-line)
              (when (re-search-forward
                     "[ \t]\\(:\\(?:[A-Za-z0-9_@-]+:\\)+\\)[ \t]*$" eol t)
                (dolist (tag (split-string (match-string-no-properties 1) ":" t))
                  (when (string-prefix-p "@" tag)
                    (puthash tag (1+ (gethash tag h 0)) h)))))))))
    h))

(defun ck-org-graphs--tag-open-vs-closed ()
  "Sorted list of (tag open closed) across all known @-tags."
  (let* ((open (ck-org-graphs--tag-counts-for-states ck-org-graphs-open-states))
         (closed (ck-org-graphs--tag-counts-for-states ck-org-graphs-closed-states))
         (keys (delete-dups
                (append (hash-table-keys open) (hash-table-keys closed)))))
    (cl-sort (cl-loop for k in keys
                      collect (list k
                                    (gethash k open 0)
                                    (gethash k closed 0)))
             #'> :key (lambda (row) (+ (nth 1 row) (nth 2 row))))))

(defun ck-org-graphs--state-counts ()
  "Alist (state . count) for currently-open heading states."
  (let ((re (ck-org-graphs--state-regex))
        (h (make-hash-table :test 'equal)))
    (dolist (f (ck-org-graphs--files))
      (with-temp-buffer
        (insert-file-contents f)
        (goto-char (point-min))
        (while (re-search-forward re nil t)
          (let ((s (match-string-no-properties 1)))
            (puthash s (1+ (gethash s h 0)) h)))))
    ;; Preserve canonical order from ck-org-graphs-open-states
    (cl-loop for s in ck-org-graphs-open-states
             for n = (gethash s h 0)
             when (> n 0)
             collect (cons s n))))

(defun ck-org-graphs--tag-counts ()
  "Alist (tag . count) of :@context: tags on currently-open headings."
  (let ((h (ck-org-graphs--tag-counts-for-states ck-org-graphs-open-states)))
    (cl-sort (cl-loop for k being the hash-keys of h using (hash-value v)
                      collect (cons k v))
             #'> :key #'cdr)))

;;;; Org file generation

(defun ck-org-graphs--insert-table (name headers rows)
  "Insert a named org table. ROWS may be cons cells (a . b) or lists (a b c ...)."
  (insert (format "#+NAME: %s\n" name))
  (insert "| " (mapconcat #'identity headers " | ") " |\n")
  (insert "|-\n")
  (if rows
      (dolist (r rows)
        (insert "| ")
        (insert (mapconcat (lambda (x) (format "%s" x))
                           (if (consp (cdr r)) r (list (car r) (cdr r)))
                           " | "))
        (insert " |\n"))
    (insert "| (no data) "
            (apply #'concat (make-list (1- (length headers)) "| 0 "))
            "|\n"))
  (insert "\n"))

(defun ck-org-graphs--insert-weekly-block (title table-name out-png)
  (insert (format "#+begin_src gnuplot :var data=%s :file %s :exports results
reset
set terminal pngcairo size 1100,420 enhanced font 'sans,10'
set title \"%s\" font 'sans,12'
set grid ytics lc rgb '#dddddd'
set border 3
set tics nomirror
set xtics rotate by -45 right font 'sans,8'
set style data histograms
set style histogram cluster gap 1
set style fill solid 0.85 border -1
set boxwidth 0.8
unset key
plot data using 2:xtic(1) lc rgb '#4a90e2'
#+end_src

" table-name out-png title)))

(defun ck-org-graphs--insert-bar-block (title table-name out-png color)
  (insert (format "#+begin_src gnuplot :var data=%s :file %s :exports results
reset
set terminal pngcairo size 900,420 enhanced font 'sans,10'
set title \"%s\" font 'sans,12'
set grid ytics lc rgb '#dddddd'
set border 3
set tics nomirror
set xtics font 'sans,9'
set style data histograms
set style fill solid 0.85 border -1
set boxwidth 0.6
unset key
plot data using 2:xtic(1) lc rgb '%s'
#+end_src

" table-name out-png title color)))

(defun ck-org-graphs--insert-grouped-bar-block (title table-name out-png)
  "Grouped histogram from a 3-column table (label, A, B)."
  (insert (format "#+begin_src gnuplot :var data=%s :file %s :exports results
reset
set terminal pngcairo size 1100,420 enhanced font 'sans,10'
set title \"%s\" font 'sans,12'
set grid ytics lc rgb '#dddddd'
set border 3
set tics nomirror
set xtics font 'sans,9'
set style data histograms
set style histogram cluster gap 1
set style fill solid 0.85 border -1
set boxwidth 0.9
set key top right
plot data using 2:xtic(1) lc rgb '#e07b3a' title 'open', \\
     ''   using 3        lc rgb '#4a90e2' title 'closed'
#+end_src

" table-name out-png title)))

(defun ck-org-graphs--insert-two-line-block (title closes-name captures-name out-png)
  (insert (format "#+begin_src gnuplot :var closes=%s :var captures=%s :file %s :exports results
reset
set terminal pngcairo size 1100,420 enhanced font 'sans,10'
set title \"%s\" font 'sans,12'
set grid ytics lc rgb '#dddddd'
set border 3
set tics nomirror
set xtics rotate by -45 right font 'sans,8'
set key top left
set style data linespoints
plot captures using 2:xtic(1) lw 2 lc rgb '#e07b3a' title 'captured', \\
     closes   using 2:xtic(1) lw 2 lc rgb '#4a90e2' title 'closed'
#+end_src

" closes-name captures-name out-png title)))

;;;###autoload
(defun ck-org-graphs-generate ()
  "Build the graphs org file and open it.
After it opens: \\<org-mode-map>\\[org-babel-execute-buffer] runs all blocks,
\\[org-toggle-inline-images] toggles inline preview."
  (interactive)
  (let* ((file (expand-file-name ck-org-graphs-output-file))
         (closes (ck-org-graphs--closes))
         (captures (ck-org-graphs--captures))
         (states (ck-org-graphs--state-counts))
         (tags (ck-org-graphs--tag-counts))
         (weekdays (ck-org-graphs--weekday-counts))
         (tag-rate (ck-org-graphs--tag-open-vs-closed)))
    (with-temp-file file
      (insert "#+TITLE: Org Productivity Graphs\n")
      (insert "#+OPTIONS: toc:nil num:nil\n")
      (insert "#+PROPERTY: header-args:gnuplot :exports results\n\n")
      (insert (format "Generated %s from %s.\n\n"
                      (format-time-string "%Y-%m-%d %H:%M")
                      (mapconcat (lambda (d) (concat "~" (file-name-nondirectory
                                                          (directory-file-name
                                                           (expand-file-name d)))))
                                 ck-org-graphs-dirs ", ")))
      (insert "Run =M-x org-babel-execute-buffer= (=C-c C-v C-b=) to render every block,\n")
      (insert "then =M-x org-toggle-inline-images= (=C-c C-x C-v=) to view.\n\n")

      (insert "* Tasks closed per week\n")
      (ck-org-graphs--insert-table "closes-table" '("week" "count") closes)
      (ck-org-graphs--insert-weekly-block
       "Tasks closed per ISO week" "closes-table" "/tmp/ck-graphs-closes.png")

      (insert "* TODO state distribution\n")
      (ck-org-graphs--insert-table "states-table" '("state" "count") states)
      (ck-org-graphs--insert-bar-block
       "Open tasks by state" "states-table" "/tmp/ck-graphs-states.png" "#7b5ea8")

      (insert "* Open tasks by context tag\n")
      (ck-org-graphs--insert-table "tags-table" '("tag" "count") tags)
      (ck-org-graphs--insert-bar-block
       "Open tasks by context" "tags-table" "/tmp/ck-graphs-tags.png" "#3aa17b")

      (insert "* Activity by weekday\n")
      (ck-org-graphs--insert-table "weekday-table" '("day" "count") weekdays)
      (ck-org-graphs--insert-bar-block
       "Closes by day of week" "weekday-table" "/tmp/ck-graphs-weekday.png" "#c9477e")

      (insert "* Per-tag close rate (open vs closed)\n")
      (ck-org-graphs--insert-table "tag-rate-table" '("tag" "open" "closed") tag-rate)
      (ck-org-graphs--insert-grouped-bar-block
       "Open vs closed tasks by context tag"
       "tag-rate-table" "/tmp/ck-graphs-tag-rate.png")

      (insert "* Inbox burn: captured vs closed per week\n")
      (ck-org-graphs--insert-table "captures-table" '("week" "count") captures)
      (ck-org-graphs--insert-table "closes-table-2" '("week" "count") closes)
      (ck-org-graphs--insert-two-line-block
       "Weekly captures vs closes"
       "closes-table-2" "captures-table"
       "/tmp/ck-graphs-burn.png"))
    (find-file file)
    (when (and (derived-mode-p 'org-mode) (fboundp 'org-display-inline-images))
      (org-display-inline-images))
    (message "ck-org-graphs: wrote %s. C-c C-v C-b to render all blocks." file)))

;;;; Babel wiring (gnuplot needs to be enabled for src blocks to execute)

;; ob-gnuplot in Emacs 30 unconditionally `org-require-package's the `gnuplot'
;; ELPA package even when :session is "none" (where we only shell out to the
;; gnuplot binary). And some old versions of that package use bare `incf' from
;; the deprecated `cl' library, which is no longer autoloaded — yielding
;; "invalid function: incf" at runtime. Provide the alias defensively.
(unless (fboundp 'incf)
  (require 'cl-lib)
  (defalias 'incf 'cl-incf))

(with-eval-after-load 'org
  (require 'ob-gnuplot nil t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   (append (or (and (boundp 'org-babel-load-languages) org-babel-load-languages) nil)
           '((gnuplot . t)))))

(provide 'ck-org-graphs)
;;; ck-org-graphs.el ends here
