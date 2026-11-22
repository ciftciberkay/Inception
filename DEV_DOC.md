# Developer documentation

## Prepare the virtual machine

Use a dedicated Linux VM with a `beciftci` user and sudo access. Install Git, Make, OpenSSL, and curl. Install Docker Engine, Buildx, and the Compose plugin using the official instructions for [Debian](https://docs.docker.com/engine/install/debian/) or [Ubuntu](https://docs.docker.com/engine/install/ubuntu/).

Enable Docker at boot and give your VM account access to it. Sign out and back in after changing group membership.

```sh
sudo systemctl enable --now docker
sudo usermod -aG docker beciftci
docker compose version
```

Configure Docker's data directory before starting the project. Use `sudo install -d /etc/docker`, then `sudoedit /etc/docker/daemon.json`. Add this setting to the JSON object and preserve any existing keys.

```json
{
  "data-root": "/home/beciftci/data/docker"
}
```

Restart Docker and check the reported path. Docker keeps existing data at the old location when switching directories. If your VM already reports the expected path, skip this change.

```sh
sudo systemctl restart docker
docker info --format '{{.DockerRootDir}}'
```

In the VM, add this line to `/etc/hosts` using `sudoedit /etc/hosts`.

```text
127.0.0.1 beciftci.42.fr
```

## Build and operate

Clone the submission repository into an empty directory inside the VM. Run these commands from the repository root.

```sh
make
make ps
```

`srcs/.env` contains nonsecret configuration. `make setup` generates missing passwords and the local TLS certificate in `secrets/`. Both `make build` and `make` run this setup. The default build uses the project Dockerfiles. Compose starts those local images and waits for service health.

Use `make logs` to inspect startup, `make restart` to restart services, and `make down` to stop them. Run Compose directly from the same directory when needed.

```sh
docker compose --env-file srcs/.env -f srcs/docker-compose.yml ps
docker network ls
docker volume inspect inception_db_data inception_wp_data
docker exec wordpress wp --allow-root user list
docker exec -it mariadb mariadb -u root -p
```

Use the local root password for MariaDB, then run `USE wordpress;` and `SHOW TABLES;`. The two named volumes are under `/home/beciftci/data/docker/volumes/`. One stores MariaDB data. The other stores WordPress files and is shared read-only with NGINX. Container removal and VM reboot preserve both volumes.

## Evaluation

Open the HTTPS site and confirm that HTTP on port 80 is closed. Check the certificate and TLS using the local certificate file.

```sh
curl --cacert secrets/tls.crt --tlsv1.2 --tls-max 1.2 https://beciftci.42.fr/
curl --cacert secrets/tls.crt --tlsv1.3 https://beciftci.42.fr/
```

Comment on a post as `reader`. Edit a page as `siteowner`. Reboot the VM, run `make`, and check that both changes are visible. Approve the comment in the dashboard if moderation is enabled.

For a PHP-FPM port change, update the listener in the WordPress Dockerfile, the WordPress health check in Compose, and `fastcgi_pass` in NGINX. Run `make down`, then `make` and check HTTPS. For MariaDB, update `--port` in its startup script, the Compose health check, the WordPress startup script, and the existing WordPress `DB_HOST` setting. For an NGINX public port change, update the listener, published port, and WordPress site URLs. Restore the default configuration after the exercise.
