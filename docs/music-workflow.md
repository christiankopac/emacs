# Music in Emacs: EMMS & MPD Workflow

This document covers the music playback configuration using EMMS (Emacs Multimedia System) integrated with MPD (Music Player Daemon).

## Overview

The setup uses MPD as the audio backend daemon, with EMMS as the Emacs frontend. This provides:

- **Persistent playback**: Music continues even if Emacs crashes
- **Multiple clients**: Control from EMMS, ncmpcpp, or mobile apps
- **Gapless playback**: MPD handles audio transitions smoothly
- **Centralized library**: Single database for all clients

## Configuration

### Music Directory

```
/mnt/media/Music
```

### MPD Connection

- **Server**: localhost
- **Port**: 6660
- **Socket**: `~/.config/mpd/socket`

### Related Files

- MPD config: `~/.config/mpd/mpd.conf`
- EMMS config: `~/.config/emacs/config/media/music.el`

## Key Bindings

### Playback Controls

| Key         | Command         | Description                |
| ----------- | --------------- | -------------------------- |
| `C-c m p`   | `emms-pause`    | Pause/resume playback      |
| `C-c m SPC` | `emms-pause`    | Pause/resume (alternative) |
| `C-c m n`   | `emms-next`     | Next track                 |
| `C-c m b`   | `emms-previous` | Previous track             |
| `C-c m s`   | `emms-stop`     | Stop playback              |

### Volume

| Key       | Command             | Description     |
| --------- | ------------------- | --------------- |
| `C-c m +` | `emms-volume-raise` | Increase volume |
| `C-c m -` | `emms-volume-lower` | Decrease volume |

### Playlist & Browser

| Key       | Command                   | Description               |
| --------- | ------------------------- | ------------------------- |
| `C-c m l` | `emms-playlist-mode-go`   | Open playlist buffer      |
| `C-c m r` | `emms-browser`            | Open music browser        |
| `C-c m a` | `emms-add-directory-tree` | Add directory to playlist |

### MPD Management

| Key       | Command                  | Description              |
| --------- | ------------------------ | ------------------------ |
| `C-c m c` | `my/emms-mpd-connect`    | Connect to MPD           |
| `C-c m u` | `my/emms-mpd-update-db`  | Update MPD database      |
| `C-c m y` | `my/emms-mpd-sync-cache` | Sync EMMS cache from MPD |

### Playlist Management

| Key       | Command                       | Description                                               |
| --------- | ----------------------------- | --------------------------------------------------------- |
| `C-c m P` | `my/mpd-add-to-monthly-picks` | Add current song to monthly picks playlist (YYYYMM-picks) |

### Ratings

| Key         | Command                  | Description                     |
| ----------- | ------------------------ | ------------------------------- |
| `C-c m 1`   | `my/mpd-rate-1`          | Set rating to 1/5 (MPD sticker + file tags) |
| `C-c m 2`   | `my/mpd-rate-2`          | Set rating to 2/5 (MPD sticker + file tags) |
| `C-c m 3`   | `my/mpd-rate-3`          | Set rating to 3/5 (MPD sticker + file tags) |
| `C-c m 4`   | `my/mpd-rate-4`          | Set rating to 4/5 (MPD sticker + file tags) |
| `C-c m 5`   | `my/mpd-rate-5`          | Set rating to 5/5 (MPD sticker + file tags) |
| `C-c m M-1` | `my/mpd-add-to-rating-1` | Add to playlist: rating-1       |
| `C-c m M-2` | `my/mpd-add-to-rating-2` | Add to playlist: rating-2       |
| `C-c m M-3` | `my/mpd-add-to-rating-3` | Add to playlist: rating-3       |
| `C-c m M-4` | `my/mpd-add-to-rating-4` | Add to playlist: rating-4       |
| `C-c m M-5` | `my/mpd-add-to-rating-5` | Add to playlist: rating-5       |

### Grouping

| Key       | Command              | Description                                    |
| --------- | -------------------- | ---------------------------------------------- |
| `C-c m g` | `my/mpd-set-grouping` | Set grouping tag (completion menu with filtering) |

### listen.el

| Key       | Command  | Description              |
| --------- | -------- | ------------------------ |
| `C-c m m` | `listen` | Open listen.el interface |

## First-Time Setup

1. **Ensure MPD is running**:

   ```bash
   systemctl --user start mpd
   # Or check status:
   systemctl --user status mpd
   ```

2. **Connect EMMS to MPD**:

   ```
   M-x emms
   ```

   Or use `C-c m c`

3. **Sync the database**:

   ```
   C-c m y
   ```

   This populates the EMMS cache from MPD's database.

4. **Browse your library**:
   ```
   C-c m r
   ```

## Common Workflows

### Playing Music

1. Open browser: `C-c m r`
2. Navigate to artist/album
3. Press `RET` to add to playlist
4. Press `C-c m l` to view playlist
5. Use `C-c m p` to play/pause

