# Developer Documentation

## Prerequisites

Install Docker with the Compose plugin on the host machine.

Create the persistent data directories:

```sh
mkdir -p /home/hboutale/data/mariadb /home/hboutale/data/wordpress
```

The Makefile also creates these directories automatically before building or starting.

## Configuration

Edit configuration values in the `.env` file created for the evaluation:

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
- `FTP_USER`
- `FTP_PASSWORD`

For validation, use your 42 domain:

```text
WORDPRESS_URL=https://hboutale.42.fr
NGINX_HOST=hboutale.42.fr
```

Add this to `/etc/hosts` on the VM if needed:

```text
127.0.0.1 hboutale.42.fr
```

## Credentials

Credential values are read from `srcs/.env`:

```text
MARIADB_ROOT_PASSWORD
MARIADB_PASSWORD
WORDPRESS_ADMIN_PASSWORD
WORDPRESS_USER_PASSWORD
FTP_PASSWORD
```

Do not put passwords in Dockerfiles. Do not commit real credentials or extra credential files to the repository.

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
srcs/requirements/bonus/cadvisor/Dockerfile
srcs/requirements/bonus/ftp/Dockerfile
srcs/requirements/bonus/ftp/conf/vsftpd.conf
srcs/requirements/bonus/ftp/tools/entry.sh
srcs/requirements/bonus/redis/Dockerfile
srcs/requirements/bonus/redis/conf/redis.conf
srcs/requirements/bonus/static/Dockerfile
srcs/requirements/bonus/static/conf/nginx.conf
srcs/requirements/bonus/static/site/
srcs/requirements/bonus/redis/conf/redis.conf
srcs/requirements/mariadb/Dockerfile
srcs/requirements/mariadb/conf/mariadb.cnf
srcs/requirements/mariadb/tools/entry.sh
```

- `ftp`: Debian-based vsftpd bonus service. Accessed via port 21, maps to WordPress data volume allowing file modifications.
- `cadvisor`: Google cAdvisor image for monitoring container resources, reachable through NGINX at `/cadvisor/`.
- `static`: Debian-based NGINX container serving a simple static portfolio site, reachable through NGINX at `/static/`.

## Containers

- `nginx`: Debian-based NGINX with a self-signed TLS certificate generated at startup if missing.
- `wordpress`: Debian-based WordPress + PHP-FPM image. The entrypoint waits for MariaDB, creates `wp-config.php`, installs WordPress, enables Redis object caching, and ensures two users exist.
- `mariadb`: Debian-based MariaDB image. The entrypoint initializes the database on first startup.
- `adminer`: Debian-based Adminer bonus service, reachable through NGINX at `/adminer/`.
- `redis`: Debian-based Redis bonus service used by WordPress for object caching.

## Network

All services are attached to one Docker bridge network:

```yaml
networks:
  inception:
    driver: bridge
```

This allows containers to resolve each other by service name, for example `wordpress` connects to `mariadb` and `redis`, `nginx` forwards PHP requests to `wordpress:9000`, and NGINX proxies requests to `adminer:8080`, `cadvisor:8080`, and `static:80`.

Only NGINX and FTP publish host ports:

```yaml
ports:
  - "443:443" # nginx
  - "21:21" # ftp
  - "21100-21110:21100-21110" # ftp passive
```

## Volumes

The project uses two Docker named volumes:

- `mariadb_data`: database files
- `wordpress_data`: WordPress website files

Their data is stored under:

```text
/home/hboutale/data/mariadb
/home/hboutale/data/wordpress
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

Check Redis:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec redis redis-cli ping
```

Check WordPress Redis cache status:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress \
	wp --allow-root --path=/var/www/html redis status
```

Open Adminer:

```text
https://hboutale.42.fr/adminer/
```

Use `mariadb` as the database server name, then log in with the MariaDB user and password from `srcs/.env`.
