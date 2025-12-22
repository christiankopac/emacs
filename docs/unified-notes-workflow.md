# Unified Notes & Productivity Workflow

A comprehensive guide to the note-taking system shared between Emacs and Neovim.

---

## 📁 Directory Structure

```
~/notes/
├── org/                          # Primary Org-mode notes (Emacs-centric)
│   ├── journal.org               # Single-file journal with date headings
│   ├── gtd/                      # GTD (Getting Things Done) system
│   │   ├── inbox.org             # Capture everything here first
│   │   ├── tasks.org             # Processed actionable tasks
│   │   ├── areas.org             # Areas of focus/responsibility
│   │   ├── horizons.org          # Long-term vision & goals
│   │   └── vision.org            # Life vision statements
│   ├── denote/                   # Denote PKM notes
│   │   ├── fleeting/             # Quick thoughts, to process later
│   │   ├── permanent/            # Evergreen notes
│   │   └── literature/           # Book/article notes
│   ├── projects/                 # Project-specific notes
│   ├── attachments/              # Images, files linked from notes
│   ├── ~archive/                 # Archived GTD items (by year)
│   └── kopac_ch/                 # Website/blog content
│
├── zk/                           # Zettelkasten notes (Neovim zk-nvim)
│   ├── .zk/                      # zk configuration
│   │   └── templates/            # Note templates
│   └── *.md                      # Markdown notes (ID-slug format)
│
├── nb/                           # nb CLI notebooks
│   ├── home/                     # Default notebook (bookmarks, notes)
│   ├── programming/              # Programming notes
│   └── react/                    # React-specific notes
│
└── archive/                      # General archive
```

---

## 🛠️ Tools Overview

### Emacs Tools

| Tool            | Purpose                        | Config File                        |
| --------------- | ------------------------------ | ---------------------------------- |
| **org-mode**    | Task management, notes, agenda | `org-core.el`, `org-extensions.el` |
| **org-gtd**     | GTD workflow implementation    | `org-extensions.el`                |
| **denote**      | Zettelkasten-style PKM         | `denote.el`                        |
| **org-capture** | Quick capture to inbox         | `org-extensions.el`                |
| **org-agenda**  | Task views & scheduling        | `org-extensions.el`                |

### Neovim Tools

| Tool                | Purpose                   | Config File                       |
| ------------------- | ------------------------- | --------------------------------- |
| **zk-nvim**         | Zettelkasten with LSP     | `lua/plugins/zk.lua`              |
| **mkdnflow**        | Markdown navigation       | `lua/plugins/mkdnflow.lua`        |
| **nb.nvim**         | nb CLI integration        | `lua/plugins/nb.lua`              |
| **render-markdown** | Pretty markdown rendering | `lua/plugins/render-markdown.lua` |

---

## 📓 Journal System

### Structure (Single File)

**File:** `~/org/journal.org`

```org
#+title: Journal
#+filetags: :journal:

* 2025-12-13 Saturday
Today I worked on simplifying my config...

* 2025-12-12 Friday
Meeting notes from the standup...
```

### Emacs Keybindings

| Key               | Command                       | Description                    |
| ----------------- | ----------------------------- | ------------------------------ |
| `C-c c j`         | org-capture → Journal         | Open today's journal entry     |
| `C-c j`           | my/open-todays-journal        | Direct journal access          |
| `j` (in calendar) | my/open-journal-from-calendar | Open journal for selected date |

### Neovim (via nb.nvim)

| Command        | Description             |
| -------------- | ----------------------- |
| `:NbToday`     | Open today's note in nb |
| `:NbYesterday` | Open yesterday's note   |
| `:NbTomorrow`  | Open tomorrow's note    |

---

## ✅ GTD Workflow

### The GTD Process

```
1. CAPTURE → Everything goes to inbox.org
2. CLARIFY → Process inbox items (C-c g p)
3. ORGANIZE → Categorize by type (project, action, reference, etc.)
4. REFLECT → Daily/weekly reviews
5. ENGAGE → Work on next actions
```

