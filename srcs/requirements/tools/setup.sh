#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
login=${1:-beciftci}

case "$login" in
    *[!a-z0-9_-]*|'') echo 'Login must contain lowercase letters, digits, _ or -' >&2; exit 1 ;;
esac

umask 077
mkdir -p "$repo_root/secrets"
for secret in db_password db_root_password wp_admin_password wp_user_password; do
    if [ ! -e "$repo_root/secrets/$secret.txt" ]; then
        openssl rand -hex 24 > "$repo_root/secrets/$secret.txt"
    fi
done

if [ ! -e "$repo_root/secrets/tls.key" ] || [ ! -e "$repo_root/secrets/tls.crt" ]; then
    openssl req -x509 -newkey rsa:3072 -sha256 -nodes -days 365 \
        -keyout "$repo_root/secrets/tls.key" \
        -out "$repo_root/secrets/tls.crt" \
        -subj "/CN=$login.42.fr" \
        -addext "subjectAltName=DNS:$login.42.fr"
fi
chmod 0600 "$repo_root"/secrets/*.txt "$repo_root/secrets/tls.key"
chmod 0644 "$repo_root/secrets/tls.crt"

if [ ! -e "$repo_root/srcs/.env" ]; then
cat > "$repo_root/srcs/.env" <<EOF
LOGIN=$login
DOMAIN_NAME=$login.42.fr
MYSQL_DATABASE=wordpress
MYSQL_USER=wp_app
WP_ADMIN_USER=siteowner
WP_ADMIN_EMAIL=$login@example.com
WP_USER=reader
WP_USER_EMAIL=reader@example.com
WP_TITLE=Inception
EOF
fi

echo "Local secrets are ready for $login."
echo 'Replace example.com emails before publishing.'
