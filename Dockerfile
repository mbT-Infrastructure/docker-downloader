FROM madebytimo/cron

COPY apt-sources.list /etc/apt/sources.list
RUN install-autonomous.sh install Fileorganizer Java Scripts && \
    apt update && apt install -y -qq rename yt-dlp && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY downloader.sh .

RUN mv /entrypoint.sh /entrypoint-cron.sh
COPY entrypoint.sh /entrypoint.sh

ENV DOWNLOADER_CRON="30 20 * * *"
ENV DOWNLOADER_PLAYLIST_URLS=""
ENV POST_EXECUTION_COMMAND=""

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
