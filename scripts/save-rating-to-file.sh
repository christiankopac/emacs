#!/usr/bin/env bash
# Save rating to file tags using kid3-cli, id3v2, or metaflac
# Usage: save-rating-to-file.sh <file_path> <rating> (1-5)

if [ $# -ne 2 ]; then
    echo "Usage: $0 <file_path> <rating>"
    echo "Rating must be between 1 and 5"
    exit 1
fi

FILE_PATH="$1"
RATING="$2"

# Validate rating
if ! [[ "$RATING" =~ ^[1-5]$ ]]; then
    echo "Error: Rating must be between 1 and 5"
    exit 1
fi

# Check if file exists
if [ ! -f "$FILE_PATH" ]; then
    echo "Error: File does not exist: $FILE_PATH"
    exit 1
fi

# Get file extension
EXT="${FILE_PATH##*.}"
EXT=$(echo "$EXT" | tr '[:upper:]' '[:lower:]')

# Try kid3-cli first (universal support)
if command -v kid3-cli >/dev/null 2>&1; then
    if kid3-cli -c "set RATING $RATING" "$FILE_PATH" >/dev/null 2>&1; then
        exit 0
    fi
fi

# Fallback: id3v2 for MP3 files
if [ "$EXT" = "mp3" ] && command -v id3v2 >/dev/null 2>&1; then
    # Convert 1-5 rating to POPM frame (Windows Media Player standard)
    # Scale: 1=1, 2=64, 3=128, 4=196, 5=255
    case "$RATING" in
        1) POPM_VALUE=1 ;;
        2) POPM_VALUE=64 ;;
        3) POPM_VALUE=128 ;;
        4) POPM_VALUE=196 ;;
        5) POPM_VALUE=255 ;;
    esac
    if id3v2 --POPM "$FILE_PATH" "$POPM_VALUE" >/dev/null 2>&1; then
        exit 0
    fi
fi

# Fallback: metaflac for FLAC files
if [ "$EXT" = "flac" ] && command -v metaflac >/dev/null 2>&1; then
    if metaflac --set-tag="RATING=$RATING" "$FILE_PATH" >/dev/null 2>&1; then
        exit 0
    fi
fi

# If we get here, no tool worked
echo "Warning: Could not save rating to file tags (no suitable tool found)"
exit 1

