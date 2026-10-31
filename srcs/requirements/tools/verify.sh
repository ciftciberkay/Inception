#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
cd "$repo_root"
set -a
. ./srcs/.env
set +a

compose() {
    docker compose --env-file srcs/.env -f srcs/docker-compose.yml "$@"
}

for service in mariadb wordpress nginx; do
    compose ps --format json "$service" | python3 -c 'import json,sys; x=json.load(sys.stdin); x=x[0] if isinstance(x,list) else x; assert x.get("State")=="running" and x.get("Health")=="healthy", x'
done

published=$(docker port nginx)
printf '%s\n' "$published" | grep -q '^443/tcp -> ' || { echo 'NGINX 443 is not published' >&2; exit 1; }
if printf '%s\n' "$published" | grep -v '^443/tcp -> ' | grep -q .; then
    echo 'Unexpected published ports' >&2
    exit 1
fi
[ -z "$(docker port mariadb)" ] || { echo 'MariaDB publishes a port' >&2; exit 1; }
[ -z "$(docker port wordpress)" ] || { echo 'WordPress publishes a port' >&2; exit 1; }
docker inspect nginx --format '{{json .HostConfig.PortBindings}}' \
    | python3 -c 'import json,sys; ports=json.load(sys.stdin); assert set(ports)=={"443/tcp"} and all(p["HostPort"]=="443" for p in ports["443/tcp"]), ports'

for volume in inception_db_data inception_wp_data; do
    docker volume inspect "$volume" >/dev/null
    docker volume inspect "$volume" | python3 -c 'import json,sys; v=json.load(sys.stdin)[0]; assert v["Driver"]=="local" and not v.get("Options"), v'
    if [ "$(uname -s)" = Linux ]; then
        mountpoint=$(docker volume inspect -f '{{.Mountpoint}}' "$volume")
        case "$mountpoint" in "/home/$LOGIN/data/"*) ;; *) echo "$volume is outside /home/$LOGIN/data" >&2; exit 1 ;; esac
    fi
done

docker exec nginx nginx -t
docker exec wordpress wp --allow-root --path=/var/www/html user list --format=json \
    | python3 -c 'import json,sys; users=json.load(sys.stdin); admins=[u for u in users if "administrator" in u["roles"]]; assert len(users)==2 and len(admins)==1, users; assert "admin" not in admins[0]["user_login"].lower(), admins'
docker exec mariadb sh -c 'MYSQL_PWD=$(cat /run/secrets/db_password) mariadb -h 127.0.0.1 -u "$MYSQL_USER" "$MYSQL_DATABASE" -N -e "SHOW TABLES"' \
    | grep -q '^wp_users$'
if docker exec mariadb mariadb -u root -e 'SELECT 1' >/dev/null 2>&1; then
    echo 'MariaDB root accepts login without a password' >&2
    exit 1
fi
curl -kfsS --resolve "$DOMAIN_NAME:443:127.0.0.1" "https://$DOMAIN_NAME/" >/dev/null
for version in 1_2 1_3; do
    openssl s_client -connect 127.0.0.1:443 -servername "$DOMAIN_NAME" \
        "-tls$version" -brief </dev/null 2>&1 \
        | grep -q "Protocol version: TLSv${version%_*}.${version#*_}" \
        || { echo "TLS $version handshake failed" >&2; exit 1; }
done
for version in 1 1_1; do
    result=$(openssl s_client -connect 127.0.0.1:443 -servername "$DOMAIN_NAME" \
        "-tls$version" -cipher 'DEFAULT:@SECLEVEL=0' -brief </dev/null 2>&1 || true)
    printf '%s\n' "$result" | grep -q 'alert protocol version' \
        || { echo "TLS $version was not explicitly rejected by the server" >&2; exit 1; }
done
echo 'Container, port, volume, and HTTPS checks passed.'
if [ "$(uname -s)" != Linux ]; then
    echo 'macOS preview: Linux volume paths and VM reboot are not verified.'
fi
