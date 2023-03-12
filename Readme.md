# downloader image

This Docker image contains a script to download playlists.

It downloads all new files from the given playlists at the given cron schedule.


## Environment variables

- `DOWNLOADER_CRON`
    - The time to run the downloader. The default is `30 20 * * *`
- `DOWNLOADER_PLAYLIST_URLS`
    - Urls of the playlists. One per line. No spaces in url allowed.


## Volumes

- `/media/downloader`
    - The config and output directory.
- `/media/downloader/config`
    - The config directory, where downloaded id's are saved.
- `/media/downloader/fail`
    - The output directory, if a file with the same name is alraedy in the output directory.
- `/media/downloader/output`
    - The output directory.
- `/media/workdir`
    - The directory which is used while downloading.


## Development

To build the image locally run:
```bash
./docker-build.sh
```