### GTD Files

| File           | Purpose                                |
| -------------- | -------------------------------------- |
| `inbox.org`    | Unprocessed captures                   |
| `tasks.org`    | Single next actions                    |
| `areas.org`    | Areas of focus (Health, Finance, etc.) |
| `horizons.org` | Goals and horizons of focus            |
| `vision.org`   | Life purpose & vision                  |

### Areas of Focus

- Health (Physical and Mental Well-being)
- Finance (Financial Management)
- Home (Household Management)
- Relationships (Friends and Family)
- Growth (Personal Development)
- Legal (Administrative matters)
- Programming (Technical skills)
- Work (Professional)
- Music (Musical Pursuits)
- Recreation (Travel, Leisure, Hobbies)

### Emacs GTD Keybindings

| Key       | Command                           | Description           |
| --------- | --------------------------------- | --------------------- |
| `C-c c i` | Capture → Inbox                   | General inbox item    |
| `C-c c t` | Capture → Task                    | TODO item to inbox    |
| `C-c c p` | Capture → Project                 | Multi-step project    |
| `C-c c s` | Capture → Someday                 | Future ideas          |
| `C-c c r` | Capture → Reference               | Reference material    |
| `C-c g c` | org-gtd-capture                   | Direct GTD capture    |
| `C-c g p` | org-gtd-process-inbox             | Process inbox items   |
| `C-c g e` | org-gtd-engage                    | Engage with tasks     |
| `C-c g n` | org-gtd-show-all-next             | Show all next actions |
| `C-c g g` | org-gtd-engage-grouped-by-context | Tasks by context      |

### Agenda Views

| Key       | View              | Description                       |
| --------- | ----------------- | --------------------------------- |
| `C-c a d` | Daily Review      | Today + priorities + deadlines    |
| `C-c a w` | Weekly Review     | Week overview + stuck projects    |
| `C-c a p` | Projects Overview | All active projects               |
| `C-c a h` | Horizons Review   | Vision → Goals → Areas → Projects |

---

## 📝 Denote (Emacs PKM)

### Note Types

| Subdirectory  | Purpose            | Keywords     |
| ------------- | ------------------ | ------------ |
| `fleeting/`   | Quick thoughts     | `fleeting`   |
| `permanent/`  | Evergreen notes    | `permanent`  |
| `literature/` | Book/article notes | `literature` |

### Filename Format

```
YYYYMMDDTHHMMSS--title-slug__keywords.org
```

Example: `20251213T143052--my-note-title__fleeting_idea.org`

### Emacs Keybindings

| Key       | Command               | Description                         |
| --------- | --------------------- | ----------------------------------- |
| `C-c c d` | Capture → Denote      | Create new denote note (fullscreen) |
| `C-c d n` | denote                | Create new note                     |
| `C-c d f` | denote-open-or-create | Find or create note                 |
| `C-c d l` | denote-link           | Insert link to note                 |
| `C-c d b` | denote-backlinks      | Show backlinks                      |
| `C-c d r` | denote-rename-file    | Rename with new metadata            |

---

## 🗃️ Zettelkasten (Neovim zk-nvim)

### Configuration

**Directory:** `~/org/nb/zk/`
**Config:** `~/.config/zk/config.toml`

### Filename Format

```
{id}-{slug}.md
```

Example: `r69u-my-note-title.md`

### zk CLI Commands

```bash
zk new              # Create new note
zk edit             # Edit existing note
zk list             # List notes
zk edit --interactive  # Fuzzy find and edit
```

### zk Aliases (from config)

```bash
zk edlast           # Edit last modified note
zk recent           # Edit recent notes (last 2 weeks)
zk lucky            # Show random note
```

### Neovim Integration

zk-nvim provides LSP features:

