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
    state=$(compose ps --format json "$service" | python3 -c 'import json,sys; x=json.load(sys.stdin); print((x[0] if isinstance(x,list) else x).get("State", ""))')
    [ "$state" = running ] || { echo "$service is not running" >&2; exit 1; }
done

published=$(docker port nginx)
printf '%s\n' "$published" | grep -q '^443/tcp -> ' || { echo 'NGINX 443 is not published' >&2; exit 1; }
if printf '%s\n' "$published" | grep -v '^443/tcp -> ' | grep -q .; then
    echo 'Unexpected published ports' >&2
    exit 1
fi
[ -z "$(docker port mariadb)" ] || { echo 'MariaDB publishes a port' >&2; exit 1; }
[ -z "$(docker port wordpress)" ] || { echo 'WordPress publishes a port' >&2; exit 1; }

for volume in inception_db_data inception_wp_data; do
    docker volume inspect "$volume" >/dev/null
    if [ "$(uname -s)" = Linux ]; then
        mountpoint=$(docker volume inspect -f '{{.Mountpoint}}' "$volume")
        case "$mountpoint" in "/home/$LOGIN/data/"*) ;; *) echo "$volume is outside /home/$LOGIN/data" >&2; exit 1 ;; esac
    fi
done

docker exec nginx nginx -t
docker exec wordpress wp --allow-root --path=/var/www/html user list --format=json \
    | python3 -c 'import json,sys; users=json.load(sys.stdin); assert len(users)==2, users; assert sum("administrator" in u["roles"] for u in users)==1, users'
curl -kfsS --resolve "$DOMAIN_NAME:443:127.0.0.1" "https://$DOMAIN_NAME/" >/dev/null
for version in 1_2 1_3; do
    openssl s_client -connect 127.0.0.1:443 -servername "$DOMAIN_NAME" \
        "-tls$version" -brief </dev/null 2>&1 \
        | grep -q "Protocol version: TLSv${version%_*}.${version#*_}" \
        || { echo "TLS $version handshake failed" >&2; exit 1; }
done
echo 'Container, port, volume, and HTTPS checks passed.'
