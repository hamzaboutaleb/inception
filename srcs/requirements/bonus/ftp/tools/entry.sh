#!/bin/sh
set -eu

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

file_env FTP_PASSWORD

require_env FTP_USER
require_env FTP_PASSWORD

if [ "$FTP_USER" = "root" ]; then
	echo "Error: FTP_USER must not be root."
	exit 1
fi

mkdir -p /var/www/html /var/run/vsftpd/empty

if ! id "$FTP_USER" >/dev/null 2>&1; then
	useradd -d /var/www/html -g www-data -s /bin/sh "$FTP_USER"
fi

echo "$FTP_USER:$FTP_PASSWORD" | chpasswd
echo "$FTP_USER" > /etc/vsftpd.userlist

if [ -n "${FTP_HOST:-}" ]; then
	pasv_address="$FTP_HOST"

	case "$FTP_HOST" in
		*[!0-9.]*)
			pasv_address="$(getent hosts "$FTP_HOST" | awk '{ print $1; exit }')"
			pasv_address="${pasv_address:-127.0.0.1}"
			;;
	esac

	{
		echo "pasv_address=$pasv_address"
	} >> /etc/vsftpd.conf
fi

chown -R www-data:www-data /var/www/html
chmod -R g+rwX /var/www/html

exec "$@"
