#!/usr/bin/env bash
# Set grouping tag for currently playing song
# Uses fzf to select from predefined groups

GROUPS_FILE="$HOME/.config/emacs/config/media/music-groups.txt"
MUSIC_DIR="/mnt/media/Music"

# Check if groups file exists
if [ ! -f "$GROUPS_FILE" ]; then
    echo "Error: Groups file not found: $GROUPS_FILE"
    exit 1
fi

# Check if fzf is available
if ! command -v fzf >/dev/null 2>&1; then
    echo "Error: fzf is not installed"
    exit 1
fi

# MPD connection settings
MPD_SOCKET="$HOME/.config/mpd/socket"
MPD_HOST="localhost"
MPD_PORT="6660"

# Get current playing file
if [ -S "$MPD_SOCKET" ]; then
    CURRENT_FILE=$(mpc -h "$MPD_SOCKET" current -f '%file%')
    MPC_CMD="mpc -h $MPD_SOCKET"
else
    CURRENT_FILE=$(mpc -h "$MPD_HOST" -p "$MPD_PORT" current -f '%file%')
    MPC_CMD="mpc -h $MPD_HOST -p $MPD_PORT"
fi

# Check if a song is playing
if [ -z "$CURRENT_FILE" ]; then
    echo "No song is currently playing"
    exit 1
fi

# Get full file path
FULL_PATH="$MUSIC_DIR/$CURRENT_FILE"

# Check if file exists
if [ ! -f "$FULL_PATH" ]; then
    echo "Error: File does not exist: $FULL_PATH"
    exit 1
fi

# Use fzf to select group (filter out comments and empty lines)
SELECTED_GROUP=$(grep -v '^#' "$GROUPS_FILE" | grep -v '^$' | fzf --height=40% --border --prompt="Select group: ")

# Check if user cancelled (ESC or no selection)
if [ -z "$SELECTED_GROUP" ]; then
    echo "Cancelled"
    exit 0
fi

# Get file extension
EXT="${FULL_PATH##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

# Save grouping to file tags
SUCCESS=false

# Try kid3-cli first (universal support)
if command -v kid3-cli >/dev/null 2>&1; then
    if kid3-cli -c "set GROUPING $SELECTED_GROUP" "$FULL_PATH" >/dev/null 2>&1; then
        SUCCESS=true
    fi
fi

# Fallback: id3v2 for MP3 files (use TXXX frame for custom tags)
if [ "$SUCCESS" = false ] && [ "$EXT" = "mp3" ] && command -v id3v2 >/dev/null 2>&1; then
    if id3v2 --TXXX "GROUPING:$SELECTED_GROUP" "$FULL_PATH" >/dev/null 2>&1; then
        SUCCESS=true
    fi
fi

# Fallback: metaflac for FLAC files
if [ "$SUCCESS" = false ] && [ "$EXT" = "flac" ] && command -v metaflac >/dev/null 2>&1; then
    if metaflac --set-tag="GROUPING=$SELECTED_GROUP" "$FULL_PATH" >/dev/null 2>&1; then
        SUCCESS=true
    fi
fi

if [ "$SUCCESS" = true ]; then
    echo "Set grouping to: $SELECTED_GROUP"
    exit 0
else
    echo "Warning: Could not save grouping to file tags"
    exit 1
fi

