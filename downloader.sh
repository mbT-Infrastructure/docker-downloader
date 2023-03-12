#!/usr/bin/env bash
set -e

CONFIG_DIR="/media/downloader/config"
FAIL_DIR="/media/downloader/fail"
OUTPUT_DIR="/media/downloader/output"
WORKDIR="/media/workdir"

echo "Start downloader"

for URL in $DOWNLOADER_PLAYLIST_URLS; do
    echo "Download from \"${URL}\""
    while true; do
        yt-dlp --extract-audio --audio-format "mp3" --embed-thumbnail \
            --download-archive "${CONFIG_DIR}/downloaded.txt" --max-downloads 1 \
            --output "$WORKDIR/%(creator).80s - %(title)s.%(ext)s" --trim-filenames "124" \
            --quiet "$URL" \
            || true
        if [[ ! "$(ls -A "$WORKDIR")" ]]; then
            echo "No new download"
            break
        fi

        echo "Downloaded new file \"$(ls -A "$WORKDIR")\""
        touch --no-create "$WORKDIR"/*.mp3

        rename --filename 's/^.* - (.*) - /$1 - /' "$WORKDIR"/*.mp3
        rename --filename 's/\s*[\(\[](Official )?(Music )?(Audio|Lyrics|Video|Videoclip|Tiktok.*)[\)\]]//gi' "$WORKDIR"/*.mp3
        rename --filename 's/\s*\|.*(Audio|Lyrics|Video|4k|Tiktok).*(\.\w*)/$3/gi' "$WORKDIR"/*.mp3

        java -jar /app/Fileorganizer.jar --tagger --path "$WORKDIR" --filename

        echo "Move file \"$(ls -A "$WORKDIR")\""
        mv --no-clobber "$WORKDIR"/*.mp3 "$OUTPUT_DIR"
        if [[ "$(ls -A "$WORKDIR")" ]]; then
            echo "Failed to move file"
            mv "$WORKDIR"/* "$FAIL_DIR"
        fi
    done
done
