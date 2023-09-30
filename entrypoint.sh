#!/usr/bin/env bash
set -e

DOWNLOAD_TYPES=(movie music musicvideo series)

mkdir --parents /media/downloader/fail
mkdir --parents /media/workdir

for DOWNLOAD_TYPE in "${DOWNLOAD_TYPES[@]}"; do
    mkdir --parents "/media/downloader/output/$DOWNLOAD_TYPE"
    mkdir --parents "/media/downloader/config/$DOWNLOAD_TYPE"
done

echo "$DOWNLOADER_LIST" > /media/downloader/downloader-list-from-environment-variable.txt
chmod a-w /media/downloader/downloader-list-from-environment-variable.txt

echo "$DOWNLOADER_CRON root POST_EXECUTION_COMMAND=\"${POST_EXECUTION_COMMAND}\"" \
    "bash --login -c '/app/downloader.sh > /proc/1/fd/1 2>&1'" > \
    /media/cron/downloader

if [[ ! -e /media/downloader/downloader-list.txt ]]; then
    echo "# [[movie|music|musicvideo|series]] URL ((NOTE))" \
    > /media/downloader/downloader-list.txt
fi

exec /entrypoint-cron.sh "$@"
