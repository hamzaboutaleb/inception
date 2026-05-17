*This project has been created as part of the 42 curriculum by hboutale.*

# Description

Inception is a system administration project focused on building a small containerized web infrastructure with Docker Compose.

The stack contains five services:

- NGINX as the only public entrypoint, serving HTTPS on port `443`.
- WordPress with PHP-FPM for the application runtime.
- MariaDB for persistent WordPress data.
- Adminer as a bonus database administration tool, routed through NGINX.
- Redis as a bonus WordPress object cache.

Each service is built from its own Dockerfile. The containers communicate through a Docker bridge network named `inception`, and persistent data is stored in Docker named volumes.

# Instructions

Build and start the stack from the repository root:

```sh
make up
```

Stop the stack:

```sh
make down
```

Rebuild from a clean Compose state:

```sh
make re
```

Show logs:

```sh
make logs
```

Show container status:

```sh
make ps
```

The configured URL is:

```text
https://hboutale.42.fr
```

Adminer is available at:

```text
https://hboutale.42.fr/adminer/
```

# Design Choices

## Virtual Machines Vs Docker

A virtual machine runs a complete guest operating system on top of a hypervisor. Docker containers share the host kernel and isolate processes with namespaces, cgroups, filesystems, and networks. For this project, containers are lighter, faster to rebuild, and easier to compose into separate services.

## Environment Variables

The evaluation expects credentials to be supplied from the `.env` file created during evaluation. Do not commit real passwords, API keys, or extra credential files to the repository.

## Docker Network Vs Host Network

A Docker bridge network isolates the project services while still allowing containers to resolve each other by service name. Host networking would remove that isolation and is forbidden by the subject.

## Docker Volumes Vs Bind Mounts

Docker volumes are managed by Docker and keep service data persistent across container rebuilds. This project uses named volumes for MariaDB data and WordPress files, with host storage configured under `/home/hboutale/data`.

# Documentation

User documentation:

```text
USER_DOC.md
```

Developer documentation:

```text
DEV_DOC.md
```

# Resources

- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- NGINX documentation: https://nginx.org/en/docs/
- WordPress CLI documentation: https://wp-cli.org/
- MariaDB documentation: https://mariadb.org/documentation/
- Adminer documentation: https://www.adminer.org/
- Redis documentation: https://redis.io/docs/

AI assistance was used to review the project requirements, compare the implementation with the subject, and draft operational documentation. The generated content was checked against the local files and tested with Docker Compose commands.
