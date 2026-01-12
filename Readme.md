# downloader image

This Docker image contains a script to automate downloads.

It downloads all new files from the given urls at the given cron schedule.

## Installation

1. Pull from [Docker Hub], download the package from [Releases] or build using `builder/build.sh`


## Usage

### Environment variables

- `DOWNLOADER_CRON`
    - The time to run the downloader. The default is `30 20 * * *`
- `DOWNLOADER_LIST`
    - List of urls to download. One per line. No spaces in url allowed.
        List is in the format `[[movie|music|musicvideo|series]] URL ((NOTE))`.
- `POST_EXECUTION_COMMAND`
    - Command to run when the downloads are finished and new files are downloaded.


### Volumes

- `/media/downloader`
    - The config and output directory.
- `/media/downloader/config`
    - The config directory, where downloaded id's are saved.
- `/media/downloader/fail`
    - The output directory, if a file with the same name is already in the output directory.
- `/media/downloader/output`
    - The output directory.
- `/media/workdir`
    - The working directory which is used while downloading.


## Development

To build and run the docker container for development execute:

```bash
docker compose --file docker-compose-dev.yaml up --build
```

[Docker Hub]: https://hub.docker.com/r/madebytimo/downloader
[Releases]: https://github.com/mbt-infrastructure/docker-downloader/releases
