FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends mariadb-server mariadb-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /var/lib/mysql/*

EXPOSE 3306

COPY conf/mariadb.cnf /etc/mysql/mariadb.conf.d/99-custom.cnf
COPY tools/entry.sh /usr/local/bin/mariadb-entrypoint.sh

RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/mariadb-entrypoint.sh"]
CMD ["mariadbd"]

HEALTHCHECK --interval=10s --timeout=5s --retries=5 \
    CMD root_password="$(cat /run/secrets/db_root_password)" \
    && mariadb-admin ping --protocol=socket --socket=/run/mysqld/mysqld.sock -uroot -p"$root_password" --silent \
    || exit 1
