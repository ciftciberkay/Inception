# User documentation

## Services

NGINX serves the site over HTTPS. WordPress manages pages, posts, and users. MariaDB stores site content and accounts.

## Start, stop, and check

Run these commands from the repository root inside the VM.

| Command | Action |
| --- | --- |
| `make` | Build the images and start the site. |
| `make ps` | Check that all three containers are running and healthy. |
| `make logs` | Follow service logs. Press Ctrl+C to exit. |
| `make restart` | Restart the services. |
| `make down` | Stop the services and preserve both volumes. |

Open `https://beciftci.42.fr/` for the site and `https://beciftci.42.fr/wp-admin/` for administration. Use the VM browser and host mapping in [DEV_DOC.md](DEV_DOC.md). The local certificate is self-signed, so the browser may show a warning.

## Credentials

The first `make` creates the following local password files in `secrets/`. Keep them private and outside Git.

| Account | Password file |
| --- | --- |
| WordPress administrator `siteowner` | `wp_admin_password.txt` |
| WordPress subscriber `reader` | `wp_user_password.txt` |
| MariaDB application account `wp_app` | `db_password.txt` |
| MariaDB administrator `root` | `db_root_password.txt` |

Change a WordPress password under **Users** in the administration panel. Update the corresponding local file afterward. Editing the file alone leaves the existing account password unchanged. Keep the database passwords for the active installation. Rotating the application password also requires updating WordPress's saved database configuration.
