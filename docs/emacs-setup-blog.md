+++
title = "My Emacs Configuration: A Productivity Powerhouse"
description = "A comprehensive guide to my Emacs setup for note-taking, task management, and writing"
date = 2025-01-27
draft = false
tags = ["emacs", "org-mode", "productivity", "gtd", "note-taking"]
categories = ["emacs", "productivity"]
+++

# My Emacs Configuration: A Productivity Powerhouse

This is a comprehensive guide to my Emacs configuration, focusing on productivity workflows, task management with Getting Things Done (GTD), note-taking, and writing. I've spent considerable time refining this setup to create a seamless, efficient workflow that adapts to how I work.

## Table of Contents

1. [Overview](#overview)
2. [Core Philosophy](#core-philosophy)
3. [File Structure](#file-structure)
4. [Getting Things Done (GTD) Workflow](#getting-things-done-gtd-workflow)
5. [Keybindings Reference](#keybindings-reference)
6. [Org Mode Configuration](#org-mode-configuration)
7. [Journal System](#journal-system)
8. [Note-Taking with Denote](#note-taking-with-denote)
9. [Agenda and Task Management](#agenda-and-task-management)
10. [Productivity Workflows](#productivity-workflows)
11. [Writing and Export](#writing-and-export)
12. [Development Tools](#development-tools)
13. [UI and Customization](#ui-and-customization)

---

## Overview

My Emacs configuration is built around **Org mode**, a powerful plain-text markup and organization system. The setup emphasizes:

- **Simplicity**: Minimal file structure, clear workflows
- **Speed**: Quick capture, fast navigation
- **Flexibility**: Adapts to different contexts (work, personal, creative)
- **Integration**: Seamless flow between capture, processing, and execution

### Key Features

- **GTD Implementation**: Full Getting Things Done workflow with org-gtd
- **Unified Journal**: Single journal file with datetree structure
- **Simplified Capture**: One inbox, clear templates
- **Powerful Agenda**: Custom views for daily, weekly, and project reviews
- **Note-Taking**: Denote for permanent notes, Org for tasks
- **Beautiful UI**: Modern fonts, themes, and visual enhancements

---

## Core Philosophy

### The Two-Minute Rule

If something takes less than two minutes, do it immediately. Otherwise, capture it.

### Inbox Zero

Everything starts in the inbox. Regular processing (ideally daily) moves items to their proper homes.

### Context-Based Work

Tasks are tagged with contexts (`@computer`, `@home`, `@errands`) so you can work efficiently based on where you are and what resources you have.

### Single Source of Truth

- **Journal**: One file (`journal.org`) for all daily entries
- **Tasks**: Organized in `tasks.org`, `work.org`, `personal.org`
- **Inbox**: Everything captured goes to `inbox.org` first

---

## File Structure

```
~/org/
├── journal.org              # Single journal file (datetree)
├── inbox.org                # GTD inbox
├── tasks.org                # GTD tasks
├── work.org                 # Work-related items
├── personal.org             # Personal items
├── routines.org             # Routines
├── gtd/
│   ├── inbox.org            # Capture everything here
│   ├── tasks.org            # Processed actionable tasks
│   ├── work.org             # Work-related projects and tasks
│   ├── personal.org         # Personal projects and tasks
│   └── routines.org         # Time-bound recurring routines (daily/weekly)
└── ~archive/                # Archived completed items
```

### Why This Structure?

**Before**: Multiple journal files per day, scattered task files, unclear organization.

**After**:

- One journal file makes searching and reviewing easier
- Clear separation: inbox → tasks → work/personal
- Simple file structure reduces cognitive load

---

## Organizational Principles and Best Practices

### Flat vs Hierarchical: What Works Best?

After years of experimentation, here are the principles that work best for maintaining a productive system with minimal overhead.

#### Principle 1: Prefer Flat Structures for Active Files

**What to Keep Flat:**

- **Journal**: One file (`journal.org`) with datetree structure
- **Inbox**: One file (`inbox.org`) - everything captured here
- **Tasks**: One file (`tasks.org`) - all actionable items
- **Work/Personal**: One file each - not split by project

**Why Flat Works:**

1. **No Decision Overhead**: Don't think "which folder?" - just capture
2. **Faster Search**: One file to search, not multiple directories
3. **Easier Navigation**: No folder structure to remember
4. **Better Linking**: Links work within same file or across files, not across folders
5. **Simpler Maintenance**: Fewer files to manage, backup, sync

**Example - Flat Structure:**

```
gtd/
├── inbox.org          # All captures
├── tasks.org          # All tasks (work + personal mixed)
├── work.org           # Work projects
└── personal.org       # Personal projects
```

**Anti-Pattern - Over-Hierarchical:**

```
gtd/
├── inbox/
│   ├── work-inbox.org
│   ├── personal-inbox.org
│   └── urgent-inbox.org
├── tasks/
│   ├── work/
│   │   ├── project-a-tasks.org
│   │   ├── project-b-tasks.org
│   │   └── meetings-tasks.org
│   └── personal/
│       ├── home-tasks.org
│       └── health-tasks.org
└── projects/
    ├── work/
    └── personal/
```

**Problems with Over-Hierarchical:**

- Too many decisions: "Is this work or personal? Which project folder?"
- Hard to search: Need to search multiple files
- Maintenance burden: More files to manage
- Context switching: Jumping between files/folders
- Link complexity: Links across folder structures

#### Principle 2: Use Tags and Properties, Not Folders

**Instead of folders, use:**

- **Tags**: `:work:`, `:personal:`, `:project-name:`
- **Properties**: `:CATEGORY:`, `:PROJECT:`, `:CONTEXT:`
- **Keywords** (in Denote): `work`, `personal`, `project-name`

**Why This Works:**

1. **Multiple Categories**: One item can have multiple tags
2. **Flexible Filtering**: Filter by any combination of tags
3. **No File Management**: Don't move files when context changes
4. **Agenda Integration**: Org agenda filters by tags automatically
5. **Search Power**: Search by tag across all files

**Example:**

```org
* TODO Review quarterly budget :work:finance:urgent:
  :PROPERTIES:
  :CATEGORY: Work
  :PROJECT: Budget Planning
  :CONTEXT: @computer
  :END:
```

**Filter in Agenda:**

- `C-c a m` then type `work` - see all work items
- `C-c a m` then type `finance` - see all finance items
- `C-c a m` then type `work&finance` - see work finance items

#### Principle 3: Separate by Life Area, Not by Project

**Good Separation:**

- `work.org` - All work-related items
- `personal.org` - All personal items
- `tasks.org` - General actionable items

**Why This Works:**

- **Clear Boundaries**: Work vs personal is usually clear
- **Context Switching**: Easy to focus on one area
- **Review Cycles**: Review work separately from personal
- **Privacy**: Easy to exclude work from personal backups

**Avoid:**

- Splitting by project (too many files)
- Splitting by date (unnecessary - use datetree in journal)
- Splitting by priority (use tags instead)

#### Principle 4: Use Subdirectories Only for Denote Silos

**When Folders Make Sense:**

- **Denote Silos**: Different contexts (work/personal/projects)
- **Archive**: Completed items by year
- **Attachments**: Media files, images

**Denote Silo Structure:**

```
denote/
├── fleeting/      # Quick notes
├── permanent/     # Polished notes
└── literature/    # Book/article notes
```

**Why This Works for Denote:**

- Denote files are permanent knowledge, not tasks
- Silos provide context separation
- Subdirectories help with workflow stages (fleeting → permanent)
- Search still works across all silos

**Archive Structure:**

```
~archive/
├── 2024_archive.org
├── 2023_archive.org
└── 2022_archive.org
```

**Why Yearly Archives:**

- Easy to find old items
- Keeps active files small
- Simple backup strategy

#### Principle 5: Minimize File Count

**Target File Count:**

- **Active Files**: 5-10 files maximum
- **Archive Files**: One per year
- **Denote Files**: Many files, but organized in silos

**Active File Structure:**

```
gtd/
├── inbox.org          # 1 file
├── tasks.org          # 1 file
├── work.org           # 1 file
└── personal.org       # 1 file

journal.org            # 1 file

denote/
├── fleeting/          # Many files, but organized
├── permanent/         # Many files, but organized
└── literature/        # Many files, but organized
```

**Why Fewer Files:**

1. **Less Cognitive Load**: Remember 5 files, not 50
2. **Faster Navigation**: Fewer files to choose from
3. **Better Search**: Search fewer files
4. **Easier Backup**: Backup 5 files, not 50
5. **Simpler Sync**: Sync fewer files

#### Principle 6: Use Org's Built-in Organization

**Org Mode Features to Use:**

- **Headings**: Organize within files using headings
- **Tags**: Categorize with tags
- **Properties**: Store metadata in properties
- **Refile**: Move items between files easily
- **Archive**: Archive completed items

**Example - Organized Within One File:**

```org
* Work
** Projects
*** TODO Project A :project-a:
*** TODO Project B :project-b:
** Meetings
*** TODO Weekly standup :meeting:
** Admin
*** TODO Update timesheet :admin:

* Personal
** Health
*** TODO Exercise :health:
** Home
*** TODO Fix door :home:
```

**Benefits:**

- All work items in one file
- Organized by headings (collapsible)
- Tagged for filtering
- Easy to navigate with `C-c C-n` / `C-c C-p`
- Search works across entire file

#### Principle 7: Archive Regularly, Don't Delete

**Archive Strategy:**

- **Completed Tasks**: Archive to yearly archive file
- **Old Projects**: Archive when project ends
- **Old Denote**: Keep all denote (they're knowledge)

**Archive Workflow:**

1. Mark task as DONE
2. `C-c C-x C-a` - Archive subtree
3. Item moves to `~archive/YYYY_archive.org`
4. Link preserved - can still reference

**Why Archive, Not Delete:**

- Historical record
- Can reference old items
- Links still work
- Easy to find if needed

### Decision Tree: Where Does This Go?

**For Tasks:**

1. **Is it actionable?**

   - **No** → Delete, file as reference (denote), or incubate
   - **Yes** → Continue

2. **Is it work or personal?**

   - **Work** → `work.org`
   - **Personal** → `personal.org`
   - **Unclear** → `tasks.org`

3. **Is it a project or single action?**
   - **Project** → Create project heading, add to work/personal
   - **Single action** → Add as task under appropriate area

**For Notes (Denote):**

1. **What type of note?**

   - **Quick capture** → `fleeting/`
   - **Polished knowledge** → `permanent/`
   - **Book/article** → `literature/`

2. **What context?**

   - **Work** → Work silo
   - **Personal** → Personal silo
   - **General** → Default denote silo

3. **Add keywords** for organization (not folders)

**For Journal:**

- **Everything** → `journal.org`
- **Use datetree** for date organization
- **Use headings** for sections (Morning/Afternoon/Evening)

### Maintenance Rules

**Daily:**

- Process inbox (move items to appropriate files)
- Add to journal
- Don't create new files

**Weekly:**

- Review all active files
- Archive completed items
- Refine tags and properties

**Monthly:**

- Review archive files
- Consolidate similar items
- Clean up unused tags

**Yearly:**

- Create new archive file
- Review old archives
- Consolidate if needed

### Anti-Patterns to Avoid

1. **Too Many Files**: More than 10 active files
2. **Deep Hierarchies**: More than 2-3 folder levels
3. **Project-Specific Files**: One file per project
4. **Date-Based Files**: One file per day/week/month (except journal)
5. **Priority Files**: Separate files for high/medium/low priority
6. **Context Files**: Separate files for each context (@home, @work, etc.)
7. **Status Files**: Separate files for TODO, NEXT, WAIT

**Instead:**

- Use tags for projects, priorities, contexts, status
- Use headings for organization within files
- Use properties for metadata
- Use agenda filters for views

### Summary: The Golden Rules

1. **Fewer Files**: 5-10 active files maximum
2. **Flat Structure**: Avoid deep folder hierarchies
3. **Tags Over Folders**: Use tags and properties for organization
4. **Life Areas**: Separate work/personal, not by project
5. **Archive Regularly**: Keep active files small
6. **Use Org Features**: Headings, tags, properties, refile
7. **Minimize Decisions**: Don't think "where does this go?" - use defaults

**The Test:**

If you have to think more than 2 seconds about where something goes, your structure is too complex. Simplify.

---

## Getting Things Done (GTD) Workflow

### The Five-Step Process

1. **Capture** → Everything goes to `inbox.org`
2. **Clarify** → Process inbox items (what is it? actionable?)
3. **Organize** → Move to appropriate file (tasks, work, personal)
4. **Reflect** → Review regularly (daily, weekly)
5. **Engage** → Work on tasks based on context

### Simplified Capture Templates

All captures go to `inbox.org`. No distinction between "task" and "capture entry" - they're the same thing. Process later.

| Key       | Template      | Description                      |
| --------- | ------------- | -------------------------------- |
| `C-c c i` | Inbox         | General capture (no TODO)        |
| `C-c c t` | Task          | Actionable item with TODO        |
| `C-c c p` | Project       | Multi-step project with subtasks |
| `C-c c s` | Someday/Maybe | Future ideas                     |
| `C-c c r` | Reference     | Reference material               |
| `C-c c j` | Journal       | Open today's journal             |
| `C-c c d` | Denote        | Create new denote note           |

**Alternative Quick Capture**: `C-c g c` - Direct GTD inbox capture (no template selection)

### Processing the Inbox

**Keybinding**: `C-c g p` (org-gtd-process-inbox)

For each inbox item, ask:

1. **What is it?** - Clarify the item
2. **Is it actionable?**
   - **No** → Delete, file as reference, or incubate (someday/maybe)
   - **Yes** → Continue
3. **What's the next action?**
   - **Single action** → Move to `tasks.org`
   - **Project** → Create project heading, add to `work.org` or `personal.org`
   - **Calendar** → Schedule it
   - **Delegated** → Tag as `WAIT`, note who's responsible
4. **Where does it belong?**
   - Work-related → `work.org`
   - Personal → `personal.org`
   - General tasks → `tasks.org`

### Engaging with Tasks

**Keybinding**: `C-c g e` (org-gtd-engage)

This shows your actionable tasks organized by context. Work on tasks based on:

- **Location**: `@home`, `@work`, `@errands`
- **Energy**: `@quick` (<15 min), `@focus` (>30 min, high energy), `@low` (>60 min, low energy)
- **Device**: `@computer`, `@phone`, `@reading`

---

## Keybindings Reference

### Essential Navigation

| Keybinding | Command                | Description                    |
| ---------- | ---------------------- | ------------------------------ |
| `C-c b`    | consult-buffer         | Switch buffers                 |
| `C-c a`    | org-agenda             | Open agenda                    |
| `C-c c`    | org-capture            | Capture menu                   |
| `C-c j`    | my/open-todays-journal | Quick journal access           |
| `C-c l`    | org-store-link         | Store link to current location |

### GTD Workflow

| Keybinding | Command                           | Description              |
| ---------- | --------------------------------- | ------------------------ |
| `C-c g c`  | org-gtd-capture                   | Quick inbox capture      |
| `C-c g p`  | org-gtd-process-inbox             | Process inbox items      |
| `C-c g e`  | org-gtd-engage                    | Engage with tasks        |
| `C-c g n`  | org-gtd-show-all-next             | Show all next actions    |
| `C-c g s`  | org-gtd-clarify-switch-to-buffer  | Switch to clarify buffer |
| `C-c g a`  | org-gtd-clarify-agenda-item       | Clarify from agenda      |
| `C-c g i`  | org-gtd-clarify-item              | Clarify item             |
| `C-c g g`  | org-gtd-engage-grouped-by-context | Engage by context        |

### Org Capture Templates

| Keybinding | Template      | Description           |
| ---------- | ------------- | --------------------- |
| `C-c c i`  | Inbox         | General capture       |
| `C-c c t`  | Task          | TODO task             |
| `C-c c p`  | Project       | Project with subtasks |
| `C-c c s`  | Someday/Maybe | Future ideas          |
| `C-c c r`  | Reference     | Reference material    |
| `C-c c j`  | Journal       | Open today's journal  |
| `C-c c d`  | Denote        | Create denote note    |

### Org Agenda

| Keybinding | Command           | Description                    |
| ---------- | ----------------- | ------------------------------ |
| `C-c a`    | org-agenda        | Open agenda menu               |
| `C-c a d`  | Daily Review      | Today's agenda + high priority |
| `C-c a w`  | Weekly Review     | Week view + stuck projects     |
| `C-c a p`  | Projects Overview | All projects and goals         |
| `C-c a h`  | Horizons Review   | Vision, goals, areas, projects |

**In Agenda View:**

- `t` - Change TODO state
- `,` - Set priority
- `:` - Set tags
- `C-c C-s` - Schedule
- `C-c C-d` - Set deadline
- `r` - Refresh agenda

### Org Mode Navigation

| Keybinding    | Command             | Description                      |
| ------------- | ------------------- | -------------------------------- |
| `TAB`         | org-cycle           | Fold/unfold heading              |
| `S-TAB`       | org-shifttab        | Cycle visibility globally        |
| `C-c C-w`     | org-refile          | Move heading to another location |
| `C-c C-x C-a` | org-archive-subtree | Archive completed item           |
| `C-c C-t`     | org-todo            | Change TODO state                |

### Org Extensions

| Keybinding | Command                             | Description                          |
| ---------- | ----------------------------------- | ------------------------------------ |
| `C-c n h`  | org-habit-stats-view-habit-at-point | View habit statistics                |
| `C-c n u`  | org-cliplink                        | Insert URL with title from clipboard |
| `C-c n s`  | org-download-screenshot             | Take screenshot                      |
| `C-c n y`  | org-download-yank                   | Paste image                          |
| `C-c n t`  | org-transclusion-add                | Add transclusion                     |
| `C-c n T`  | org-transclusion-mode               | Toggle transclusion mode             |
| `C-c n p`  | org-pomodoro                        | Start pomodoro timer                 |

### Org QL (Query Language)

| Keybinding | Command              | Description           |
| ---------- | -------------------- | --------------------- |
| `C-c q q`  | org-ql-search        | Search with query     |
| `C-c q s`  | org-ql-sparse-tree   | Sparse tree view      |
| `C-c q b`  | org-ql-search-buffer | Search current buffer |
| `C-c q t`  | org-ql-tags          | Search by tags        |
| `C-c q p`  | org-ql-projects      | Show projects         |
| `C-c q d`  | org-ql-due-today     | Due today             |
| `C-c q w`  | org-ql-due-this-week | Due this week         |
| `C-c q n`  | org-ql-todo-next     | Next actions          |
| `C-c q a`  | org-ql-agenda        | QL agenda             |

### Denote (Note-Taking)

| Keybinding  | Command                         | Description                |
| ----------- | ------------------------------- | -------------------------- |
| `C-c d n`   | denote                          | Create new note            |
| `C-c d N`   | denote-subdirectory             | Create in subdirectory     |
| `C-c d f`   | denote-open-or-create           | Open or create note        |
| `C-c d l`   | denote-link                     | Create link to note        |
| `C-c d d`   | consult-denote                  | Search notes               |
| `C-c d r`   | consult-denote                  | Search notes (alternative) |
| `C-c d b`   | denote-backlinks                | Show backlinks             |
| `C-c d t`   | denote-backlinks-toggle-context | Toggle backlink context    |
| `C-c d m`   | denote-menu                     | Browse notes menu          |
| `C-c d s`   | my/denote-switch-silo           | Switch silo                |
| `C-c d L`   | my/denote-list-silos            | List all silos             |
| `C-c d c`   | my/denote-create-in-silo        | Create in specific silo    |
| `C-c d R`   | my/denote-rename-marked-files   | Bulk rename (dired)        |
| `C-c d g w` | my/denote-to-gtd-workflow       | Interactive GTD workflow   |
| `C-c d g l` | my/action-from-denote-with-link | Create action with link    |
| `C-c d g h` | my/habit-from-denote            | Create habit               |
| `C-c d g c` | my/calendar-from-denote         | Create calendar event      |
| `C-c d g d` | my/delegate-from-denote         | Delegate task              |
| `C-c d g i` | my/incubate-from-denote         | Incubate idea              |
| `C-c d g p` | my/project-from-denote          | Create project             |
| `C-c d g m` | my/denote-gtd-menu              | Denote+GTD menu            |

### Xeft (Fast Search)

| Keybinding | Command | Description      |
| ---------- | ------- | ---------------- |
| `C-c z`    | xeft    | Fast note search |

### Development

| Keybinding | Command                | Description               |
| ---------- | ---------------------- | ------------------------- |
| `C-x g`    | magit-status           | Git status                |
| `C-c p f`  | project-find-file      | Find file in project      |
| `C-c p d`  | project-find-dir       | Find directory in project |
| `C-c p g`  | project-find-regexp    | Find regexp in project    |
| `C-c p s`  | project-switch-project | Switch project            |
| `C-c f f`  | format-all-buffer      | Format buffer             |

### Themes

| Keybinding  | Command                          | Description               |
| ----------- | -------------------------------- | ------------------------- |
| `C-c t t`   | my/toggle-theme                  | Toggle theme              |
| `C-c t d`   | my/use-default-theme             | Use default theme         |
| `C-c t g`   | my/load-gui-theme                | Load GUI theme            |
| `C-c t SPC` | my/toggle-default-theme          | Toggle default/custom     |
| `C-c t r`   | my/reset-all-themes              | Reset all themes          |
| `C-c t f`   | my/fix-poet-theme-issues         | Fix theme issues          |
| `C-c t b`   | my/load-theme-for-current-buffer | Load theme for buffer     |
| `C-c t T`   | my/toggle-transparency           | Toggle transparency (GUI) |

### Fonts

| Keybinding  | Command                          | Description        |
| ----------- | -------------------------------- | ------------------ |
| `C-c M-f r` | fontaine-set-preset regular      | Regular font       |
| `C-c M-f o` | fontaine-set-preset org-reading  | Org reading font   |
| `C-c M-f w` | fontaine-set-preset writing      | Writing font       |
| `C-c M-f p` | fontaine-set-preset presentation | Presentation font  |
| `C-c M-f c` | fontaine-set-preset compact      | Compact font       |
| `C-c M-f l` | fontaine-set-preset large        | Large font         |
| `C-c M-f t` | fontaine-toggle-preset           | Toggle font preset |

### Writing

| Keybinding  | Command              | Description       |
| ----------- | -------------------- | ----------------- |
| `C-c w s d` | dictionary-search    | Dictionary lookup |
| `M-$`       | jinx-correct         | Correct word      |
| `C-M-$`     | jinx-change-language | Change language   |

### Maintenance

| Keybinding | Command                            | Description                         |
| ---------- | ---------------------------------- | ----------------------------------- |
| `C-c m f`  | my/find-denote-missing-frontmatter | Find files missing front matter     |
| `C-c m p`  | my/find-org-missing-properties     | Find headings missing properties    |
| `C-c m c`  | my/find-tasks-without-context      | Find tasks without context tags     |
| `C-c m u`  | my/find-unlinked-denote            | Find unlinked denote notes          |
| `C-c m a`  | my/maintenance-check               | Run all maintenance checks          |
| `C-c m o`  | my/cleanup-old-archives            | Find old completed items to archive |

---

## Org Mode Configuration

### TODO Keywords

```elisp
org-todo-keywords '((sequence "NEXT(n)" "TODO(t)" "WAIT(w@)" "SOMEDAY(s)" "|" "DONE(d)" "CNCL(c@)"))
```

- **NEXT**: Next action to do
- **TODO**: Task to be done
- **WAIT**: Waiting for someone/something
- **SOMEDAY**: Future idea, not actionable now
- **DONE**: Completed
- **CNCL**: Cancelled

### Tags

**Contexts** (where you can do it):

- `@computer` - Any computer
- `@desktop` - Desktop computer
- `@laptop` - Laptop
- `@phone` - Phone tasks
- `@home` - Home (non-computer)
- `@errands` - Outside tasks
- `@music` - With instrument/studio
- `@reading` - Reading tasks
- `@anywhere` - Can do anywhere

**Energy & Time**:

- `@quick` - <15 min, low energy
- `@focus` - >30 min, high energy
- `@low` - >60 min, low energy

**Special**:

- `@idea` - Future ideas

### Agenda Files

```elisp
org-agenda-files '("~/org/journal.org"
                   "~/org/gtd/inbox.org"
                   "~/org/gtd/tasks.org"
                   "~/org/gtd/work.org"
                   "~/org/gtd/personal.org"
                   "~/org/gtd/routines.org")  ; Time-bound recurring routines
```

### Agenda Custom Commands

**Daily Review** (`C-c a d`):

- Today's agenda
- High priority tasks
- Due this week
- Waiting for items

**Weekly Review** (`C-c a w`):

- Week view
- Stuck projects
- Coming deadlines
- Delegated tasks

**Projects Overview** (`C-c a p`):

- Active projects
- Current goals
- Life areas

**Horizons Review** (`C-c a h`):

- Vision (3-5 years)
- Goals (1-2 years)
- Areas of focus
- Active projects
- Next actions

### Super Agenda Groups

The agenda is organized into groups:

1. **Today** - Scheduled for today
2. **Next Actions** - NEXT tasks
3. **Calendar** - Calendar items
4. **Overdue** - Past deadlines
5. **Due Today** - Deadlines today
6. **Due Soon** - Future deadlines/scheduled
7. **Projects** - Project items
8. **Waiting/Delegated** - WAIT tasks
9. **Incubated** - Someday/maybe items
10. **Actions** - General actions
11. **Important** - High priority (A)
12. **Inbox** - Unprocessed items
13. **Done** - Completed tasks

---

## Journal System

### Single Journal File

All journal entries live in one file: `~/org/journal.org`

**Structure**:

```org
* 2025
** 2025-01
*** 2025-01-27 Monday
**** Morning
    Entry here...
**** Afternoon
    Entry here...
**** Evening
    Entry here...
**** Notes
    Random notes...
**** Tomorrow
    Plans for tomorrow...
```

### Accessing Your Journal

- **Quick Access**: `C-c j` - Opens today's journal
- **Via Capture**: `C-c c j` - Opens today's journal via capture menu
- **From Calendar**: In calendar view, press `j` to open journal for that date

### Journal Workflow

1. **Morning**: Open journal (`C-c j`), add to "Morning" section
2. **Throughout Day**: Quick captures to "Notes" section
3. **Evening**: Reflect in "Evening" section, plan "Tomorrow"
4. **Review**: Search entire journal file for patterns, insights

### Benefits of Single File

- **Search**: One file to search across all entries
- **Review**: Easy to see patterns over time
- **Simplicity**: No file management overhead
- **Portability**: One file to backup/sync

---

## Note-Taking with Denote

Denote is a powerful note-taking system for **permanent knowledge** - ideas, reference material, meeting notes, literature notes, and anything you want to keep and reference long-term.

### Denote vs Org: When to Use What

**Use Denote for:**

- Permanent knowledge and reference material
- Meeting notes and documentation
- Literature notes (book summaries, article notes)
- Project documentation and planning
- Ideas and concepts you want to link together
- Anything that's not immediately actionable

**Use Org for:**

- Tasks and actionable items
- Projects with deadlines
- Daily journal entries
- Agenda items
- Anything that needs scheduling or completion tracking

**The Bridge**: Denote notes can spawn Org tasks. When a denote note contains actionable items, create GTD tasks linked back to the note.

### Core Concepts

**File Naming Convention:**

```
YYYYMMDDTHHMMSS--title-slug__keyword1_keyword2.ext
```

Example:

```
20250127T143000--field-recording-guide__music_audio_technique.org
```

**Components:**

1. **Identifier** (`20250127T143000`): Timestamp ensures uniqueness
2. **Title Slug** (`field-recording-guide`): Human-readable, URL-friendly
3. **Keywords** (`music_audio_technique`): Tags separated by underscores
4. **Extension** (`.org`): File format

**Front Matter:**

Each denote file includes Org front matter:

```org
#+title:      Field Recording Guide
#+date:       [2025-01-27 Mon 14:30]
#+filetags:   :music:audio:technique:
#+identifier: 20250127T143000
```

### Creating Notes

**Basic Creation**: `C-c d n`

- Prompts for title
- Prompts for keywords (comma-separated)
- Prompts for subdirectory (fleeting/permanent/literature)
- Creates file with proper naming

**Quick Create in Subdirectory**: `C-c d N`

- Same as above, but explicitly choose subdirectory

**Open or Create**: `C-c d f`

- Type part of title or ID
- Opens existing note or creates new one
- Great for quick access

**Create in Specific Silo**: `C-c d c`

- Choose silo first, then create note
- Useful for organizing by context (work/personal)

### File Organization: Silos

Silos are separate directories for different contexts or purposes. This keeps notes organized without mixing concerns.

**Available Silos:**

- `denote` - Default personal notes (`~/org/denote/`)
- `journal` - Journal entries (`~/org/journal.org`)
- `gtd` - GTD-related notes (`~/org/`)
- `projects` - Project documentation (`~/org/gtd/projects/`)
- `nb` - Notebook-style notes (`~/org/nb/`)
- `zk` - Zettelkasten notes (`~/org/nb/zk/`)
- `archive` - Archived notes (`~/org/archive/`)

**Switching Silos:**

- `C-c d s` - Switch current silo
- `C-c d L` - List all silos and their paths
- `C-c d c` - Create note in specific silo

**Subdirectories within Silos:**

- `fleeting` - Quick notes, rough drafts
- `permanent` - Polished, permanent knowledge
- `literature` - Notes on books, articles, papers

### Searching and Finding Notes

**Consult Denote**: `C-c d d` (or `C-c d r`)

- Fuzzy search across all notes
- Search by title, keywords, or content
- Fast and efficient

**Denote Menu**: `C-c d m`

- Browse notes in a table view
- Sort by date, modification, keywords
- Filter and search

**Xeft**: `C-c z`

- Ultra-fast full-text search
- Searches content, not just metadata
- Great for finding specific information

**Backlinks**: `C-c d b`

- See all notes that link to current note
- Discover connections
- Navigate your knowledge graph

### Linking Notes

**Create Link**: `C-c d l`

- Prompts for target note (fuzzy search)
- Inserts `[[denote:IDENTIFIER][Title]]` link
- Links are bidirectional - backlinks automatically tracked

**Link Format:**

```org
[[denote:20250127T143000][Field Recording Guide]]
```

**Following Links:**

- `C-c C-o` - Open link at point
- `RET` - In denote buffers, follow link
- Links work across all denote files

### Renaming Files: The Complete Workflow

Renaming denote files is crucial for maintaining organization. The system intelligently handles renaming while preserving links.

#### Why Rename?

1. **Title Changes**: As your understanding evolves, titles may need updating
2. **Keyword Refinement**: Add or change keywords for better organization
3. **Organization**: Move notes between subdirectories or silos
4. **Consistency**: Ensure all files follow naming conventions

#### Smart Renaming

**From Front Matter**: `C-c d r`

- Extracts title, date, and keywords from front matter
- Builds new filename using Denote's slugification
- Updates filename while preserving identifier (if present)
- Keeps human-readable title in front matter

**How It Works:**

1. Reads `#+title:` from front matter
2. Reads `#+date:` and extracts date
3. Reads `#+filetags:` and extracts keywords
4. Slugifies title (e.g., "Field Recording Guide" → "field-recording-guide")
5. Builds filename: `YYYYMMDDT000000--field-recording-guide__keyword1_keyword2.org`
6. Renames file
7. Updates all links across all denote files

**Bulk Renaming in Dired**: `C-c d R`

- Mark multiple files in dired (`m` to mark)
- Run `C-c d R`
- Intelligently renames all marked files
- Shows results in buffer

**Renaming Workflow Example:**

1. **Initial Note**:

   ```
   File: 20250127T143000--quick-note__temp.org
   Front matter:
   #+title: Quick Note
   #+filetags: :temp:
   ```

2. **Update Content and Front Matter**:

   ```org
   #+title: Field Recording Techniques for Outdoor Environments
   #+date: [2025-01-27 Mon 14:30]
   #+filetags: :music:audio:technique:recording:
   ```

3. **Rename**: `C-c d r`

   - System reads front matter
   - Creates: `20250127T143000--field-recording-techniques-for-outdoor-environments__music_audio_technique_recording.org`
   - Updates all links automatically

#### Renaming Best Practices

1. **Update Front Matter First**: Always update `#+title:` and `#+filetags:` before renaming
2. **Use Descriptive Titles**: Clear titles make searching easier
3. **Consistent Keywords**: Use the same keywords for related notes
4. **Test Links**: After renaming, verify links still work
5. **Batch Rename**: Use dired for multiple files at once

### Organizing with Subdirectories

**Fleeting Notes** (`fleeting/`):

- Quick captures, rough ideas
- Temporary notes that may become permanent
- Think of as "inbox" for knowledge

**Permanent Notes** (`permanent/`):

- Polished, well-thought-out notes
- Reference material you'll use long-term
- Finalized knowledge

**Literature Notes** (`literature/`):

- Notes on books, articles, papers
- Summaries and key points
- Source material

**Workflow:**

1. Capture in `fleeting/` - quick note
2. Develop and refine
3. Move to `permanent/` when ready
4. Link to related notes

### Denote + GTD Integration

The real power comes from connecting Denote (knowledge) with Org GTD (actions).

#### Creating GTD Tasks from Denote Notes

**Interactive Workflow**: `C-c d g w`

- While viewing a denote note
- Prompts for action type: single-action, habit, calendar, delegate, incubate
- Creates appropriate GTD task
- Links back to denote note automatically

**Quick Actions:**

- `C-c d g l` - Create single action with link
- `C-c d g h` - Create habit from note
- `C-c d g c` - Create calendar event
- `C-c d g d` - Delegate task
- `C-c d g i` - Incubate (someday/maybe)
- `C-c d g p` - Create project

**Example Workflow:**

1. **Reading a denote note** about "Learning Rust"
2. **Think**: "I should actually learn this"
3. **Run**: `C-c d g w` → choose "single-action"
4. **Result**: GTD task created: "Review [[denote:20250127T143000][Learning Rust]]"
5. **Task appears in inbox**, process normally
6. **Link preserved** - can jump back to note

#### Keyword-Based Automation

Denote notes with specific keywords can auto-create GTD tasks:

- `_action` keyword → Creates single action
- `_delegate` keyword → Creates delegated task
- `_someday` keyword → Creates incubated item
- `_habit` keyword → Creates habit

**Example:**

```
File: 20250127T143000--review-budget__finance_action.org
```

When you process this note, the `_action` keyword triggers GTD task creation.

### Advanced Workflows

#### Meeting Notes → Action Items

1. **Create Meeting Note**: `C-c d n`

   - Title: "Meeting - Project Planning - 2025-01-27"
   - Keywords: `meeting, project, planning`

2. **Take Notes During Meeting**:

   ```org
   * Attendees
   - Alice
   - Bob
   - Charlie

   * Discussion
   - Reviewed project timeline
   - Discussed resource allocation

   * Action Items
   - [ ] Alice: Review budget proposal
   - [ ] Bob: Update project timeline
   - [ ] Charlie: Schedule follow-up meeting
   ```

3. **Create GTD Tasks**: For each action item, `C-c d g l`

   - Creates linked GTD task
   - Preserves context from meeting note

#### Literature Notes → Habits

1. **Read Book**: Create literature note
2. **Identify Habit**: "I should read 30 minutes daily"
3. **Run**: `C-c d g h`
4. **Result**: Habit created with link back to book note

#### Project Documentation

1. **Create Project Note**: `C-c d n` in `projects/` silo
2. **Document Project**: Goals, resources, notes
3. **Create Project in GTD**: `C-c d g p`
4. **Link Tasks**: GTD tasks link back to project note

### Best Practices

1. **One Idea Per Note**: Keep notes focused
2. **Link Liberally**: Connect related ideas
3. **Use Keywords Consistently**: Build a keyword taxonomy
4. **Regular Review**: Periodically review and refine notes
5. **Rename When Needed**: Keep filenames accurate
6. **Move Through Stages**: fleeting → permanent
7. **Link to Actions**: Connect knowledge (denote) to actions (GTD)

### Keybindings Summary

| Keybinding  | Command                         | Description                |
| ----------- | ------------------------------- | -------------------------- |
| `C-c d n`   | denote                          | Create new note            |
| `C-c d N`   | denote-subdirectory             | Create in subdirectory     |
| `C-c d f`   | denote-open-or-create           | Open or create note        |
| `C-c d l`   | denote-link                     | Create link to note        |
| `C-c d d`   | consult-denote                  | Search notes               |
| `C-c d r`   | consult-denote                  | Search notes (alternative) |
| `C-c d b`   | denote-backlinks                | Show backlinks             |
| `C-c d t`   | denote-backlinks-toggle-context | Toggle backlink context    |
| `C-c d m`   | denote-menu                     | Browse notes menu          |
| `C-c d s`   | my/denote-switch-silo           | Switch silo                |
| `C-c d L`   | my/denote-list-silos            | List all silos             |
| `C-c d c`   | my/denote-create-in-silo        | Create in specific silo    |
| `C-c d R`   | my/denote-rename-marked-files   | Bulk rename (dired)        |
| `C-c d g w` | my/denote-to-gtd-workflow       | Interactive GTD workflow   |
| `C-c d g l` | my/action-from-denote-with-link | Create action with link    |
| `C-c d g h` | my/habit-from-denote            | Create habit               |
| `C-c d g c` | my/calendar-from-denote         | Create calendar event      |
| `C-c d g d` | my/delegate-from-denote         | Delegate task              |
| `C-c d g i` | my/incubate-from-denote         | Incubate idea              |
| `C-c d g p` | my/project-from-denote          | Create project             |
| `C-c d g m` | my/denote-gtd-menu              | Denote+GTD menu            |

---

## Recurring Routines and Time-Bound Tasks

For daily and weekly routines that happen at specific times (like morning coffee, commuting, evening check-in), use scheduled items with time specifications and repeaters.

### Creating a Routines File

Create a dedicated file for routines: `~/org/gtd/routines.org`

**Structure:**

```org
#+title: Daily and Weekly Routines
#+filetags: :routines:

* Daily Routines
** Morning
*** TODO Wake up
   SCHEDULED: <2025-01-27 Mon 06:30 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

*** TODO Morning coffee & check-in
   SCHEDULED: <2025-01-27 Mon 07:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

*** TODO Commuting (7-9am)
   SCHEDULED: <2025-01-27 Mon 07:00-09:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

** Evening
*** TODO Evening check-in
   SCHEDULED: <2025-01-27 Mon 20:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

*** TODO Dinner
   SCHEDULED: <2025-01-27 Mon 19:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

* Weekly Routines
** TODO Weekly review
   SCHEDULED: <2025-01-27 Mon 18:00 .+1w>
   :PROPERTIES:
   :STYLE: habit
   :END:

** TODO Grocery shopping
   SCHEDULED: <2025-01-27 Mon 10:00 .+1w>
   :PROPERTIES:
   :STYLE: habit
   :END:
```

### Time Specifications

**Basic Time:**

```org
SCHEDULED: <2025-01-27 Mon 07:00>
```

**Time Range:**

```org
SCHEDULED: <2025-01-27 Mon 07:00-09:00>
```

**With Repeater (Daily):**

```org
SCHEDULED: <2025-01-27 Mon 07:00 .+1d>
```

**With Repeater (Weekly):**

```org
SCHEDULED: <2025-01-27 Mon 18:00 .+1w>
```

**With Repeater (Weekdays Only):**

```org
SCHEDULED: <2025-01-27 Mon 07:00 +1d>
```

Note: `.+1d` repeats every day, `+1d` repeats on weekdays only.

### Repeater Patterns

| Pattern | Description   | Example          |
| ------- | ------------- | ---------------- |
| `.+1d`  | Every day     | Daily routines   |
| `+1d`   | Every weekday | Workday routines |
| `.+2d`  | Every 2 days  | Every other day  |
| `.+1w`  | Every week    | Weekly routines  |
| `.+2w`  | Every 2 weeks | Bi-weekly        |
| `.+1m`  | Every month   | Monthly routines |

### Viewing Routines in Agenda

**Agenda with Time Grid:**

1. Open agenda: `C-c a`
2. Select daily view (or press `d` for daily review)
3. Routines appear at their scheduled times
4. Time grid shows your day visually

**Time Grid Features:**

- Routines appear at their scheduled times
- Visual timeline of your day
- See gaps and busy periods
- Plan around existing routines

**Example Agenda View:**

```
Monday   27 January 2025
 06:30...... TODO Wake up
 07:00...... TODO Morning coffee & check-in
 07:00-09:00 TODO Commuting (7-9am)
 19:00...... TODO Dinner
 20:00...... TODO Evening check-in
```

### Quick Setup Workflow

1. **Create Routines File**: `~/org/gtd/routines.org`

2. **Add to Agenda Files**:

   ```elisp
   org-agenda-files '("~/org/journal.org"
                      "~/org/gtd/inbox.org"
                      "~/org/gtd/tasks.org"
                      "~/org/gtd/work.org"
                      "~/org/gtd/personal.org"
                      "~/org/gtd/routines.org")  ; Add this
   ```

3. **Create Routine Items**:

   - Use capture: `C-c c t` → Create task
   - Or directly in `routines.org`
   - Set schedule with time: `C-c C-s` then enter date and time
   - Add repeater: After scheduling, edit to add `.+1d` or `.+1w`

4. **Mark as Habit** (optional):

   - Add property: `:PROPERTIES: :STYLE: habit :END:`
   - Shows consistency graph in agenda

### Commuting Example

For your 7-9am commuting routine:

```org
*** TODO Commuting (7-9am)
   SCHEDULED: <2025-01-27 Mon 07:00-09:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

   Use this time for:
   - [ ] Review today's agenda
   - [ ] Listen to podcast/audiobook
   - [ ] Plan day ahead
   - [ ] Process quick inbox items
```

**Benefits:**

- See commuting time in agenda
- Plan tasks around it
- Use time productively
- Track consistency

### Routines vs Regular Tasks

**Routines** (in `routines.org`):

- Time-bound, recurring
- Happen at specific times
- Use scheduled with time
- Mark as habits for tracking
- Examples: wake up, coffee, commuting, dinner

**Regular Tasks** (in `tasks.org`, `work.org`, `personal.org`):

- Not time-bound
- Do when context allows
- Use tags for context (`@computer`, `@home`)
- Examples: review budget, call dentist, fix door

### Planning Around Routines

**Morning Planning:**

1. Open agenda: `C-c a d` (daily review)
2. See routines at their times
3. Plan tasks around routines
4. Use commuting time for planning/review

**Example Day:**

```
06:30 - Wake up
07:00 - Morning coffee & check-in
07:00-09:00 - Commuting (plan day, review agenda)
09:00 - Start work
12:00 - Lunch
19:00 - Dinner
20:00 - Evening check-in
```

**Benefits:**

- Visual timeline of your day
- See available time slots
- Plan tasks in available windows
- Respect routine boundaries

### Updating Routines

**Change Time:**

1. Open `routines.org`
2. Find routine item
3. `C-c C-s` to reschedule
4. Update time
5. Repeater stays the same

**Change Frequency:**

1. Edit scheduled line
2. Change repeater (`.+1d` → `.+1w`)
3. Save

**Temporarily Skip:**

1. In agenda, mark as `DONE`
2. Next occurrence still appears
3. Or reschedule to skip specific days

### Integration with GTD

**Routines are Separate from GTD:**

- Routines = Time-bound, recurring activities
- GTD Tasks = Actionable items to do when possible

**Workflow:**

1. **Routines** show in agenda at their times
2. **GTD Tasks** show in agenda without times (do when context allows)
3. Plan GTD tasks around routines
4. Use routine time for planning/review

**Example:**

- **Routine**: Commuting 7-9am (scheduled)
- **GTD Task**: Review budget (`@computer`, no time)
- **Plan**: Do GTD task during commuting if on computer, or later when at computer

### Best Practices

1. **Keep Routines Simple**: Only time-bound, recurring items
2. **Use Time Ranges**: For activities that take time (commuting, meals)
3. **Mark as Habits**: For tracking consistency
4. **Review Regularly**: Update times/frequencies as needed
5. **Don't Over-Schedule**: Leave buffer time between routines
6. **Separate from Tasks**: Routines are structure, tasks are actions

### Keybindings for Routines

| Keybinding | Command         | Description                     |
| ---------- | --------------- | ------------------------------- |
| `C-c C-s`  | org-schedule    | Schedule item with date/time    |
| `C-c C-d`  | org-deadline    | Set deadline                    |
| `C-c a d`  | Daily Review    | View daily agenda with routines |
| `C-c n h`  | org-habit-stats | View habit statistics           |

### Example: Complete Routines File

```org
#+title: Daily and Weekly Routines
#+filetags: :routines:

* Daily Routines
** Morning
*** TODO Wake up
   SCHEDULED: <2025-01-27 Mon 06:30 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

*** TODO Morning coffee & check-in
   SCHEDULED: <2025-01-27 Mon 07:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

   - Review today's agenda
   - Check email
   - Plan day

*** TODO Commuting (7-9am)
   SCHEDULED: <2025-01-27 Mon 07:00-09:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

   Use this time for:
   - [ ] Review today's tasks
   - [ ] Listen to podcast
   - [ ] Process quick inbox items
   - [ ] Plan day ahead

** Afternoon
*** TODO Lunch
   SCHEDULED: <2025-01-27 Mon 12:30 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

** Evening
*** TODO Dinner
   SCHEDULED: <2025-01-27 Mon 19:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

*** TODO Evening check-in
   SCHEDULED: <2025-01-27 Mon 20:00 .+1d>
   :PROPERTIES:
   :STYLE: habit
   :END:

   - Review day
   - Process inbox
   - Plan tomorrow
   - Update journal

* Weekly Routines
** TODO Weekly review
   SCHEDULED: <2025-01-27 Mon 18:00 .+1w>
   :PROPERTIES:
   :STYLE: habit
   :END:

** TODO Grocery shopping
   SCHEDULED: <2025-01-27 Mon 10:00 .+1w>
   :PROPERTIES:
   :STYLE: habit
   :END:
```

---

## Agenda and Task Management

### Daily Workflow

1. **Morning**:

   - Open agenda: `C-c a`
   - Review today's items
   - Check high priority tasks
   - Plan your day

2. **Throughout Day**:

   - Capture as needed: `C-c c t` (task) or `C-c g c` (quick capture)
   - Work from agenda or engage: `C-c g e`

3. **Evening**:
   - Process inbox: `C-c g p`
   - Update journal: `C-c j`
   - Review tomorrow's items

### Weekly Review

**Keybinding**: `C-c a w`

1. Clear inbox completely
2. Review all projects
3. Update next actions
4. Check waiting/delegated items
5. Review someday/maybe list
6. Plan upcoming week

### Monthly Review

1. Review journal entries for the month
2. Identify patterns and themes
3. Update goals and projects
4. Archive completed items

### Project Management

Projects are multi-step outcomes. Structure:

```org
* TODO Project Name [/]
  :PROPERTIES:
  :CATEGORY: Work
  :END:

  Project description and context...

  ** TODO First step
  ** TODO Second step
  ** TODO Third step
```

- Use `[/]` to track project completion
- Break into concrete next actions
- Review regularly in Projects Overview (`C-c a p`)

---

## Productivity Workflows

### The Capture-Process-Execute Cycle

1. **Capture** (2 seconds):

   - Thought pops up → `C-c g c` → type → done
   - Don't think, just capture

2. **Process** (5-10 minutes, daily):

   - Open inbox: `C-c g p`
   - For each item: clarify, decide, organize
   - Move to appropriate file

3. **Execute** (work time):
   - Engage: `C-c g e`
   - Work from agenda: `C-c a`
   - Focus on context-appropriate tasks

### Context Switching

Use tags to filter by context:

- **Location**: `@home`, `@work`, `@errands`
- **Device**: `@computer`, `@phone`, `@reading`
- **Energy**: `@quick`, `@focus`, `@low`

In agenda, filter by tag to see only relevant tasks.

### Time Blocking

Use scheduling (`C-c C-s`) to block time:

```org
* TODO Review quarterly budget
  SCHEDULED: <2025-01-28 Mon 14:00>
```

Agenda shows scheduled items at their times.

### Pomodoro Technique

**Keybinding**: `C-c n p`

Start a pomodoro timer for focused work:

- 25 minutes of focused work
- 5 minute break
- Tracks time spent on tasks

### Habit Tracking

Track recurring habits:

```org
* TODO Exercise
  SCHEDULED: <2025-01-27 Mon .+1d>
  :PROPERTIES:
  :STYLE: habit
  :END:
```

Habits appear in agenda and show consistency graphs.

---

## Writing and Export

### Org Mode Writing Features

- **Mixed Pitch**: Variable-pitch font for prose, fixed-pitch for code
- **Visual Line Mode**: Word wrapping
- **Spell Checking**: Jinx for real-time correction
- **Dictionary**: `C-c w s d` for word lookup

### Export Formats

- **HTML**: `C-c C-e h h` - Export to HTML
- **PDF**: `C-c C-e l p` - Export to PDF (via LaTeX)
- **Markdown**: `C-c C-e m m` - Export to Markdown
- **Hugo**: `C-c C-e H h` - Export to Hugo (via ox-hugo)

### Writing Workflow

1. Write in Org mode
2. Use headings for structure
3. Add links, images, code blocks as needed
4. Export when ready

### Pandoc Integration

Pandoc mode enables conversion between formats:

- Org → Markdown
- Markdown → HTML
- And many more

---

## Development Tools

### Version Control

- **Magit**: `C-x g` - Full Git interface
- **Git Timemachine**: `C-x v t` - Browse file history
- **Git Messenger**: `C-x v p` - Show commit messages

### Project Management

- **Project Find File**: `C-c p f`
- **Project Find Directory**: `C-c p d`
- **Project Find Regexp**: `C-c p g`
- **Switch Project**: `C-c p s`

### Code Formatting

- **Format Buffer**: `C-c f f` - Auto-format current buffer
- Supports multiple languages via format-all

### LSP and Completion

- Tree-sitter for syntax highlighting
- LSP for language servers
- Corfu for completion
- Flycheck for error checking

---

## UI and Customization

### Themes

Multiple themes available:

- Poet Dark (default)
- Modus Themes
- Everforest
- Doric Themes
- EF Themes

**Toggle**: `C-c t t`

### Fonts

Font presets for different contexts:

- **Regular**: Default font
- **Org Reading**: Optimized for reading Org files
- **Writing**: Optimized for prose writing
- **Presentation**: Larger font for presentations
- **Compact**: Smaller font for more content
- **Large**: Larger font for accessibility

**Switch**: `C-c M-f [preset]`

### Visual Enhancements

- **Org Modern**: Clean, modern Org mode appearance
- **Mixed Pitch**: Variable-pitch for prose, fixed-pitch for code
- **Icons**: Nerd icons throughout
- **Beacon**: Highlight cursor when jumping
- **Which-Key**: Show available keybindings

### Window Management

- **Ace Window**: `C-x o` - Quick window switching
- **Avy**: Jump to visible text
- **Dirvish**: Enhanced file browser

---

## Tips and Best Practices

### Daily Habits

1. **Morning**: Review agenda, plan day
2. **Capture**: Capture everything immediately
3. **Process**: Process inbox daily (ideally end of day)
4. **Evening**: Update journal, review tomorrow

### Weekly Habits

1. **Weekly Review**: `C-c a w` - Review projects, update next actions
2. **Inbox Zero**: Clear inbox completely
3. **Project Review**: Check all active projects
4. **Archive**: Archive completed items

### Monthly Habits

1. **Journal Review**: Review past month's journal entries
2. **Goal Review**: Update goals and projects
3. **Archive**: Archive old completed items
4. **System Review**: Reflect on what's working, what's not

### Keyboard Efficiency

- Learn the keybindings - they're faster than menus
- Use which-key (`C-h`) to discover keybindings
- Customize keybindings to match your workflow
- Use prefixes consistently (`C-c g` for GTD, `C-c d` for Denote)

### File Organization

- Keep inbox small - process regularly
- Archive completed items
- Use consistent naming
- Tag everything appropriately

---

## Integrated Workflows: BASB + GTD + Denote

Combining Building a Second Brain (BASB), Getting Things Done (GTD), and Denote creates a powerful system for knowledge management and productivity. Here are practical workflows with simplicity and priority in mind.

### Core Philosophy

**BASB (Building a Second Brain):**

- **Capture**: Save everything interesting
- **Organize**: Save for actionability
- **Distill**: Find the essence
- **Express**: Show your work

**GTD (Getting Things Done):**

- **Capture**: Get it out of your head
- **Clarify**: What is it? Is it actionable?
- **Organize**: Put it where it belongs
- **Reflect**: Review regularly
- **Engage**: Do it

**Denote:**

- **Knowledge**: Permanent notes, reference material
- **Linking**: Connect ideas
- **Discovery**: Find connections

**The Integration:**

- **Denote** = Knowledge (BASB: Organize, Distill)
- **GTD** = Actions (BASB: Express)
- **Journal** = Capture and reflection

### Workflow 1: The Daily Flow (Priority: Simplicity)

**Morning (5 minutes):**

1. **Open Agenda**: `C-c a d` - See today's routines and tasks
2. **Review Journal**: `C-c j` - Check yesterday's notes, plan today
3. **Process Inbox**: `C-c g p` - Clear inbox from yesterday

**Throughout Day:**

1. **Capture Everything**: `C-c g c` - Quick capture to inbox
2. **Knowledge Capture**: `C-c d n` - Create denote note for interesting ideas
3. **Journal Thoughts**: `C-c j` - Quick journal entry

**Evening (10 minutes):**

1. **Process Inbox**: `C-c g p` - Process all captures
2. **Update Journal**: `C-c j` - Reflect on day
3. **Review Tomorrow**: `C-c a` - Check tomorrow's items

**Weekly (30 minutes):**

1. **Weekly Review**: `C-c a w` - Review projects, update next actions
2. **Process Denote**: Review fleeting notes, create permanent notes
3. **Archive**: Archive completed items

**Why This Works:**

- Minimal decisions (inbox → process → organize)
- Clear separation (knowledge vs actions)
- Regular processing prevents buildup
- Simple, sustainable routine

### Workflow 2: Knowledge → Action Pipeline

**The Flow:**

```
Capture → Denote (fleeting) → Process → Denote (permanent) → GTD Action
```

**Step-by-Step:**

1. **Capture Interesting Idea**: `C-c d n`

   - Title: "Field Recording Techniques"
   - Keywords: `audio, technique, fleeting`
   - Subdirectory: `fleeting/`

2. **Develop the Idea** (over days/weeks):

   - Add notes, links, examples
   - Refine understanding

3. **Process to Permanent**: When ready

   - Move to `permanent/` subdirectory
   - Add more keywords: `audio, technique, permanent, reference`
   - Link to related notes

4. **Create Action** (if actionable): `C-c d g w`
   - Choose action type (single-action, project, habit)
   - GTD task created with link back to note
   - Process through GTD workflow

**Example:**

```org
;; Denote Note (permanent/20250127T143000--field-recording-techniques__audio_technique_permanent.org)
#+title: Field Recording Techniques
#+filetags: :audio:technique:permanent:

* Overview
Techniques for recording audio in outdoor environments...

* Key Points
- Wind protection
- Microphone placement
- Equipment recommendations

* Related
- [[denote:20250120T100000][Outdoor Audio Equipment]]
- [[denote:20250115T140000][Microphone Types]]

* Actions
- [ ] Practice field recording
- [ ] Review equipment list
```

Then create GTD action: `C-c d g l` → Creates task "Review [[denote:20250127T143000][Field Recording Techniques]]"

**Benefits:**

- Knowledge preserved in Denote
- Actions tracked in GTD
- Links maintain connection
- Can reference knowledge while doing action

### Workflow 3: Project Documentation + Task Management

**For Work Projects:**

1. **Create Project Denote**: `C-c d n` in `projects/` silo

   - Title: "Project Alpha"
   - Keywords: `project, work, project-alpha`

2. **Document Project**:

   - Goals, resources, notes
   - Meeting notes linked
   - Reference material

3. **Create GTD Project**: `C-c d g p`

   - Creates project in `work.org`
   - Links back to denote note
   - Breaks into actionable steps

4. **Work on Tasks**:
   - Tasks in `work.org` link to project denote
   - Update denote as project progresses
   - Reference denote while working

**Structure:**

```org
;; work.org
* Projects
** TODO [[denote:20250127T120000][Project Alpha]] :project-alpha:
   :PROPERTIES:
   :CATEGORY: Work
   :PROJECT: Project Alpha
   :END:

   *** NEXT Review project requirements
   *** TODO Set up development environment
   *** TODO Create initial prototype
```

```org
;; Denote: projects/20250127T120000--project-alpha__project_work_project-alpha.org
#+title: Project Alpha
#+filetags: :project:work:project-alpha:

* Overview
Project Alpha is a web application for...

* Goals
- Goal 1
- Goal 2

* Resources
- [[denote:20250120T100000][Technical Specs]]
- [[denote:20250115T140000][Meeting Notes - Kickoff]]

* Progress
- [x] Initial planning
- [ ] Development
- [ ] Testing
```

**Benefits:**

- Knowledge (denote) separate from actions (GTD)
- Easy to reference project context
- Links maintain connection
- Can work on tasks while referencing knowledge

### Workflow 4: Literature Notes → Permanent Notes → Actions

**Reading a Book/Article:**

1. **Create Literature Note**: `C-c d n`

   - Title: Book/Article title
   - Keywords: `literature, [topic]`
   - Subdirectory: `literature/`

2. **Take Notes While Reading**:

   - Key concepts
   - Quotes
   - Ideas

3. **Create Permanent Notes** (after reading):

   - Extract key concepts
   - Create separate permanent notes
   - Link to literature note
   - Link concepts together

4. **Create Actions** (if actionable):
   - `C-c d g w` → Choose action type
   - Implement ideas from book
   - Create habits based on book

**Example:**

```org
;; Literature Note
#+title: Getting Things Done by David Allen
#+filetags: :literature:productivity:

* Key Concepts
- Two-minute rule
- Weekly review
- Inbox processing

* Permanent Notes Created
- [[denote:20250127T140000][Two-Minute Rule]]
- [[denote:20250127T141000][Weekly Review Process]]
```

```org
;; Permanent Note
#+title: Two-Minute Rule
#+filetags: :productivity:technique:permanent:

* Concept
If something takes less than two minutes, do it immediately.

* Application
- Process quick inbox items immediately
- Reply to short emails
- File documents

* Related
- [[denote:20250127T120000][Getting Things Done by David Allen]]
- [[denote:20250127T130000][Inbox Processing]]
```

**Benefits:**

- Literature notes preserve source
- Permanent notes extract concepts
- Actions implement ideas
- All linked together

### Workflow 5: Meeting Notes → Action Items

**During Meeting:**

1. **Create Meeting Denote**: `C-c d n`

   - Title: "Meeting - [Topic] - 2025-01-27"
   - Keywords: `meeting, [project], [topic]`

2. **Take Notes**:

   - Attendees
   - Discussion points
   - Decisions made
   - Action items

3. **After Meeting**:

   - For each action item: `C-c d g l`
   - Creates GTD task with link to meeting note
   - Preserves context

**Example:**

```org
;; Meeting Note
#+title: Meeting - Project Planning - 2025-01-27
#+filetags: :meeting:project-alpha:

* Attendees
- Alice
- Bob
- Charlie

* Discussion
- Reviewed timeline
- Discussed resources

* Action Items
- [ ] Alice: Review budget proposal
- [ ] Bob: Update timeline
- [ ] Charlie: Schedule follow-up
```

After meeting, for each action item:

- `C-c d g l` → Creates task "Review budget proposal [[denote:20250127T150000][Meeting - Project Planning - 2025-01-27]]"

**Benefits:**

- Meeting context preserved
- Action items tracked in GTD
- Can reference meeting notes while working
- Clear accountability

---

## CLI Tools Integration: nb and zk

Your setup includes `nb` and `zk` as Denote silos. Here are ideas for integrating these CLI tools with your Emacs workflow.

### nb (CLI Notebook) Integration

**What is nb:**

- CLI-based note-taking system
- Git-backed, markdown-based
- Fast search and organization
- Can sync to remote git repos

**Integration Ideas:**

#### 1. Use nb for Quick CLI Captures

**Workflow:**

- Quick terminal capture: `nb new "Quick note"`
- Process later in Emacs
- Or use nb for specific contexts (terminal-only work)

**Setup:**

```bash
# Add to your shell config
alias nbc='nb new'
alias nbs='nb search'
alias nbl='nb list'
```

**Use Cases:**

- Terminal-only work sessions
- Quick captures when Emacs not available
- Server/remote work
- Command-line focused workflows

#### 2. nb as Archive/Backup System

**Workflow:**

- Use nb for long-term archive
- Sync nb to git remote
- Access from anywhere via git

**Setup:**

```bash
# Initialize nb in your notes directory
nb init ~/org/nb/

# Add remote
nb remote set origin git@github.com:username/notes.git

# Auto-sync on changes
nb sync
```

**Benefits:**

- Git-backed (version control)
- Accessible from CLI
- Can sync to remote
- Good for backup/archive

#### 3. nb for Specific Workflows

**Use nb for:**

- Command reference notes
- Terminal snippets
- Server documentation
- CLI-focused projects

**Example:**

```bash
# Create server documentation
nb new "Server Setup" --tags server,docs

# Add command snippets
nb edit "Server Setup"
# Add commands, configs, etc.

# Search later
nb search "nginx"
```

**Integration with Emacs:**

- Access nb files via Denote silo: `~/org/nb/`
- Can open in Emacs: `C-c d f` then search for nb note
- Or use `nb open` from terminal

### zk (CLI Zettelkasten) Integration

**What is zk:**

- CLI-based Zettelkasten system
- Fast full-text search
- Link management
- Markdown-based

**Integration Ideas:**

#### 1. zk for Fast Knowledge Search

**Workflow:**

- Use zk for ultra-fast search across all notes
- CLI-based, very fast
- Good for quick lookups

**Setup:**

```bash
# Initialize zk in your notes directory
zk init ~/org/nb/zk/

# Create notes
zk new "Concept Name"

# Fast search
zk search "concept"
```

**Use Cases:**

- Quick concept lookups
- Fast full-text search
- Terminal-based research
- When Emacs not available

#### 2. zk for Zettelkasten Workflow

**Workflow:**

- Use zk for pure Zettelkasten method
- Atomic notes
- Heavy linking
- Fast discovery

**Example:**

```bash
# Create atomic note
zk new "Two-Minute Rule"

# Link to related note
zk link "Two-Minute Rule" "Inbox Processing"

# Find connections
zk list --linked "Two-Minute Rule"
```

**Integration with Emacs:**

- Access zk files via Denote silo: `~/org/nb/zk/`
- Can open in Emacs: `C-c d f` then search
- Or use `zk edit` from terminal

#### 3. Combined Workflow: zk + Denote

**Strategy:**

- Use zk for atomic, heavily-linked notes (pure Zettelkasten)
- Use Denote for more structured notes (meetings, projects, literature)
- Both accessible from Emacs via silos

**Workflow:**

1. **Quick atomic idea**: `zk new "Idea"`
2. **Develop into structured note**: Create Denote note, link to zk note
3. **Search both**: Use Emacs search or CLI tools

### Combined CLI + Emacs Workflow

**The Hybrid Approach:**

1. **Quick Captures**: Use CLI tools (`nb` or `zk`)

   - Fast, no Emacs needed
   - Terminal-friendly

2. **Development**: Use Emacs (Denote)

   - Rich editing
   - Better linking
   - Integration with GTD

3. **Search**: Use both
   - CLI for speed
   - Emacs for context

**Example Daily Flow:**

```bash
# Morning: Quick capture in terminal
nb new "Meeting idea" --tags work,meeting

# Later: Develop in Emacs
# C-c d f → search "Meeting idea" → open in Emacs
# Add details, create GTD action

# Search: Use either
nb search "meeting"  # CLI - fast
# or
C-c d d → search "meeting"  # Emacs - rich context
```

**Benefits:**

- Fast CLI captures
- Rich Emacs development
- Best of both worlds
- Accessible from anywhere

---

## Maintenance Workflows and Tools

Keeping your system clean and organized is crucial for long-term productivity. Here are tools and workflows for maintenance.

### Finding Files with Missing Metadata

#### 1. Denote Files Missing Front Matter

**Custom Function** (add to your config):

```elisp
(defun my/find-denote-missing-frontmatter ()
  "Find all denote files missing required front matter."
  (interactive)
  (let ((denote-dirs (mapcar #'cdr my-denote-silos))
        (missing-files '()))
    (dolist (dir denote-dirs)
      (when (file-directory-p dir)
        (dolist (file (directory-files-recursively dir "\\.org$"))
          (with-temp-buffer
            (insert-file-contents file)
            (goto-char (point-min))
            (unless (and (re-search-forward "^#\\+title:" nil t)
                         (re-search-forward "^#\\+date:" nil t)
                         (re-search-forward "^#\\+filetags:" nil t))
              (push file missing-files))))))
    (if missing-files
        (progn
          (with-output-to-temp-buffer "*Missing Front Matter*"
            (princ "Files missing required front matter:\n\n")
            (dolist (file missing-files)
              (princ (format "%s\n" file))))
          (message "Found %d files with missing front matter" (length missing-files)))
      (message "All files have required front matter"))))

(global-set-key (kbd "C-c m f") 'my/find-denote-missing-frontmatter)
```

**Usage**: `C-c m f` - Shows all files missing front matter

#### 2. Org Files Missing Properties

**Custom Function**:

```elisp
(defun my/find-org-missing-properties ()
  "Find org headings missing important properties."
  (interactive)
  (let ((files (org-agenda-files))
        (missing '()))
    (dolist (file files)
      (with-current-buffer (find-file-noselect file)
        (org-map-entries
         (lambda ()
           (let ((props (org-entry-properties)))
             (when (and (org-entry-is-todo-p)
                        (not (org-entry-get nil "CATEGORY"))
                        (not (org-entry-get nil "PROJECT")))
               (push (list file (org-get-heading t t)) missing))))
         nil 'file))
      (kill-buffer (current-buffer)))
    (if missing
        (progn
          (with-output-to-temp-buffer "*Missing Properties*"
            (princ "Headings missing properties:\n\n")
            (dolist (item missing)
              (princ (format "%s: %s\n" (car item) (cadr item)))))
          (message "Found %d headings with missing properties" (length missing)))
      (message "All headings have properties"))))

(global-set-key (kbd "C-c m p") 'my/find-org-missing-properties)
```

**Usage**: `C-c m p` - Shows headings missing properties

#### 3. Using Org QL for Maintenance Queries

**Find Unlinked Denote Notes**:

```elisp
(defun my/find-unlinked-denote ()
  "Find denote notes with no backlinks."
  (interactive)
  (org-ql-search (mapcar #'cdr my-denote-silos)
    '(and (tags "denote")
          (not (denote-backlinks)))
    :action (lambda ()
              (format "- %s\n" (org-get-heading t t)))))
```

**Find Tasks Without Context Tags**:

```elisp
(defun my/find-tasks-without-context ()
  "Find tasks without context tags."
  (interactive)
  (org-ql-search (org-agenda-files)
    '(and (todo "TODO" "NEXT")
          (not (tags-regexp "@")))
    :action (lambda ()
              (format "- %s\n" (org-get-heading t t)))))
```

### Regular Maintenance Workflows

#### Daily Maintenance (2 minutes)

1. **Process Inbox**: `C-c g p`
2. **Archive Completed**: `C-c C-x C-a` on done items
3. **Quick Check**: Look for obvious issues

#### Weekly Maintenance (15 minutes)

1. **Weekly Review**: `C-c a w`
2. **Process Fleeting Notes**: Review `denote/fleeting/`, move to permanent
3. **Check for Orphans**: Find unlinked notes
4. **Archive Old Items**: Archive completed projects

#### Monthly Maintenance (30 minutes)

1. **Metadata Audit**: `C-c m f` and `C-c m p`
2. **Fix Missing Metadata**: Add front matter, properties
3. **Review Archive**: Check old archives, consolidate if needed
4. **Keyword Cleanup**: Standardize keywords across notes
5. **Link Audit**: Find broken links, fix them

#### Quarterly Maintenance (1 hour)

1. **Full System Review**:

   - Review all active files
   - Consolidate similar items
   - Archive old projects
   - Update file structure if needed

2. **Knowledge Base Review**:

   - Review permanent notes
   - Merge similar notes
   - Update links
   - Archive outdated knowledge

3. **Workflow Review**:
   - What's working?
   - What's not?
   - Adjust workflows
   - Update documentation

### Maintenance Keybindings

| Keybinding | Command                            | Description                      |
| ---------- | ---------------------------------- | -------------------------------- |
| `C-c m f`  | my/find-denote-missing-frontmatter | Find files missing front matter  |
| `C-c m p`  | my/find-org-missing-properties     | Find headings missing properties |
| `C-c m u`  | my/find-unlinked-denote            | Find unlinked denote notes       |
| `C-c m c`  | my/find-tasks-without-context      | Find tasks without context tags  |

### Automated Maintenance Scripts

#### Shell Script for nb/zk Maintenance

```bash
#!/bin/bash
# ~/bin/maintain-notes.sh

echo "=== Note Maintenance ==="

# Find nb notes without tags
echo "Finding nb notes without tags..."
nb list --no-color | grep -v "\[" | while read -r note; do
    echo "Untagged: $note"
done

# Find zk notes without links
echo "Finding zk notes without links..."
zk list | while read -r note; do
    links=$(zk list --linked "$note" | wc -l)
    if [ "$links" -eq 0 ]; then
        echo "Unlinked: $note"
    fi
done

echo "=== Maintenance Complete ==="
```

#### Emacs Maintenance Function

```elisp
(defun my/maintenance-check ()
  "Run all maintenance checks."
  (interactive)
  (message "Running maintenance checks...")
  (my/find-denote-missing-frontmatter)
  (my/find-org-missing-properties)
  (message "Maintenance checks complete. Check *Missing Front Matter* and *Missing Properties* buffers."))

(global-set-key (kbd "C-c m a") 'my/maintenance-check)
```

**Usage**: `C-c m a` - Run all maintenance checks

### Best Practices for Maintenance

1. **Regular Processing**: Process inbox daily, don't let it build up
2. **Immediate Metadata**: Add metadata when creating items
3. **Weekly Review**: Regular review prevents issues
4. **Automate Checks**: Use functions to find issues automatically
5. **Fix as You Go**: Fix issues when you find them, don't accumulate
6. **Archive Regularly**: Keep active files small
7. **Link Liberally**: More links = better discovery
8. **Standardize Keywords**: Use consistent keywords

---

## Conclusion

This Emacs configuration is the result of years of refinement, focusing on simplicity, speed, and effectiveness. The key principles:

1. **Capture everything** - Don't let thoughts slip away
2. **Process regularly** - Keep inbox empty
3. **Work from context** - Use tags to filter tasks
4. **Review consistently** - Daily, weekly, monthly reviews
5. **Keep it simple** - Minimal files, clear structure

The setup adapts to different workflows while maintaining a consistent structure. Whether you're managing tasks, taking notes, writing, or coding, everything flows through a unified system.

### Getting Started

If you're new to this setup:

1. **Learn the basics**: Capture (`C-c c`), Agenda (`C-c a`), Process (`C-c g p`)
2. **Start capturing**: Use `C-c g c` for quick captures
3. **Process daily**: Make inbox processing a habit
4. **Use the journal**: `C-c j` to open today's journal
5. **Explore**: Use which-key to discover more features

### Resources

- [Org Mode Manual](https://orgmode.org/manual/)
- [Getting Things Done](https://gettingthingsdone.com/)
- [Denote Manual](https://protesilaos.com/emacs/denote)
- [Org GTD Package](https://github.com/Malabarba/org-gtd)

---

_This configuration is constantly evolving. The key is to find what works for you and adapt it to your needs._
