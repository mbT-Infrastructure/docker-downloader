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
        yt-dlp --extract-audio --audio-format "opus" --embed-thumbnail \
            --download-archive "${CONFIG_DIR}/downloaded.txt" --max-downloads 1 \
            --output "$WORKDIR/%(creator).80s - %(title)s.%(ext)s" --trim-filenames "124" \
            --quiet "$URL" \
            || true
        if [[ ! "$(ls -A "$WORKDIR")" ]]; then
            echo "No new download"
            break
        fi

        echo "Downloaded new file \"$(ls -A "$WORKDIR")\""
        touch --no-create "$WORKDIR"/*

        rename --filename 's/^.* - (.*) - /$1 - /' "$WORKDIR"/*
        rename --filename 's/\s*[\(\[](Official )?(Music )?(Audio|Lyrics|Video|Videoclip|Tiktok.*)[\)\]]//gi' "$WORKDIR"/*
        rename --filename 's/\s*\|.*(Audio|Lyrics|Video|4k|Tiktok).*(\.\w*)/$3/gi' "$WORKDIR"/*

        fileorganizer tagger FilenameToTag "$WORKDIR"

        echo "Move file \"$(ls -A "$WORKDIR")\""
        mv --no-clobber "$WORKDIR"/* "$OUTPUT_DIR"
        if [[ "$(ls -A "$WORKDIR")" ]]; then
            echo "Failed to move file"
            mv "$WORKDIR"/* "$FAIL_DIR"
        fi
    done
done
