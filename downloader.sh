#!/usr/bin/env bash
set -e

CONFIG_DIR="/media/downloader/config"
FAIL_DIR="/media/downloader/fail"
NEW_DOWNLOAD=false
OUTPUT_DIR="/media/downloader/output"
WORKDIR="/media/workdir"

echo "Start downloader"

for URL in $DOWNLOADER_PLAYLIST_URLS; do
    echo "Download from \"${URL}\""
    while true; do
        yt-dlp --extract-audio --audio-format "opus" --embed-thumbnail --embed-thumbnail \
            --convert-thumb png --postprocessor-args \
            "ThumbnailsConvertor+ffmpeg_o:-c:v png -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\"" \
            --download-archive "${CONFIG_DIR}/downloaded.txt" --max-downloads 1 \
            --output "$WORKDIR/%(creator).80s - %(title)s.%(ext)s" --trim-filenames "124" \
            --quiet "$URL" \
            || true
        if [[ ! "$(ls -A "$WORKDIR")" ]]; then
            echo "No new download"
            break
        fi

        echo "Downloaded new file \"$(ls -A "$WORKDIR")\""
        NEW_DOWNLOAD=true
        touch --no-create "$WORKDIR"/*

        normalize-filename.sh "$WORKDIR"/*
        rename --filename --unicode UTF-8 \
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

if [[ "$NEW_DOWNLOAD" == true ]] && [[ -n "$POST_EXECUTION_COMMAND" ]]; then
    eval "$POST_EXECUTION_COMMAND"
fi
