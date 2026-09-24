# Developer documentation

## macOS setup

Install [Docker Desktop for Apple silicon](https://docs.docker.com/desktop/setup/install/mac-install/) on the M3 Mac. Start it and wait for the engine. Verify:

```sh
docker version
docker compose version
```

The project runs through Docker Desktop. No separately managed UTM VM is needed for development. Docker Desktop operates its own Linux VM internally.

## Local configuration

Run `make setup` in repository root. It creates four password files and a self-signed TLS keypair in ignored `secrets/`. Review email addresses in tracked `srcs/.env`. Never put credentials there.

Map `beciftci.42.fr` to `127.0.0.1` in macOS `/etc/hosts`. For a command-line check without editing hosts, use `curl --resolve beciftci.42.fr:443:127.0.0.1`.

## Build and launch

```sh
make config
make build
make up
make ps
make verify
```

`make` also builds and starts everything. Compose waits for MariaDB health, then WordPress health, before starting NGINX. Every Dockerfile starts from `debian:12`. WordPress source and WP-CLI download during image build.

## Data and container commands

```sh
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
docker compose --env-file srcs/.env -f srcs/docker-compose.yml logs -f
docker volume inspect inception_db_data inception_wp_data
docker exec wordpress wp --allow-root --path=/var/www/html user list
make down
make restart
```

`make down` preserves named volumes. `make up` recreates containers without deleting site content. `make fclean` deletes project volumes and images. Back up data before using it. Monitor disk usage with `df -h`. Inspect build cache with `docker builder du`; remove unused cache with `docker builder prune` if needed.

## Linux evaluation

The assignment brief explicitly requires a virtual machine and host data under `/home/<login>/data`. Docker Desktop on macOS cannot prove those host-side requirements. For strict evaluation, run this repository in an Ubuntu VM. Install Docker Engine and Compose using `srcs/requirements/tools/install-docker-ubuntu.sh beciftci`, then configure the Docker data root with `srcs/requirements/tools/configure-docker-data-root.sh beciftci`. Run `make setup`, `make`, and `make verify` there. The Makefile verifies the data root on Linux.

## Acceptance checks

1. Confirm three running containers and healthy dependencies.
2. Check that Docker publishes only NGINX port 443.
3. Check TLS 1.2 and 1.3; reject older protocols.
4. Open the site and `/wp-admin/`.
5. Confirm exactly two users: `siteowner` and `reader`.
6. Restart and rebuild; confirm content persists.
7. Inspect both named volumes.
8. Confirm Git contains no credentials or private keys.

Commit only repository files. Push from the Ubuntu submission computer when ready. Keep local volumes and ignored secrets out of Git.
