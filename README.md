*This project has been created as part of the 42 curriculum by beciftci.*

# Inception

## Description

Inception runs WordPress through three locally built Docker images: NGINX, WordPress with PHP-FPM, and MariaDB. NGINX alone publishes HTTPS port 443. A private Docker network connects the services. Two named volumes preserve website and database files. Each image starts from `debian:12`.

`srcs/docker-compose.yml` defines the stack. The three directories in `srcs/requirements/` contain its Dockerfiles and configuration. `srcs/requirements/tools/` contains setup scripts.

## Instructions

The subject requires a Linux virtual machine. Install Docker Engine and Compose there, then follow [DEV_DOC.md](DEV_DOC.md) to place Docker data beneath `/home/beciftci/data`. From the repository root:

```sh
make
make verify
```

`make` creates ignored local credentials on first use. Map `beciftci.42.fr` to the VM's IP address on the machine opening the site. Open `https://beciftci.42.fr/`. The generated certificate is self-signed. On macOS, Docker Desktop can preview the stack with `127.0.0.1`, but its volume paths do not meet the subject's host-path requirement.

See [USER_DOC.md](USER_DOC.md) for operation and [DEV_DOC.md](DEV_DOC.md) for setup and Linux submission notes. Keep `secrets/` out of Git. Tracked `srcs/.env` holds nonsecret settings.

## Project description

### Design choices

- NGINX terminates TLS and forwards PHP requests to WordPress.
- WordPress uses PHP-FPM without an embedded web server.
- MariaDB accepts connections through the private Docker network.
- Compose mounts credentials as secret files.
- Foreground daemons own PID 1; restart policies recover crashes.

### Virtual machines versus Docker

The subject requires a personal Linux VM. Docker containers share its Linux kernel but isolate individual services. Docker Desktop also runs a Linux VM internally on macOS; this local preview does not demonstrate the required host data path.

A VM runs its own operating system and kernel. Containers share the host kernel, so separate services need fewer resources than separate VMs.

### Secrets versus environment variables

Environment variables hold nonsecret configuration, including domain and usernames. Compose mounts passwords and TLS files from ignored `secrets/` files. Credentials do not enter Dockerfiles or Git.

Container environment variables can appear in Docker inspection output. Secrets are supplied as files under `/run/secrets`; keep their source files private and outside Git. Local Compose secrets are file mounts, not an encrypted secret store.

### Docker network versus host network

The named bridge network allows service-name discovery. Compose publishes only NGINX port 443.

Host networking shares the host's network namespace and removes the separate container network. The project uses a bridge network to isolate the services and expose only the selected HTTPS port.

### Docker volumes versus bind mounts

Named volumes preserve data across container replacement. On Linux with the configured Docker data root, they reside beneath `/home/beciftci/data/docker/volumes/`. Bind mounts do not supply persistent website or database files.

Docker manages named volumes. A bind mount exposes a specific host file or directory directly inside a container. Both can persist data, but the subject requires native named volumes for the website and database.

## Resources

- Inception subject, version 5.4 (provided assignment PDF)
- [Docker Desktop installation for Mac](https://docs.docker.com/desktop/setup/install/mac-install/)
- [Docker Engine installation for Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Docker Compose reference](https://docs.docker.com/reference/compose-file/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WordPress requirements](https://wordpress.org/about/requirements/)
- [WP-CLI handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.com/docs/)

AI assisted with planning, Docker configuration, startup scripts, and documentation. The maintainer should understand each configuration before evaluation.
