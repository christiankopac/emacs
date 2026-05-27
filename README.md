# Emacs Configuration

A modular Emacs setup for note-taking, writing, coding, and productivity. Works the same on WSL, Arch, NixOS, Debian/Ubuntu, and macOS — system differences are detected at runtime and handled by `ck-system.el`.

## Quick start

```bash
git clone <repo-url> ~/.config/emacs
emacs                   # first launch installs ~80 packages via Elpaca (a few minutes)
```

First launch is slow because Elpaca clones every package; subsequent launches are ~0.5–1s on TTY and a few seconds on GUI (most of which is theme + dashboard + fontset setup).

## Layout

```
.emacs.d/
├── init.el                   # Top-level: package declarations + module loads
├── early-init.el             # Pre-init: GC, file-name-handler, frame params
├── ck-emacs-modules/         # All package configuration (one file per area)
│   ├── ck-system.el          # OS / distro / display-server detection (loaded first)
│   ├── ck-core.el            # Basic editing, search, modern Emacs niceties
│   ├── ck-clipboard.el       # Portable clipboard (WSL/Wayland/X11/macOS, GUI + TTY)
│   ├── ck-fonts.el           # Daemon-safe font resolution + fontaine presets
│   ├── ck-completion.el      # Vertico + Corfu + Cape + Marginalia + Consult
│   ├── ck-icons.el           # all-the-icons, nerd-icons
│   ├── ck-ui.el              # Spacious-padding, beacon, helpful, which-key
│   ├── ck-modeline.el        # mood-line config (loaded after package)
│   ├── ck-dashboard.el       # Startup dashboard
│   ├── ck-navigation.el      # Window/buffer navigation
│   ├── ck-editing.el         # Editing helpers
│   ├── ck-file-associations.el  # openwith + dirvish + dired
│   ├── ck-org-core.el        # Core org-mode
│   ├── ck-org-extensions.el  # org-appear, org-modern, etc.
│   ├── ck-org-export.el      # ox-pandoc, etc.
│   ├── ck-org-graphs.el      # ck-org-graphs-generate (gnuplot)
│   ├── ck-ox-hugo.el         # Blog publishing
│   ├── ck-denote.el          # Zettelkasten notes
│   ├── ck-xeft.el            # Fast note search
│   ├── ck-hyperbole.el       # Hyperbole
│   ├── ck-development.el     # LSP, flycheck, tree-sitter (via treesit-auto)
│   ├── ck-writing.el         # Markdown, olivetti, jinx
│   ├── ck-email.el           # mu4e, smtpmail, bbdb
│   ├── ck-ai.el              # gptel, ellama, copilot
│   └── ck-music.el           # emms, listen
├── ck-lisp/
│   ├── ck-functions.el       # Custom interactive commands
│   └── ck-maintenance.el     # Maintenance utilities
├── bin/                      # Helper scripts (compile.el, check.el)
├── Makefile                  # Optional byte-compile (see below)
└── docs/                     # Workflow guides (denote, org-gtd, music, email, etc.)
```

## Dependencies

### Fonts

Three families are required for a complete GUI experience. JetBrains Mono is the free default and is the actual installed name used by the fallback chain.

| Font | Role |
|---|---|
| **JetBrainsMono Nerd Font** (or **MonoLisa Nerd Font Mono** if you have it) | Code / default |
| **Symbols Nerd Font Mono** | Icon glyphs (nerd-icons, dirvish, mood-line) |
| **Literata** | Prose / variable-pitch |

Per-OS install:

