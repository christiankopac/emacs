# Development Workflow Guide

## Overview

This guide covers web development workflows in Emacs, including navigation, LSP features, debugging, version control, and project management—everything you'd typically do in VS Code or Vim.

---

## Table of Contents

1. [Project Navigation](#project-navigation)
2. [File Management](#file-management)
3. [Code Navigation](#code-navigation)
4. [LSP Features (Eglot)](#lsp-features-eglot)
5. [Syntax Checking (Flycheck)](#syntax-checking-flycheck)
6. [Code Completion (Corfu)](#code-completion-corfu)
7. [Git Integration (Magit)](#git-integration-magit)
8. [Terminal and Shell](#terminal-and-shell)
9. [Language-Specific Workflows](#language-specific-workflows)
10. [Debugging](#debugging)
11. [Search and Replace](#search-and-replace)
12. [Multiple Cursors](#multiple-cursors)
13. [Window Management](#window-management)
14. [Common Tasks](#common-tasks)

---

## Project Navigation

### Finding Files

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c f` | consult-fd | Find file in project (fast, like fzf) |
| `C-x C-f` | find-file | Open file by path |
| `C-c w r` | recentf-open | Open recent file |
| `C-c b` | consult-buffer | Switch buffer/recent file |

**Consult-fd Features:**
- Fast fuzzy search
- Respects `.gitignore`
- Preview files while typing
- Instant results

**Example:**
```
C-c f
Search: comp/butt
→ Finds: components/Button.tsx
```

---

### Buffer Management

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c b` | consult-buffer | Switch buffer |
| `C-x k` | kill-buffer | Close buffer |
| `C-x C-b` | ibuffer | Buffer list (like VS Code's file tree) |
| `C-x b` | switch-to-buffer | Switch buffer by name |

**IBuffer Features:**
- Group buffers by project/mode
- Mark multiple buffers (m)
- Kill marked buffers (D)
- Save marked buffers (S)

---

### Project Management

Your config includes project.el for VS Code-like project features.

**Common Tasks:**
```
C-x p f    → Find file in project
C-x p g    → Run grep in project
C-x p s    → Save all project files
C-x p k    → Kill all project buffers
C-x p !    → Run shell command in project root
```

---

## File Management

### Dired (File Manager)

**Open Dired:** `C-x d`

**Like VS Code's Explorer but more powerful:**

| Key | Action | VS Code Equivalent |
|-----|--------|-------------------|
| `RET` | Open file | Double-click |
| `^` | Parent directory | Click .. |
| `+` | Create directory | Right-click → New Folder |
| `C` | Copy file | Ctrl+C |
| `R` | Rename/move | F2 |
| `D` | Delete | Delete |
| `m` | Mark file | Check box |
| `u` | Unmark | Uncheck |
| `g` | Refresh | F5 |
| `q` | Quit | Close tab |

**Advanced:**
- `% m` - Mark by regex
- `t` - Toggle all marks
- `! command` - Run shell command on file
- `Z` - Compress/uncompress

---

### Dirvish Features

Enhanced dired with:
- Icons for file types
- File size and date
- Image previews
- Quick actions

**Sorting:**
- `o` - Change sort order
- Directories always first

**External Programs (OpenWith):**
Files open in external apps automatically:
- `.mkv, .mp4` → MPV
- `.png, .jpg` → feh
- `.pdf` → zathura
- `.docx` → LibreOffice

---

## Code Navigation

### Jump to Definition

**Keybinding:** `M-.` (eglot-find-definition)

Jump to where a function/class/variable is defined.

**Return:** `M-,` (eglot-find-back)

**Example:**
```typescript
// Cursor on Button
import { Button } from './components/Button'
          ^
// Press M-. → Opens Button.tsx at definition
```

---

### Find References

**Keybinding:** `M-?` (eglot-find-references)

Show all places where symbol is used.

**Use Case:**
- Find all calls to a function
- See where a component is imported
- Track variable usage

---

### Go to Type Definition

**Keybinding:** `C-c e t` (eglot-find-typeDefinition)

Jump to type definition (TypeScript/Flow).

**Example:**
```typescript
const user: User = {...}
            ^
// Press C-c e t → Jump to User interface definition
```

---

### Go to Implementation

**Keybinding:** `C-c e i` (eglot-find-implementation)

Find all implementations of an interface/abstract class.

---

### Symbol Navigation

**Keybinding:** `C-c e s` (consult-eglot-symbols)

Fuzzy search all symbols in project (functions, classes, variables).

**Like VS Code's:** `Ctrl+T`

**Example:**
```
C-c e s
Search: useState
→ Shows all useState imports/usages across project
```

---

### Jump Around Quickly

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-:` | avy-goto-char | Jump to any visible character |
| `C-'` | avy-goto-char-2 | Jump to two characters |
| `M-g f` | avy-goto-line | Jump to line |
| `M-g w` | avy-goto-word-1 | Jump to word start |

**How Avy Works:**
1. Press `C-:`
2. Type a character (e.g., `f`)
3. All instances of `f` are labeled (a, s, d, f, g, h, j, k, l)
4. Press label to jump instantly

**Like Vim's EasyMotion or VS Code's JumpTo extension**

---

## LSP Features (Eglot)

Your Eglot setup provides VS Code-like IntelliSense.

### Rename Symbol

**Keybinding:** `C-c e r` (eglot-rename)

Rename symbol across entire project.

**Example:**
```typescript
function oldName() { }
         ^
// C-c e r → Type "newName"
// All references updated across project
```

---

### Code Actions

**Keybinding:** `C-c e a` (eglot-code-actions)

Quick fixes and refactorings:
- Add missing imports
- Generate code
- Extract function
- Organize imports

**Like:** VS Code's lightbulb menu

---

### Format Document

**Keybinding:** `C-c e f` (eglot-format)

Format current buffer with configured formatter.

**Format on Save:** Enabled for Go (`gofmt`/`goimports`)

---

### Hover Documentation

**Keybinding:** `C-c e h` (eldoc)

Show documentation for symbol at point.

**Auto-appears in echo area** (like VS Code's hover tooltip)

---

### Signature Help

**Automatically shows parameter hints** while typing function calls.

```typescript
function greet(name: string, age: number) {}

greet(|)  ← Cursor here shows: (name: string, age: number)
```

---

## Syntax Checking (Flycheck)

Real-time error and warning detection.

### View Errors

**Automatic:** Errors show in sidebar and underlined in code

**Keybindings:**
| Key | Command | Description |
|-----|---------|-------------|
| `C-c ! l` | flycheck-list-errors | List all errors (like VS Code's Problems) |
| `C-c ! n` | flycheck-next-error | Next error |
| `C-c ! p` | flycheck-previous-error | Previous error |
| `C-c ! v` | flycheck-verify-setup | Check flycheck config |

---

### Sideline Errors

Errors appear inline (right side of window) like VS Code:

```typescript
const x: number = "string"  ❌ Type 'string' not assignable to 'number'
```

---

### Language-Specific Checkers

**TypeScript:**
- `typescript-tslint`
- `typescript-eslint`

**Go:**
- `go-staticcheck`
- `go-vet`
- `go-golint`

**Shell:**
- `shellcheck`

---

## Code Completion (Corfu)

In-buffer completion popup (like VS Code's IntelliSense).

### Trigger Completion

**Auto-trigger:** Typing automatically shows completions

**Manual trigger:** `M-/`

### Navigate Completions

| Key | Action |
|-----|--------|
| `TAB` or `C-n` | Next completion |
| `S-TAB` or `C-p` | Previous completion |
| `RET` | Accept completion |
| `ESC` | Cancel |
| `M-d` | Show documentation |

---

### Completion Sources

- LSP (functions, variables, types)
- File paths
- Keywords
- Snippets (if configured)

---

## Git Integration (Magit)

**The most powerful Git interface**, better than VS Code's Git GUI.

### Open Magit

**Keybinding:** `C-x g`

Opens Magit status buffer (like VS Code's Source Control panel).

---

### Magit Status Buffer

**Sections:**
- Untracked files
- Unstaged changes
- Staged changes
- Recent commits

**Basic Operations:**

| Key | Action | VS Code Equivalent |
|-----|--------|-------------------|
| `s` | Stage file/hunk | + icon (stage changes) |
| `u` | Unstage file/hunk | - icon (unstage) |
| `k` | Discard changes | Discard Changes |
| `c c` | Commit | Source Control → Commit |
| `P p` | Push | Push icon |
| `F p` | Pull | Pull icon |
| `b b` | Switch branch | Bottom-left branch selector |
| `b c` | Create branch | + icon in branches |
| `l l` | Log | Timeline view |
| `d d` | Diff | Show changes |
| `TAB` | Toggle section | Collapse/expand |
| `g` | Refresh | Refresh |
| `q` | Quit | Close panel |

---

### Staging Hunks (Partial Staging)

**Stage parts of a file:**

1. In Magit status, navigate to file
2. Press `TAB` to expand changes
3. Navigate to specific hunk
4. Press `s` to stage just that hunk

**Like:** VS Code's "Stage Selected Ranges"

---

### Committing

```
c c    → Commit
       → Write message in new buffer
       → C-c C-c to finish
       → C-c C-k to cancel
```

**Commit Options:**
- `c a` - Amend last commit
- `c e` - Extend last commit (no message change)
- `c w` - Reword last commit

---

### Branching

```
b b    → Switch branch (with completion)
b c    → Create new branch
b m    → Rename branch
b k    → Delete branch
```

---

### Pushing/Pulling

```
P p    → Push to remote
F p    → Pull from remote
F u    → Pull with rebase
```

---

### Viewing History

```
l l    → Log current branch
l o    → Log other branches
l a    → Log all branches
```

**In log view:**
- `RET` - Show commit details
- `d` - Show diff
- `a` - Apply commit (cherry-pick)
- `r` - Revert commit

---

### Diff View

```
d d    → Diff unstaged changes
d s    → Diff staged changes
d r    → Diff range
```

**Navigation:**
- `n` - Next hunk
- `p` - Previous hunk
- `M-n` - Next file
- `M-p` - Previous file

---

### Merge Conflicts

When conflicts occur:

1. Magit shows conflicted files
2. Open file (`RET`)
3. Use `smerge-mode` (automatically enabled):
   - `C-c ^ n` - Next conflict
   - `C-c ^ p` - Previous conflict
   - `C-c ^ u` - Keep upper (ours)
   - `C-c ^ l` - Keep lower (theirs)
   - `C-c ^ a` - Keep both
   - `C-c ^ RET` - Keep current

4. Stage resolved files (`s` in Magit)
5. Commit merge (`c c`)

---

### Git Time Machine

**Keybinding:** `C-x v t`

Browse file's Git history (like VS Code's Timeline view).

**Controls:**
- `p` - Previous revision
- `n` - Next revision
- `q` - Quit time machine
- `w` - Copy commit hash
- `b` - Blame

---

### Diff-hl (Gutter Indicators)

Shows changes in the gutter (like VS Code's diff indicators):

- **Green bar** - Added lines
- **Blue bar** - Modified lines
- **Red triangle** - Deleted lines

**Commands:**
- `C-x v =` - Show diff at point
- `C-x v n` - Next change
- `C-x v p` - Previous change

---

## Terminal and Shell

### Built-in Terminal

**Keybinding:** `C-c t`

Opens `vterm` (full-featured terminal emulator).

**Features:**
- Full color support
- Works with ncurses apps
- Copy/paste with Emacs
- Fast performance

**Usage:**
- Type commands normally
- `C-c C-t` - Toggle between char-mode and line-mode
- `C-c C-c` - Send `C-c` to terminal
- `C-c C-z` - Toggle between terminal and last buffer

---

### Shell Commands

**Run single command:**
```
M-!       → shell-command (output in new buffer)
M-|       → shell-command-on-region (pipe region)
C-u M-!   → Insert output at point
```

**Example:**
```
Select JSON text
M-| jq .    → Format JSON in place
```

---

### Project Shell Commands

```
C-x p !   → Run command in project root
C-x p &   → Async command in project root
```

**Example:**
```
C-x p ! npm run build
→ Runs build from project root
```

---

## Language-Specific Workflows

### TypeScript/JavaScript

**LSP Server:** `typescript-language-server`

**Features:**
- Auto-import suggestions
- Refactoring (extract function, constant, type)
- Organize imports
- IntelliSense

**Keybindings:**
```
M-.       → Go to definition
M-?       → Find references
C-c e r   → Rename
C-c e a   → Code actions (auto-import, quick fixes)
C-c e f   → Format
```

**Workflow Example:**
```typescript
// 1. Type component name
import { But|

// 2. Corfu shows: Button, ButtonProps
// 3. Accept with RET
// 4. If import missing, C-c e a → Add import
```

---

### Go

**LSP Server:** `gopls`

**Auto-format on save:** Enabled (`gofmt-before-save`)

**Keybindings:**
```
M-.       → Go to definition
M-?       → Find references
C-c e r   → Rename
C-c e a   → Code actions (add import, extract function)
```

**Go-specific checkers:**
- `go-staticcheck` - Advanced linting
- `go-vet` - Official Go vet
- `go-golint` - Style checks

---

### Python

**LSP Server:** `pylsp` (Python Language Server)

**Features:**
- Type checking
- Auto-completion
- Refactoring
- Linting (pylint, flake8)

---

### Shell Scripts

**LSP Server:** `bash-language-server`

**Checker:** `shellcheck`

**Features:**
- Syntax checking
- Best practices warnings
- Common error detection

---

### HTML/CSS

**LSP Servers:**
- `html-languageserver`
- `css-languageserver`

**Features:**
- Tag completion
- CSS property suggestions
- Color preview
- Emmet-like expansion

---

### Markdown

**LSP Server:** `marksman`

**Preview:** `C-c C-c p` (grip-mode)

**Features:**
- Real-time preview in browser
- Link checking
- Table formatting

---

## Debugging

### Basic Debugging

**GUD (Grand Unified Debugger):**

```
M-x gdb           → Start GDB
M-x pdb           → Start Python debugger
```

**Breakpoints:**
```
C-x C-a C-b      → Set breakpoint
C-x C-a C-d      → Delete breakpoint
```

**Navigation:**
```
C-x C-a C-n      → Next line
C-x C-a C-s      → Step into
C-x C-a C-r      → Continue
```

---

### Node.js Debugging

Use `vterm` with Node inspector:

```
C-c t
$ node --inspect-brk script.js
$ chrome://inspect (in Chrome)
```

---

## Search and Replace

### Search in File

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-s` | isearch-forward | Search forward |
| `C-r` | isearch-backward | Search backward |
| `M-%` | query-replace | Replace with prompt |
| `C-M-%` | query-replace-regexp | Regex replace |

**During search:**
- `C-s` - Next match
- `C-r` - Previous match
- `RET` - Stop at current
- `C-g` - Cancel search

---

### Search in Project

**Keybinding:** `C-c s s` (consult-ripgrep)

Fast grep across entire project (like VS Code's global search).

**Features:**
- Live preview
- Regex support
- Respects `.gitignore`
- Extremely fast

**Example:**
```
C-c s s
Search: TODO.*urgent
→ Shows all TODO comments with "urgent"
```

**Advanced Search:**
```
term1 term2          # Both terms (AND)
term1 | term2        # Either term (OR)
!exclude             # Exclude term
-g "*.ts"            # Only .ts files
```

---

### Search and Replace in Multiple Files

**Workflow:**

1. Find files: `C-c s s pattern`
2. In results, press `C-c C-e` (embark-export)
3. Results exported to grep buffer
4. Press `w` (wgrep-change-to-wgrep-mode)
5. Edit directly in buffer
6. Press `C-c C-c` to apply changes to all files

**Like:** VS Code's "Replace in Files"

---

### Visual Replace (Interactive)

**Keybinding:** `M-%`

```
M-%
Query replace: oldText
with: newText

For each match:
y → Replace this one
n → Skip this one
! → Replace all remaining
q → Quit
```

---

## Multiple Cursors

**Like VS Code's multi-cursor editing**

### Add Cursors

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C->` | mc/mark-next-like-this | Add cursor at next match |
| `C-<` | mc/mark-previous-like-this | Add cursor at previous |
| `C-S-c C-S-c` | mc/edit-lines | Cursor on each line in region |

---

### Workflow Example

```
1. Place cursor on "const"
2. Press C-> three times
   → Creates 4 cursors on each "const"
3. Type "let"
   → All "const" become "let"
4. Press ESC to exit multi-cursor
```

**Use Cases:**
- Rename multiple variables at once
- Edit similar lines simultaneously
- Add/remove prefixes in bulk

---

## Window Management

### Split Windows

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-x 2` | split-window-below | Split horizontal |
| `C-x 3` | split-window-right | Split vertical |
| `C-x 0` | delete-window | Close current window |
| `C-x 1` | delete-other-windows | Close all except current |
| `C-x o` | other-window | Cycle through windows |

---

### Ace Window (Quick Switch)

**Keybinding:** `M-p`

Shows letters in each window, press letter to jump.

**Like:** VS Code's split editor navigation

**Actions:**
- `x` - Delete window
- `s` - Swap windows
- `v` - Split vertical
- `b` - Split horizontal

---

### Window Layouts

**Save layout:**
```
C-x r w a    → Save window config to register 'a'
C-x r j a    → Restore window config from 'a'
```

---

## Common Tasks

### Open File Under Cursor

**Keybinding:** `C-c C-o` or `C-x C-f` (in path)

Opens file path at point.

**Works with:**
- Import statements: `import './components/Button'`
- Relative paths: `../utils/helper.js`
- URLs: `https://example.com`

---

### Copy File Path

```
M-x copy-file-name-to-clipboard
```

Copies current file's full path.

---

### Create File in Current Directory

```
C-x C-f ./newfile.tsx RET
```

If file doesn't exist, it will be created on save.

---

### Duplicate Line

**Custom function needed** (add this to your config):

```elisp
(defun duplicate-line ()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank))

(global-set-key (kbd "C-c d") 'duplicate-line)
```

---

### Comment/Uncomment

| Keybinding | Command | Description |
|------------|---------|-------------|
| `M-;` | comment-dwim | Comment/uncomment line or region |
| `C-x C-;` | comment-line | Toggle line comment |

---

### Indent/Unindent

| Keybinding | Command | Description |
|------------|---------|-------------|
| `TAB` | indent-for-tab-command | Auto-indent line |
| `C-M-\` | indent-region | Auto-indent region |
| `C-x TAB` | indent-rigidly | Shift region right |
| `C-u -4 C-x TAB` | - | Shift region left 4 spaces |

---

### Select Expand Region

**Keybinding:** `C-=`

Intelligently expand selection:

```
1st press: Word
2nd press: String/function call
3rd press: Statement
4th press: Function
5th press: Class
```

**Like:** VS Code's "Expand Selection"

---

### Fold/Unfold Code

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c @ C-c` | hs-toggle-hiding | Toggle fold at point |
| `C-c @ C-M-h` | hs-hide-all | Fold all |
| `C-c @ C-M-s` | hs-show-all | Unfold all |

**Enable:** `M-x hs-minor-mode`

---

### Kill Buffer and Window

```
M-x kill-buffer-and-window  (bind to C-x 4 0)
```

Closes both buffer and its window.

---

### Bookmarks

**Set bookmark:** `C-x r m`
**Jump to bookmark:** `C-x r b`
**List bookmarks:** `C-x r l`
**Delete bookmark:** `C-x r d`

**Use Case:** Mark important files/positions in large projects

---

## Pro Tips

### 1. Use Projectile/Project.el

Always work within a project for better navigation and search.

### 2. Learn Magit Thoroughly

It's 10x better than VS Code's Git UI once you know it.

### 3. Leverage LSP Fully

- Always run `M-x eglot-ensure` in language buffers
- Use code actions (`C-c e a`) liberally
- Rename with LSP, not find/replace

### 4. Master Avy

`C-:` + character is faster than using mouse/arrow keys.

### 5. Use Dired for Bulk Operations

Mark files, run commands on all at once.

### 6. Ripgrep is Your Friend

`C-c s s` is faster than any IDE's search.

### 7. Multiple Cursors for Repetitive Edits

Don't manually edit similar lines—use `C->`.

### 8. Embrace the Minibuffer

Completion in the minibuffer is powerful—learn to use it.

### 9. Window Configurations

Save common layouts with registers.

### 10. Terminal in Emacs

Keep `vterm` open for quick commands without leaving Emacs.

---

## Comparison to VS Code

| VS Code | Emacs Equivalent | Keybinding |
|---------|------------------|------------|
| Ctrl+P | Find file in project | `C-c f` |
| Ctrl+Shift+F | Search in project | `C-c s s` |
| F12 | Go to definition | `M-.` |
| Shift+F12 | Find references | `M-?` |
| F2 | Rename symbol | `C-c e r` |
| Ctrl+. | Code actions | `C-c e a` |
| Ctrl+Shift+O | Go to symbol | `C-c e s` |
| Ctrl+` | Toggle terminal | `C-c t` |
| Ctrl+B | Toggle sidebar | `C-x d` (dired) |
| Ctrl+G | Go to line | `M-g g` |
| Ctrl+D | Multi-cursor next | `C->` |
| Ctrl+Shift+K | Delete line | `C-S-backspace` |
| Alt+↑/↓ | Move line up/down | `M-↑`/`M-↓` |
| Ctrl+/ | Toggle comment | `M-;` |
| Ctrl+Space | Trigger suggest | `M-/` |

---

*Last Updated: 2025-09-30*

