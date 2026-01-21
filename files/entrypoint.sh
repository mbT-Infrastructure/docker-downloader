#!/usr/bin/env bash
set -e -o pipefail

DOWNLOAD_TYPES=(movie music musicvideo news podcast series)

mkdir --parents /media/downloader/fail
mkdir --parents /media/workdir
for DOWNLOAD_TYPE in "${DOWNLOAD_TYPES[@]}"; do
    mkdir --parents "/media/downloader/output/$DOWNLOAD_TYPE"
    mkdir --parents "/media/downloader/config/$DOWNLOAD_TYPE"
done

echo "$DOWNLOADER_LIST" > /media/downloader/downloader-list-from-environment-variable.txt
chmod a-w /media/downloader/downloader-list-from-environment-variable.txt

echo "${POST_EXECUTION_COMMAND}" > /dev/shm/downloader-post-execution-command

echo "$DOWNLOADER_CRON root bash --login -c 'downloader.sh > /proc/1/fd/1 2>&1'" \
    > /media/cron/downloader

if [[ ! -e /media/downloader/downloader-list.txt ]]; then
    DOWNLOAD_TYPES_STRING="${DOWNLOAD_TYPES[*]}"
    echo "# [[${DOWNLOAD_TYPES_STRING// /|}]] URL ((NOTE))" \
    > /media/downloader/downloader-list.txt
fi

"$@"
