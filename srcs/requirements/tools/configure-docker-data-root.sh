#!/bin/sh
set -eu

if [ "$(id -u)" -ne 0 ]; then
    echo 'Run this script with sudo inside the Ubuntu VM.' >&2
    exit 1
fi

login=${1:-beciftci}
case "$login" in
    *[!a-z0-9_-]*|'') echo 'Invalid login' >&2; exit 1 ;;
esac

getent passwd "$login" >/dev/null || { echo "Ubuntu user $login does not exist" >&2; exit 1; }
target="/home/$login/data/docker"
current=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null || true)
if [ "$current" = "$target" ]; then
    echo "Docker already stores data in $target"
    exit 0
fi
if [ -n "$current" ] && [ "$current" != /var/lib/docker ]; then
    echo "Unexpected Docker data root: $current" >&2
    exit 1
fi
if [ -f /etc/docker/daemon.json ]; then
    python3 - "$target" <<'PY'
import json
import pathlib
import sys

data = json.loads(pathlib.Path('/etc/docker/daemon.json').read_text())
if 'data-root' in data and data['data-root'] != sys.argv[1]:
    raise SystemExit('daemon.json already sets another data-root')
PY
fi
if [ -e "$target" ]; then
    echo "Target already exists: $target" >&2
    exit 1
fi

systemctl stop docker.service docker.socket
mkdir -p "/home/$login/data"
chown "$login:$login" "/home/$login/data"
if [ -d /var/lib/docker ]; then
    mv /var/lib/docker "$target"
else
    mkdir -p "$target"
fi

mkdir -p /etc/docker
python3 - "$target" <<'PY'
import json
import pathlib
import sys

path = pathlib.Path('/etc/docker/daemon.json')
data = json.loads(path.read_text()) if path.exists() else {}
if 'data-root' in data and data['data-root'] != sys.argv[1]:
    raise SystemExit('daemon.json already sets another data-root')
data['data-root'] = sys.argv[1]
path.write_text(json.dumps(data, indent=2) + '\n')
PY

systemctl start docker.service
actual=$(docker info --format '{{.DockerRootDir}}')
[ "$actual" = "$target" ] || { echo "Docker reports unexpected data root: $actual" >&2; exit 1; }
echo "Docker data root: $actual"
