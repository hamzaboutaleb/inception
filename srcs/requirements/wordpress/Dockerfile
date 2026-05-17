FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    mariadb-client \
    php-cli \
    php-curl \
    php-fpm \
    php-gd \
    php-intl \
    php-mbstring \
    php-mysql \
    php-redis \
    php-soap \
    php-xml \
    php-zip \
    tar \
    unzip \
    && mkdir -p /usr/src/wordpress /var/www/html /run/php \
    && curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
    && curl -fsSL https://wordpress.org/latest.tar.gz -o /tmp/wordpress.tar.gz \
    && tar -xzf /tmp/wordpress.tar.gz -C /usr/src/wordpress --strip-components=1 \
    && rm -f /tmp/wordpress.tar.gz \
    && curl -fsSL https://downloads.wordpress.org/plugin/redis-cache.latest-stable.zip -o /tmp/redis-cache.zip \
    && unzip -q /tmp/redis-cache.zip -d /usr/src/wordpress/wp-content/plugins \
    && rm -f /tmp/redis-cache.zip \
    && sed -ri 's!^listen = .*!listen = 0.0.0.0:9000!' /etc/php/*/fpm/pool.d/www.conf \
    && sed -ri 's!^;?clear_env = .*!clear_env = no!' /etc/php/*/fpm/pool.d/www.conf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY tools/entry.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh \
    && chown -R www-data:www-data /usr/src/wordpress /var/www/html

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm8.2", "-F"]
