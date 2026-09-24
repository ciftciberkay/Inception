*This project has been created as part of the 42 curriculum by beciftci.*

# Inception

## Description

Inception runs WordPress through three locally built Docker images: NGINX, WordPress with PHP-FPM, and MariaDB. NGINX alone publishes HTTPS port 443. A private Docker network connects the services. Two named volumes preserve website and database files. Each image starts from `debian:12`.

## Instructions

Install [Docker Desktop for Apple silicon](https://docs.docker.com/desktop/setup/install/mac-install/) and start it. Docker Desktop includes Docker Compose. From the repository root:

```sh
make setup
make
make verify
```

Map `beciftci.42.fr` to `127.0.0.1` in macOS `/etc/hosts`, or test with `curl --resolve beciftci.42.fr:443:127.0.0.1`. Open `https://beciftci.42.fr/`. The generated certificate is self-signed.

See [USER_DOC.md](USER_DOC.md) for operation and [DEV_DOC.md](DEV_DOC.md) for setup and Linux submission notes. Keep `secrets/` out of Git. Tracked `srcs/.env` holds nonsecret settings.

## Project description

### Design choices

- NGINX terminates TLS and forwards PHP requests to WordPress.
- WordPress uses PHP-FPM without an embedded web server.
- MariaDB accepts connections through the private Docker network.
- Compose mounts credentials as secret files.
- Foreground daemons own PID 1; restart policies recover crashes.

### Virtual machines versus Docker

Docker Desktop runs a Linux virtual machine internally on macOS. Containers share its Linux kernel. This setup needs no separately managed UTM VM for development. The assignment brief explicitly requires a VM and data under `/home/<login>/data`; macOS Docker Desktop cannot demonstrate those host-side requirements. Use the documented Linux setup for strict evaluation.

### Secrets versus environment variables

Environment variables hold nonsecret configuration, including domain and usernames. Compose mounts passwords and TLS files from ignored `secrets/` files. Credentials do not enter Dockerfiles or Git.

### Docker network versus host network

The named bridge network allows service-name discovery. Compose publishes only NGINX port 443.

### Docker volumes versus bind mounts

Named volumes preserve data across container replacement. Docker Desktop stores them inside its Linux VM. On Linux with the configured Docker data root, they reside beneath `/home/beciftci/data/docker/volumes/`.

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
