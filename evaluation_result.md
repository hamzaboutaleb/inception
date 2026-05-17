# Inception Evaluation Result

Date: 2026-05-16
Repository checked: `/home/hboutaleb/Desktop/inception`

## Overall Result

Result: PASS for the automated/static checks I could validate locally.

The previous blocking issues were fixed:
- committed secret files were removed from the working tree
- Compose no longer uses Docker `secrets:` or `/run/secrets`
- credentials are read from the local ignored `srcs/.env`
- the configured domain is now `hboutale.42.fr`
- MariaDB first-run initialization no longer starts a temporary background daemon
- WordPress correctly initializes even if the shared volume was touched by NGINX first

Important Git note: the deleted files under `secrets/` must be committed as deletions before submission. Until then, `git ls-files secrets` still lists them because they were tracked previously.

## Files Changed For Fixes

- `.gitignore`
- `srcs/docker-compose.yml`
- `srcs/requirements/mariadb/Dockerfile`
- `srcs/requirements/mariadb/tools/entry.sh`
- `srcs/requirements/wordpress/tools/entry.sh`
- `README.md`
- `DEV_DOC.md`
- `USER_DOC.md`
- deleted `secrets/credentials.txt`
- deleted `secrets/db_password.txt`
- deleted `secrets/db_root_password.txt`
- deleted `secrets/db_wordpress_password.txt`

Local ignored file updated:
- `srcs/.env`

## Validation Evidence

### Static Checks

Status: PASS

- Root `Makefile` exists.
- Required project files are under `srcs/`.
- `srcs/docker-compose.yml` renders with `docker compose config`.
- No active `secrets:` or `/run/secrets` usage remains in Compose/service files.
- No `network: host`, `network_mode: host`, `links:`, or `--link` found.
- No `tail -f`, `sleep infinity`, infinite loop keepalive, or background `&` process pattern found in active project scripts.
- Compose defines a named bridge network: `inception`.
- One Dockerfile exists per service.
- Images are named like their services: `nginx`, `wordpress`, `mariadb`, `redis`, `adminer`.
- Dockerfiles use `debian:bookworm-slim`.
- WordPress Dockerfile does not install NGINX.
- MariaDB Dockerfile does not install NGINX.
- NGINX exposes only port 443.
- NGINX config allows TLSv1.2 and TLSv1.3.
- WordPress admin username is `owner`, which does not contain `admin`.

### Runtime Checks

Status: PASS

- `make` successfully built and started the stack from clean project data before the login correction.
- `docker compose ps` showed all services running:
  - `nginx`
  - `wordpress`
  - `mariadb`
  - `redis`
  - `adminer`
- `docker network ls` showed `srcs_inception`.
- After correcting the login to `hboutale`, `docker compose config` shows volume devices:
  - `/home/hboutale/data/mariadb`
  - `/home/hboutale/data/wordpress`
- `curl -sS -I --max-time 5 http://localhost` failed to connect to port 80, which is expected.
- The final corrected domain is `https://hboutale.42.fr`; restart with clean data on the `hboutale` account to regenerate the certificate with that CN.
- MariaDB query showed WordPress tables exist and `wp_users` contains 2 users.
- WordPress logs showed:
  - WordPress files copied into `/var/www/html`
  - `wp-config.php` generated
  - WordPress installed successfully
  - normal WordPress user created

## Manual Checks Still Needed During Defense

These require browser/manual evaluator interaction:
- Ensure `/etc/hosts` contains `127.0.0.1 hboutale.42.fr` if campus DNS does not resolve it locally.
- Open `https://hboutale.42.fr` in the browser.
- Add a comment with the normal WordPress user.
- Log into `/wp-admin` with the administrator user.
- Edit a page and verify the change on the public website.
- Reboot the VM and verify WordPress/MariaDB persistence.
- Bonus services can be evaluated only if mandatory remains fully passing.
