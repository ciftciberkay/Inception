#!/bin/sh
set -eu

: "${MYSQL_DATABASE:?MYSQL_DATABASE is required}"
: "${MYSQL_USER:?MYSQL_USER is required}"

case "$MYSQL_DATABASE" in *[!a-zA-Z0-9_]*|'') echo 'Invalid MYSQL_DATABASE' >&2; exit 1 ;; esac
case "$MYSQL_USER" in *[!a-zA-Z0-9_]*|'') echo 'Invalid MYSQL_USER' >&2; exit 1 ;; esac

read_secret() {
    test -s "$1" || { echo "Missing secret: $1" >&2; exit 1; }
    value=$(cat "$1")
    case "$value" in *[!a-fA-F0-9]*|'') echo "Secret must be hexadecimal: $1" >&2; exit 1 ;; esac
    printf '%s' "$value"
}

root_password=$(read_secret /run/secrets/db_root_password)
db_password=$(read_secret /run/secrets/db_password)

mkdir -p /run/mysqld /var/lib/mysql
chown mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --auth-root-authentication-method=normal >/dev/null
fi

if [ ! -f /var/lib/mysql/.inception-initialized ]; then
    mariadbd --user=mysql --skip-networking --socket=/run/mysqld/mysqld.sock &
    server_pid=$!
    trap 'kill "$server_pid" 2>/dev/null || true' EXIT INT TERM

    ready=0
    for attempt in $(seq 1 30); do
        if mariadb-admin --socket=/run/mysqld/mysqld.sock ping --silent >/dev/null 2>&1; then
            ready=1
            break
        fi
        sleep 1
    done
    [ "$ready" -eq 1 ] || { echo 'MariaDB initialization timed out' >&2; exit 1; }

    if mariadb --socket=/run/mysqld/mysqld.sock -uroot -e 'SELECT 1' >/dev/null 2>&1; then
        mariadb --socket=/run/mysqld/mysqld.sock -uroot <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';
FLUSH PRIVILEGES;
SQL
    fi

    MYSQL_PWD="$root_password" mariadb --socket=/run/mysqld/mysqld.sock -uroot <<SQL
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$db_password';
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
SQL
    touch /var/lib/mysql/.inception-initialized
    chown mysql:mysql /var/lib/mysql/.inception-initialized
    MYSQL_PWD="$root_password" mariadb-admin --socket=/run/mysqld/mysqld.sock -uroot shutdown
    wait "$server_pid" || true
    trap - EXIT INT TERM
fi

exec mariadbd --user=mysql --console
