#!/bin/sh
set -eu

CERT_DIR="/etc/nginx/ssl"
CERT_FILE="$CERT_DIR/inception.crt"
KEY_FILE="$CERT_DIR/inception.key"

mkdir -p "$CERT_DIR"

if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
	echo "Generating self-signed TLS certificate for ${NGINX_HOST:-localhost}..."
	openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
		-keyout "$KEY_FILE" \
		-out "$CERT_FILE" \
		-subj "/CN=${NGINX_HOST:-localhost}" >/dev/null 2>&1
fi

exec "$@"
