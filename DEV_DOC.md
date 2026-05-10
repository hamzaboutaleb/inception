# Developer Documentation

## Prerequisites

Install Docker with the Compose plugin on the host machine.

Create the persistent data directories:

```sh
mkdir -p /home/hboutaleb/data/mariadb /home/hboutaleb/data/wordpress
```

The Makefile also creates these directories automatically before building or starting.

## Configuration

Edit non-secret values in:

```text
srcs/.env
```

Important variables:

- `MARIADB_USER`
- `MARIADB_DATABASE`
- `WORDPRESS_TITLE`
- `WORDPRESS_URL`
- `NGINX_HOST`
- `WORDPRESS_ADMIN_USER`
- `WORDPRESS_ADMIN_EMAIL`
- `WORDPRESS_USER`
- `WORDPRESS_USER_EMAIL`

For validation, use your 42 domain:

```text
WORDPRESS_URL=https://hboutaleb.42.fr
NGINX_HOST=hboutaleb.42.fr
```

Add this to `/etc/hosts` on the VM if needed:

```text
127.0.0.1 hboutaleb.42.fr
```

## Secrets

Secret values are read from files mounted by Docker Compose:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/db_wordpress_password.txt
```

Do not put passwords in Dockerfiles. Do not commit real credentials to the repository.

## Build And Launch

From the repository root:

```sh
make up
```

Equivalent Compose command:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env up -d --build
```

Stop:

```sh
make down
```

Remove containers, images created by Compose, and named volumes:

```sh
make fclean
```

Rebuild from a clean Compose state:

```sh
make re
```

## Project Layout

```text
srcs/docker-compose.yml
srcs/.env
srcs/requirements/nginx/Dockerfile
srcs/requirements/nginx/conf/default.conf
srcs/requirements/nginx/tools/entry.sh
srcs/requirements/wordpress/Dockerfile
srcs/requirements/wordpress/tools/entry.sh
srcs/requirements/mariadb/Dockerfile
srcs/requirements/mariadb/conf/mariadb.cnf
srcs/requirements/mariadb/tools/entry.sh
```

## Containers

- `nginx`: Debian-based NGINX with a self-signed TLS certificate generated at startup if missing.
- `wordpress`: Debian-based WordPress + PHP-FPM image. The entrypoint waits for MariaDB, creates `wp-config.php`, installs WordPress, and ensures two users exist.
- `mariadb`: Debian-based MariaDB image. The entrypoint initializes the database on first startup.

## Network

All services are attached to one Docker bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

This allows containers to resolve each other by service name, for example `wordpress` connects to `mariadb`, and `nginx` forwards PHP requests to `wordpress:9000`.

Only NGINX publishes a host port:

```yaml
ports:
  - "443:443"
```

## Volumes

The project uses two Docker named volumes:

- `mariadb_data`: database files
- `wordpress_data`: WordPress website files

Their data is stored under:

```text
/home/hboutaleb/data/mariadb
/home/hboutaleb/data/wordpress
```

## Useful Checks

Validate Compose:

```sh
make config
```

Check NGINX config:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec nginx nginx -t
```

Check WordPress installation:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress \
	wp --allow-root --path=/var/www/html core is-installed
```

Check MariaDB from WordPress:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress \
	wp --allow-root --path=/var/www/html db check
```
