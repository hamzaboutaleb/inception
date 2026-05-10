#!/bin/sh
set -eu

WORDPRESS_DIR="/var/www/html"
WORDPRESS_SOURCE="/usr/src/wordpress"

file_env() {
	var="$1"
	file_var="${var}_FILE"

	eval value="\${$var:-}"
	eval file_value="\${$file_var:-}"

	if [ -n "$value" ] && [ -n "$file_value" ]; then
		echo "Error: both $var and $file_var are set. Use only one."
		exit 1
	fi

	if [ -n "$file_value" ]; then
		if [ ! -f "$file_value" ]; then
			echo "Error: secret file $file_value does not exist."
			exit 1
		fi

		value="$(cat "$file_value")"
	fi

	export "$var=$value"
}

require_env() {
	var="$1"

	eval value="\${$var:-}"
	if [ -z "$value" ]; then
		echo "Error: $var is required."
		exit 1
	fi
}

validate_admin_username() {
	case "$WORDPRESS_ADMIN_USER" in
		*[aA][dD][mM][iI][nN]*)
			echo "Error: WORDPRESS_ADMIN_USER must not contain admin or administrator."
			exit 1
			;;
	esac
}

generate_salt() {
	LC_ALL=C tr -dc 'A-Za-z0-9!@#$%^&*()_+-=[]{}<>:,.?' < /dev/urandom | head -c 64
}

wp_cli() {
	wp --allow-root --path="$WORDPRESS_DIR" "$@"
}

file_env WORDPRESS_DB_PASSWORD
file_env WORDPRESS_ADMIN_PASSWORD
file_env WORDPRESS_USER_PASSWORD

require_env WORDPRESS_DB_HOST
require_env WORDPRESS_DB_NAME
require_env WORDPRESS_DB_USER
require_env WORDPRESS_DB_PASSWORD
require_env WORDPRESS_TITLE
require_env WORDPRESS_URL
require_env WORDPRESS_ADMIN_USER
require_env WORDPRESS_ADMIN_EMAIL
require_env WORDPRESS_ADMIN_PASSWORD
require_env WORDPRESS_USER
require_env WORDPRESS_USER_EMAIL
require_env WORDPRESS_USER_PASSWORD

validate_admin_username

if [ "$WORDPRESS_ADMIN_USER" = "$WORDPRESS_USER" ]; then
	echo "Error: WORDPRESS_ADMIN_USER and WORDPRESS_USER must be different."
	exit 1
fi

db_host="${WORDPRESS_DB_HOST%%:*}"
db_port="${WORDPRESS_DB_HOST#*:}"

if [ "$db_host" = "$db_port" ]; then
	db_port="3306"
fi

echo "Waiting for MariaDB at $db_host:$db_port..."

for i in $(seq 1 60); do
	if mariadb-admin ping -h"$db_host" -P"$db_port" -u"$WORDPRESS_DB_USER" -p"$WORDPRESS_DB_PASSWORD" --silent >/dev/null 2>&1; then
		break
	fi

	sleep 1

	if [ "$i" -eq 60 ]; then
		echo "Error: MariaDB did not become ready in time."
		exit 1
	fi
done

mkdir -p "$WORDPRESS_DIR"

if [ -z "$(find "$WORDPRESS_DIR" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
	echo "Copying WordPress files into $WORDPRESS_DIR..."
	cp -a "$WORDPRESS_SOURCE/." "$WORDPRESS_DIR/"
fi

if [ ! -f "$WORDPRESS_DIR/wp-config.php" ]; then
	echo "Creating wp-config.php..."

	wp_cli config create \
		--dbname="$WORDPRESS_DB_NAME" \
		--dbuser="$WORDPRESS_DB_USER" \
		--dbpass="$WORDPRESS_DB_PASSWORD" \
		--dbhost="$WORDPRESS_DB_HOST" \
		--dbcharset="utf8" \
		--dbcollate="" \
		--skip-salts \
		--extra-php <<EOF
define( 'AUTH_KEY',         '$(generate_salt)' );
define( 'SECURE_AUTH_KEY',  '$(generate_salt)' );
define( 'LOGGED_IN_KEY',    '$(generate_salt)' );
define( 'NONCE_KEY',        '$(generate_salt)' );
define( 'AUTH_SALT',        '$(generate_salt)' );
define( 'SECURE_AUTH_SALT', '$(generate_salt)' );
define( 'LOGGED_IN_SALT',   '$(generate_salt)' );
define( 'NONCE_SALT',       '$(generate_salt)' );
EOF
fi

wp_cli config set DB_NAME "$WORDPRESS_DB_NAME" --type=constant >/dev/null
wp_cli config set DB_USER "$WORDPRESS_DB_USER" --type=constant >/dev/null
wp_cli config set DB_PASSWORD "$WORDPRESS_DB_PASSWORD" --type=constant >/dev/null
wp_cli config set DB_HOST "$WORDPRESS_DB_HOST" --type=constant >/dev/null

if ! wp_cli core is-installed >/dev/null 2>&1; then
	echo "Installing WordPress..."

	wp_cli core install \
		--url="$WORDPRESS_URL" \
		--title="$WORDPRESS_TITLE" \
		--admin_user="$WORDPRESS_ADMIN_USER" \
		--admin_password="$WORDPRESS_ADMIN_PASSWORD" \
		--admin_email="$WORDPRESS_ADMIN_EMAIL" \
		--skip-email
else
	wp_cli option update siteurl "$WORDPRESS_URL"
	wp_cli option update home "$WORDPRESS_URL"
fi

if ! wp_cli user get "$WORDPRESS_USER" >/dev/null 2>&1; then
	wp_cli user create "$WORDPRESS_USER" "$WORDPRESS_USER_EMAIL" \
		--user_pass="$WORDPRESS_USER_PASSWORD" \
		--role=subscriber
fi

if [ "$(wp_cli user list --field=ID | wc -l)" -lt 2 ]; then
	echo "Error: WordPress must contain at least two users."
	exit 1
fi

chown -R www-data:www-data "$WORDPRESS_DIR"

exec "$@"
