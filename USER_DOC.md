# User Documentation

## Services

This stack provides a WordPress website served through NGINX over HTTPS.

- `nginx`: public entrypoint on port `443`, configured for TLSv1.2 and TLSv1.3.
- `wordpress`: WordPress with PHP-FPM, reachable only from the Docker network.
- `mariadb`: database server, reachable only from the Docker network.

Only NGINX is exposed to the host machine. WordPress and MariaDB do not publish host ports.

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

The current local configuration uses:

```text
https://localhost
```

For subject validation, configure your host entry and `.env` to use:

```text
https://hboutaleb.42.fr
```

The WordPress administration panel is available at:

```text
https://localhost/wp-admin
```

or, after domain configuration:

```text
https://hboutaleb.42.fr/wp-admin
```

The TLS certificate is self-signed, so browsers will show a certificate warning.

## Credentials

Non-secret configuration is stored in:

```text
srcs/.env
```

Secret values are stored in local Docker secret files:

```text
secrets/db_password.txt
secrets/db_root_password.txt
secrets/db_wordpress_password.txt
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
curl -k -I https://localhost
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
