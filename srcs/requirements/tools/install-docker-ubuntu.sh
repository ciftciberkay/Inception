#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo 'Run with sudo inside Ubuntu.' >&2
    exit 1
fi

login=${1:-beciftci}
getent passwd "$login" >/dev/null || { echo "User $login does not exist" >&2; exit 1; }
. /etc/os-release
[ "$ID" = ubuntu ] || { echo 'This installer requires Ubuntu.' >&2; exit 1; }

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates curl git make openssl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl enable --now docker.service
usermod -aG docker "$login"
docker compose version
echo "Docker installed. Log out and back in as $login."
