# Developer documentation

The subject requires a Linux virtual machine. The macOS Docker Desktop setup below previews the stack; it cannot prove the required host volume paths.

## macOS setup

Install [Docker Desktop for Apple silicon](https://docs.docker.com/desktop/setup/install/mac-install/) on the M3 Mac. Start it and wait for the engine. Verify:

```sh
docker version
docker compose version
```

The project runs through Docker Desktop. No separately managed UTM VM is needed for development. Docker Desktop operates its own Linux VM internally.

## Local configuration

Run `make` in repository root. It creates four password files and a self-signed TLS keypair in ignored `secrets/` before building. Review email addresses in tracked `srcs/.env`. Never put credentials there.

Map `beciftci.42.fr` to `127.0.0.1` in macOS `/etc/hosts`. For a command-line check without editing hosts, use `curl --resolve beciftci.42.fr:443:127.0.0.1`.

## Build and launch

```sh
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
docker exec mariadb sh -c 'MYSQL_PWD=$(cat /run/secrets/db_password) mariadb -h 127.0.0.1 -u "$MYSQL_USER" "$MYSQL_DATABASE" -e "SHOW TABLES"'
make down
make restart
```

`make down` preserves named volumes. `make up` recreates containers without deleting site content. Monitor disk usage with `df -h`.

The database command reads the application password from its mounted secret. Root login without a password must fail. The root password is in `secrets/db_root_password.txt`.

## Linux evaluation

For strict evaluation, run this repository in an Ubuntu VM. Install Docker Engine and Compose using `srcs/requirements/tools/install-docker-ubuntu.sh beciftci`, then configure the Docker data root with `srcs/requirements/tools/configure-docker-data-root.sh beciftci`. Run `make setup`, `make`, and `make verify` there. The Makefile verifies the data root on Linux.

## Acceptance checks

1. Confirm three running containers and healthy dependencies.
2. Check that Docker publishes only NGINX port 443.
3. Check TLS 1.2 and 1.3; reject older protocols.
4. Open the site and `/wp-admin/`.
5. Confirm exactly two users: `siteowner` and `reader`.
6. Restart and rebuild; confirm content persists.
7. Inspect both named volumes.
8. Confirm Git contains no credentials or private keys.

## Evaluation explanations

Docker builds an image from each Dockerfile and runs each service in its own container. Compose reads `srcs/docker-compose.yml` to build and connect those images, plus their network, volumes, and secrets. The same image could be started with `docker run`, but its connections and settings would then need separate commands. Containers share the VM's Linux kernel; a VM supplies its own kernel. The root Makefile provides project commands, while `srcs/` holds service configuration.

Commit only repository files. Push from the Ubuntu submission computer when ready. Keep local volumes and ignored secrets out of Git.
