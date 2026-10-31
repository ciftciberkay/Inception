FROM debian:12

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nginx ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html

COPY conf/inception.conf /etc/nginx/sites-available/inception.conf
RUN rm -f /etc/nginx/sites-enabled/default \
    && ln -s /etc/nginx/sites-available/inception.conf /etc/nginx/sites-enabled/inception.conf

CMD ["nginx", "-g", "daemon off;"]
