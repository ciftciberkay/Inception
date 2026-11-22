#!/bin/sh
set -eu

case "$WP_ADMIN_USER" in *[Aa][Dd][Mm][Ii][Nn]*) echo 'Administrator username cannot contain admin' >&2; exit 1 ;; esac
[ "$WP_ADMIN_USER" != "$WP_USER" ] || { echo 'WordPress users must differ' >&2; exit 1; }

for secret in db_password wp_admin_password wp_user_password; do
    test -s "/run/secrets/$secret" || { echo "Missing secret: $secret" >&2; exit 1; }
done
db_password=$(cat /run/secrets/db_password)

if [ ! -f /var/www/html/wp-load.php ]; then
    cp -a /usr/src/wordpress/. /var/www/html/
fi
chown -R www-data:www-data /var/www/html

wp_run() {
    runuser -u www-data -- wp --path=/var/www/html "$@"
}

if [ ! -f /var/www/html/wp-config.php ]; then
    wp_run config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$db_password" \
        --dbhost=mariadb:3306 \
        --skip-check
fi

ready=0
for attempt in $(seq 1 30); do
    if DB_PASSWORD="$db_password" php -r '
        $db = @new mysqli("mariadb", getenv("MYSQL_USER"), getenv("DB_PASSWORD"), getenv("MYSQL_DATABASE"), 3306);
        exit($db->connect_errno ? 1 : 0);
    ' >/dev/null 2>&1; then
        ready=1
        break
    fi
    sleep 2
done
[ "$ready" -eq 1 ] || { echo 'WordPress database timed out' >&2; exit 1; }

if ! wp_run core is-installed --quiet; then
    wp_run core install \
        --url="https://$DOMAIN_NAME" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$(cat /run/secrets/wp_admin_password)" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email
fi

if ! wp_run user get "$WP_USER" --field=ID >/dev/null 2>&1; then
    wp_run user create "$WP_USER" "$WP_USER_EMAIL" \
        --role=subscriber \
        --user_pass="$(cat /run/secrets/wp_user_password)"
fi

exec php-fpm8.2 -F
