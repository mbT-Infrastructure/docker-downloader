#!/usr/bin/env bash
set -e

CONFIG_DIR="/media/downloader/config"
FAIL_DIR="/media/downloader/fail"
LOCK_FILE="/run/lock/$(basename "$0").lock"
NEW_DOWNLOAD=false
OUTPUT_DIR="/media/downloader/output"
WORKDIR="/media/workdir"

# Aquire lock
if [ -e "$LOCK_FILE" ]; then
    echo "Error: $(basename "$0") is already running. Exiting."
    exit 1
fi
touch "$LOCK_FILE"

echo "Start downloader"

mapfile -t DOWNLOADER_ITEMS_FILE </media/downloader/downloader-list.txt
mapfile -t DOWNLOADER_ITEMS_ENVIRONMENT_VARIABLE \
    </media/downloader/downloader-list-from-environment-variable.txt
DOWNLOADER_ITEMS=("${DOWNLOADER_ITEMS_ENVIRONMENT_VARIABLE[@]}" "${DOWNLOADER_ITEMS_FILE[@]}")

for ITEM in "${DOWNLOADER_ITEMS[@]}"; do
    ITEM="${ITEM##*([[:space:]])}"
    if [[ -z "$ITEM" ]] || [[ "$ITEM" == "#"* ]]; then
        echo "Skipping \"${ITEM}\"."
        continue
    fi
    TYPE="${ITEM%% *}"
    URL="${ITEM#* }"
    URL="${URL%% *}"
    NOTE="${ITEM#"$TYPE $URL"}"
    NOTE="${NOTE# }"

    RUN_FILENAME_SANITIZE=false
    RUN_FILEORGANIZER=false
    YT_DLP_ARGUMENTS=()
    if [[ "$TYPE" == movie ]]; then
        YT_DLP_ARGUMENTS=(--output \
        "${WORKDIR}/%(title)s (%(release_date>%Y,upload_date>%Y)s) [%(language).2s].%(ext)s")
    elif [[ "$TYPE" == music ]]; then
        RUN_FILENAME_SANITIZE=true
        RUN_FILEORGANIZER=true
        YT_DLP_ARGUMENTS=(--extract-audio --audio-format "opus" \
        --postprocessor-args "ThumbnailsConvertor+ffmpeg_o:-c:v \
        mjpeg -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\"" \
        --output "${WORKDIR}/%(creator).80s - %(title)s.%(ext)s")
    elif [[ "$TYPE" == musicvideo ]]; then
        YT_DLP_ARGUMENTS=(--output "${WORKDIR}/%(creator).80s - %(title)s.%(ext)s")
        RUN_FILENAME_SANITIZE=true
    elif [[ "$TYPE" == news ]]; then
        YT_DLP_ARGUMENTS=(--output "${WORKDIR}/%(release_date>%Y.%m.%d,upload_date>%Y.%m.%d)s \
%(playlist_title,channel)s - %(title)s \\[%(language).2s\\].%(ext)s")
    elif [[ "$TYPE" == series ]]; then
        YT_DLP_ARGUMENTS=(--output "${WORKDIR}/%(series,playlist_title)s S%(season_number|XX)02dE\
%(episode_number,playlist_index|XX)02d%(title& |)s%(title|)s (%(release_date>%Y,upload_date>%Y)s) [\
%(language).2s].%(ext)s")
    else
        echo "Type \"${TYPE}\" not supported."
        continue
    fi

    echo "Download ${TYPE} from \"${URL}\""
    while true; do
        EXIT_CODE=0
        yt-dlp "${YT_DLP_ARGUMENTS[@]}" --abort-on-unavailable-fragments --audio-multistream \
            --concurrent-fragments 8 --convert-thumb jpg \
            --download-archive "${CONFIG_DIR}/${TYPE}/downloaded.txt" \
            --embed-chapters --embed-metadata --embed-subs --embed-thumbnail \
            --format-sort res,vcodec:av01,acodec:opus,vcodec:vp9,vcodec:h264 --max-downloads 1 \
            --sub-langs all,-live_chat --trim-filenames "124" --quiet "$URL" || EXIT_CODE=$?
        if [[ "$EXIT_CODE" != @(101|0) ]]; then
            echo "Download failed with exit code ${EXIT_CODE}."
            rm -f "$WORKDIR"/*
        fi
        if [[ ! "$(ls -A "$WORKDIR")" ]]; then
            echo "No new download"
            break
        fi

        echo "Downloaded new file \"$(ls -A "$WORKDIR")\""
        NEW_DOWNLOAD=true
        touch --no-create "$WORKDIR"/*

        normalize-filename.sh "$WORKDIR"/*

        if [[ "$RUN_FILENAME_SANITIZE" == true ]]; then
        rename --filename --unicode UTF-8 \
            -E 's/^.* - (.*) - /$1 - /' \
            -E 's/^((.*, ){3,}.*), .*( - )/$1$3/' \
            -E 's/\[(.*)\]/\($1\)/g' \
            -E "s/ *\(((Official|Offizielles) )?((Music|Musik) ?)?(Audio|Lyrics|Video|Videoclip|Tik\
tok.*)\)//gi" \
            "$WORKDIR"/*
        fi

        if [[ "$RUN_FILEORGANIZER" == true ]]; then
            fileorganizer tagger FilenameToTag "$WORKDIR"
        fi

        if [[ -n "$NOTE" ]]; then
            rename --filename --unicode UTF-8 "s/^/${NOTE} - /" "$WORKDIR"/*
        fi

        echo "Move file \"$(ls -A "$WORKDIR")\""
        mv --no-clobber "$WORKDIR"/* "${OUTPUT_DIR}/${TYPE}"
        if [[ "$(ls -A "$WORKDIR")" ]]; then
            echo "Failed to move file"
            mv "$WORKDIR"/* "$FAIL_DIR"
        fi
    done
done

POST_EXECUTION_COMMAND="$(cat /tmp/post-execution-command)"
if [[ "$NEW_DOWNLOAD" == true ]] && [[ -n "$POST_EXECUTION_COMMAND" ]]; then
    eval "$POST_EXECUTION_COMMAND"
fi

# Release lock
rm "$LOCK_FILE"