### Adding New Music

When you add new music to `/mnt/media/Music`:

1. Update MPD database: `C-c m u`
2. Sync EMMS cache: `C-c m y`
3. Browse in EMMS: `C-c m r`

### Quick Add Directory

1. `C-c m a`
2. Select directory
3. All tracks added to current playlist

### Adding to Monthly Picks Playlist

Add the currently playing song to a monthly picks playlist (format: `YYYYMM-picks`, e.g., `202512-picks`):

1. Press `C-c m P` while a song is playing
2. The song will be added to the current month's picks playlist

You can also use the bash script:

```bash
~/.config/emacs/scripts/add-to-monthly-picks.sh
```

### Rating Songs

You can rate songs in two ways:

**Option 1: Set Rating (MPD Stickers + File Tags)**

- Press `C-c m 1` through `C-c m 5` to set a rating from 1 to 5
- Ratings are saved to:
  - **MPD stickers** (can be queried with `mpc sticker "file" get rating`)
  - **File tags** (embedded in the audio file itself)
    - MP3: Uses POPM frame (Windows Media Player standard)
    - FLAC: Uses RATING tag
    - Other formats: Uses RATING tag via kid3-cli
- File tags are portable and persist even if MPD database is rebuilt
- Tools used (in order of preference):
  - `kid3-cli` (universal support for MP3, FLAC, OGG, etc.)
  - `id3v2` (MP3 fallback)
  - `metaflac` (FLAC fallback)

**Option 2: Add to Rating Playlist**

- Press `C-c m M-1` through `C-c m M-5` to add the current song to a rating-based playlist
- Creates playlists named `rating-1`, `rating-2`, etc.
- Useful for organizing songs by rating

You can also use the bash scripts:

```bash
# Set rating (MPD sticker + file tags)
~/.config/emacs/scripts/save-rating-to-file.sh <file_path> <rating>

# Add to rating playlist
~/.config/emacs/scripts/add-to-rating-playlist.sh <rating>
# Example: add-to-rating-playlist.sh 5
```

### Setting Grouping Tags

Grouping allows you to categorize songs by mood, activity, or genre using predefined groups.

**In Emacs:**
- Press `C-c m g` to open a completion menu
- Type to filter the list of available groups
- Select a group to tag the currently playing song
- Uses `completing-read` with orderless filtering (type to search)

**In ncmpcpp:**
- Press `Alt-g` to open an fzf menu
- Type to filter the list of available groups
- Select a group to tag the currently playing song

**Configuration:**
- Edit `~/.config/emacs/config/media/music-groups.txt` to add/remove groups
- One group per line (comments start with `#`)
- Groups are saved to:
  - **MPD stickers** (can be queried with `mpc sticker "file" get grouping`)
  - **File tags** (embedded in the audio file as `GROUPING` tag)
    - MP3: Uses TXXX frame
    - FLAC: Uses GROUPING Vorbis comment
    - Other formats: Uses GROUPING tag via kid3-cli

**Example groups included:**
- ambient, background, chill, classical, dance, focus, gym, jazz, lounge, party, relax, road-trip, rock, sleep, study, workout, yoga

You can also use the bash script directly:
```bash
~/.config/emacs/scripts/set-grouping.sh
```

## Playlist Mode Keys

When in the EMMS playlist buffer (`*EMMS Playlist*`):

| Key       | Action                     |
| --------- | -------------------------- |
| `RET`     | Play track at point        |
| `n` / `p` | Next/previous line         |
| `d`       | Remove track from playlist |
| `D`       | Clear entire playlist      |
| `s`       | Save playlist              |
| `C`       | Clear and add new tracks   |
| `r`       | Toggle repeat              |
| `R`       | Toggle random/shuffle      |

## Browser Mode Keys

When in the EMMS browser:

| Key   | Action                             |
| ----- | ---------------------------------- |
| `RET` | Expand/collapse or add to playlist |
| `SPC` | Add to playlist without playing    |
| `b`   | Go back/up one level               |
| `q`   | Quit browser                       |

## Troubleshooting

### EMMS shows empty playlist

- Ensure `emms-player-mpd-music-directory` matches MPD's `music_directory`
- Run `C-c m y` to sync cache from MPD

### Cannot connect to MPD

- Check MPD is running: `systemctl --user status mpd`
- Verify port is correct (6660, not default 6600)
- Check `localhost` is accessible

### No sound

- Ensure PulseAudio/PipeWire is running
- Check MPD audio output configuration
- Try `mpc play` from terminal to test MPD directly

### Database out of sync

- Run `C-c m u` to update MPD database
- Then `C-c m y` to sync EMMS cache

## Alternative: listen.el

listen.el is a simpler music player also configured. Access it with:

```
C-c m m
```

It uses VLC as its backend and provides a minimal interface for quick music browsing.
