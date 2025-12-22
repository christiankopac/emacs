# Complete Productivity System Documentation

**A comprehensive guide to the unified note-taking and task management system**

_Last Updated: 2025-12-13_

---

## Table of Contents

1. [System Architecture](#system-architecture)
2. [Directory Structure](#directory-structure)
3. [GTD Workflow](#gtd-workflow)
4. [Journal System](#journal-system)
5. [Denote PKM](#denote-pkm)
6. [Zettelkasten (zk)](#zettelkasten-zk)
7. [nb Notebooks](#nb-notebooks)
8. [Emacs Configuration](#emacs-configuration)
9. [Neovim Configuration](#neovim-configuration)
10. [Daily Workflows](#daily-workflows)
11. [Integration & Sync](#integration--sync)
12. [Troubleshooting](#troubleshooting)
13. [Best Practices](#best-practices)

---

## System Architecture

### Overview

This is a **dual-editor productivity system** that combines:

- **Emacs** for GTD task management, org-mode notes, and structured workflows
- **Neovim** for markdown-based zettelkasten, quick notes, and code-related documentation

### Core Principles

1. **Capture Everything** → All inputs go to `inbox.org` first
2. **Process Regularly** → Weekly inbox processing with GTD methodology
3. **Separate by Purpose** → GTD for tasks, Denote/zk for knowledge, nb for bookmarks
4. **Single Source of Truth** → Each note type has one primary editor
5. **Cross-Editor Access** → Both editors can read/write shared directories

### Tool Selection Matrix

| Use Case        | Primary Tool | Editor | Format |
| --------------- | ------------ | ------ | ------ |
| Task Management | org-gtd      | Emacs  | `.org` |
| Daily Journal   | org-mode     | Emacs  | `.org` |
| Evergreen Notes | Denote       | Emacs  | `.org` |
| Zettelkasten    | zk-nvim      | Neovim | `.md`  |
| Bookmarks       | nb.nvim      | Neovim | `.md`  |
| Quick Notes     | nb.nvim      | Neovim | `.md`  |
| Project Notes   | Denote       | Emacs  | `.org` |

---

## Directory Structure

### Complete File Tree

```
~/notes/
│
├── org/                              # Emacs org-mode notes
│   ├── journal.org                   # Single-file journal (date headings)
│   │
│   ├── gtd/                          # GTD system files
│   │   ├── inbox.org                 # ⬇️ Everything captured here first
│   │   ├── tasks.org                 # Single next actions
│   │   ├── areas.org                 # Areas of focus/responsibility
│   │   ├── horizons.org              # Goals (1-2 years)
│   │   └── vision.org                # Vision (3-5 years)
│   │
│   ├── denote/                       # Denote PKM notes
│   │   ├── fleeting/                 # Quick thoughts (to process)
│   │   ├── permanent/                # Evergreen notes
│   │   └── literature/               # Book/article notes
│   │
│   ├── projects/                     # Project-specific notes
│   ├── attachments/                  # Images, PDFs, files
│   ├── ~archive/                     # Archived GTD items (by year)
│   │   └── gtd_2025_archive.org      # Yearly archives
│   └── kopac_ch/                     # Website/blog content
│
├── zk/                               # Zettelkasten (Neovim)
│   ├── .zk/                          # zk configuration
│   │   ├── config.toml               # Local config
│   │   └── templates/                # Note templates
│   │       └── default.md
│   └── *.md                          # Notes (ID-slug format)
│
└── nb/                               # nb CLI notebooks
    ├── .current                      # Current notebook pointer
    ├── home/                         # Default notebook
    ├── programming/                  # Programming notes
    └── react/                        # React-specific notes
```

### Directory Purposes

| Directory         | Purpose                | Managed By     |
| ----------------- | ---------------------- | -------------- |
| `org/journal.org` | Daily journal entries  | Emacs          |
| `org/gtd/`        | Task management system | Emacs org-gtd  |
| `org/denote/`     | Knowledge base (PKM)   | Emacs denote   |
| `org/projects/`   | Project documentation  | Emacs denote   |
| `zk/`             | Zettelkasten notes     | Neovim zk-nvim |
| `nb/`             | Notebooks & bookmarks  | Neovim nb.nvim |

---

## GTD Workflow

### The Five Stages

#### 1. CAPTURE

**Goal:** Get everything out of your head

**Methods:**

- `C-c c t` → Quick task capture
- `C-c c i` → General inbox item
- `C-c g c` → Direct GTD capture (no template menu)

**Destination:** `~/org/gtd/inbox.org`

**Example:**

```org
* TODO Review quarterly budget
  :PROPERTIES:
  :CREATED:  [2025-12-13 Fri 14:30]
  :END:
  Captured from meeting with finance team
```

#### 2. CLARIFY

**Goal:** Decide what each item means and what to do with it

**Command:** `C-c g p` (org-gtd-process-inbox)

**Decisions:**

- **Trash** → Delete it
- **Reference** → Store for later (no action)
- **Someday/Maybe** → Future possibility
- **Quick Action** (<2 min) → Do it now
- **Single Action** → Add to tasks.org
- **Project** → Create project with next action
- **Calendar** → Schedule for specific time
- **Delegated** → Assign to someone else
- **Habit** → Recurring action
- **Incubated** → Remind me later

**Areas of Focus:**
When clarifying, items are tagged with areas:

- Health, Finance, Home
- Relationships, Growth, Legal
- Programming, Work
- Music, Recreation

#### 3. ORGANIZE

**Goal:** Put items in the right place

**Files:**

- `tasks.org` → Single next actions
- `areas.org` → Areas of focus
- `horizons.org` → Goals
- `vision.org` → Life vision

**During Clarify:**

- Items automatically organized by type
- Areas of focus assigned via prompts
- Projects created with initial next actions

#### 4. REFLECT

**Goal:** Review and update your system

**Daily Review:**

- `C-c a d` → Daily agenda view
- Check scheduled items
- Review priorities

**Weekly Review:**

- `C-c a w` → Weekly overview
- `C-c g p` → Process entire inbox
- `C-c a p` → Review all projects
- `C-c a h` → Review horizons alignment

#### 5. ENGAGE

**Goal:** Do the work

**Commands:**

- `C-c g e` → Engage with tasks
- `C-c g n` → Show all next actions
- `C-c g g` → Tasks grouped by context
- `C-c a` → Agenda views

### GTD File Structure

#### inbox.org

```org
* TODO Call dentist for appointment
  :PROPERTIES:
  :CREATED:  [2025-12-13 Fri 10:00]
  :END:

* Review project proposal
  :PROPERTIES:
  :CREATED:  [2025-12-13 Fri 11:30]
  :END:
```

#### tasks.org

```org
* TODO Email Sarah about meeting
  :PROPERTIES:
  :ORG_GTD: Actions
  :AREA: Work
  :END:

* TODO Buy groceries
  :PROPERTIES:
  :ORG_GTD: Actions
  :AREA: Home
  :END:
```

#### areas.org

```org
* Health
  :PROPERTIES:
  :AREA: Health
  :END:
  Physical and mental well-being

* Finance
  :PROPERTIES:
  :AREA: Finance
  :END:
  Financial management and budgeting
```

### GTD Keybindings Reference

| Key       | Command                           | Description         |
| --------- | --------------------------------- | ------------------- |
| `C-c c i` | Capture → Inbox                   | General inbox item  |
| `C-c c t` | Capture → Task                    | TODO item           |
| `C-c c p` | Capture → Project                 | Multi-step project  |
| `C-c c s` | Capture → Someday                 | Future ideas        |
| `C-c c r` | Capture → Reference               | Reference material  |
| `C-c g c` | org-gtd-capture                   | Direct GTD capture  |
| `C-c g p` | org-gtd-process-inbox             | Process inbox       |
| `C-c g e` | org-gtd-engage                    | Engage with tasks   |
| `C-c g n` | org-gtd-show-all-next             | All next actions    |
| `C-c g g` | org-gtd-engage-grouped-by-context | By context          |
| `C-c g s` | org-gtd-clarify-switch-to-buffer  | Clarify buffer      |
| `C-c g a` | org-gtd-clarify-agenda-item       | Clarify from agenda |
| `C-c g i` | org-gtd-clarify-item              | Clarify item        |

### Agenda Views

#### Daily Review (`C-c a d`)

Shows:

- Today's scheduled items
- High priority tasks (PRIORITY="A")
- Due this week
- Waiting/Delegated items

#### Weekly Review (`C-c a w`)

Shows:

- Week overview
- Stuck projects
- Coming deadlines (next 14 days)
- Delegated tasks

#### Projects Overview (`C-c a p`)

Shows:

- Active projects (LEVEL=2)
- Current goals (LEVEL=2)
- Life areas (LEVEL=2)

#### Horizons Review (`C-c a h`)

Shows:

- Vision (3-5 years) - LEVEL=1
- Goals (1-2 years) - LEVEL=2
- Areas of focus - LEVEL=2
- Active projects - LEVEL=2
- Next actions

### Areas of Focus

Defined in `org-extensions.el`:

```elisp
org-gtd-areas-of-focus '(
  "Health"         ;; Physical and Mental Well-being
  "Finance"        ;; Financial Management
  "Home"           ;; Household Management
  "Relationships"  ;; Friends and Relationships
  "Growth"         ;; Personal Growth and Self-Improvement
  "Legal"          ;; Administrative matters
  "Programming"   ;; Technical skills
  "Work"           ;; Professional and Job-Related
  "Music"          ;; Musical Pursuits
  "Recreation"     ;; Travel, Leisure and Hobbies
)
```

---

## Journal System

### Structure

**Single File:** `~/org/journal.org`

**Format:**

```org
#+title: Journal
#+filetags: :journal:

* 2025-12-13 Saturday
Today I worked on simplifying my Emacs configuration.
The journal system is now much cleaner.

* 2025-12-12 Friday
Had a productive meeting with the team.
Need to follow up on the project proposal.
```

### Features

- **Simple date headings** → `* YYYY-MM-DD DayName`
- **No templates** → Just write under the date
- **Auto-creation** → Date entry created if missing
- **Quick navigation** → Jump to any date

### Keybindings

| Key            | Command                       | Description            |
| -------------- | ----------------------------- | ---------------------- |
| `C-c c j`      | org-capture → Journal         | Open today's journal   |
| `C-c j`        | my/open-todays-journal        | Direct journal access  |
| `j` (calendar) | my/open-journal-from-calendar | Open for selected date |

### Implementation

**Function:** `my/open-journal-for-date` (in `org-core.el`)

**Behavior:**

1. Opens `~/org/journal.org`
2. Searches for date heading
3. Creates if missing
4. Positions cursor at end of entry

**Code:**

```elisp
(defun my/open-journal-for-date (date-string)
  "Open journal.org and navigate to DATE-STRING entry (YYYYMMDD format)."
  (let* ((journal-file (expand-file-name "~/org/journal.org"))
         (year (string-to-number (substring date-string 0 4)))
         (month (string-to-number (substring date-string 4 6)))
         (day (string-to-number (substring date-string 6 8)))
         (date-obj (encode-time 0 0 0 day month year))
         (date-heading (format-time-string "%Y-%m-%d %A" date-obj)))
    ;; Create file if needed
    (unless (file-exists-p journal-file)
      (with-temp-file journal-file
        (insert "#+title: Journal\n#+filetags: :journal:\n\n")))
    ;; Open and navigate
    (find-file journal-file)
    (goto-char (point-min))
    (if (re-search-forward (concat "^\\* " (regexp-quote date-heading)) nil t)
        (progn
          (org-end-of-subtree)
          (unless (bolp) (insert "\n")))
      (goto-char (point-max))
      (unless (bolp) (insert "\n"))
      (insert (format "* %s\n\n" date-heading)))
    (message "Journal: %s" date-heading)))
```

---

## Denote PKM

### Overview

**Denote** is the primary knowledge management system in Emacs. It provides:

- Unique file identifiers (timestamp-based)
- Keyword tagging
- Backlinks
- Subdirectory organization

### File Naming

**Format:** `YYYYMMDDTHHMMSS--title-slug__keywords.org`

**Example:** `20251213T143052--emacs-configuration-tips__fleeting_emacs.org`

**Components:**

- `20251213T143052` → Timestamp (unique ID)
- `--` → Separator
- `emacs-configuration-tips` → Title slug
- `__` → Keyword separator
- `fleeting_emacs` → Keywords

### Subdirectories

| Directory     | Purpose            | Keywords     |
| ------------- | ------------------ | ------------ |
| `fleeting/`   | Quick thoughts     | `fleeting`   |
| `permanent/`  | Evergreen notes    | `permanent`  |
| `literature/` | Book/article notes | `literature` |

### Known Keywords

```elisp
denote-known-keywords '(
  "fleeting"
  "permanent"
  "literature"
  "reference"
  "project"
)
```

### Keybindings

| Key       | Command                         | Description              |
| --------- | ------------------------------- | ------------------------ |
| `C-c c d` | Capture → Denote                | Create note (fullscreen) |
| `C-c d n` | denote                          | Create new note          |
| `C-c d N` | denote-subdirectory             | Create in subdirectory   |
| `C-c d f` | denote-open-or-create           | Find or create           |
| `C-c d l` | denote-link                     | Insert link to note      |
| `C-c d b` | denote-backlinks                | Show backlinks           |
| `C-c d t` | denote-backlinks-toggle-context | Toggle context           |

### Backlinks

**Display:**

- Bottom window (45% width)
- Shows only titles (no paths)
- Read-only mode
- Updates automatically

**Configuration:**

```elisp
(setq denote-backlinks-display-buffer-action
      '((display-buffer-reuse-window display-buffer-in-side-window)
        (side . bottom)
        (dedicated . t)
        (window-width . 45)
        (slot . 0)
        (preserve-size . (t .t))
        (window-parameters . ((no-delete-other-windows . t)))))
```

### Denote Silos

**Silos** are directories that Denote can access:

```elisp
my-denote-silos '(
  ("denote" . "~/org/denote/")
  ("gtd" . "~/org/")
  ("projects" . "~/org/gtd/projects/")
  ("nb" . "~/org/nb/")
  ("zk" . "~/org/nb/zk/")
  ("archive" . "~/org/archive/")
)
```

**Usage:**

- Browse silos with `denote-dired`
- Link between silos
- Search across silos

### Workflow

1. **Quick Capture** → `C-c c d` → Create fleeting note
2. **Process Later** → Move to `permanent/` if valuable
3. **Link Notes** → `C-c d l` → Create connections
4. **Review Backlinks** → `C-c d b` → See connections

---

## Zettelkasten (zk)

### Overview

**zk** is a markdown-based zettelkasten system, primarily used in Neovim.

**Directory:** `~/org/nb/zk/`

**Config:** `~/.config/zk/config.toml`

### File Naming

**Format:** `{id}-{slug}.md`

**Example:** `r69u-emacs-productivity-tips.md`

**ID Generation:**

- Random alphanumeric
- 4 characters
- Lowercase

### Configuration

**From `~/.config/zk/config.toml`:**

```toml
[note]
language = "en"
default-title = "Untitled"
filename = "{{id}}-{{slug title}}"
extension = "md"
template = "default.md"

id-charset = "alphanum"
id-length = 4
id-case = "lower"

[format.markdown]
hashtags = true
colon-tags = true

[tool]
editor = "nvim"
```

### zk CLI Commands

```bash
zk new                    # Create new note
zk edit                   # Edit existing note
zk list                   # List all notes
zk edit --interactive     # Fuzzy find and edit
zk search <query>         # Search notes
```

### zk Aliases

```bash
zk edlast                 # Edit last modified note
zk recent                 # Edit recent notes (last 2 weeks)
zk lucky                  # Show random note
```

### Neovim Integration

**Plugin:** `zk-org/zk-nvim`

**Features:**

- LSP integration
- Auto-completion for links
- Go to definition (follow links)
- Diagnostics for dead links
- Wiki-link title hints

**Configuration:**

```lua
require("zk").setup({
  picker_options = {
    snacks_picker = {
      layout = {
        preset = "ivy",
      }
    }
  },
  lsp = {
    config = {
      name = "zk",
      cmd = { "zk", "lsp" },
      filetypes = { "markdown" },
    },
    auto_attach = {
      enabled = true,
    },
  },
})
```

### Workflow

1. **Create Note** → `zk new` or via Neovim
2. **Link Notes** → Use `[[note-id]]` syntax
3. **Follow Links** → LSP go-to-definition
4. **Search** → `zk search <query>`

---

## nb Notebooks

### Overview

**nb** is a CLI-based notebook system, integrated with Neovim.

**Directory:** `~/notes/nb/`

### Notebooks

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
| `:NbYesterday`      | Yesterday's note   |
| `:NbTomorrow`       | Tomorrow's note    |

### Configuration

```lua
require("nb-nvim").setup({
  notebook = "commonplace",  -- Default notebook
})
```

### nb CLI

```bash
nb add                    # Add note
nb edit <id>              # Edit note
nb list                   # List notes
nb search <query>          # Search notes
nb bookmark <url>         # Save bookmark
nb notebooks              # List notebooks
nb use <notebook>         # Switch notebook
```

### File Format

**Bookmarks:** `{timestamp}.bookmark.md`
**Notes:** `{timestamp}.md`

**Example:**

- `20251016233748.bookmark.md` → Bookmark
- `20251017020343.md` → Regular note

---

## Emacs Configuration

### Configuration Files

```
~/.config/emacs/
├── init.el                    # Main entry point
├── config/
│   ├── org/
│   │   ├── org-core.el        # Core org settings, journal
│   │   ├── org-extensions.el  # GTD, capture, agenda
│   │   └── denote.el          # Denote PKM
│   └── ...
```

### Key Configuration Points

#### org-core.el

**Journal Function:**

- `my/open-journal-for-date` → Opens journal for date
- `my/open-todays-journal` → Opens today's journal
- `my/open-journal-from-calendar` → Opens from calendar

**Org Settings:**

```elisp
org-directory "~/org/"
org-agenda-files '("~/org/journal.org" "~/org")
org-refile-targets '(
  ("~/org/gtd/inbox.org" :maxlevel . 1)
  ("~/org/gtd/tasks.org" :maxlevel . 1)
  ("~/org/gtd/areas.org" :maxlevel . 1)
  ("~/org/gtd/vision.org" :maxlevel . 1)
  ("~/org/gtd/horizons.org" :maxlevel . 1)
)
```

#### org-extensions.el

**GTD Configuration:**

```elisp
org-gtd-directory "~/org/gtd"
org-gtd-default-file-name "inbox"
org-gtd-inbox (expand-file-name "inbox.org" org-gtd-directory)
```

**Capture Templates:**

- `i` → Inbox
- `t` → Task
- `p` → Project
- `s` → Someday/Maybe
- `r` → Reference
- `j` → Journal
- `d` → Denote

#### denote.el

**Silos:**

```elisp
my-denote-silos '(
  ("denote" . "~/org/denote/")
  ("gtd" . "~/org/")
  ("projects" . "~/org/gtd/projects/")
  ("nb" . "~/org/nb/")
  ("zk" . "~/org/nb/zk/")
  ("archive" . "~/org/archive/")
)
```

**Settings:**

```elisp
denote-file-type 'org
denote-subdirectories '("fleeting" "permanent" "literature")
denote-known-keywords '("fleeting" "permanent" "literature" "reference" "project")
```

---

## Neovim Configuration

### Configuration Files

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── plugins/
│   │   ├── zk.lua              # Zettelkasten
│   │   ├── mkdnflow.lua        # Markdown navigation
│   │   └── nb.lua              # nb.nvim
│   └── config/
│       ├── keymaps.lua
│       └── options.lua
```

### Key Plugins

#### zk-nvim (`zk.lua`)

**Features:**

- LSP integration
- Picker integration (snacks)
- Auto-completion
- Link following

#### mkdnflow (`mkdnflow.lua`)

**Purpose:** Markdown navigation and utilities

#### nb.nvim (`nb.lua`)

**Purpose:** nb CLI integration

**Commands:**

- `:NbAddNote`
- `:NbEditNote`
- `:NbSelectNotebook`
- `:NbToday`

### Keybindings

**Snacks Picker:**

- `<leader>ff` → Find files
- `<leader>sg` → Grep
- `<leader>fr` → Recent files

---

## Daily Workflows

### Morning Routine

1. **Open Emacs**
2. **Daily Review** → `C-c a d`
   - Check scheduled items
   - Review priorities
   - Check deadlines
3. **Select Tasks** → Pick 3-5 tasks for the day
4. **Start Working**

### Throughout the Day

1. **Capture Tasks** → `C-c c t` (anywhere)
2. **Capture Ideas** → `C-c c i`
3. **Quick Notes** → `C-c c d` (Denote)
4. **Work on Tasks** → From agenda or `C-c g e`

### Evening Routine

1. **Journal Entry** → `C-c c j`
2. **Process Inbox** → `C-c g p` (if time)
3. **Review Tomorrow** → `C-c a d` (check scheduled)

### Weekly Review (Friday)

1. **Process Inbox** → `C-c g p` → Empty completely
2. **Weekly Agenda** → `C-c a w`
3. **Projects Review** → `C-c a p`
4. **Horizons Review** → `C-c a h`
5. **Plan Next Week** → Schedule items

### Monthly Review

1. **Review All Projects** → `C-c a p`
2. **Review Areas** → Check `areas.org`
3. **Review Goals** → Check `horizons.org`
4. **Review Vision** → Check `vision.org`
5. **Archive Completed** → Move to `~archive/`

---

## Integration & Sync

### Shared Directories

Both editors can access:

| Directory      | Emacs               | Neovim       |
| -------------- | ------------------- | ------------ |
| `~/org/`       | ✅ Primary          | ✅ Read/edit |
| `~/org/nb/zk/` | ✅ Via denote silos | ✅ Primary   |
| `~/notes/nb/`  | ✅ Via denote silos | ✅ Primary   |

### Cross-Editor Workflow

**Example: Capture in Emacs, Review in Neovim**

1. Capture task → Emacs `C-c c t`
2. Process inbox → Emacs `C-c g p`
3. Review notes → Neovim (if markdown)

**Example: Create zk Note, Link from Denote**

1. Create note → Neovim `zk new`
2. Link from Denote → Emacs `C-c d l` → Navigate to `zk/` silo

### File Format Compatibility

| Format | Emacs        | Neovim       |
| ------ | ------------ | ------------ |
| `.org` | ✅ Native    | ✅ Read/edit |
| `.md`  | ✅ Read/edit | ✅ Native    |

### Sync Considerations

- **No automatic sync** → Manual file access
- **Git** → Can version control notes
- **File conflicts** → Rare (different primary tools)

---

## Troubleshooting

### Common Issues

#### 1. Journal Not Opening

**Symptom:** `C-c c j` fails with date parsing error

**Solution:** Check `my/open-journal-for-date` function in `org-core.el`

**Fix:** Ensure date parsing uses `string-to-number` not `org-parse-time-string`

#### 2. Capture Templates Not Working

**Symptom:** Templates capture to wrong location

**Solution:** Check `org-capture-templates` uses backquotes `` ` `` not quotes `'`

**Fix:** Use `(file ,org-gtd-inbox)` not `(file org-gtd-inbox)`

#### 3. Denote Backlinks Not Showing

**Symptom:** Backlinks buffer empty or not appearing

**Solution:**

- Check `denote-backlinks-display-buffer-action`
- Ensure `denote-backlinks-show-files` is `t`
- Verify note has links

#### 4. GTD Process Inbox Not Working

**Symptom:** `C-c g p` doesn't open clarify buffer

**Solution:**

- Check `org-gtd-mode` is `t`
- Verify `org-gtd-directory` is correct
- Check `inbox.org` exists and has items

#### 5. zk LSP Not Working

**Symptom:** No auto-completion in Neovim

**Solution:**

- Check `zk lsp` command works in terminal
- Verify LSP config in `zk.lua`
- Check `zk` is in PATH

### Debug Commands

**Emacs:**

```elisp
M-x describe-variable RET org-gtd-inbox
M-x describe-variable RET org-capture-templates
M-x describe-function RET my/open-journal-for-date
```

**Neovim:**

```lua
:checkhealth zk
:LspInfo
```

---

## Best Practices

### GTD Best Practices

1. **Process Inbox Daily** → Don't let it pile up
2. **Weekly Review** → Essential for system health
3. **One Inbox** → Everything goes to `inbox.org`
4. **Clear Next Actions** → Tasks should be actionable
5. **Regular Archive** → Move completed items

### Journal Best Practices

1. **Write Daily** → Even if brief
2. **No Structure** → Just write under date
3. **Review Weekly** → Look back at entries
4. **Keep Simple** → Single file, date headings

### Denote Best Practices

1. **Start Fleeting** → Move to permanent if valuable
2. **Link Liberally** → Create connections
3. **Use Keywords** → Tag for retrieval
4. **Review Backlinks** → Discover connections

### zk Best Practices

1. **Atomic Notes** → One idea per note
2. **Link Notes** → Create web of knowledge
3. **Use IDs** → Don't rename manually
4. **Search Regularly** → Discover forgotten notes

### General Best Practices

1. **Capture Immediately** → Don't trust memory
2. **Process Regularly** → Weekly inbox processing
3. **Review System** → Monthly system review
4. **Keep Simple** → Don't over-complicate
5. **Use What Works** → Adapt to your needs

---

## Quick Reference

### Emacs Capture (C-c c)

```
i → Inbox
t → Task
p → Project
s → Someday/Maybe
r → Reference
j → Journal
d → Denote
```

### Emacs GTD (C-c g)

```
c → Capture
p → Process inbox
e → Engage
n → Next actions
g → Grouped by context
```

### Emacs Agenda (C-c a)

```
d → Daily
w → Weekly
p → Projects
h → Horizons
```

### Emacs Denote (C-c d)

```
n → New note
f → Find or create
l → Link
b → Backlinks
```

### Neovim Notes

```
:NbToday         → Today's note
:NbAddNote       → New note
zk new           → New zk note
zk recent        → Recent notes
```

---

## Appendix

### Configuration Locations

**Emacs:**

- Main: `~/.config/emacs/init.el`
- Org: `~/.config/emacs/config/org/`
- Denote: `~/.config/emacs/config/org/denote.el`

**Neovim:**

- Main: `~/.config/nvim/init.lua`
- Plugins: `~/.config/nvim/lua/plugins/`

**zk:**

- Global: `~/.config/zk/config.toml`
- Local: `~/org/nb/zk/.zk/config.toml`

### File Formats

**Org Mode:**

- Headings: `* Heading`
- TODO: `* TODO Task`
- Links: `[[file:path.org][description]]`
- Tags: `:tag1:tag2:`

**Markdown (zk):**

- Headings: `# Heading`
- Links: `[[note-id]]`
- Tags: `#tag` or `:tag:`

### Useful Commands

**Emacs:**

```elisp
M-x org-agenda
M-x org-capture
M-x denote
M-x org-gtd-process-inbox
```

**Neovim:**

```vim
:NbToday
:NbAddNote
zk new
zk edit --interactive
```

**Terminal:**

```bash
zk new
zk edit --interactive
zk search <query>
nb add
nb list
```

---

_Document maintained in: `~/org/denote/`_
_Last comprehensive update: 2025-12-13_
