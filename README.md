# Emacs Configuration

A comprehensive, modular Emacs configuration optimized for note-taking, writing, coding, and productivity. Built with modern packages and best practices.

## Features

### Core Functionality
- **Package Management**: Uses [Elpaca](https://github.com/progfolio/elpaca) for fast, async package installation
- **Completion System**: Vertico (vertical completion) + Corfu (in-buffer completion) + Cape
- **Search**: Consult, Embark, and ripgrep integration
- **Icons**: Nerd Icons and All The Icons support
- **Themes**: Multiple theme support (Modus, Poet, Doric, EF Themes, Everforest, Leuven)

### Note-Taking & Organization
- **Org Mode**: Full-featured Org mode setup with modern enhancements
- **Denote**: Zettelkasten-style note-taking system
- **Xeft**: Fast note search and creation
- **Org-GTD**: Getting Things Done workflow integration
- **Org Journal**: Daily journaling system
- **Org QL**: Powerful query language for Org files

### Development
- **LSP Support**: Language Server Protocol integration
- **Tree-sitter**: Modern syntax parsing
- **Version Control**: Magit, Forge, and Git integration
- **Code Quality**: Flycheck, Format-all, Apheleia
- **AI Tools**: GPTel (Claude, OpenAI, Perplexity) and Copilot

### Writing & Publishing
- **Spell Checking**: Jinx (fast spell checker)
- **Markdown**: Full Markdown mode support
- **Export**: Org export with Pandoc integration
- **PDF Tools**: PDF viewing and annotation
- **EPUB**: Nov mode for EPUB reading

### Email
- **Mu4e**: Email client with multiple account support
- **BBDB**: Address book integration
- **Consult-Mu**: Fast email search

### UI Enhancements
- **Dashboard**: Customizable startup screen
- **Dirvish**: Modern file manager with icons
- **Mood-line**: Customizable modeline
- **Which-key**: Keybinding hints
- **Beacon**: Visual cursor tracking
- **Fontaine**: Font preset management

## Requirements

### Essential
- **Emacs 29+** (recommended) or Emacs 28
- **Git** (for package installation)
- **ripgrep** or **ugrep** (for fast search)

### Optional but Recommended
- **pass** (password store) - for API keys and email passwords
- **mu** and **offlineimap** - for email functionality
- **pandoc** - for document conversion
- **Nerd Fonts** - for icons in terminal

### System Dependencies
- For PDF viewing: `poppler` utilities
- For tree-sitter: Build tools (gcc, make)

## Installation

1. **Clone this repository** to your Emacs config directory:
   ```bash
   git clone <your-repo-url> ~/.config/emacs
   ```

2. **Start Emacs** - it will automatically:
   - Install Elpaca package manager
   - Download and install all packages
   - Configure everything

3. **First startup may take 5-10 minutes** while packages are installed.

## Configuration Structure

```
~/.config/emacs/
├── init.el                 # Main configuration file
├── early-init.el           # Early initialization (performance)
├── config/
│   ├── core/              # Core Emacs settings
│   ├── ui/                # UI packages and themes
│   ├── org/               # Org mode configuration
│   ├── dev/               # Development tools
│   ├── writing/           # Writing tools
│   ├── email/             # Email configuration
│   ├── ai/                # AI tools
│   ├── media/             # Media players
│   └── functions/         # Custom functions
├── docs/                  # Documentation
└── banner/                # Dashboard ASCII art
```

## Customization Required

### 1. Email Configuration (`custom.el`)

Email addresses and names are configured in `custom.el` (not tracked in git). Update these variables:

```elisp
(setq my/gmail-address "your.email@gmail.com"
      my/gmail-name "Your Name"
      my/fastmail-address "your.email@example.com"
      my/fastmail-name "Your Name")
```

**Email Passwords**: This config uses `pass` (password store). Set up your passwords:
```bash
pass insert email/gmail
pass insert email/fastmail
```

### 2. API Keys (`config/ai/ai-tools.el`)

AI tools use `pass` for API keys. Set them up:
```bash
pass insert api-keys/anthropic
pass insert api-keys/openai
pass insert api-keys/perplexity
```

### 3. File Paths

The configuration uses `~/notes/` for notes and `~/src/` for projects. You can customize these in:
- `config/org/denote.el` - Note directories
- `config/org/org-core.el` - Org directories
- `config/dev/development.el` - Project directories

### 4. Fonts (`config/ui/fonts-ligatures.el`)

Default fonts are:
- **Monospace**: MonoLisa Nerd Font
- **Serif**: Literata

Install these fonts or modify the configuration to use your preferred fonts.

### 5. Theme

Default theme is `poet-dark`. Change in `init.el`:
```elisp
(load-theme 'poet-dark t)
```

Available themes: `modus-themes`, `poet-theme`, `doric-themes`, `ef-themes`, `everforest`, `leuven-theme`

## Key Features Explained

### Package Management (Elpaca)

This config uses [Elpaca](https://github.com/progfolio/elpaca) instead of the built-in package.el:
- Faster installation
- Async package processing
- Better dependency management
- Automatic autoload generation

### Completion System

**Vertico**: Vertical completion menu in minibuffer
- `C-n` / `C-p` to navigate
- `TAB` to complete
- `RET` to select

**Corfu**: In-buffer completion popup
- Automatic completion as you type
- `TAB` to accept
- `M-1` to select first candidate

**Cape**: Additional completion backends
- File paths, buffers, symbols, etc.

### Note-Taking Workflow

**Denote**: Zettelkasten-style notes
- `C-c d n` - Create new note
- `C-c d f` - Find note
- `C-c d F` - Quick fleeting note
- Notes are timestamped and keyword-tagged

**Org-GTD**: Getting Things Done
- `C-c g c` - Quick capture
- `C-c g p` - Process inbox
- `C-c g e` - Engage (work on tasks)

**Xeft**: Fast note search
- `C-c z f` - Search notes
- `C-c z n` - New note

### Development Tools

**LSP**: Language Server Protocol
- Automatic setup for many languages
- `M-.` - Go to definition
- `M-,` - Go back
- `C-c e r` - Rename symbol

**Magit**: Git interface
- `C-x g` - Git status
- `C-x v t` - Git timemachine
- `C-x v p` - Git messenger

## Essential Keybindings

### Navigation
- `C-c b` - Switch buffer (Consult)
- `C-x d` - Dired (file manager)
- `M-p` - Switch window (ace-window)
- `C-:` - Jump to character (avy)

### Org Mode
- `C-c a` - Org agenda
- `C-c c` - Org capture
- `C-c l` - Store link

### Denote
- `C-c d n` - New note
- `C-c d f` - Find note
- `C-c d F` - Fleeting note

### Development
- `C-x g` - Magit status
- `C-c p f` - Find file in project
- `C-c s s` - Search in project

### Themes
- `C-c t t` - Toggle theme
- `C-c t d` - Default theme

### Help
- `C-h k` - Describe key
- `C-h f` - Describe function
- `C-h v` - Describe variable

See `docs/quick-reference.md` for a complete keybinding reference.

## Documentation

Comprehensive documentation is available in the `docs/` directory:

- **quick-reference.md** - Essential keybindings cheat sheet
- **new-features-guide.md** - Guide to new features and workflows
- **org-gtd-workflow.md** - Getting Things Done with Org mode
- **denote-workflow.md** - Zettelkasten note-taking guide
- **development-workflow.md** - Development tools and workflows
- **troubleshooting.md** - Common issues and solutions

## Performance

This configuration includes several performance optimizations:

- **Early GC tuning**: High threshold during startup, normal after
- **Lazy loading**: Packages loaded on-demand
- **Native compilation**: Automatic byte-compilation
- **Process output buffering**: Optimized for async operations

## Terminal vs GUI

The configuration adapts to your environment:
- **GUI**: Full theme support, icons, fonts
- **Terminal**: Simplified UI, compatible themes, Nerd Font icons

## Customization

### Adding Packages

Use `use-package` in `init.el`:
```elisp
(use-package my-package
  :ensure t
  :config
  (my-package-mode 1))
```

### Custom Functions

Add custom functions to `config/functions/custom-functions.el`.

### Theme Customization

Themes are loaded in `init.el`. You can:
- Switch themes with `C-c t t`
- Add custom theme files
- Customize faces in `custom.el` (auto-generated, not in repo)

## Troubleshooting

### Packages Not Loading

1. Check Elpaca installation: `M-x elpaca-info`
2. Rebuild packages: `M-x elpaca-rebuild`
3. Check `*Messages*` buffer for errors

### Icons Not Showing

1. Install Nerd Fonts: https://www.nerdfonts.com/
2. Set terminal font to a Nerd Font
3. In GUI, ensure `all-the-icons` fonts are installed: `M-x all-the-icons-install-fonts`

### Email Not Working

1. Install `mu` and `offlineimap`
2. Set up `pass` entries for email passwords
3. Configure email accounts in `config/email/email.el`

### Performance Issues

1. Check `*Messages*` for warnings
2. Profile startup: `M-x emacs-init-time`
3. Disable unused packages in `init.el`

See `docs/troubleshooting.md` for more solutions.

## Contributing

This is a personal configuration, but feel free to:
- Fork and adapt for your needs
- Report issues or suggest improvements
- Share your customizations

## License

This configuration is provided as-is. Individual packages have their own licenses.

## Acknowledgments

This configuration is built on the excellent work of:
- [Elpaca](https://github.com/progfolio/elpaca) - Package manager
- [use-package](https://github.com/jwiegley/use-package) - Package configuration
- [Doom Emacs](https://github.com/doomemacs/doomemacs) - Inspiration for structure
- All the package maintainers and contributors

## Notes

- `custom.el` is auto-generated and excluded from the repository (contains personal paths)
- Email addresses in `config/email/email.el` are placeholders - update before use
- API keys are stored in `pass` (password store), not in the configuration
- File paths use `~/notes/` and `~/src/` - customize as needed

---

**Happy Emacsing!** 🐃

