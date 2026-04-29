;;; bbdb-site.el --- local shim for BBDB site vars -*- lexical-binding: t -*-

;; BBDB (from GNU ELPA / Nongnu) expects a `bbdb-site.el` to exist and be
;; `require`-able. When BBDB is installed via source-based package managers
;; (e.g. Elpaca), the upstream build step that generates `bbdb-site.el` from
;; `bbdb-site.el.in` may not run. This lightweight shim provides the minimum
;; definitions BBDB needs to load cleanly.

;;; Code:

(defconst bbdb-version "3.2.2d"
  "Version of BBDB.

This is used for reporting/debugging; BBDB also has an interactive `bbdb-version`
function that can derive the version from its sources.")

(defcustom bbdb-tex-path nil
  "List of directories with the BBDB TeX files.
If this is t assume that these files reside in directories that are part of the
regular TeX search path."
  :group 'bbdb-utilities-tex
  :type '(choice (const :tag "Files in TeX path" t)
                 (repeat (directory :tag "Directory"))))

(provide 'bbdb-site)

;;; bbdb-site.el ends here


