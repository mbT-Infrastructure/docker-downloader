#!/usr/bin/env bash
set -e

mkdir --parents /media/downloader/config
mkdir --parents /media/downloader/fail
mkdir --parents /media/downloader/output
mkdir --parents /media/workdir

echo "$DOWNLOADER_CRON root DOWNLOADER_PLAYLIST_URLS=\"${DOWNLOADER_PLAYLIST_URLS}\"" \
    "bash --login -c '/app/downloader.sh > /proc/1/fd/1 2>&1'" > \
    /media/cron/downloader

exec /entrypoint-cron.sh "$@"
