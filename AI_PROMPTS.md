# AI Prompts For Inception Defense

Use these prompts to understand the project and practice explaining it during evaluation. Replace any values if your final `.env` changes.

Project facts to keep in mind:

- 42 login: `hboutale`
- Domain: `https://hboutale.42.fr`
- Services: NGINX, WordPress with PHP-FPM, MariaDB
- Bonus services: Redis, Adminer
- Data paths:
  - `/home/hboutale/data/mariadb`
  - `/home/hboutale/data/wordpress`
- Docker network: `inception`
- Public port: `443` only
- TLS: v1.2 and v1.3
- Admin username: `owner`
- Normal WordPress user: `wpuser`

## Full Project Explanation

```text
Act as a 42 Inception evaluator. Explain this project from zero to defense level.

My project uses Docker Compose to run NGINX, WordPress with PHP-FPM, and MariaDB. It also has Redis and Adminer as bonus services. The public domain is https://hboutale.42.fr. NGINX is the only service exposed to the host, on port 443. WordPress talks to MariaDB through a Docker bridge network. WordPress and MariaDB use named volumes backed by /home/hboutale/data/wordpress and /home/hboutale/data/mariadb.

Explain:
- what each service does
- how requests flow from browser to NGINX to WordPress/PHP-FPM to MariaDB
- why port 80 is closed
- why Docker volumes are needed
- why Docker networks are needed
- what I should say during evaluation
```

## Docker Theory

```text
Explain Docker for the 42 Inception project in simple terms.

Cover:
- image vs container
- Dockerfile vs docker-compose.yml
- build time vs runtime
- ENTRYPOINT vs CMD
- why one Dockerfile per service is required
- why using ready-made DockerHub service images is forbidden
- why containers are lighter than virtual machines

After the explanation, ask me 10 oral defense questions and wait for my answers one by one.
```

## Docker Compose

```text
Explain my docker-compose.yml like an evaluator.

Important details:
- services: nginx, wordpress, mariadb, redis, adminer
- images have the same names as services
- all services use the inception bridge network
- nginx exposes only "443:443"
- wordpress_data is mounted at /var/www/html
- mariadb_data is mounted at /var/lib/mysql
- host paths are /home/hboutale/data/wordpress and /home/hboutale/data/mariadb
- credentials come from .env during evaluation

Explain every section: services, build, image, container_name, depends_on, environment, ports, networks, volumes, driver_opts.
```

## NGINX And TLS

```text
Help me explain the NGINX container in my Inception defense.

My NGINX:
- listens on port 443 only
- uses a self-signed certificate
- supports TLSv1.2 and TLSv1.3
- serves WordPress through PHP-FPM on the wordpress container port 9000
- proxies /adminer/ to the Adminer service
- denies hidden dotfiles

Explain:
- what TLS does
- why HTTPS works even with a self-signed certificate warning
- why HTTP on port 80 must fail
- how NGINX forwards PHP requests to WordPress/PHP-FPM
- how to prove TLS v1.2/v1.3 with openssl
```

## WordPress And PHP-FPM

```text
Explain WordPress with PHP-FPM for my Inception project.

My WordPress container:
- is built from debian:bookworm-slim
- installs PHP-FPM and PHP extensions
- does not install NGINX
- listens on port 9000 inside the Docker network
- copies WordPress files into /var/www/html
- creates wp-config.php
- installs WordPress with WP-CLI
- creates an admin user called owner
- creates a normal user called wpuser
- connects to MariaDB using environment variables from .env

Explain why WordPress and NGINX are separate containers, what PHP-FPM does, and how wp-config.php connects WordPress to MariaDB.
```

## MariaDB

```text
Explain the MariaDB container in my Inception project.

My MariaDB:
- is built from debian:bookworm-slim
- does not install NGINX
- stores data in /var/lib/mysql
- uses a Docker volume backed by /home/hboutale/data/mariadb
- creates a database called mydb
- creates a database user called myuser
- runs as the foreground process
- initializes on first run without running a background daemon in the entrypoint

Explain:
- what a database is
- why WordPress needs MariaDB
- what persistence means
- how to log into MariaDB from inside the container
- how to prove the database is not empty
```

