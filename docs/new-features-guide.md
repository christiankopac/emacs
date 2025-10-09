# New Features Guide

## Recent Configuration Additions

This guide covers the new features added to your Emacs configuration.

---

## 1. Denote Fleeting denote

### Overview
Quickly create fleeting denote (temporary thoughts/ideas) in a dedicated subdirectory.

### Location
All fleeting denote are stored in: `~/Sync/2_denote/2_denote/fleeting-2_denote/`

### Usage

**Quick Fleeting Note:**
```
C-c d F
→ Prompts for title
→ Automatically adds "fleeting" keyword
→ Saves to fleeting-denote subdirectory
```

**Example:**
```
C-c d F
Title: Interesting idea about productivity
→ Creates: ~/Sync/2_denote/2_denote/fleeting-2_denote/20250930T120000--interesting-idea-about-productivity__fleeting.org
```

### Workflow

**Capture → Process → Promote:**

1. **Capture** fleeting thoughts quickly with `C-c d F`
2. **Process** them regularly (daily/weekly review)
3. **Promote** to permanent denote:
   - `C-c d R` (rename/move to permanent-denote)
   - Or create new permanent note and link back

**Best Practices:**
- Use fleeting denote for quick captures during the day
- Keep inbox at zero by processing them regularly
- Extract valuable insights into permanent denote
- Delete or archive processed fleeting denote

---

## 2. Org Capture Journal with Datetree

### Overview
Quick journal entries organized by date in a single file with hierarchical date tree structure.

### Location
All journal entries in: `~/Sync/org/journal.org`

### Usage

**Two capture templates:**

**Template 1: Journal Entry (prompted)**
```
C-c c j
→ Prompts for entry title
→ Creates entry with time and your text
```

**Template 2: Journal (simple)**
```
C-c c J
→ No prompt, just start typing
→ Quick capture with time
```

### Structure

The journal file organizes entries like this:

```org
#+TITLE: Journal

* 2025
** 2025-W40
*** 2025-09-30 Monday
**** 14:23 Had a great meeting with team
denote about the meeting...

**** 16:45 Finished project milestone
Description of accomplishment...

*** 2025-10-01 Tuesday
**** 09:15 Morning thoughts
...
```

**Tree Type:** Week-based
- Entries grouped by year → week → day
- Easy to see weekly patterns
- Collapse/expand by week

### Features

**Automatic:**
- Time stamp (e.g., `14:23`)
- Date hierarchy (Year → Week → Day)
- Proper org structure

**Manual Control:**
- Change `tree-type` to `month` for monthly grouping
- Or `day` for simple date-only structure

**Example Change:**
```elisp
;; In org-core.el, change:
:tree-type week    → :tree-type month
```

### Workflow

**Daily Journaling:**
```
1. C-c c j
2. Type entry title: "Productive morning"
3. Add details
4. C-c C-c to save
```

**Quick Capture:**
```
1. C-c c J
2. Start typing immediately
3. C-c C-c to save
```

**Review:**
- Open `~/Sync/org/journal.org`
- Navigate with TAB (collapse/expand)
- Search with `C-s` or `C-c s s`

---

## 3. Movie Tracking with Denote

### Overview
Structured movie denote with pre-filled metadata template.

### Location
All movie denote in: `~/Sync/2_denote/2_denote/movies/`

### Usage

**Create Movie Note:**
```
C-c d m
→ Movie title: The Matrix
→ Year: 1999
→ Director: Wachowski Sisters
→ Genre: Sci-Fi
→ Rating (1-10): 9
```

### Generated Template

Creates a note with this structure:

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

[Your summary here]

* denote

[Your thoughts and observations]

* Quotes

[Memorable quotes]

* Related Movies

[Link to similar movies]
```

### Features

**Automatic:**
- Date you added the note
- "movie" keyword automatically added
- Watched date (today)

**Pre-filled:**
- Year, Director, Genre, Rating
- Structured sections ready to fill

**Linking:**
Use denote links in "Related Movies" section:
```org
* Related Movies

