# User Documentation

## Services

This stack provides a WordPress website served through NGINX over HTTPS, plus Adminer and Redis bonus services.

- `nginx`: public entrypoint on port `443`, configured for TLSv1.2 and TLSv1.3.
- `wordpress`: WordPress with PHP-FPM, reachable only from the Docker network.
- `mariadb`: database server, reachable only from the Docker network.
- `adminer`: database administration interface, reachable through NGINX.
- `redis`: object cache for WordPress, reachable only from the Docker network.

Only NGINX is exposed to the host machine. WordPress, MariaDB, Adminer, and Redis do not publish host ports.

## Start And Stop

From the repository root:

```sh
make up
```

To stop the stack:

```sh
make down
```

To rebuild everything:

```sh
make re
```

To view logs:

```sh
make logs
```

## Access

The configured domain is:

```text
https://hboutale.42.fr
```

Ensure the VM host entry points this domain to localhost:

```text
127.0.0.1 hboutale.42.fr
```

The WordPress administration panel is available at:

```text
https://hboutale.42.fr/wp-admin
```

The TLS certificate is self-signed, so browsers will show a certificate warning.

Adminer is available at:

```text
https://hboutale.42.fr/adminer/
```

For the Adminer server field, use:

```text
mariadb
```

## Credentials

Configuration and evaluation credentials are stored in the local `.env` file:

```text
srcs/.env
```

The default WordPress users are defined by `.env`:

- administrator login: `WORDPRESS_ADMIN_USER`
- normal user login: `WORDPRESS_USER`

The administrator username must not contain `admin` or `administrator`.

## Check Services

Show running containers:

```sh
make ps
```

Check HTTPS:

```sh
curl -k -I https://hboutale.42.fr
```

Check WordPress users:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress \
	wp --allow-root --path=/var/www/html user list
```

Check the database:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec wordpress \
	wp --allow-root --path=/var/www/html db check
```

Check Redis:

```sh
docker compose -f srcs/docker-compose.yml --env-file srcs/.env exec redis redis-cli ping
```
