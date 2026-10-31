FROM debian:12

ARG WORDPRESS_VERSION=7.1.2

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       ca-certificates curl tar util-linux php8.2-fpm php8.2-cli php8.2-mysql \
       php8.2-curl php8.2-gd php8.2-mbstring php8.2-xml php8.2-zip \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /run/php /usr/src/wordpress /var/www/html \
    && sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' /etc/php/8.2/fpm/pool.d/www.conf \
    && curl -fsSL "https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz" \
       -o /tmp/wordpress.tar.gz \
    && echo 'c0c666689d66b870d8825500bb8e402ed04de52602c61a6f516c6236b8c9ac67  /tmp/wordpress.tar.gz' \
       | sha256sum -c - \
    && tar -xzf /tmp/wordpress.tar.gz --strip-components=1 -C /usr/src/wordpress \
    && rm /tmp/wordpress.tar.gz \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
       -o /usr/local/bin/wp \
    && chmod 0755 /usr/local/bin/wp

COPY tools/entrypoint.sh /usr/local/bin/inception-wordpress
RUN chmod 0755 /usr/local/bin/inception-wordpress

WORKDIR /var/www/html
ENTRYPOINT ["/usr/local/bin/inception-wordpress"]
