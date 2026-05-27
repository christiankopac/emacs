# Optional byte-compile of ck-emacs-modules and ck-lisp.
#
# `make compile' is normally not needed — the .el files load fine via
# `require'. Compiling once turns each `(require 'ck-XXX)' into an .elc
# load (~3x faster parse) and lets native-comp produce .eln on the side.
#
# `make clean'   drops every .elc + the native-comp cache so the next
#                Emacs start does a full recompile.

EMACS ?= emacs
MODULES := ck-emacs-modules
LISP    := ck-lisp
ELPACA  := $(HOME)/.emacs.d/elpaca/builds

.PHONY: compile clean check status

compile: bin/compile.el
	@$(EMACS) --batch -Q --script bin/compile.el

clean:
	@find $(MODULES) $(LISP) -name '*.elc' -delete 2>/dev/null
	@rm -rf eln-cache
	@echo "removed .elc and eln-cache/"

status:
	@printf "%-30s %s\n" "ck-emacs-modules .el" "$$(ls $(MODULES)/*.el 2>/dev/null | wc -l)"
	@printf "%-30s %s\n" "ck-emacs-modules .elc" "$$(ls $(MODULES)/*.elc 2>/dev/null | wc -l)"
	@printf "%-30s %s\n" "ck-lisp .el" "$$(ls $(LISP)/*.el 2>/dev/null | wc -l)"
	@printf "%-30s %s\n" "ck-lisp .elc" "$$(ls $(LISP)/*.elc 2>/dev/null | wc -l)"

check: bin/check.el
	@$(EMACS) --batch -Q --script bin/check.el