- Auto-completion for note links
- Go to definition (follow links)
- Diagnostics for dead links
- Wiki-link title hints

---

## 📚 nb Notebooks (Neovim)

### Current Notebooks

| Notebook      | Purpose                            |
| ------------- | ---------------------------------- |
| `home`        | Default - bookmarks, general notes |
| `programming` | Programming notes & snippets       |
| `react`       | React-specific notes               |

### Neovim Commands

| Command             | Description        |
| ------------------- | ------------------ |
| `:NbAddNote`        | Create new note    |
| `:NbEditNote`       | Edit existing note |
| `:NbSelectNotebook` | Switch notebook    |
| `:NbToday`          | Today's note       |

### nb CLI

```bash
nb add              # Add note
nb edit <id>        # Edit note
nb list             # List notes
nb search <query>   # Search notes
nb bookmark <url>   # Save bookmark
```

---

## 🔄 Cross-Editor Workflow

### Shared Directories

Both editors can access the same notes:

| Directory      | Emacs              | Neovim             |
| -------------- | ------------------ | ------------------ |
| `~/org/` | Primary (org-mode) | Read/edit markdown |
| `~/org/nb/zk/`  | Via denote silos   | Primary (zk-nvim)  |
| `~/notes/nb/`  | Via denote silos   | Primary (nb.nvim)  |

### Recommended Workflow

1. **Quick capture** → Emacs `C-c c t` (anywhere)
2. **Process inbox** → Emacs `C-c g p` (GTD workflow)
3. **Write long-form** → Either editor (preference)
4. **Zettelkasten** → Neovim `zk` for markdown, Emacs `denote` for org
5. **Bookmarks** → Neovim `nb bookmark <url>`
6. **Review agenda** → Emacs `C-c a` (org-agenda)

---

## ⌨️ Quick Reference

### Emacs Capture (C-c c)

```
i → Inbox (general)
t → Task (TODO)
p → Project (with subtasks)
s → Someday/Maybe
r → Reference
j → Journal
d → Denote note
```

### Emacs GTD (C-c g)

```
c → Capture to GTD
p → Process inbox
e → Engage
n → Show next actions
g → Grouped by context
```

### Emacs Agenda (C-c a)

```
d → Daily review
w → Weekly review
p → Projects
h → Horizons
```

### Neovim Notes

```
:NbToday         → Today's nb note
:NbAddNote       → New nb note
zk new           → New zk note (terminal)
<leader>ff       → Find files
<leader>sg       → Grep in files
```

---

## 🔧 Configuration Files

### Emacs

```
~/.config/emacs/
├── config/org/
│   ├── org-core.el        # Core org settings, journal
│   ├── org-extensions.el  # GTD, capture templates, agenda
│   └── denote.el          # Denote PKM configuration
```

### Neovim

```
~/.config/nvim/
├── lua/plugins/
│   ├── zk.lua             # Zettelkasten
│   ├── mkdnflow.lua       # Markdown navigation
│   └── nb.lua             # nb.nvim notebooks
```

### zk CLI

```
~/.config/zk/config.toml   # Global zk configuration
~/org/nb/zk/.zk/            # Local zk config & templates
```

---

## 📅 Daily Workflow Example

### Morning

1. `C-c a d` (Emacs) → Review daily agenda
2. `C-c g n` → Check next actions
3. Pick tasks for the day

### Throughout Day

1. `C-c c t` → Capture tasks as they come
2. `C-c c i` → Capture notes/ideas
3. Work on tasks from agenda

### Evening

1. `C-c c j` → Journal entry
2. `C-c g p` → Process inbox
3. `C-c a w` → Quick weekly review (Friday)

### Weekly Review

1. `C-c a w` → Weekly agenda view
2. `C-c a p` → Review all projects
3. `C-c g p` → Empty inbox completely
4. `C-c a h` → Review horizons alignment

---

_Last updated: 2025-12-13_
