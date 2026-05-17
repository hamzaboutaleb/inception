#!/bin/sh
set -eu

DATADIR="/var/lib/mysql"
RUNDIR="/run/mysqld"
SOCKET="$RUNDIR/mysqld.sock"

validate_identifier() {
	name="$1"
	value="$2"

	case "$value" in
		*[!a-zA-Z0-9_]*)
			echo "Error: $name may only contain letters, numbers, and underscores."
			exit 1
			;;
	esac
}

validate_password() {
	name="$1"
	value="$2"

	case "$value" in
		*"'"*)
			echo "Error: $name must not contain single quotes."
			exit 1
			;;
	esac
}

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

file_env MARIADB_ROOT_PASSWORD
file_env MARIADB_PASSWORD

mkdir -p "$RUNDIR"
chown mysql:mysql "$RUNDIR"

mkdir -p "$DATADIR"

if [ ! -d "$DATADIR/mysql" ]; then
	echo "Initializing MariaDB data directory..."

	if [ -z "${MARIADB_ROOT_PASSWORD:-}" ]; then
		echo "Error: MARIADB_ROOT_PASSWORD is required on first initialization."
		exit 1
	fi

	if [ -n "${MARIADB_USER:-}" ] && [ -z "${MARIADB_PASSWORD:-}" ]; then
		echo "Error: MARIADB_USER is set, but MARIADB_PASSWORD is missing."
		exit 1
	fi

	if [ -z "${MARIADB_USER:-}" ] && [ -n "${MARIADB_PASSWORD:-}" ]; then
		echo "Error: MARIADB_PASSWORD is set, but MARIADB_USER is missing."
		exit 1
	fi

	if [ -n "${MARIADB_USER:-}" ] && [ -z "${MARIADB_DATABASE:-}" ]; then
		echo "Error: MARIADB_USER is set, but MARIADB_DATABASE is missing."
		echo "Set MARIADB_DATABASE so privileges can be granted."
		exit 1
	fi

	validate_password MARIADB_ROOT_PASSWORD "$MARIADB_ROOT_PASSWORD"

	if [ -n "${MARIADB_DATABASE:-}" ]; then
		validate_identifier MARIADB_DATABASE "$MARIADB_DATABASE"
	fi

	if [ -n "${MARIADB_USER:-}" ]; then
		validate_identifier MARIADB_USER "$MARIADB_USER"
		validate_password MARIADB_PASSWORD "$MARIADB_PASSWORD"
	fi

	chown -R mysql:mysql "$DATADIR"
	mariadb-install-db --user=mysql --datadir="$DATADIR"

	init_sql="$RUNDIR/init.sql"

	cat > "$init_sql" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test\\_%';
EOF

	if [ -n "${MARIADB_DATABASE:-}" ]; then
		echo "Creating database: $MARIADB_DATABASE"

		cat >> "$init_sql" <<EOF
CREATE DATABASE IF NOT EXISTS \`$MARIADB_DATABASE\`;
EOF
	fi

	if [ -n "${MARIADB_USER:-}" ] && [ -n "${MARIADB_PASSWORD:-}" ]; then
		echo "Creating user: $MARIADB_USER"

		cat >> "$init_sql" <<EOF
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'%' IDENTIFIED BY '$MARIADB_PASSWORD';
CREATE USER IF NOT EXISTS '$MARIADB_USER'@'localhost' IDENTIFIED BY '$MARIADB_PASSWORD';
EOF

		if [ -n "${MARIADB_DATABASE:-}" ]; then
			echo "Granting privileges on database: $MARIADB_DATABASE"

			cat >> "$init_sql" <<EOF
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'%';
GRANT ALL PRIVILEGES ON \`$MARIADB_DATABASE\`.* TO '$MARIADB_USER'@'localhost';
EOF
		fi
	fi

	cat >> "$init_sql" <<EOF
FLUSH PRIVILEGES;
EOF

	chown mysql:mysql "$init_sql"
	chmod 600 "$init_sql"

	echo "Starting MariaDB with initial configuration..."
	exec su -s /bin/sh mysql -c "$* --init-file=$init_sql"
else
	echo "MariaDB data directory already initialized."
fi

exec su -s /bin/sh mysql -c "$*"
