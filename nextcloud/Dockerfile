FROM nextcloud:stable-apache

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sudo \
    ffmpeg \
    libmagickcore-6.q16-6-extra

COPY new_entrypoint.sh /new_entrypoint.sh

COPY mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf

RUN chmod a+x /new_entrypoint.sh

ENTRYPOINT ["/new_entrypoint.sh"]
