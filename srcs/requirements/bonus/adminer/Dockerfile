FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    php-cli \
    php-cgi \
    php-mysql \
    adminer \
    && mkdir -p /var/www/html \
    && cp /usr/share/adminer/adminer.php /var/www/html/index.php \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/html"]

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD php -r "exit(@fsockopen('127.0.0.1', 8080) ? 0 : 1);"
