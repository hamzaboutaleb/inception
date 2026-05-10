COMPOSE_FILE	= srcs/docker-compose.yml
ENV_FILE		= srcs/.env
COMPOSE			= docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)
DATA_DIR		= /home/hboutaleb/data

.PHONY: all dirs build up down stop restart logs ps status config clean fclean re

all: up

dirs:
	mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

build: dirs
	$(COMPOSE) build

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

restart:
	$(COMPOSE) restart

logs:
	$(COMPOSE) logs -f

ps status:
	$(COMPOSE) ps

config:
	$(COMPOSE) config

clean: down

fclean:
	$(COMPOSE) down -v --rmi all --remove-orphans

re: fclean up
