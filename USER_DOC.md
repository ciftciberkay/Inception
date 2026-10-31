# User documentation

## Services

NGINX serves the website over HTTPS. WordPress supplies content and administration. MariaDB stores data. Only port 443 is exposed outside Docker.

## Start and stop

Start Docker Engine. Run commands from repository root:

```sh
make            # build and start
make ps         # show service status
make logs       # follow logs
make down       # stop; preserve data
make restart    # restart containers
```

## Website and administration

On a Linux VM, map the domain to the VM's IP address in the browser machine's hosts file:

```text
<VM_IP> beciftci.42.fr
```

For a macOS Docker Desktop preview, use `127.0.0.1` instead.

Open `https://beciftci.42.fr/` for the site and `https://beciftci.42.fr/wp-admin/` for administration. The TLS certificate is self-signed. Trust it locally or accept the browser warning for this local project.

## Credentials

Run `make setup` before first launch. It creates ignored files in `secrets/`. Administrator username defaults to `siteowner`; second user defaults to `reader`. Their passwords reside in `secrets/wp_admin_password.txt` and `secrets/wp_user_password.txt`. Database passwords reside in `secrets/db_password.txt` and `secrets/db_root_password.txt`. Never commit these files.

Nonsecret settings reside in tracked `srcs/.env`. Update email addresses before publishing. Changing usernames after initialization does not rename existing WordPress users; use WordPress administration.

To change a WordPress password, sign in as the administrator and open Users, select the account, then set its new password. Update the corresponding ignored password file locally to keep your credential record accurate. Editing that file alone does not change an existing WordPress account. Mac and VM installations have separate local credentials.

Keep database secrets unchanged while operating an existing installation. Database password rotation also requires updating the persisted WordPress `DB_PASSWORD` configuration; changing a secret file alone is insufficient.

## Check service health

Run `make verify` for containers, ports, volumes, users, and HTTPS. Inspect logs with `make logs`. On Linux, the two named volumes reside under `/home/beciftci/data/docker/volumes/`. Inspect them with `docker volume inspect inception_db_data inception_wp_data`. Check free space with `df -h`.
