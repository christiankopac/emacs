# Troubleshooting Guide

## Common Issues and Solutions

This guide covers common errors, issues, and how to resolve them in your Emacs configuration.

---

## Table of Contents

1. [Startup Errors](#startup-errors)
2. [Package Issues](#package-issues)
3. [LSP Problems](#lsp-problems)
4. [Performance Issues](#performance-issues)
5. [Display Problems](#display-problems)
6. [Keybinding Conflicts](#keybinding-conflicts)
7. [Org Mode Issues](#org-mode-issues)
8. [Git/Magit Problems](#gitmagit-problems)
9. [Terminal Issues](#terminal-issues)
10. [General Debugging](#general-debugging)

---

## Startup Errors

### Error: "Symbol's function definition is void"

**Cause:** Function called before package is loaded (common with Elpaca).

**Solution:**
```elisp
;; Wrap in with-eval-after-load
(with-eval-after-load 'package-name
  (function-call))
```

**Example:**
```elisp
;; BAD:
(vertico-mode)

;; GOOD:
(with-eval-after-load 'vertico
  (vertico-mode))
```

---

### Error: "Recursive load"

**Cause:** Config file has `(provide 'package-name)` that conflicts with actual package.

**Solution:** Rename the provide statement:
```elisp
;; BAD:
(provide 'dashboard)

;; GOOD:
(provide 'dashboard-config)
```

---

### Error: "Key sequence starts with non-prefix key"

**Cause:** Keybinding conflict. A key is bound to a command and also used as a prefix.

**Example:**
```
C-x C-c  → bound to save-buffers-kill-terminal
C-x C-c b  → CONFLICT! Can't use C-x C-c as prefix
```

**Solution:** Use a different prefix:
```elisp
;; BAD:
(global-set-key (kbd "C-x C-c b") 'consult-buffer)

;; GOOD:
(global-set-key (kbd "C-c b") 'consult-buffer)
```

---

### Error: "package--build-compatibility-table"

**Cause:** Mixing package managers (Elpaca + package.el).

**Solution:**
1. Remove `~/.emacs.d/elpa/` directory
2. Restart Emacs
3. Let Elpaca reinstall everything

```bash
rm -rf ~/.emacs.d/elpa/
```

---

### Error: Init file fails to load

**Debug process:**

1. **Start with debug mode:**
   ```bash
   emacs --debug-init
   ```

2. **View complete error backtrace**

3. **Bisect your config:**
   - Comment out half of init.el
   - Restart, see if error persists
   - Narrow down to problematic section

4. **Start with minimal config:**
   ```bash
   emacs -Q
   ```

---

## Package Issues

### Package won't install (Elpaca)

**Symptoms:**
- `(use-package foo :ensure t)` doesn't install package

**Solutions:**

1. **Force rebuild:**
   ```elisp
   M-x elpaca-rebuild foo
   ```

2. **Clear cache:**
   ```bash
   rm -rf ~/.emacs.d/elpaca/
   ```
   Then restart Emacs.

3. **Check Elpaca log:**
   ```elisp
   M-x elpaca-log
   ```
   Look for errors during installation.

4. **Try different recipe:**
   ```elisp
   (use-package foo
     :ensure (:host github :repo "author/foo"))
   ```

---

### Package update breaks config

**Solution:**

1. **Pin package to working version:**
   ```elisp
   (use-package foo
     :ensure (:ref "commit-hash-or-tag"))
   ```

2. **Rollback single package:**
   ```elisp
   M-x elpaca-delete foo
   M-x elpaca-try foo  ;; reinstall
   ```

3. **Check package's GitHub for breaking changes**

---

### "File not found" when loading config files

**Cause:** Incorrect path in `load-file`.

**Solution:**
```elisp
;; Use expand-file-name with user-emacs-directory
(load-file (expand-file-name "config/ui/dashboard.el" user-emacs-directory))
```

**Debug:**
```elisp
;; Check if file exists
(file-exists-p (expand-file-name "config/ui/dashboard.el" user-emacs-directory))
;; → Should return t
```

---

## LSP Problems

### LSP server not starting

**Symptoms:**
- No completions
- No go-to-definition
- No errors showing

**Solutions:**

1. **Check if LSP server is installed:**
   ```bash
   # TypeScript
   which typescript-language-server
   
   # Go
   which gopls
   
   # Python
   which pylsp
   ```

2. **Install missing server:**
   ```bash
   # TypeScript
   npm install -g typescript-language-server typescript
   
   # Go
   go install golang.org/x/tools/gopls@latest
   
   # Python
   pip install python-lsp-server
   ```

3. **Manually start LSP:**
   ```elisp
   M-x eglot
   ```

4. **Check Eglot events:**
   ```elisp
   M-x eglot-events-buffer
   ```
   Look for connection errors.

5. **Restart LSP server:**
   ```elisp
   M-x eglot-reconnect
   ```

---

### LSP completions not working

**Solutions:**

1. **Check Corfu is active:**
   ```elisp
   M-x corfu-mode
   ```

2. **Manually trigger completion:**
   ```elisp
   M-/
   ```

3. **Check company-mode is NOT enabled:**
   ```elisp
   M-x company-mode  ;; Should toggle OFF
   ```
   (Corfu and company conflict)

4. **Verify LSP is connected:**
   ```elisp
   M-x eglot  ;; Should say "Eglot already running"
   ```

---

### "LSP :: Not project directory"

**Cause:** Eglot requires a project (git repo or .project file).

**Solutions:**

1. **Initialize git:**
   ```bash
   git init
   ```

2. **Create .project file:**
   ```bash
   touch .project
   ```

3. **Add to project.el:**
   ```elisp
   M-x project-remember-project
   ```

---

### Slow LSP performance

**Solutions:**

1. **Reduce diagnostics:**
   ```elisp
   (setq eglot-events-buffer-size 0)  ;; Disable event logging
   ```

2. **Limit sync:**
   ```elisp
   (setq eglot-sync-connect nil)
   ```

3. **Exclude large directories:**
   Create `.gitignore` or `.ignore`:
   
   ```
   node_modules/
   dist/
   build/
   ```

4. **Increase gc threshold:**
   ```elisp
   (setq gc-cons-threshold (* 100 1024 1024))  ;; 100MB
   ```

---

## Performance Issues

### Emacs is slow on startup

**Solutions:**

1. **Profile startup:**
   ```elisp
   M-x esup
   ```
   (Install: `(use-package esup :ensure t)`)

2. **Defer package loading:**
   ```elisp
   (use-package foo
     :ensure t
     :defer t)  ;; Load only when needed
   ```

3. **Use `:after` for dependencies:**
   ```elisp
   (use-package foo
     :ensure t
     :after bar)  ;; Load only after bar
   ```

4. **Lazy load org-mode:**
   ```elisp
   (use-package org
     :ensure nil
     :defer t)
   ```

5. **Check what's taking time:**
   Add to init.el:
   ```elisp
   (defun my/display-startup-time ()
     (message "Emacs loaded in %s" (emacs-init-time)))
   (add-hook 'emacs-startup-hook #'my/display-startup-time)
   ```

---

### Editing is laggy

**Causes & Solutions:**

1. **Large files:**
   ```elisp
   M-x so-long-mode  ;; Enable for very long lines
   ```

2. **Too many minor modes:**
   ```elisp
   M-x describe-mode  ;; List active modes
   ;; Disable unnecessary ones
   ```

3. **Font rendering (GUI):**
   ```elisp
   (setq inhibit-compacting-font-caches t)
   ```

4. **LSP overhead:**
   ```elisp
   M-x eglot-shutdown  ;; Temporarily disable LSP
   ```

5. **Disable smooth scrolling:**
   ```elisp
   (setq scroll-conservatively 0)
   ```

---

### High CPU usage

**Debug:**

1. **Check what's running:**
   ```elisp
   M-x proced  ;; Process list
   ```

2. **Profile CPU:**
   ```elisp
   M-x profiler-start RET cpu RET
   ;; Use Emacs normally for a minute
   M-x profiler-report
   ```

3. **Common culprits:**
   - LSP server
   - Flycheck running too often
   - Auto-save/backup
   - Aggressive garbage collection

---

## Display Problems

### Icons not showing

**Causes & Solutions:**

**1. Nerd Fonts not installed (Terminal):**
```bash
# Install nerd-fonts
paru -S ttf-nerd-fonts-symbols  # Arch
brew install font-hack-nerd-font  # Mac
```

Set terminal font to a Nerd Font.

**2. all-the-icons not installed (GUI):**
```elisp
M-x all-the-icons-install-fonts
```

**3. Duplicate icons in dired:**
- Disable `all-the-icons-dired` (already done in your config)
- Use only dirvish with nerd-icons

---

### Wrong colors/theme issues

**Solutions:**

1. **Reload theme:**
   ```elisp
   M-x load-theme RET theme-name RET
   ```

2. **Disable all themes first:**
   ```elisp
   (mapc #'disable-theme custom-enabled-themes)
   (load-theme 'modus-vivendi-tinted t)
   ```

3. **Terminal color issues:**
   - Use a terminal with true color support
   - Export in shell config:
     ```bash
     export TERM=xterm-256color
     ```

4. **Check theme is installed:**
   ```elisp
   M-x describe-theme
   ```

---

### Font rendering issues

**Solutions:**

1. **Font not installed:**
   ```bash
   fc-list | grep "Font Name"  # Check if installed
   ```

2. **Fallback to default:**
   ```elisp
   (set-face-attribute 'default nil :family "monospace")
   ```

3. **Reset font cache:**
   ```bash
   fc-cache -fv
   ```

---

## Keybinding Conflicts

### Keybinding doesn't work

**Debug:**

1. **Check what key does:**
   ```elisp
   C-h k KEYBINDING
   ```

2. **Check where it's defined:**
   ```elisp
   M-x describe-key-briefly KEYBINDING
   ```

3. **List all bindings:**
   ```elisp
   C-h b  ;; or M-x describe-bindings
   ```

4. **Check mode-specific bindings:**
   ```elisp
   C-h m  ;; Describe current major mode
   ```

---

### Which-key not showing

**Solutions:**

1. **Enable which-key:**
   ```elisp
   M-x which-key-mode
   ```

2. **Reduce delay:**
   ```elisp
   (setq which-key-idle-delay 0.1)
   ```

3. **Check if suppressed:**
   ```elisp
   (setq which-key-show-early-on-C-h t)
   ```

---

## Org Mode Issues

### Org agenda files not found

**Solutions:**

1. **Check agenda file paths:**
   ```elisp
   M-x org-agenda-files
   ```

2. **Set correct paths:**
   ```elisp
   (setq org-agenda-files '("~/Sync/2_denote/agenda" 
                            "~/Sync/org/gtd/"))
   ```

3. **Rebuild agenda:**
   ```elisp
   M-x org-agenda-redo-all
   ```

---

### Org export not working

**Solutions:**

1. **Install export backends:**
   ```bash
   # Markdown export
   sudo apt install pandoc
   
   # PDF export
   sudo apt install texlive
   ```

2. **Enable export backend:**
   ```elisp
   (require 'ox-md)    ;; Markdown
   (require 'ox-html)  ;; HTML
   ```

---

### Org babel code blocks not executing

**Solutions:**

1. **Enable language:**
   ```elisp
   (org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
      (python . t)
      (shell . t)
      (js . t)))
   ```

2. **Disable confirmation:**
   ```elisp
   (setq org-confirm-babel-evaluate nil)
   ```

---

## Git/Magit Problems

### Magit not showing status

**Solutions:**

1. **Check if in git repo:**
   ```bash
   git status
   ```

2. **Refresh magit:**
   ```elisp
   g  ;; In magit buffer
   ```

3. **Check git executable:**
   ```elisp
   M-: (executable-find "git")  ;; Should return path
   ```

---

### Magit is slow

**Solutions:**

1. **Disable auto-revert:**
   ```elisp
   (setq magit-auto-revert-mode nil)
   ```

2. **Reduce status sections:**
   ```elisp
   (setq magit-status-sections-hook
         '(magit-insert-status-headers
           magit-insert-untracked-files
           magit-insert-unstaged-changes
           magit-insert-staged-changes))
   ```

3. **Use shallow clone:**
   ```bash
   git config --global fetch.depth 10
   ```

---

### Diff-hl indicators not showing

**Solutions:**

1. **Enable diff-hl:**
   ```elisp
   M-x global-diff-hl-mode
   ```

2. **Check in git repo:**
   Only works in git-tracked files.

3. **Refresh:**
   ```elisp
   M-x diff-hl-magit-post-refresh
   ```

---

## Terminal Issues

### Vterm not working

**Solutions:**

1. **Install dependencies:**
   ```bash
   # Arch
   sudo pacman -S cmake libtool
   
   # Ubuntu
   sudo apt install cmake libtool libtool-bin
   ```

2. **Compile vterm module:**
   ```elisp
   M-x vterm-module-compile
   ```

3. **Check shell:**
   ```elisp
   (setq vterm-shell "/bin/bash")  ;; or /bin/zsh
   ```

---

### Colors wrong in terminal

**Solutions:**

1. **Export TERM:**
   ```bash
   export TERM=xterm-256color
   ```

2. **Enable true color:**
   ```elisp
   (unless (display-graphic-p)
     (xterm-mouse-mode 1))
   ```

---

## General Debugging

### Enable Debug Mode

**On error:**
```elisp
M-x toggle-debug-on-error
```

Now when an error occurs, you'll see a full backtrace.

---

### Check Error Messages

```elisp
M-x view-echo-area-messages
```

Shows all messages from the echo area.

---

### Inspect Variable

```elisp
C-h v variable-name RET
```

Shows current value and documentation.

---

### Test in Clean Environment

```bash
emacs -Q  # No init file
emacs -Q -l ~/test.el  # Load specific file
```

---

### Byte-compile Check

```elisp
M-x byte-compile-file RET init.el RET
```

Catches syntax errors and warnings.

---

### Check Recent Changes

```elisp
M-x diff-buffer-with-file
```

Shows unsaved changes in current buffer.

---

### Reset Emacs State

```bash
# Backup first!
mv ~/.emacs.d ~/.emacs.d.bak
# Restart Emacs - clean slate
```

---

## Getting Help

### Built-in Help

```elisp
C-h ?     # Help menu
C-h k     # Describe key
C-h f     # Describe function
C-h v     # Describe variable
C-h m     # Describe mode
C-h b     # List all keybindings
C-h i     # Info manuals
```

---

### Community Resources

- **r/emacs** - Reddit community
- **Emacs StackExchange** - Q&A
- **System Crafters** - Video tutorials
- **Protesilaos Stavrou** - Emacs philosophy & packages
- **#emacs on Libera.Chat** - IRC

---

### Report Bugs

**Package bugs:**
1. Check package's GitHub issues
2. Try to reproduce with minimal config
3. Include backtrace and Emacs version

**Emacs bugs:**
```elisp
M-x report-emacs-bug
```

---

## Prevention Tips

1. **Version control your config:**
   ```bash
   cd ~/.emacs.d
   git init
   git add .
   git commit -m "Working config"
   ```

2. **Test changes incrementally:**
   - Don't add 10 packages at once
   - Test after each change
   - Commit working states

3. **Keep backups:**
   ```bash
   cp init.el init.el.bak
   ```

4. **Read error messages carefully:**
   - They usually tell you exactly what's wrong
   - Google the exact error message

5. **Use `:defer t` liberally:**
   - Prevents load-time errors
   - Faster startup
   - Errors only when actually using package

---

*Last Updated: 2025-09-30*

