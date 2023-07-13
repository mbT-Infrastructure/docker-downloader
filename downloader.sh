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

        rename --filename --unicode UTF-8 \
            -E 's/\s/ /g' \
            -E 's/  / /g' \
            -E 's/ [x&] /, /gi' \
            -E 's/¡/i/gi' \
            -E 's/@/ at /gi' \
            -E 's/á/a/gi' \
            -E 's/é/e/gi' \
            -E 's/í/i/gi' \
            -E 's/ń/n/gi' \
            -E 's/ñ/n/gi' \
            -E 's/ó/o/gi' \
            -E 's/ø/ö/gi' \
            -E 's/[^a-zäöüß0-9 +\-\(\)\.,]//gi' \
            -E 's/^.* - (.*) - /$1 - /' \
            -E 's/^((.*, ){3,}.*), .*( - )/$1$3/' \
            -E 's/\[(.*)\]/\($1\)/g' \
            -E 's/ *\(((Official|Offizielles) )?((Music|Musik) ?)?(Audio|Lyrics|Video|Videoclip|Tiktok.*)\)//gi' \
            -E 's/ *[\|｜].*(Audio|Lyrics|Video|4k|Tiktok).*(\.\w*)/$3/gi' \
            -E 's/[\|｜]\s*(\w.*)(\.\w*)/\($1\)$2/' \
            "$WORKDIR"/*

        fileorganizer tagger FilenameToTag "$WORKDIR"

        echo "Move file \"$(ls -A "$WORKDIR")\""
        mv --no-clobber "$WORKDIR"/* "$OUTPUT_DIR"
        if [[ "$(ls -A "$WORKDIR")" ]]; then
            echo "Failed to move file"
            mv "$WORKDIR"/* "$FAIL_DIR"
        fi
    done
done
