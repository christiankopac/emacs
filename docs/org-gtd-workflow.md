# Org-GTD Workflow Guide

## Overview

This guide covers the Getting Things Done (GTD) methodology implementation in your Emacs configuration, along with other powerful Org mode features for productivity.

---

## Table of Contents

1. [GTD Core Concepts](#gtd-core-concepts)
2. [GTD Workflow](#gtd-workflow)
3. [Keybindings Reference](#keybindings-reference)
4. [Org Agenda Features](#org-agenda-features)
5. [Org Journal](#org-journal)
6. [Org Habits](#org-habits)
7. [Org Roam Integration](#org-roam-integration)
8. [Advanced Features](#advanced-features)

---

## GTD Core Concepts

### The Five Horizons of Focus

1. **Vision (3-5 Years)** - Long-term life vision and purpose
2. **Goals (1-2 Years)** - Annual objectives and milestones
3. **Areas of Focus** - Ongoing responsibilities (health, career, relationships, etc.)
4. **Projects** - Multi-step outcomes with deadlines
5. **Next Actions** - Single, concrete tasks you can do right now

### GTD Categories

Your configuration uses these GTD categories:

- **Inbox** - Uncategorized items to process
- **Actions** - Single next actions
- **Projects** - Multi-step initiatives
- **Calendar** - Time-specific events
- **Waiting/Delegated** - Items blocked by others
- **Incubated** - Someday/maybe items

---

## GTD Workflow

### 1. Capture Everything

**Keybinding:** `C-c d c` (org-gtd-capture)

Capture any thought, task, or idea immediately without interrupting your flow.

**Capture Templates:**

```
C-c c i  → Inbox item (general capture)
C-c c t  → Task (with TODO)
C-c c p  → Project (with sub-tasks)
```

**Example:**
```
* TODO Review quarterly budget
  :PROPERTIES:
  :CREATED: [2025-09-30]
  :END:
```

---

### 2. Clarify and Organize

**Keybinding:** `C-c d p` (org-gtd-process-inbox)

Process your inbox regularly (ideally daily). For each item, ask:

1. **What is it?** - Clarify the item
2. **Is it actionable?**
   - **No** → Delete, file as reference, or incubate
   - **Yes** → Continue to next step
3. **What's the next action?**
4. **Will it take less than 2 minutes?**
   - **Yes** → Do it now
   - **No** → Continue to next step
5. **Is it a project (multiple steps)?**
   - **Yes** → Create project with next actions
   - **No** → Add as single action
6. **Assign context and priority**

**Clarification Commands:**

```
C-c d a  → Clarify agenda item
C-c d i  → Clarify item
C-c d s  → Switch to clarify buffer
```

---

### 3. Organize by Context

**Tag System:**

**Life Areas (Grouped):**
- `area` (parent tag)
  - `health`
  - `relationships`
  - `finance`
  - `career`
  - `learning`
  - `home`

**Contexts:**
- `@work` - Office/work environment
- `@personal` - Personal time/home

**Energy Levels:**
- `quick` - Low-energy, short tasks (<15 min)
- `focus` - High-energy, deep work (>30 min)

**Setting Tags:** `C-c C-q` in org heading

**Example:**
```
* TODO Write quarterly report                    :@work:focus:career:
  DEADLINE: <2025-10-15>
* TODO Call dentist                              :@personal:quick:health:
```

---

### 4. Engage with Your Work

**Keybinding:** `C-c d e` (org-gtd-engage)

View and work on your tasks.

**Engage Views:**
```
C-c d e  → Engage with tasks
C-c d n  → Show all next actions
C-c d g  → Engage grouped by context
```

**Custom Agenda Views:**

**Daily Review (`d d` in agenda):**
- Today's agenda
- High priority tasks
- Due this week
- Waiting items

**Weekly Review (`d w` in agenda):**
- Week overview
- Stuck projects
- Coming deadlines
- Delegated tasks

**Projects Overview (`d p` in agenda):**
- Active projects
- Current goals
- Life areas

**Horizons Review (`d h` in agenda):**
- Vision (3-5 years)
- Goals (1-2 years)
- Areas of focus
- Active projects
- Next actions

---

### 5. Review Regularly

**Daily Review (5-10 minutes):**
1. Open agenda: `C-c a` then `d d`
2. Process inbox: `C-c d p`
3. Review today's tasks
4. Plan next actions

**Weekly Review (30-60 minutes):**
1. Open weekly agenda: `C-c a` then `d w`
2. Clear inbox completely
3. Review all projects
4. Update next actions
5. Check waiting/delegated items
6. Review someday/maybe list

**Monthly Review:**
Use the journal system: `C-c j m`

**Checklist:**
- [ ] Clear physical inbox
- [ ] Clear email inbox
- [ ] Clear 2_denote/capture
- [ ] Review project list
- [ ] Review next actions
- [ ] Review waiting for
- [ ] Review someday/maybe

---

## Keybindings Reference

### GTD Core

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c g c` | org-gtd-capture | Capture new item (quick) |
| `C-c g p` | org-gtd-process-inbox | Process inbox |
| `C-c g e` | org-gtd-engage | Engage with tasks |
| `C-c g n` | org-gtd-show-all-next | Show all next actions |
| `C-c g s` | org-gtd-clarify-switch-to-buffer | Switch to clarify buffer |
| `C-c g a` | org-gtd-clarify-agenda-item | Clarify agenda item |
| `C-c g i` | org-gtd-clarify-item | Clarify item |
| `C-c g g` | org-gtd-engage-grouped-by-context | Engage grouped by context |

### Org Capture (Integrated with GTD)

**Two Capture Workflows:**
1. **org-capture (`C-c c`)** - Template-based capture with rich options
   - Best for: Most captures, journaling, structured input
2. **org-gtd-capture (`C-c g c`)** - Direct inbox capture, no prompts
   - Best for: Ultra-quick brain dump, minimal friction

| Keybinding | Template | Description | Destination |
|------------|----------|-------------|-------------|
| `C-c c` | - | Open capture menu | - |
| `C-c c i` | [GTD] Inbox | Quick inbox capture | `→ inbox.org` |
| `C-c c t` | [GTD] Task | TODO task with schedule | `→ inbox.org` |
| `C-c c p` | [GTD] Project | Project with sub-tasks | `→ inbox.org` |
| `C-c c j` | [Journal] Entry | Weekly journal with prompt | `→ journal.org` |
| `C-c c J` | [Journal] Quick | Fast journal entry | `→ journal.org` |
| `C-c c m` | [GTD] Meeting | Meeting with attendees & action items | `→ inbox.org` |
| `C-c c s` | [GTD] Someday/Maybe | Future ideas/incubation | `→ inbox.org` |
| `C-c c r` | [GTD] Reference | Reference material | `→ inbox.org` |
| `C-c c l` | [GTD] Link | Web link or bookmark | `→ inbox.org` |
| `C-c c h` | [GTD→Tasks] Habit | Recurring habit with properties | `→ tasks.org` |
| `C-c g c` | GTD Capture | Direct to inbox (no template) | `→ inbox.org` |

### Org Agenda

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c a` | org-agenda | Open agenda menu |
| `C-c l` | org-store-link | Store link to current location |

**In Agenda View:**

| Key | Action |
|-----|--------|
| `d d` | Daily review |
| `d w` | Weekly review |
| `d p` | Projects overview |
| `d h` | Horizons review |
| `t` | Change TODO state |
| `q` | Quick effort |
| `,` | Set priority |
| `:` | Set tags |
| `C-c C-s` | Schedule |
| `C-c C-d` | Deadline |
| `r` | Refresh agenda |

---

## Org Agenda Features

### Agenda Files

Your agenda searches these directories:
- `~/Sync/2_denote/agenda/`
- `~/Sync/org/gtd/`

### Archive

Completed tasks are archived to:
- `~/Sync/2_denote/archive/[filename]_archive`

**Archive Command:** `C-c C-x C-a`

### Refile

Move items between files and headings.

**Keybinding:** `C-c C-w`

**Refile Targets:**
- Current file (up to level 3)
- Agenda files (up to level 2)
- denote files (up to level 2)
- GTD files (up to level 2)
- Archive files (up to level 2)

---

## Org Journal

Your journal system includes both denote-based daily journals and org-capture-based quick journaling.

### Quick Journal (Org Capture with Datetree)

**Keybindings:**
- `C-c c j` - Journal entry with prompt
- `C-c c J` - Quick journal (no prompt)

**Features:**
- All entries in single file: `~/Sync/org/journal.org`
- Week-based datetree structure
- Automatic timestamps
- Easy to search and review

**Structure:**
```org
* 2025
** 2025-W40
*** 2025-09-30 Monday
**** 14:23 Had productive morning
denote about what happened...

**** 16:45 Completed project milestone
Description of accomplishment...

*** 2025-10-01 Tuesday
**** 09:15 Morning reflection
Today's plan and thoughts...
```

**Usage:**

**With Prompt:**
```
C-c c j
Entry: Productive morning session
[Type your denote]
C-c C-c to save
```

**Quick (No Prompt):**
```
C-c c J
[Start typing immediately]
C-c C-c to save
```

**Benefits:**
- Single file for all journal entries
- Organized by week (easy to review weekly patterns)
- Collapse/expand with TAB
- Search entire journal history
- Integrates with org-agenda

---

### Daily Journal (Denote-based)

**Keybinding:** `C-c j d`

Creates/opens separate daily journal files with:
- Date header
- Carryover TODOs from previous day
- Automatic agenda integration
- Linking between daily denote

**File Location:** `~/Sync/org/journal/YYYY-MM-DD.org`

---

### Weekly Journal

**Keybinding:** `C-c j w`

Creates weekly journal with GTD planning sections:

**Sections:**
1. **Weekly Planning**
   - Goals & Outcomes
   - Projects to Advance
   - Next Actions by Context (@computer, @home, @errands, @calls)
   - Scheduled Items
   - Waiting For

2. **Weekly Review**
   - Accomplishments
   - Incomplete Items
   - Insights & Adjustments
   - Process Inbox (checklist)

**File Location:** `~/Sync/org/journal/weekly/YYYY-WNN.org`

---

### Monthly Journal

**Keybinding:** `C-c j m`

Creates monthly journal with strategic planning:

**Sections:**
1. **Monthly Planning**
   - Theme & Focus Areas
   - Major Goals
   - Active Projects
   - Areas of Responsibility Review
   - Key Deadlines & Events

2. **Monthly Review**
   - Progress on Goals
   - Projects Completed
   - Projects Stalled/Blocked
   - Wins & Challenges
   - Metrics & Tracking
   - GTD System Health Check
   - Carry Forward to Next Month

**File Location:** `~/Sync/org/journal/monthly/YYYY-MM.org`

---

### Yearly Journal

**Keybinding:** `C-c j y`

Creates yearly journal for vision and annual planning:

**Sections:**
1. **Yearly Planning**
   - Vision & Purpose
   - Major Objectives
   - Key Projects
   - Areas of Focus (Health, Relationships, Career, Finance, Learning, Creative)
   - Habits to Build/Break
   - Quarterly Milestones (Q1-Q4)

2. **Yearly Review**
   - Achievements & Wins
   - Goals Assessment
   - Disappointments & Failures
   - Growth & Evolution
   - Relationships
   - Skills & Knowledge Gained
   - Life Balance Assessment
   - Lessons Learned
   - Gratitude

**File Location:** `~/Sync/org/journal/yearly/YYYY.org`

---

## Org Habits

Track recurring habits with visual consistency graphs.

### Creating a Habit

```org
* TODO Exercise
  SCHEDULED: <2025-09-30 Mon .+1d>
  :PROPERTIES:
  :STYLE: habit
  :END:
```

**Habit Properties:**
- `SCHEDULED: <date .+Nd>` - Repeat every N days
- `:STYLE: habit` - Mark as habit

**Repeat Patterns:**
- `.+1d` - Every day
- `.+2d` - Every 2 days
- `.+1w` - Every week
- `.+1m` - Every month

### Viewing Habits

**Keybinding:** `C-c n h` (org-habit-stats-view-habit-at-point)

Shows:
- Consistency graph
- Completion percentage
- Streak information

---

## Org Roam Integration

### Core Roam Commands

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c n f` | org-roam-node-find | Find or create node |
| `C-c n i` | org-roam-node-insert | Insert link to node |
| `C-c n c` | org-roam-capture | Capture to roam |
| `C-c n l` | org-roam-buffer-toggle | Toggle backlinks sidebar |
| `C-c n g` | org-roam-graph | Show graph visualization |

### Roam Dailies (Journal Integration)

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c n d t` | org-roam-dailies-goto-today | Go to today's daily |
| `C-c n d y` | org-roam-dailies-goto-yesterday | Go to yesterday |
| `C-c n d d` | org-roam-dailies-goto-date | Go to specific date |
| `C-c n d n` | org-roam-dailies-goto-next-note | Next daily note |
| `C-c n d p` | org-roam-dailies-goto-previous-note | Previous daily note |

---

## Advanced Features

### Org Transclusion

**Keybinding:** `C-c n t` (add), `C-c n T` (toggle mode)

Include content from other org files:

```org
#+transclude: [[file:~/Sync/2_denote/2_denote/project.org::*Goals]]
```

---

### Org Pomodoro

**Keybinding:** `C-c n p`

Start pomodoro timer on current task:
- 25 minutes work
- 5 minutes break
- Longer break after 4 pomodoros

---

### Org QL (Query Language)

Search and filter org files with powerful queries.

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c q q` | org-ql-search | Search org files |
| `C-c q s` | org-ql-sparse-tree | Sparse tree from query |
| `C-c q b` | org-ql-search-buffer | Search current buffer |
| `C-c q t` | org-ql-tags | Search by tags |
| `C-c q p` | org-ql-projects | Search projects |
| `C-c q d` | org-ql-due-today | Due today |
| `C-c q w` | org-ql-due-this-week | Due this week |
| `C-c q n` | org-ql-todo-next | Next TODOs |

**Example Queries:**
```elisp
;; All TODO items tagged with @work
(todo "TODO" (tags "@work"))

;; High priority items due this week
(and (priority "A") (deadline :from today :to +7))

;; Projects with no NEXT actions
(and (tags "project") (not (descendants (todo "NEXT"))))
```

---

### Org Edna (Dependencies)

Track task dependencies automatically.

**Example:**
```org
* TODO Write draft
  :PROPERTIES:
  :BLOCKER: previous-sibling
  :TRIGGER: next-sibling todo!(NEXT)
  :END:

* TODO Review draft

* TODO Publish
```

When "Write draft" is completed, "Review draft" automatically becomes NEXT.

---

### Org Cliplink

**Keybinding:** `C-c n u`

Insert web link with title automatically fetched:

```org
[[https://example.com][Example Domain - Official Site]]
```

---

### Org Download

**Screenshot:** `C-c n s`
**Yank from clipboard:** `C-c n y`

Automatically saves images to `attach/images/` with timestamps.

---

### Org Export

Export org files to various formats.

**Keybinding:** `C-c C-e` (opens export menu)

**Available Formats:**
- `h h` - HTML
- `l p` - PDF (via LaTeX)
- `m m` - Markdown
- `t t` - Plain text
- `i i` - iCalendar

---

## Tips and Best Practices

### 1. Keep Inbox at Zero

Process inbox daily. Don't let it accumulate.

### 2. Use Contexts Effectively

Tag tasks with where/when they can be done:
- `@work` for office tasks
- `@personal` for home tasks
- `quick` for tasks that take <15 minutes

### 3. Review Regularly

- **Daily:** 5-10 minutes
- **Weekly:** 30-60 minutes
- **Monthly:** 1-2 hours
- **Quarterly:** Half day
- **Yearly:** Full day

### 4. One Next Action Per Project

Every project should have at least one NEXT action defined.

### 5. Use Deadlines Sparingly

Only set deadlines for things that truly have a deadline. Use scheduled for "do on this day."

### 6. Archive Completed Work

Keep your active files clean by archiving completed tasks.

### 7. Trust Your System

If it's not in your GTD system, it doesn't exist. Capture everything.

---

## Troubleshooting

### Issue: Agenda not showing items

**Solution:**
- Check `org-agenda-files` includes your GTD directory
- Verify file extensions are `.org`
- Rebuild agenda: `C-c a r`

### Issue: Habits not appearing

**Solution:**
- Ensure `:STYLE: habit` property is set
- Check habit has SCHEDULED with repeater (`.+Nd`)
- Enable `org-habit` module

### Issue: Refile not working

**Solution:**
- Check `org-refile-targets` configuration
- Use `C-u C-c C-w` to refile with full path
- Verify target files are in agenda files

---

## Resources

- **GTD Book:** "Getting Things Done" by David Allen
- **Org Mode Manual:** `C-h i d m Org RET`
- **Org-GTD Package:** https://github.com/Trevoke/org-gtd.el

---

*Last Updated: 2025-09-30*
