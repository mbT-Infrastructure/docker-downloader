FROM madebytimo/cron

COPY apt-sources.list /etc/apt/sources.list
RUN install-autonomous.sh install Java Scripts && \
    apt update && apt install -y -qq rename yt-dlp && \ 
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY downloader.sh Fileorganizer.jar .

RUN mv /entrypoint.sh /entrypoint-cron.sh
COPY entrypoint.sh /entrypoint.sh

ENV DOWNLOADER_CRON="30 20 * * *"
ENV DOWNLOADER_PLAYLIST_URLS=""

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
