#!/bin/bash

URL=$1
QUALITY=$2
OUTPUT_DIR="/var/www/html/videos"
LOG_FILE="/var/www/html/yt_downloader_debug.log"

# Log the user running the script
echo "Script executed by user: $(whoami)" >> "$LOG_FILE"
echo "Starting download script at $(date)" >> "$LOG_FILE"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Clear existing media files in the output directory
rm -f "$OUTPUT_DIR"/*.mp4
rm -f "$OUTPUT_DIR"/*.webm

# Set the format based on the requested quality
case $QUALITY in
    "1080p")
        FORMAT="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
        ;;
    "720p")
        FORMAT="bestvideo[height<=720]+bestaudio/best[height<=720]"
        ;;
    "480p")
        FORMAT="bestvideo[height<=480]+bestaudio/best[height<=480]"
        ;;
    "360p")
        FORMAT="bestvideo[height<=360]+bestaudio/best[height<=360]"
        ;;
    *)
        FORMAT="best"
        ;;
esac

# Construct the output file name
OUTPUT_FILE="$OUTPUT_DIR/video"

# Download the video using yt-dlp

yt-dlp -f "$FORMAT" -o "$OUTPUT_FILE" "$URL" 2>> "$LOG_FILE"

# Check if the download was successful
if [ $? -eq 0 ]; then
    echo "Downloaded video to $OUTPUT_FILE" >> "$LOG_FILE"
    echo "Video saved as: $(basename "$OUTPUT_FILE")"
else
    echo "Error: Video download failed" >> "$LOG_FILE"
    cat "$LOG_FILE"
fi

