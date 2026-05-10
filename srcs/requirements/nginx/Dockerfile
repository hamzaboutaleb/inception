FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    nginx \
    openssl \
    && mkdir -p /etc/nginx/ssl /var/www/html /run/nginx \
    && rm -f /etc/nginx/sites-enabled/default \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/entry.sh /usr/local/bin/nginx-entrypoint.sh

RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
