FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    redis-server \
    redis-tools \
    && mkdir -p /run/redis \
    && chown redis:redis /run/redis \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD redis-cli ping | grep -q PONG
