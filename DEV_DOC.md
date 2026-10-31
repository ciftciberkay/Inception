# Developer documentation

The subject requires a Linux virtual machine. The macOS Docker Desktop setup below previews the stack; it cannot prove the required host volume paths.

## Optional macOS preview

Install [Docker Desktop for Apple silicon](https://docs.docker.com/desktop/setup/install/mac-install/) on the M3 Mac. Start it and wait for the engine. Verify:

```sh
docker version
docker compose version
```

Use the Ubuntu VM for the required project workflow. Docker Desktop provides an optional macOS preview through its own internal Linux VM.

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

Use an Ubuntu 24.04 ARM64 VM on the Apple silicon Mac. Allocate 4 CPU cores, 6 GB RAM, and a 25 GB disk. An Ubuntu amd64 VM can run the same repository on an Intel/AMD submission machine. Use a Linux account named `beciftci`, with sudo access. Internet access is required for package installation and image builds.

Install Git before cloning if it is unavailable: run `sudo apt-get update`, then `sudo apt-get install -y git`. Clone the submission repository into an empty directory inside the VM. Run these commands from its root:

```sh
sudo ./srcs/requirements/tools/install-docker-ubuntu.sh beciftci
# Log out and back in to activate membership in the docker group.
sudo ./srcs/requirements/tools/configure-docker-data-root.sh beciftci
make
make verify
```

The installer supplies Git, Make, OpenSSL, curl, Python 3, Docker Engine, and Compose. Docker is enabled at boot. The data-root script moves Docker's existing directory while the daemon is stopped; use it in the dedicated project VM. The Makefile checks that Docker reports `/home/beciftci/data/docker` on Linux. Both native named-volume mountpoints are below `/home/beciftci/data/docker/volumes/`; no bind mount supplies persistent application data.

Run `hostname -I` in Ubuntu. In the Mac's `/etc/hosts`, map `beciftci.42.fr` to the VM's reachable IP instead of `127.0.0.1`. For checks from inside the VM, use `curl -k --resolve beciftci.42.fr:443:127.0.0.1 https://beciftci.42.fr/`.

The evaluation's initial cleanup deletes application data. It also deletes Docker's data-root directory with this layout. After that cleanup, `make` restarts Docker with sudo when its data-root directory is absent, allowing the daemon to recreate its internal directories before rebuilding. Do not run the evaluation's destructive cleanup on a shared machine or against data that must be kept.

For a build without cached application layers:

```sh
docker compose --env-file srcs/.env -f srcs/docker-compose.yml build --no-cache
make up
make verify
```

### Reboot and persistence

Edit Sample Page in the WordPress administration dashboard and add a comment as `reader`. A new comment may need administrator approval. Then reboot Ubuntu with `sudo reboot`. After signing back in, run `make up` and `make verify`. Confirm the edited page, comment, two users, and database tables remain. `make down` must also preserve both volumes.

### Required configuration modification

The reviewer chooses a service and an available replacement port. Change all settings that refer to that port, rebuild, restart, and demonstrate access. Keep the submitted defaults at NGINX 443, PHP-FPM 9000, and MariaDB 3306.

For a PHP-FPM change from 9000 to 9001, update these three files:

- `srcs/requirements/wordpress/Dockerfile`: PHP-FPM `listen` setting.
- `srcs/requirements/nginx/conf/inception.conf`: `fastcgi_pass wordpress:9001`.
- `srcs/docker-compose.yml`: WordPress healthcheck socket port.

Then run `make down`, `make up`, and `make verify`. The website must still work on HTTPS 443. Restore 9000 in all three files and repeat those commands.

For MariaDB, change its configuration port, WordPress's `--dbhost` and PHP readiness-check port, and the MariaDB healthcheck's connection port. Existing `wp-config.php` is persisted, so also set the new host before stopping the running stack:

```sh
docker exec wordpress wp --allow-root config set DB_HOST mariadb:3307
```

Rebuild and restart the whole stack. Restore both source settings and the persisted `DB_HOST` afterward. For NGINX, update both `listen` lines and the Compose port mapping. A replacement public HTTPS port also requires updating WordPress `home` and `siteurl` to include that port; restore them to `https://beciftci.42.fr` when the exercise ends. NGINX's `wordpress_host` map includes a nonstandard HTTPS port in the FastCGI host value so WordPress does not repeatedly redirect to the same URL.

## Acceptance checks

1. Confirm three running containers and healthy dependencies.
2. Check that Docker publishes only NGINX port 443.
3. Check TLS 1.2 and 1.3; reject older protocols.
4. Open the site and `/wp-admin/`.
5. Confirm exactly two users: `siteowner` and `reader`.
6. Restart and rebuild; confirm content persists.
7. Inspect both named volumes.
8. Confirm Git contains no credentials or private keys.
9. Complete the service configuration modification and restore the defaults.

## Evaluation explanations

Docker builds an image from each Dockerfile and runs each service in its own container. Compose reads `srcs/docker-compose.yml` to build and connect those images, plus their network, volumes, and secrets. The same image could be started with `docker run`, but its connections and settings would then need separate commands. Containers share the VM's Linux kernel; a VM supplies its own kernel. The root Makefile provides project commands, while `srcs/` holds service configuration.

Commit only repository files. Push from the Ubuntu submission computer when ready. Keep local volumes and ignored secrets out of Git.
