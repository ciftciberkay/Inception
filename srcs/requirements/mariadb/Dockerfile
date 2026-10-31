FROM debian:12

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mariadb-server \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/mysqld /var/lib/mysql \
    && chown mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/60-inception.cnf /etc/mysql/mariadb.conf.d/60-inception.cnf
COPY tools/entrypoint.sh /usr/local/bin/inception-mariadb
RUN chmod 0755 /usr/local/bin/inception-mariadb

ENTRYPOINT ["/usr/local/bin/inception-mariadb"]
