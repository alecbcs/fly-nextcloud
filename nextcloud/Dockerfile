FROM nextcloud:stable-apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    ffmpeg \
    imagemagick

COPY new_entrypoint.sh /new_entrypoint.sh

RUN chmod a+x /new_entrypoint.sh

ENTRYPOINT ["/new_entrypoint.sh"]