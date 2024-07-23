#!/bin/bash

# Get the parameters
url=$1
quality=$2

# Set the format based on the user's choice
case $quality in
    "1080p")
        format="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
        ;;
    "720p")
        format="bestvideo[height<=720]+bestaudio/best[height<=720]"
        ;;
    "480p")
        format="bestvideo[height<=480]+bestaudio/best[height<=480]"
        ;;
    "360p")
        format="bestvideo[height<=360]+bestaudio/best[height<=360]"
        ;;
    *)
        echo "Invalid option, defaulting to best quality."
        format="best"
        ;;
esac

# Define the download directory and current date
download_dir="/var/www/Downloads"
current_date=$(date +%Y-%m-%d)
yt_dl_dir="/var/www/yt-dl"
progress_file="/tmp/yt_download_progress_$$.txt"

# Download the video and write progress to the file
yt-dlp -f "$format" -o "$download_dir/%(title)s.%(ext)s" "$url" --newline | while IFS= read -r line; do
    echo "$line" >> "$progress_file"
done

# Get the downloaded file path
downloaded_file=$(yt-dlp --get-filename -o "$download_dir/%(title)s.%(ext)s" "$url")

# Check if the directory with the current date exists in yt-dl, if not, create it
if [ ! -d "$yt_dl_dir/$current_date" ]; then
    mkdir -p "$yt_dl_dir/$current_date"
fi

# Move the downloaded video to the directory with the current date
mv "$downloaded_file" "$yt_dl_dir/$current_date/"

# Get video details
video_title=$(yt-dlp --get-title "$url")
file_size=$(du -h "$yt_dl_dir/$current_date/$(basename "$downloaded_file")" | cut -f1)
download_date=$(date +%Y-%m-%d)
file_location="$yt_dl_dir/$current_date/$(basename "$downloaded_file")"

# Append video details to list.txt
{
    echo "Title: $video_title"
    echo "File: $(basename "$downloaded_file")"
    echo "Size: $file_size"
    echo "Download Date: $download_date"
    echo "Location: $file_location"
    echo "------------------------------------"
} >> "$yt_dl_dir/list.txt"

# Clean up progress file
rm "$progress_file"

echo "Download completed successfully."