- [[denote:20250930T120000][Blade Runner]] - Similar cyberpunk theme
- [[denote:20250930T130000][Dark City]] - Reality manipulation
```

### Workflow

**After Watching:**
```
1. C-c d m
2. Fill in metadata (2 minutes)
3. Write summary while fresh
4. Add memorable quotes
5. Link to related movies
```

**Finding Movies:**
```
C-c x k  → Browse by genre/rating/year keywords
C-c s d  → Search movie denote
C-c d f  → Find specific movie
```

**Advanced Usage:**

**Add Custom Fields:**
Edit the template in `config/org/denote.el`:
```elisp
(insert "- Actors: %s\n" actors)
(insert "- IMDb: %s\n" imdb-link)
```

**Add More Sections:**
```elisp
(insert "\n* Cinematography\n\n")
(insert "\n* Soundtrack\n\n")
(insert "\n* Themes\n\n")
```

---

## 4. Updated Denote Directory Structure

### Overview
Organized subdirectories for different types of denote.

### Structure

```
~/Sync/2_denote/2_denote/
├── fleeting-2_denote/        # Quick captures, temporary thoughts
├── permanent-2_denote/       # Processed, evergreen denote
├── literature-2_denote/      # Book/article summaries
├── movies/                # Movie tracking denote
└── [other files]          # General denote in root
```

### Using Subdirectories

**Method 1: Specific Keybinding**
```
C-c d F  → Fleeting note (auto-subdirectory)
C-c d m  → Movie note (auto-subdirectory)
```

**Method 2: Choose Subdirectory**
```
C-c d N  → Prompts for subdirectory
```

**Method 3: Standard Denote (with prompt)**
```
C-c d n
Title: My Note
Keywords: permanent
Subdirectory: permanent-2_denote/  ← Choose here
```

### Configuration

**Available Subdirectories:**
```elisp
denote-subdirectories:
  - fleeting-denote
  - permanent-denote
  - literature-denote
  - movies
```

**Known Keywords:**
```elisp
denote-known-keywords:
  - fleeting
  - permanent
  - literature
  - reference
  - project
  - movie
```

**Add Custom Subdirectory:**

In `config/org/denote.el`:
```elisp
(setq denote-subdirectories '("fleeting-denote" 
                              "permanent-denote" 
                              "literature-denote" 
                              "movies"
                              "recipes"))  ; Add your own
```

---

## Complete Keybindings Reference

### Denote denote

| Keybinding | Command | Description |
|------------|---------|-------------|
| `C-c d n` | denote | Create note (prompts for subdirectory) |
| `C-c d N` | denote-subdirectory | Create note in specific subdirectory |
| `C-c d F` | my/denote-fleeting | Quick fleeting note |
| `C-c d m` | my/denote-movie | Create movie note |
| `C-c d f` | denote-open-or-create | Find/open note |
| `C-c d l` | denote-link | Insert link |
| `C-c d b` | denote-backlinks | Show backlinks |
| `C-c d R` | denote-rename-file | Rename/move note |

### Org Capture

| Keybinding | Template | Description |
|------------|----------|-------------|
| `C-c c i` | Inbox | General capture |
| `C-c c t` | Task | TODO task |
| `C-c c p` | Project | Project with sub-tasks |
| `C-c c j` | Journal Entry | Journal with prompt |
| `C-c c J` | Journal (simple) | Quick journal |

---

## Workflows

### Workflow 1: Zettelkasten with Fleeting denote

**Goal:** Build knowledge base using slip-box method.

**Steps:**

1. **Capture Fleeting Thoughts:**
   ```
   Throughout day:
   C-c d F → Quick thought
   ```

2. **Daily Processing:**
   ```
   Open ~/Sync/2_denote/2_denote/fleeting-2_denote/
   Review each note:
     - Trivial? Delete it
     - Valuable? Create permanent note
   ```

3. **Create Permanent denote:**
   ```
   C-c d n
   Title: [Concept in your own words]
   Keywords: permanent [topic]
   Subdirectory: permanent-2_denote/
   
   Write:
   - One idea per note
   - In your own words
   - Link to related denote
   ```

4. **Link denote:**
   ```
   C-c d i → Link related concepts
   C-c x n → Visualize network
   ```

---

### Workflow 2: Journaling + Task Management

**Goal:** Daily journaling integrated with GTD.

**Morning Routine:**
```
1. C-c c j → "Morning reflection"
   - How do I feel?
   - What's the priority today?

