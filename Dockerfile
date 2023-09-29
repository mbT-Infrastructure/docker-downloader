FROM madebytimo/cron

RUN install-autonomous.sh install Basics FFmpeg Fileorganizer Java Python Scripts YtDlp \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY downloader.sh .

RUN mv /entrypoint.sh /entrypoint-cron.sh
COPY entrypoint.sh /entrypoint.sh

ENV DOWNLOADER_CRON="30 20 * * *"
ENV DOWNLOADER_LIST=""
ENV POST_EXECUTION_COMMAND=""

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "sleep", "infinity" ]
