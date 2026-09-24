# User documentation

## Services

NGINX serves the website over HTTPS. WordPress supplies content and administration. MariaDB stores data. Only port 443 is exposed outside Docker.

## Start and stop

Start Docker Desktop. Run commands from repository root:

```sh
make            # build and start
make ps         # show service status
make logs       # follow logs
make down       # stop; preserve data
make restart    # restart containers
```

`make fclean` removes project containers, images, and volumes. It deletes both persistent datasets. Use it only for a full reset.

## Website and administration

Add this line to macOS `/etc/hosts`:

```text
127.0.0.1 beciftci.42.fr
```

Open `https://beciftci.42.fr/` for the site and `https://beciftci.42.fr/wp-admin/` for administration. The TLS certificate is self-signed. Trust it locally or accept the browser warning for this local project.

## Credentials

Run `make setup` before first launch. It creates ignored files in `secrets/`. Administrator username defaults to `siteowner`; second user defaults to `reader`. Their passwords reside in `secrets/wp_admin_password.txt` and `secrets/wp_user_password.txt`. Database passwords reside in `secrets/db_password.txt` and `secrets/db_root_password.txt`. Never commit these files.

Nonsecret settings reside in tracked `srcs/.env`. Update email addresses before publishing. Changing usernames after initialization does not rename existing WordPress users; use WordPress administration.

## Check service health

Run `make verify` for containers, ports, volumes, users, and HTTPS. Inspect logs with `make logs`. Docker Desktop stores named volumes inside its Linux VM; inspect them with `docker volume inspect inception_db_data inception_wp_data`. Check Mac free space with `df -h`.
