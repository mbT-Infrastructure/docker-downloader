#!/usr/bin/env bash
set -e

mkdir --parents /media/downloader/config
mkdir --parents /media/downloader/fail
mkdir --parents /media/downloader/output
mkdir --parents /media/workdir

echo "$DOWNLOADER_CRON root DOWNLOADER_PLAYLIST_URLS=\"${DOWNLOADER_PLAYLIST_URLS}\" /app/downloader.sh" \
    > /media/cron/downloader

exec /entrypoint-cron.sh "$@"
