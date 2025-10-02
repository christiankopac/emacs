# Denote Workflow Guide

## Overview

Denote is a simple, signature-based note-taking system for Emacs that emphasizes:
- **Simplicity:** Plain text files with consistent naming
- **Flexibility:** Works with any text editor
- **Portability:** No database, just files
- **Linking:** Easy cross-references between notes
- **Discoverability:** Built-in search and navigation

---

## Table of Contents

1. [Core Concepts](#core-concepts)
2. [File Naming Convention](#file-naming-convention)
3. [Creating Notes](#creating-notes)
4. [Linking Notes](#linking-notes)
5. [Finding and Exploring Notes](#finding-and-exploring-notes)
6. [Journal Integration](#journal-integration)
7. [Templates](#templates)
8. [Keybindings Reference](#keybindings-reference)
9. [Workflows](#workflows)
10. [Advanced Features](#advanced-features)

---

## Core Concepts

### The Denote Philosophy

1. **Files are notes** - Each note is a plain text file
2. **Filenames are metadata** - Information encoded in filename
3. **Links are simple** - Use `[[denote:ID]]` format
4. **Search is king** - Find notes by content, not location
5. **Signatures organize** - Group related notes with signatures
6. **Subdirectories categorize** - Organize by type and workflow stage

### Directory Structure

```
~/Sync/org/notes/          # Main notes directory
  ├── fleeting-notes/      # Quick captures, temporary thoughts
  │   └── 20250930T120000--quick-idea__fleeting.org
  ├── permanent-notes/     # Processed, evergreen notes
  │   └── 20250930T130000--concept-note__permanent.org
  ├── literature-notes/    # Book and article summaries
  │   └── 20250930T140000--book-summary__literature.org
  ├── movies/              # Movie tracking and reviews
  │   └── 20250930T150000--the-matrix__movie.org
  └── [root level]         # General notes
      └── 20250930T160000--meeting-notes__work_project.org
```

---

## File Naming Convention

Denote uses a structured filename format:

```
IDENTIFIER==SIGNATURE--TITLE__KEYWORDS.EXTENSION
```

### Components

1. **Identifier** (required)
   - Format: `YYYYMMDDTHHmmss`
   - Example: `20250930T120000`
   - Automatically generated timestamp
   - Ensures unique filenames

2. **Signature** (optional)
   - Format: `==SIGNATURE`
   - Example: `==project-alpha`
   - Groups related notes
   - Good for series, projects, or categories

3. **Title** (required)
   - Format: `--title-with-hyphens`
   - Example: `--meeting-notes`
   - Human-readable description
   - Spaces converted to hyphens

4. **Keywords** (optional)
   - Format: `__keyword1_keyword2_keyword3`
   - Example: `__work_project_planning`
   - Tags for categorization
   - Underscore-separated

5. **Extension**
   - `.org` for org-mode files
   - `.md` for markdown files
   - `.txt` for plain text

### Examples

```
# Simple note
20250930T120000--my-first-note.org

# Note with keywords
20250930T120000--project-ideas__work_brainstorm.org

# Note with signature and keywords
20250930T120000==alpha--status-update__project_work.org

# Journal entry
20250930T080000==journal--morning-reflection__journal_personal.org
```

---

## Creating Notes

### Basic Note Creation

**Keybinding:** `C-c d n`

Creates a new note with prompts for:
1. Title
2. Keywords (comma-separated)
3. Subdirectory (choose from available)
4. Signature (optional)

**Available Subdirectories:**
- `fleeting-notes` - Quick captures
- `permanent-notes` - Processed knowledge
- `literature-notes` - Book/article notes
- `movies` - Movie tracking
- `[root]` - General notes

**Example Flow:**
```
C-c d n
Title: Project Planning
Keywords: work, project, alpha
Subdirectory: permanent-notes/
Signature: project-alpha
```

Result: `permanent-notes/20250930T120000==project-alpha--project-planning__work_project_alpha.org`

---

### Quick Fleeting Note

**Keybinding:** `C-c d F`

Creates a fleeting note (temporary thought/idea) with minimal prompts.

**Features:**
- Automatically saves to `fleeting-notes/` subdirectory
- Automatically adds "fleeting" keyword
- Quick capture for ideas during the day

**Example:**
```
C-c d F
Title: Interesting productivity insight
→ Creates: fleeting-notes/20250930T120000--interesting-productivity-insight__fleeting.org
```

**Workflow:**
1. Capture thoughts throughout the day with `C-c d F`
2. Process daily/weekly (review fleeting notes)
3. Promote valuable notes to permanent notes
4. Delete or archive processed fleeting notes

---

### Choose Subdirectory

**Keybinding:** `C-c d N`

Creates note and explicitly prompts for subdirectory selection.

**Use Case:** When you want to choose subdirectory without going through full prompts.

---

### Creating Note from Region

**Command:** `M-x denote-region`

Creates a new note with selected text as content (no default keybinding).

**Use Case:**
1. Select text in any buffer
2. Run `M-x denote-region`
3. Give it a title and keywords
4. Text is automatically inserted into new note

---

### Movie Note with Template

**Keybinding:** `C-c d v`

Creates a movie tracking note with pre-filled metadata template.

**Prompts for:**
- Movie title
- Year
- Director
- Genre
- Rating (1-10)

**Auto-generates:**
```org
#+title:      The Matrix
#+date:       [2025-09-30 Mon 14:23]
#+filetags:   :movie:
#+identifier: 20250930T142300

* Movie Information

- Year: 1999
- Director: Wachowski Sisters
- Genre: Sci-Fi
- Rating: 9/10
- Watched: [2025-09-30 Mon]

* Summary

* Notes

* Quotes

* Related Movies
```

**Saves to:** `movies/` subdirectory

**Use Case:** Track movies you've watched with structured metadata for later searching and linking.

---

## Linking Notes

### Insert Link to Existing Note

**Keybinding:** `C-c d l`

Opens completion menu to select and insert link.

**Format:** `[[denote:20250930T120000][Note Title]]`

**Features:**
- Fuzzy search by title, keywords, or content
- Preview in minibuffer
- Automatic title insertion

---

### Show Backlinks

**Keybinding:** `C-c d b`

Display all notes linking to current note.

**Use Case:**
- Discover connections
- See context
- Navigate related notes

---

## Finding and Exploring Notes

### Explore Commands

Denote Explore provides powerful navigation and discovery tools.

#### Count Notes

**Keybinding:** `C-c x c`

Count total number of notes in your denote directory.

---

#### Count Keywords

**Keybinding:** `C-c x k`

Count and display all keywords with usage statistics.

**Features:**
- Shows keyword frequency
- Helps identify keyword usage patterns
- Useful for cleanup and organization

---

#### Network Graph

**Keybinding:** `C-c x n`

Generate an interactive network visualization of note connections.

**Features:**
- Interactive D3.js graph
- Click nodes to navigate
- See connection patterns
- Identify note clusters
- Opens in web browser

---

#### Backlinks Chart

**Keybinding:** `C-c x b`

Generate a bar chart showing notes sorted by number of backlinks.

**Use Case:**
- Find most referenced notes
- Identify hub notes
- Understand note importance

---

#### Degree Chart

**Keybinding:** `C-c x g`

Generate a bar chart showing notes sorted by total connections (degree).

**Use Case:**
- Find hub notes (many connections)
- Identify orphans (no connections)
- Discover central concepts

---

#### Timeline Chart

**Keybinding:** `C-c x t`

Generate a timeline showing note creation over time.

**Use Case:**
- Visualize note-taking patterns
- Identify productive periods
- Track knowledge growth

---

#### Isolated Notes

**Keybinding:** `C-c x i`

Find notes with no links (neither linking out nor being linked to).

**Use Case:**
- Identify orphan notes
- Notes needing integration
- Cleanup candidates

---

#### Missing Links

**Keybinding:** `C-c x m`

Find broken links (links pointing to non-existent notes).

**Use Case:**
- Identify deleted notes still referenced
- Cleanup broken references
- Maintain note integrity

---

#### Random Walk

**Keybinding:** `C-c x w`

Start a random walk through your notes, following random links.

**Use Case:**
- Serendipitous discovery
- Review old notes
- Spark creativity

---

#### Random Links

**Keybinding:** `C-c x l`

Open a random note that has links (for exploration).

---

#### Find Duplicates

**Keybinding:** `C-c x d`

Find notes with duplicate or very similar titles.

**Use Case:**
- Identify duplicate content
- Merge similar notes
- Cleanup organization

---

#### Zero Keywords

**Keybinding:** `C-c x z`

Find notes without any keywords.

**Use Case:**
- Identify untagged notes
- Improve discoverability
- Maintenance task

---

#### Single Keyword

**Keybinding:** `C-c x s`

Find notes with only one keyword.

**Use Case:**
- Identify under-tagged notes
- Improve categorization

---

#### Sync Metadata

**Keybinding:** `C-c x o`

Synchronize front-matter metadata with filename metadata.

**Use Case:**
- Fix metadata inconsistencies
- Update after manual edits

---

#### Rename Keyword

**Keybinding:** `C-c x r`

Rename a keyword across all notes.

**Features:**
- Updates filenames
- Updates file contents
- Updates all references

**Use Case:**
- Fix typos in keywords
- Standardize keyword naming
- Refactor organization

---

### Search and Find

#### Find Note

**Keybinding:** `C-c d f`

Find and open a note by title, keywords, or signature.

**Search Features:**
- Fuzzy matching
- Keyword filtering
- Date filtering
- Signature filtering

---

#### Search All Notes

**Grep in Notes:** `C-c s g`

Full-text search across all notes using `consult-denote-grep`.

**Find Note with Preview:** `C-c s d`

Find and open notes with live preview using `consult-denote-find`.

**Example Searches (in grep):**
```
project alpha              # Find "project alpha"
TODO.*@work               # Regex search
!archive                  # Exclude matches
```

---

#### Find by Keywords

**Command:** `M-x denote-find-by-keywords`

Filter notes by one or more keywords (no default keybinding).

**Example:**
- Select `work` → Shows all work notes
- Then select `project` → Shows work AND project notes

---

#### Find by Signature

**Command:** `M-x denote-find-by-signature`

Show all notes with a specific signature (no default keybinding).

---

## Journal Integration

Denote includes a journal system that integrates with the calendar.

### Create/Open Journal Entry

**Daily Journal with Template:** `C-c j d`

Creates or opens today's daily journal with a structured template including:
- Morning Planning section
- Daily Notes/Log
- Evening Reflection

**Quick Log Entry:** `C-c j l` ⭐

Org-capture style quick entry for today's journal log. Perfect for capturing thoughts throughout the day!

**How it works:**
1. Press `C-c j l` from anywhere
2. A small capture buffer appears at the bottom
3. Type your entry (timestamp already added)
4. Press `C-c C-c` to save and close (or `C-c C-k` to cancel)
5. Entry is automatically added under `** Log` in today's journal

**Features:**
- Works from anywhere in Emacs
- Only shows the entry you're typing (like org-capture)
- Automatically creates journal if needed
- Timestamps each entry
- Saved to: `~/Sync/org/journal/daily/`

---

### Journal Navigation

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c j d` | my/daily-journal | Create/open today's journal with template |
| `C-c j l` | my/journal-log-entry | Quick log entry (use this!) |

---

### Calendar Integration

In calendar mode:
- Journal entries are marked
- Click date to open/create entry
- Visual indicator of existing entries

**Enable:** Automatically enabled in `calendar-mode`

---

## Templates

### Built-in Templates

Your configuration includes several templates:

#### Meeting Notes
```org
#+title: Meeting Notes - [Topic]
#+date: [Date]
#+filetags: :meeting:

* Attendees
- 

* Agenda
1. 

* Discussion

* Action Items
- [ ] 

* Next Steps
```

#### Book Notes
```org
#+title: [Book Title]
#+date: [Date]
#+filetags: :book:reading:

* Metadata
- Author: 
- Published: 
- ISBN: 

* Summary

* Key Takeaways
- 

* Quotes

* Personal Reflections
```

#### Code Snippet
```org
#+title: [Snippet Title]
#+date: [Date]
#+filetags: :code:snippet:

* Description

* Code
#+begin_src [language]

#+end_src

* Usage

* References
```

---

### Creating Custom Templates

Add templates to your capture system:

```elisp
(setq denote-templates
      '((custom-template . "#+title: TITLE\n#+date: DATE\n\n* Content\n")))
```

---

## Keybindings Reference

### Core Denote Commands

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c d n` | denote | Create new note |
| `C-c d N` | denote-subdirectory | Create note in specific subdirectory |
| `C-c d F` | my/denote-fleeting | Quick fleeting note |
| `C-c d v` | my/denote-movie | Create movie note with template |
| `C-c d f` | denote-open-or-create | Find and open note |
| `C-c d l` | denote-link | Insert link to note |
| `C-c d b` | denote-backlinks | Show backlinks |

### Denote Explore

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c x c` | denote-explore-count-notes | Count all notes |
| `C-c x k` | denote-explore-count-keywords | Count keywords |
| `C-c x d` | denote-explore-duplicate-notes | Find duplicates |
| `C-c x z` | denote-explore-zero-keywords | Notes without keywords |
| `C-c x s` | denote-explore-single-keywords | Notes with one keyword |
| `C-c x o` | denote-explore-sync-metadata | Sync metadata |
| `C-c x r` | denote-explore-rename-keyword | Rename keyword |
| `C-c x n` | denote-explore-network | Generate network graph |
| `C-c x w` | denote-explore-random-walk | Random walk through notes |
| `C-c x l` | denote-explore-random-links | Random linked notes |
| `C-c x t` | denote-explore-barchart-timeline | Timeline chart |
| `C-c x b` | denote-explore-barchart-backlinks | Backlinks chart |
| `C-c x g` | denote-explore-barchart-degree | Degree chart |
| `C-c x i` | denote-explore-isolated-notes | Find isolated notes |
| `C-c x m` | denote-explore-missing-links | Find broken links |

### Denote Journal

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c j d` | my/daily-journal | Daily journal with template |
| `C-c j l` | my/journal-log-entry | Quick timestamped log entry ⭐ |

### Search

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c s d` | consult-denote-find | Find note with preview |
| `C-c s g` | consult-denote-grep | Full-text search in notes |

### Link Management

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c d l` | denote-link | Insert link to note |

---

## Workflows

### Workflow 1: Project Documentation

**Goal:** Document a project with multiple related notes.

**Steps:**
1. Create project index: `C-c d n`
   - Title: "Project Alpha Index"
   - Signature: `project-alpha`
   - Keywords: `project, work`

2. Create project notes with same signature:
   - Meeting notes: `C-c d n` → signature: `project-alpha`
   - Technical specs: `C-c d n` → signature: `project-alpha`
   - Progress updates: `C-c d n` → signature: `project-alpha`

3. Link them together:
   - In index note, use `C-c d l` to link to project notes

4. Explore project:
   - `C-c x s` → Select `project-alpha` → See all notes

---

### Workflow 2: Research and Literature Notes

**Goal:** Take notes on research papers, books, and articles.

**Steps:**
1. Create literature note: `C-c d n`
   - Title: Paper/book title
   - Keywords: `literature, [topic]`
   - Use book template if available

2. While reading, create atomic notes:
   - Select interesting passage
   - `M-x denote-region` → Create note from region
   - Add keywords: `concept, [topic]`

3. Link concepts together:
   - Use `C-c d l` to link related concepts
   - Build concept map

4. Discover connections:
   - `C-c x n` → View network graph
   - Find related concepts across sources

---

### Workflow 3: Daily Journaling with Capture

**Goal:** Daily reflections and thought capture.

**Steps:**
1. Morning: Open today's journal: `C-c j d`
   - Fill in Morning Planning section
   - Set your top 3 priorities

2. Throughout the day: Quick capture thoughts with `C-c j l`
   - Press `C-c j l` → capture buffer appears
   - Type your thought
   - Press `C-c C-c` to save
   - Repeat anytime you have a thought
   
   **Workflow:**
   ```
   09:30 → C-c j l → "Team standup - John mentioned new API issue" → C-c C-c
   11:45 → C-c j l → "Had breakthrough on database optimization" → C-c C-c
   14:20 → C-c j l → "Client feedback positive, wants feature X" → C-c C-c
   16:30 → C-c j l → "Remember to follow up with client tomorrow" → C-c C-c
   ```
   
   **Result in journal:**
   ```org
   ** Log
   *** 09:30 - Team standup - John mentioned new API issue
   *** 11:45 - Had breakthrough on database optimization
   *** 14:20 - Client feedback positive, wants feature X
   *** 16:30 - Remember to follow up with client tomorrow
   ```

3. Evening review:
   - Process journal entries
   - Extract important insights into permanent notes
   - Use `M-x denote-region` to create notes from journal entries

4. Weekly review:
   - Search journals: `C-c s g` and search for "journal"
   - Identify patterns and themes
   - Update project notes

---

### Workflow 4: Zettelkasten Method

**Goal:** Build interconnected knowledge base.

**Steps:**
1. **Capture fleeting notes (temporary):**
   ```
   Throughout the day:
   C-c d F → Quick idea
   C-c d F → Interesting observation
   C-c d F → Book quote
   ```
   All saved to `fleeting-notes/` automatically.

2. **Daily/Weekly Processing:**
   ```
   Open fleeting-notes directory
   For each note, ask:
   - Is this valuable? → Create permanent note
   - Is this trivial? → Delete it
   - Is this for reference? → Move to literature-notes
   ```

3. **Create permanent notes:**
   ```
   C-c d n
   Title: [Concept in your own words]
   Keywords: permanent [topic]
   Subdirectory: permanent-notes/
   
   Write:
   - One idea per note
   - In your own words
   - Link to related notes with C-c d l
   ```

4. **Link extensively:**
   - Every permanent note links to at least one other
   - Use `C-c d l` for linking
   - Create structure notes (index notes) to organize themes

5. **Discover emergent structures:**
   - `C-c x n` → View network graph
   - `C-c x d` → Find hub notes (most connected)
   - `C-c x b` → Explore connection paths
   - `C-c x i` → Find isolated notes to connect

**Example Processing Flow:**
```
Fleeting: "People remember stories better than facts"
    ↓
Permanent: "Narrative Memory Advantage"
    Content: Our brains are wired for narrative structure...
    Links to: [[Memory Formation]], [[Storytelling]], [[Learning Methods]]
    ↓
Structure Note: "Effective Learning Techniques"
    Links to multiple permanent notes about learning
```

---

### Workflow 5: Movie/Media Tracking

**Goal:** Build personal media library with notes and insights.

**After Watching a Movie:**

1. **Create movie note immediately:**
   ```
   C-c d v
   Title: The Matrix
   Year: 1999
   Director: Wachowski Sisters
   Genre: Sci-Fi
   Rating: 9
   ```

2. **Fill in while fresh (5-10 minutes):**
   - **Summary:** 2-3 sentence plot summary
   - **Notes:** 
     - What stood out
     - Cinematography highlights
     - Key scenes
     - Acting performances
   - **Quotes:** Memorable dialogue
   - **Related Movies:** Link to similar films

3. **Link to related movies:**
   ```
   * Related Movies
   
   - [[denote:ID][Blade Runner]] - Similar cyberpunk aesthetic
   - [[denote:ID][Dark City]] - Reality manipulation theme
   - [[denote:ID][Inception]] - Mind-bending narrative
   ```

4. **Add custom keywords for searching:**
   ```
   Keywords: movie, sci-fi, 1990s, action, philosophical
   ```

**Finding and Organizing:**

```
C-c x k → Browse by genre/keyword
  → See all "thriller" movies
  → Compare ratings

C-c s d → Search movie notes
  → "Kubrick" → Find all Kubrick films
  → "neo-noir" → Find by style

C-c d f → Open specific movie
```

**Create Collections:**

```
C-c d n
Title: Sci-Fi Movies Collection
Subdirectory: permanent-notes/
Keywords: permanent, movies, sci-fi

Content:
* Best Rated
- [[The Matrix]] - 9/10
- [[Blade Runner]] - 10/10

* By Theme
** Artificial Intelligence
- [[Ex Machina]]
- [[Her]]

** Time Travel
- [[Primer]]
- [[12 Monkeys]]
```

---

### Workflow 6: Meeting Minutes and Action Items

**Goal:** Document meetings and track action items.

**Steps:**
1. Before meeting:
   - `C-c d n` with meeting template
   - Title: "Meeting - [Topic] - YYYY-MM-DD"
   - Signature: `meetings` or project signature
   - Keywords: `meeting, [project]`

2. During meeting:
   - Fill in attendees
   - Take notes in Discussion section
   - Add action items with TODO keywords

3. After meeting:
   - Link to related notes: `C-c d l`
   - Export action items to org-agenda

4. Follow-up:
   - Find all meetings: `C-c s g` and search for "meeting"
   - Or by project: `C-c x s` → Select project signature

---

## Advanced Features

### Renaming and Refactoring

**Keybinding:** `C-c d R`

Safely rename notes while updating all links.

**Features:**
- Updates filename
- Updates title in content
- Updates all links across notes
- Preserves signature and keywords

---

### Bulk Operations

**Dired Integration:**

Open notes directory in Dired, then:
- Mark files: `m`
- Add signature to marked: Custom function
- Rename bulk: `denote-dired-rename-files`

---

### Keywords Management

**Best Practices:**
- Keep keywords short and simple
- Use consistent naming (singular vs plural)
- Limit to 3-5 keywords per note
- Create keyword hierarchy in your mind

**Example Hierarchy:**
```
work
  ├─ project
  ├─ meeting
  └─ planning

personal
  ├─ health
  ├─ finance
  └─ learning
```

---

### Signature Strategies

**Use Signatures For:**
- Projects: `==project-alpha`
- Series: `==tutorial-series`
- Courses: `==course-emacs`
- Book chapters: `==book-gtd`
- Clients: `==client-acme`

**Benefits:**
- Group related notes
- Easy filtering
- Sortable in file browsers
- Clear organization

---

### Integration with Org-Roam

Denote can coexist with Org-Roam:

**Approach:**
- Use Denote for structured notes (projects, meetings)
- Use Org-Roam for knowledge graph (concepts, ideas)
- Link between systems using file links

---

### Search Techniques

**Ripgrep Search (`C-c s s`):**

```bash
# Boolean operators
term1 term2          # AND (both terms)
term1 | term2        # OR (either term)
!term                # NOT (exclude)

# Regex
TODO.*@work          # TODO followed by @work
\bword\b             # Exact word match

# File type
-g "*.org"           # Only .org files

# Context
-A 2                 # Show 2 lines after match
-B 2                 # Show 2 lines before match
```

---

### File Conversion

Convert between formats while preserving denote structure.

**Use Custom Functions:**
- `C-c k c r m` - Convert region to Markdown
- `C-c k c r o` - Convert region to Org
- In Dired: `C-c k f c` - Convert file format

---

## Tips and Best Practices

### 1. Start Simple

Don't over-organize at the beginning. Let structure emerge from usage.

### 2. Link Liberally

More links = better discovery. When in doubt, link it.

### 3. Use Descriptive Titles

Titles should be clear 6 months from now. Avoid vague titles like "thoughts" or "notes".

### 4. Review Regularly

- **Daily:** Process fleeting notes
- **Weekly:** Review and link recent notes
- **Monthly:** Explore network, find orphans

### 5. Keywords: Quality Over Quantity

Use 2-4 meaningful keywords rather than 10 vague ones.

### 6. Leverage Signatures for Series

Starting a tutorial series or project? Use a signature from the beginning.

### 7. Create Index Notes

For large topics, create an index note that links to all related notes.

### 8. Use Templates Consistently

Templates ensure completeness and make notes easier to process later.

### 9. Don't Fear Orphans

Orphan notes (no links) are okay temporarily. Use `C-c x S` to find them during reviews.

### 10. Backlinks Are Gold

Regularly check backlinks (`C-c d b`) to discover unexpected connections.

---

## Maintenance Tasks

### Weekly Maintenance (15 minutes)

1. Process fleeting notes into permanent notes
2. Check for orphan notes: `C-c x d` → Sort ascending
3. Review backlinks on recent notes
4. Add missing links: `C-c x S`

### Monthly Maintenance (30 minutes)

1. Review keyword consistency
2. Explore network: `C-c x n`
3. Create index notes for emerging themes
4. Archive completed project notes
5. Update project signatures

### Quarterly Maintenance (1 hour)

1. Full-text search for common topics
2. Refactor note structure if needed
3. Review and clean up keywords
4. Create meta notes (notes about notes)
5. Visualize and document your knowledge graph

---

## Troubleshooting

### Issue: Links not working

**Solution:**
- Check link format: `[[denote:ID]]`
- Verify target note exists
- Rebuild cache if using denote-explore

### Issue: Can't find notes

**Solution:**
- Check `denote-directory` path
- Verify file naming format
- Use full-text search: `C-c s s`

### Issue: Signature not showing in filename

**Solution:**
- Use `C-c d R` to rename with signature
- Check for double `==` in filename

### Issue: Journal entries not appearing in calendar

**Solution:**
- Verify `denote-journal-calendar-mode` is enabled
- Check journal files are in correct directory
- Refresh calendar view

---

## Resources

- **Denote Manual:** https://protesilaos.com/emacs/denote
- **Denote Video Tutorial:** https://protesilaos.com/codelog/2022-06-18-denote-demo/
- **Zettelkasten Method:** https://zettelkasten.de/
- **Protesilaos Stavrou's Blog:** https://protesilaos.com/

---

*Last Updated: 2025-09-30*

