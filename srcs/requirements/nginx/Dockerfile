FROM debian:12

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends nginx \
    && rm -rf /var/lib/apt/lists/* \
    && rm -f /etc/nginx/sites-enabled/default

COPY conf/inception.conf /etc/nginx/sites-enabled/inception.conf

CMD ["nginx", "-g", "daemon off;"]
