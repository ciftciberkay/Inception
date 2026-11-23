FROM debian:12

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=755 tools/entrypoint.sh /usr/local/bin/inception-mariadb

ENTRYPOINT ["/usr/local/bin/inception-mariadb"]
