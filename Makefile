COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

.DEFAULT_GOAL := all
.PHONY: all setup check build up down restart logs ps

all: up

setup:
	./srcs/requirements/tools/setup.sh

check:
	@set -e; . ./srcs/.env; expected="/home/$$LOGIN/data/docker"; \
	actual=$$(docker info --format '{{.DockerRootDir}}'); \
	test "$$actual" = "$$expected" || { echo "Set Docker data-root to $$expected in the VM. See DEV_DOC.md."; exit 1; }

build: check setup
	$(COMPOSE) build

up: build
	$(COMPOSE) up -d --wait --no-build --pull never

down:
	$(COMPOSE) down

restart:
	$(COMPOSE) restart
	$(COMPOSE) up -d --wait --no-build --pull never

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps
