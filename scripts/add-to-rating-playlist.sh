#!/usr/bin/env bash
# Add currently playing song to rating-based playlist (rating-1, rating-2, etc.)
# Usage: add-to-rating-playlist.sh <rating> (1-5)

if [ $# -ne 1 ]; then
    echo "Usage: $0 <rating>"
    echo "Rating must be between 1 and 5"
    exit 1
fi

RATING=$1

# Validate rating
if ! [[ "$RATING" =~ ^[1-5]$ ]]; then
    echo "Error: Rating must be between 1 and 5"
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

# Generate playlist name
PLAYLIST_NAME="rating-$RATING"

# Add to playlist and save
$MPC_CMD add "$CURRENT_FILE"
$MPC_CMD save "$PLAYLIST_NAME"

echo "Added to playlist: $PLAYLIST_NAME"