- **Arch**: `sudo pacman -S ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono` and `yay -S otf-literata`
- **NixOS / home-manager**: `nerd-fonts.jetbrains-mono`, `nerd-fonts.symbols-only`. Literata isn't packaged — drop from Google Fonts into `~/.local/share/fonts/`.
- **Debian / Ubuntu / WSL**: Tarball install from [nerdfonts.com](https://www.nerdfonts.com/) — apt's nerd-fonts coverage is poor. Literata via Google Fonts.
- **macOS**: `brew install --cask font-jetbrains-mono-nerd-font font-symbols-only-nerd-font` + Literata from Google Fonts.

After installing, run `M-x ck/fonts-status` to verify the chain resolved to a real installed family (and not silently fell through to "monospace").

### System binaries

| Tool | Used by | Required? |
|---|---|---|
| `ripgrep` | consult-ripgrep, xeft | yes |
| `fd` (or `fdfind`) | consult-fd, dirvish | yes |
| `gnuplot` | ck-org-graphs | for graphs |
| `enchant-2` (with `hunspell`/`aspell` dicts) | jinx | for spell-check |
| `wl-clipboard` (`wl-copy` / `wl-paste`) | ck-clipboard | yes on WSL/Wayland |
| `xclip` or `xsel` | ck-clipboard fallback | recommended |
| `xdg-open` / `wslview` / `open` | openwith | yes on Linux/WSL/macOS |
| `mpv` | openwith video/audio | recommended |
| `mu` | mu4e email | for email |
| `pandoc` | ox-pandoc, pandoc-mode | for export |
| `hugo` | ox-hugo blog | for blog |
| `node` + `npm` | copilot.el server | for copilot |
| `trash-cli` or `gio` | delete-by-moving-to-trash | yes (either) |

Per-OS install commands are listed at the end of this README.

## What's where

### System detection (`ck-system.el`)

The first module loaded. Single source of truth for which platform Emacs is running on:

```
ck/macos-p      ck/linux-p      ck/wsl-p       ck/windows-p
ck/distro       ck/nix-active-p
ck/display-server   ; one of: tty, ns, w32, wslg, wayland, x11
```

Helpers:

- `(ck/has? "rg")` — memoized `executable-find`
- `(ck/has-any "wl-copy" "xclip" "pbcopy")` — first executable wins
- `(ck/open-command)` — platform-correct "open this" (`open` on macOS, `wslview` on WSL if installed, else `xdg-open`)

Interactive:

- `M-x ck/system-status` — shows the detected platform + open command.

### Clipboard (`ck-clipboard.el`)

One module replacing the old WSL-only one. Works in **both GUI and TTY** on all platforms.

- **GUI mode**: trusts Emacs's built-in selection (NS / X11 / pgtk). Do not override.
- **TTY mode**: bridges `interprogram-paste-function` / `interprogram-cut-function` to the system clipboard.
- Writes are synchronous with backend caching — first successful backend (`wl-copy` → `xclip` → `clip.exe` on WSL) is cached and reused.
- Reads also cache the first working backend.

Interactive:

- `M-x ck/clipboard-status` — shows detected system, the read/write chain, and which backends are cached.
- `M-x ck/clipboard-paste-force` — bypass the dedupe cache and re-read fresh from the OS clipboard. Useful when WSLg sync goes stale.
- `M-x ck/clipboard-force-bridge` — force the external bridge on even in GUI mode. Use if your GUI clipboard misbehaves.

### Fonts (`ck-fonts.el`)

Resolves the monospace / serif / nerd-symbol families **lazily**, on the first GUI frame — not at file-load time. This fixes the "daemon shows generic Monospace" bug.

- `M-x ck/fonts-status` — shows which families actually got resolved.
- `M-x fontaine-set-preset` — switch between presets (`regular`, `writing`, `org-reading`, `presentation`, `compact`, `large`).
- Quick keys: `C-c M-f r/o/w/p/c/l` for each preset.

### Performance behaviour

- `gc-cons-threshold` is 256MB during interactive use, paused entirely during minibuffer use, with a 5-second idle-timer running GC quietly in the background.
- `auto-revert-mode` uses inotify (push-based), not 5-second polling.
- `vc-handled-backends` is restricted to `(Git)` — Emacs no longer probes for CVS / SVN / Bzr / Hg / Mtn on every file open.
- Heavy packages (magit, dirvish, helm, hyperbole, copilot, ollama-buddy, pandoc-mode, jinx, etc.) are deferred.
- `corfu` fires at 3 chars + 0.3s delay (was 2 + 0.2) — less aggressive on every keystroke.
- `cape-dabbrev` searches the current buffer only (was: all buffers).
- `pixel-scroll-precision-mode` on for smooth GUI scrolling.
- `repeat-mode` on — after `C-x o` you can hit just `o o o` to keep cycling.
- `save-place-mode` + `savehist-mode` on — cursor positions and minibuffer history persist across sessions.
- `bidi-paragraph-direction` is set to `left-to-right` and `bidi-inhibit-bpa` is `t` — skips Emacs's bidirectional reorder pass on lines without RTL text.

## Build (optional)

The `.el` files load fine as-is. Byte-compiling them is opt-in — it shaves a small amount of parse time and lets native-comp produce `.eln` on the side.

```bash
make compile     # byte-compile ck-emacs-modules/ + ck-lisp/
make clean       # drop .elc files and eln-cache/
make status      # count .el vs .elc
make check       # smoke-test ck-system loads cleanly
```

Note: `init.el` currently uses `load-file` (not `require`), so byte-compilation alone doesn't change runtime behaviour — it just lets you catch warnings early. Migrating to `require` is a separate change that hasn't been done because it broke twice in interactive testing.

## Customisation you need to do per machine

### Email (`custom.el`)

`custom.el` is gitignored — set your email addresses there:

```elisp
(setq my/gmail-address "you@gmail.com"
      my/gmail-name "Your Name"
      my/fastmail-address "you@example.com"
      my/fastmail-name "Your Name")
```

Email passwords via `pass`:

```bash
pass insert email/gmail
pass insert email/fastmail
```

### AI keys

```bash
pass insert api-keys/anthropic
pass insert api-keys/openai
pass insert api-keys/perplexity
```

### Paths

The config assumes `~/org/` for org files and `~/src/` for projects. Adjust in `ck-org-core.el` and `ck-development.el` if needed.

## Key bindings

### Navigation
- `C-c b` — switch buffer (consult)
- `C-x C-f` — find file (recentf-aware)
- `M-p` — switch window (ace-window)
- `C-:` — jump to char (avy)
- `C-x o`, then `o o o` — cycle windows via repeat-mode

### Org
- `C-c a` — org-agenda
- `C-c c` — org-capture
- `C-c l` — org-store-link

### Denote
- `C-c d n` — new note
- `C-c d f` — find note

### Development
- `C-x g` — magit-status
- `C-x v t` — git-timemachine

### AI
- `C-c M-e` — ellama
- `C-c o` — ollama-buddy role menu
- `C-c O` — ollama-buddy full menu

### Status / diagnostics
- `M-x ck/system-status`
- `M-x ck/fonts-status`
- `M-x ck/clipboard-status`

### Themes
- `C-c t t` — toggle theme
- `C-c t SPC` — default theme

### Help
- `C-h k/f/v` — describe key / function / variable (helpful)

## Documentation

Workflow guides in `docs/`:

- `quick-reference.md` — keybinding cheatsheet
- `denote-workflow.md` — Zettelkasten note-taking
- `org-gtd-workflow.md` — Getting Things Done
- `development-workflow.md` — LSP, magit, formatting
- `unified-notes-workflow.md` — combined denote + org-gtd
- `music-workflow.md` — emms + listen
- `email.md` — mu4e configuration
- `troubleshooting.md` — common issues

⚠ The workflow docs still reference an old `config/<area>/` directory layout in places; the real layout is `ck-emacs-modules/`. The workflow content is mostly still correct — just substitute paths.

## Per-OS install commands

### Arch / Manjaro
```bash
sudo pacman -S ripgrep fd gnuplot enchant wl-clipboard xclip mpv \
               pandoc hugo nodejs npm graphviz trash-cli mu \
               ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols-mono
yay -S otf-literata wslu
```

### NixOS / home-manager
```nix
home.packages = with pkgs; [
  ripgrep fd gnuplot enchant wl-clipboard xclip mpv
  pandoc hugo nodejs graphviz trash-cli mu
  nerd-fonts.jetbrains-mono nerd-fonts.symbols-only
];
# Literata: drop into ~/.local/share/fonts/ manually
```

### Debian / Ubuntu / WSL (apt)
```bash
sudo apt install ripgrep fd-find gnuplot libenchant-2-2 wl-clipboard \
                 xclip mpv pandoc hugo nodejs npm graphviz trash-cli \
                 mu4e maildir-utils wslu
mkdir -p ~/.local/bin && ln -sf "$(which fdfind)" ~/.local/bin/fd
# Nerd Fonts + Literata: install via tarball from nerdfonts.com / fonts.google.com
```

### macOS (Homebrew)
```bash
brew install ripgrep fd gnuplot enchant mpv pandoc hugo node graphviz mu
brew install --cask font-jetbrains-mono-nerd-font font-symbols-only-nerd-font
# Literata: download from Google Fonts → ~/Library/Fonts
```

## Troubleshooting

### Icons / fonts show as boxes

```elisp
M-x ck/fonts-status
```

If `nerd=` falls through to the monospace family, your Symbols Nerd Font Mono isn't installed. Install per the table above and restart Emacs.

### Clipboard isn't working

```elisp
M-x ck/clipboard-status
```

Shows the detected system + chain + cached backend. If write-cached is `nil`, no backend succeeded — check `wl-copy` / `xclip` / `clip.exe` is installed.

WSLg out-of-sync? `M-x ck/clipboard-paste-force`.

### Packages won't install

```elisp
M-x elpaca-info
M-x elpaca-rebuild
```

Check `*Messages*` for errors.

### Email not working

Install `mu` (system package, not via Elpaca). `M-x mu4e` should then work; the email module gracefully warns if `mu` is missing.

### Performance

```elisp
M-x emacs-init-time
```

If high, check `*Messages*` for warnings about slow loads. The most common culprits in this config are:

- `poet-dark` theme — heavy face setup (typical 0.5–1.5s)
- Native-comp JIT after editing elisp (`eln-cache/` recompiles; one-time cost)
- Dashboard rendering with icons