2. C-c a → Open agenda (review tasks)

3. C-c d F → Capture any overnight thoughts
```

**Throughout Day:**
```
C-c c J → Quick journal entries
  - "Great meeting outcome"
  - "Interesting insight about X"
  - "Need to follow up on Y"
```

**Evening Review:**
```
1. C-c c j → "Evening review"
   - What got done?
   - What didn't?
   - What did I learn?

2. Process fleeting denote from journal
   - Extract tasks → C-c c t
   - Extract ideas → C-c d n
```

---

### Workflow 3: Movie/Book Tracking

**Goal:** Build personal media library with denote.

**After Watching Movie:**
```
1. C-c d m → Create movie note
   Fill metadata (5 minutes)

2. Write while fresh:
   * Summary (2-3 sentences)
   * Key scenes/moments
   * Favorite quotes
   * Themes and symbolism

3. Link related movies:
   C-c d i → Link similar films
```

**Finding Patterns:**
```
C-c x k → View by genre
  → See all sci-fi movies
  → Identify patterns in your taste

C-c s d → Search for director
  → See all Kubrick films
  → Compare ratings
```

**Build Movie Collection:**
```
Create index note:
  C-c d n
  Title: Movie Collection Index
  
Link by:
  - Genre
  - Director
  - Theme
  - Era
  - Rating
```

---

## Tips

### Fleeting denote

1. **Capture Fast:** Don't overthink, just capture
2. **Process Daily:** Review and delete/promote every day
3. **Set Limit:** Keep max 20-30 fleeting denote at a time
4. **Use Tags:** Add context with keywords

### Journal

1. **Time Entries:** Automatic timestamps help track when thoughts occurred
2. **Search Later:** Use `C-c s s` to find past entries
3. **Link to Projects:** Reference tasks/projects from journal
4. **Weekly Review:** Collapse weeks to see patterns

### Movies

1. **Rate Honestly:** Use full 1-10 scale
2. **Write Immediately:** Summary fades quickly
3. **Link Liberally:** Connect themes across movies
4. **Add Keywords:** Genre, era, mood, director

---

## Customization

### Change Journal Structure

**Monthly instead of weekly:**
```elisp
;; In config/org/org-core.el
:tree-type week  →  :tree-type month
```

**Daily (flat structure):**
```elisp
:tree-type week  →  :tree-type day
```

### Add Movie Fields

**In config/org/denote.el, add to `my/denote-movie`:**
```elisp
(let* ((title (read-string "Movie title: "))
       (year (read-string "Year: "))
       (director (read-string "Director: "))
       (actors (read-string "Main actors: "))  ; NEW
       (runtime (read-string "Runtime: "))     ; NEW
       ...
```

Then insert:
```elisp
(insert (format "- Actors: %s\n" actors))
(insert (format "- Runtime: %s\n" runtime))
```

### Create Book Template

**Similar to movies:**
```elisp
(defun my/denote-book ()
  "Create a book note with pre-filled metadata."
  (interactive)
  (let* ((title (read-string "Book title: "))
         (author (read-string "Author: "))
         (year (read-string "Published: "))
         (pages (read-string "Pages: "))
         (rating (read-string "Rating (1-10): "))
         (denote-directory (expand-file-name "books/" denote-directory))
         (keywords '("book" "literature")))
    (denote title keywords)
    (goto-char (point-max))
    (insert "\n* Book Information\n\n")
    (insert (format "- Author: %s\n" author))
    (insert (format "- Published: %s\n" year))
    (insert (format "- Pages: %s\n" pages))
    (insert (format "- Rating: %s/10\n" rating))
    (insert (format "- Read: %s\n" (format-time-string "[%Y-%m-%d %a]")))
    (insert "\n* Summary\n\n")
    (insert "\n* Key Takeaways\n\n")
    (insert "\n* Quotes\n\n")
    (insert "\n* Personal Reflections\n\n")
    (save-buffer)))

(global-set-key (kbd "C-c d b") 'my/denote-book)
```

---

*Last Updated: 2025-09-30*