## Volumes And Persistence

```text
Teach me Docker volumes using my Inception project.

My volumes:
- wordpress_data -> /var/www/html -> /home/hboutale/data/wordpress
- mariadb_data -> /var/lib/mysql -> /home/hboutale/data/mariadb

Explain:
- named volume vs bind mount
- why the subject requires /home/login/data
- what happens if containers are deleted but volumes remain
- what happens if volumes are deleted
- how to prove persistence after reboot
- which commands I should run during evaluation
```

## Docker Network

```text
Explain Docker networking for my Inception defense.

My project uses a bridge network called inception. NGINX, WordPress, MariaDB, Redis, and Adminer are all on this network. Only NGINX publishes port 443 to the host. WordPress reaches MariaDB using the service name mariadb. NGINX reaches WordPress using the service name wordpress.

Explain:
- what a Docker bridge network is
- why service names work as hostnames
- why network: host is forbidden
- why links are forbidden
- why MariaDB and WordPress do not expose host ports
```

## Security And Secrets

```text
Explain the credential rule for 42 Inception.

The evaluator says credentials, API keys, and environment variables must be set inside a .env file during evaluation. My previous project had committed secret files, but I fixed it by removing the secrets directory from the working tree, adding secrets/ to .gitignore, and reading credentials from .env.

Explain:
- why committed credentials are dangerous
- why secrets outside .env fail the evaluation
- what should and should not be committed
- how to explain this fix to an evaluator
```

## Corrections I Made

```text
Help me explain these fixes during defense:

1. I removed committed secret files and moved credential usage to .env.
2. I corrected the login/domain from hboutaleb to hboutale.
3. I changed the volume paths to /home/hboutale/data/...
4. I changed MariaDB first-run initialization so the entrypoint does not run a temporary background daemon.
5. I fixed WordPress initialization so it copies WordPress core files even if NGINX creates a default file in the shared volume first.

For each fix, explain:
- what was wrong
- why it could fail the evaluation
- what was changed
- how to verify it
```

## Practice Defense Questions

```text
Act as a strict but fair 42 evaluator for Inception.

Ask me one question at a time. Wait for my answer before asking the next one. Correct me if I am wrong.

Focus on:
- Docker basics
- Docker Compose
- NGINX with TLS
- WordPress with PHP-FPM
- MariaDB
- volumes and persistence
- Docker networking
- .env credentials
- why port 443 only
- why no network host, links, tail -f, sleep infinity, or background processes
- Redis and Adminer bonus
```

## Command Practice

```text
Quiz me on the commands I need for the Inception evaluation.

Use these commands as the base:
- make
- make fclean
- make ps
- docker compose -f srcs/docker-compose.yml --env-file srcs/.env config
- docker compose -f srcs/docker-compose.yml --env-file srcs/.env ps
- docker network ls
- docker volume ls
- docker volume inspect srcs_mariadb_data
- docker volume inspect srcs_wordpress_data
- curl -k -I https://hboutale.42.fr
- openssl s_client -connect localhost:443 -tls1_2 -brief
- openssl s_client -connect localhost:443 -tls1_3 -brief

Ask me what each command proves and what output I should expect.
```

## Explain Like I Am The Evaluated Student

```text
Write a short oral defense script for me as the evaluated student.

The script should explain:
- project goal
- service architecture
- request flow
- Dockerfiles
- Compose file
- NGINX TLS
- WordPress/PHP-FPM
- MariaDB
- volumes
- network
- persistence
- bonus Redis and Adminer

Keep it natural, like something I can say out loud in 3 to 5 minutes.
```

## Find Weak Points

```text
Review my Inception project like an evaluator and find possible weak points.

Project summary:
- NGINX, WordPress/PHP-FPM, MariaDB mandatory
- Redis and Adminer bonus
- domain: hboutale.42.fr
- public port: 443 only
- volumes under /home/hboutale/data
- credentials from .env
- custom Dockerfiles based on debian:bookworm-slim
- no host network, no links, no tail -f, no sleep infinity, no background daemon in entrypoint

Give me:
- likely evaluator concerns
- how to answer them
- commands to prove each point
- what to fix if a check fails
```

