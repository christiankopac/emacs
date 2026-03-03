#!/usr/bin/env bash
# Add currently playing song to monthly picks playlist (format: YYYYMM-picks)

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

# Generate playlist name (YYYYMM-picks)
PLAYLIST_NAME=$(date +"%Y%m-picks")

# Add to playlist and save
$MPC_CMD add "$CURRENT_FILE"
$MPC_CMD save "$PLAYLIST_NAME"

echo "Added to playlist: $PLAYLIST_NAME"

