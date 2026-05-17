FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    vsftpd \
    && install -d -m 755 /var/run/vsftpd/empty \
    && install -d -o www-data -g www-data /var/www/html \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY conf/vsftpd.conf /etc/vsftpd.conf
COPY --chmod=755 tools/entry.sh /usr/local/bin/ftp-entrypoint.sh

EXPOSE 21 21100-21110

ENTRYPOINT ["/usr/local/bin/ftp-entrypoint.sh"]
CMD ["vsftpd", "/etc/vsftpd.conf"]

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD grep -q vsftpd /proc/1/comm || exit 1
