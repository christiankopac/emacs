# Emacs Quick Reference

## Essential Keybindings Cheat Sheet

Quick reference for the most common tasks and keybindings in your Emacs configuration.

---

## File Operations

| Keybinding | Action |
|------------|--------|
| `C-c f` | Find file in project (fuzzy) |
| `C-x C-f` | Open file by path |
| `C-x C-s` | Save file |
| `C-x s` | Save all buffers |
| `C-c w r` | Open recent file |
| `C-x C-w` | Save as (write file) |
| `C-x k` | Close buffer |

---

## Navigation

| Keybinding | Action |
|------------|--------|
| `C-c b` | Switch buffer |
| `C-x d` | Open file manager (dired) |
| `M-.` | Go to definition (LSP) |
| `M-,` | Go back |
| `M-?` | Find references |
| `C-:` | Jump to character (avy) |
| `M-g g` | Go to line |
| `M-p` | Switch window (ace-window) |

---

## Search

| Keybinding | Action |
|------------|--------|
| `C-s` | Search forward |
| `C-r` | Search backward |
| `C-c s s` | Search in project (ripgrep) |
| `M-%` | Find and replace |
| `C-M-%` | Regex find and replace |

---

## Editing

| Keybinding | Action |
|------------|--------|
| `C-space` | Set mark (start selection) |
| `C-w` | Cut |
| `M-w` | Copy |
| `C-y` | Paste (yank) |
| `M-y` | Cycle through kill ring |
| `C-/` or `C-_` | Undo |
| `C-x u` | Undo tree (vundo) |
| `M-;` | Comment/uncomment |
| `C-=` | Expand selection |

---

## Code

| Keybinding | Action |
|------------|--------|
| `M-/` | Auto-complete |
| `C-c e a` | Code actions (LSP) |
| `C-c e r` | Rename symbol (LSP) |
| `C-c e f` | Format document |
| `C-c e h` | Show documentation |
| `C-c ! l` | List errors (flycheck) |
| `C-c ! n` | Next error |
| `C-c ! p` | Previous error |

---

## Multiple Cursors

| Keybinding | Action |
|------------|--------|
| `C->` | Add cursor at next match |
| `C-<` | Add cursor at previous |
| `C-S-c C-S-c` | Cursor on each selected line |

---

## Window Management

| Keybinding | Action |
|------------|--------|
| `C-x 2` | Split horizontal |
| `C-x 3` | Split vertical |
| `C-x 0` | Close window |
| `C-x 1` | Close other windows |
| `C-x o` | Next window |
| `M-p` | Jump to window (ace) |

---

## Git (Magit)

| Keybinding | Action |
|------------|--------|
| `C-x g` | Open Magit status |
| `s` | Stage (in Magit) |
| `u` | Unstage (in Magit) |
| `c c` | Commit |
| `P p` | Push |
| `F p` | Pull |
| `b b` | Switch branch |
| `l l` | View log |

---

## Org Mode

| Keybinding | Action |
|------------|--------|
| `C-c c` | Capture menu |
| `C-c c i` | Capture to inbox |
| `C-c c t` | Capture task |
| `C-c c j` | Journal entry (prompted) |
| `C-c c J` | Quick journal |
| `C-c a` | Agenda |
| `C-c l` | Store link |
| `C-c C-c` | Execute/toggle |
| `C-c C-t` | Cycle TODO state |
| `C-c C-s` | Schedule |
| `C-c C-d` | Deadline |
| `C-c C-w` | Refile |

---

## Denote (denote)

| Keybinding | Action |
|------------|--------|
| `C-c d n` | New note |
| `C-c d N` | New note in subdirectory |
| `C-c d F` | Quick fleeting note |
| `C-c d m` | Create movie note |
| `C-c d f` | Find note |
| `C-c d i` | Insert link |
| `C-c d b` | Show backlinks |
| `C-c x k` | Explore by keywords |
| `C-c x n` | Show network graph |

---

## Terminal

| Keybinding | Action |
|------------|--------|
| `C-c t` | Open terminal |
| `M-!` | Run shell command |
| `M-\|` | Run command on region |

---

## Help

| Keybinding | Action |
|------------|--------|
| `C-h k` | Describe key |
| `C-h f` | Describe function |
| `C-h v` | Describe variable |
| `C-h m` | Describe mode |
| `C-h b` | List all keybindings |
| `C-h i` | Info manual |

---

## Special Keys Notation

| Notation | Meaning |
|----------|---------|
| `C-` | Control key |
| `M-` | Alt/Option key (Meta) |
| `S-` | Shift key |
| `RET` | Enter/Return |
| `SPC` | Space bar |
| `TAB` | Tab key |
| `ESC` | Escape key |

**Examples:**
- `C-x` = Control + x
- `M-x` = Alt + x
- `C-c C-s` = Control + c, then Control + s

---

## Emergency Commands

| Keybinding | Action |
|------------|--------|
| `C-g` | Cancel current command |
| `ESC ESC ESC` | Emergency escape |
| `C-x C-c` | Quit Emacs |
| `M-x kill-emacs` | Force quit |
| `M-x toggle-debug-on-error` | Debug mode |

---

## Minibuffer Commands

When in minibuffer (bottom input area):

| Key | Action |
|-----|--------|
| `TAB` | Complete |
| `C-n` | Next suggestion |
| `C-p` | Previous suggestion |
| `RET` | Accept |
| `C-g` | Cancel |
| `M-.` | Preview file |

---

## Common Command Patterns

### Execute Command
```
M-x command-name RET
```

### Numeric Arguments
```
C-u 4 C-n        → Move down 4 lines
C-u C-u C-n      → Move down 16 lines (4²)
M-5 C-n          → Move down 5 lines
```

### Region (Selection) Commands
```
1. Set mark: C-space
2. Move cursor to select
3. Execute command (cut, copy, comment, etc.)
```

### Rectangle (Column) Editing
```
1. Set mark: C-space
2. Move down to select columns
3. C-x r k → Kill rectangle
4. C-x r y → Yank rectangle
5. C-x r t → Insert text in rectangle
```

---

## Tips for Beginners

1. **C-g is your friend** - Cancel any accidental command
2. **Use the minibuffer** - Most powerful feature for discovery
3. **M-x** - Access any command by name
4. **C-h k** - Learn what any keybinding does
5. **Practice keybindings** - They become muscle memory
6. **Don't memorize everything** - Learn what you use often
7. **Use which-key** - Shows available keybindings (auto-appears)
8. **Customize gradually** - Don't change everything at once
9. **Keep this reference handy** - Until keybindings become natural
10. **Ask for help** - `C-h` is the help prefix

---

## Most Important Commands

If you only learn 20 keybindings, learn these:

1. `C-g` - Cancel
2. `C-x C-f` - Open file
3. `C-x C-s` - Save
4. `C-x k` - Close buffer
5. `C-c b` - Switch buffer
6. `C-c f` - Find file in project
7. `M-.` - Go to definition
8. `M-,` - Go back
9. `C-c s s` - Search project
10. `C-space` - Start selection
11. `C-w` - Cut
12. `M-w` - Copy
13. `C-y` - Paste
14. `C-/` - Undo
15. `M-;` - Comment
16. `C-x g` - Git status
17. `C-c a` - Org agenda
18. `C-c c` - Capture
19. `M-x` - Execute command
20. `C-h k` - Describe key

---

*Print this and keep it next to your keyboard!*

*Last Updated: 2025-09-30*

