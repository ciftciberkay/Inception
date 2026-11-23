#!/bin/sh
set -eu

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

cat > /run/mysqld/inception-init.sql <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '$root_password';
CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$db_password';
ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$db_password';
GRANT ALL PRIVILEGES ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%';
SQL
chown mysql:mysql /run/mysqld/inception-init.sql
chmod 0600 /run/mysqld/inception-init.sql

exec mariadbd --user=mysql --console --bind-address=0.0.0.0 --port=3306 \
    --skip-name-resolve --init-file=/run/mysqld/inception-init.sql
