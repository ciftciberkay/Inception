*This project has been created as part of the 42 curriculum by beciftci.*

# Inception

## Description

Inception runs a WordPress site in a Linux virtual machine. Docker Compose connects three locally built services: NGINX for HTTPS, WordPress with PHP-FPM, and MariaDB for the database.

## Instructions

Follow [DEV_DOC.md](DEV_DOC.md) to set up Docker and the volume data path in your VM. In the repository root, run `make`. It creates local secret files, builds the three images, and starts the services.

Open `https://beciftci.42.fr/` in the VM. See [USER_DOC.md](USER_DOC.md) for accounts, service status, and shutdown.

## Project description

The root Makefile runs `srcs/docker-compose.yml`. The service directories under `srcs/requirements/` contain the Dockerfiles, configuration, and startup scripts. Each image uses Debian 12. NGINX publishes only port 443, accepts TLS 1.2 and 1.3, and sends PHP requests to WordPress. The main processes run in the foreground. Docker restarts containers when they exit.

| Comparison | Choice in this project |
| --- | --- |
| Virtual machines vs Docker | A VM runs its own OS and kernel. Docker containers share the VM's kernel and isolate each service. |
| Secrets vs environment variables | `srcs/.env` holds nonsecret settings. Compose mounts local secret files under `/run/secrets` for the services that need them. |
| Docker network vs host network | A bridge network lets services reach one another by name. Host networking shares the host's network namespace. |
| Docker volumes vs bind mounts | Docker manages named volumes. A bind mount maps a particular host path into a container. This project uses two named volumes for application data. |

## Resources

- Inception subject, version 5.4
- [Docker Compose](https://docs.docker.com/compose/)
- [Docker volumes](https://docs.docker.com/engine/storage/volumes/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [WP-CLI handbook](https://make.wordpress.org/cli/handbook/)
- [MariaDB documentation](https://mariadb.com/docs/)

AI assisted with planning, Docker configuration, startup scripts, and documentation.
