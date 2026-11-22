#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/../../.." && pwd)
cd "$repo_root"
. ./srcs/.env

umask 077
mkdir -p secrets
for secret in db_password db_root_password wp_admin_password wp_user_password; do
    if [ ! -s "secrets/$secret.txt" ]; then
        openssl rand -hex 24 > "secrets/$secret.txt"
    fi
done

if [ ! -s secrets/tls.key ] || [ ! -s secrets/tls.crt ]; then
    openssl req -x509 -newkey rsa:3072 -sha256 -nodes -days 365 \
        -keyout secrets/tls.key -out secrets/tls.crt \
        -subj "/CN=$DOMAIN_NAME" \
        -addext "subjectAltName=DNS:$DOMAIN_NAME"
fi
chmod 0600 secrets/*.txt secrets/tls.key
chmod 0644 secrets/tls.crt
