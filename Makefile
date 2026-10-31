COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

.DEFAULT_GOAL := all
.PHONY: all setup check build up down restart logs ps verify

all: up

setup:
	./srcs/requirements/tools/setup.sh

check:
	@test -f srcs/.env || { echo "Run make setup first"; exit 1; }
	@test -f secrets/db_password.txt || { echo "Run make setup first"; exit 1; }
	@test -f secrets/db_root_password.txt || { echo "Run make setup first"; exit 1; }
	@test -f secrets/wp_admin_password.txt || { echo "Run make setup first"; exit 1; }
	@test -f secrets/wp_user_password.txt || { echo "Run make setup first"; exit 1; }
	@test -f secrets/tls.crt || { echo "Run make setup first"; exit 1; }
	@test -f secrets/tls.key || { echo "Run make setup first"; exit 1; }
	@docker info >/dev/null 2>&1 || { echo "Start Docker Engine first"; exit 1; }
	@if [ "$$(uname -s)" = Linux ]; then \
		. srcs/.env; expected="/home/$$LOGIN/data/docker"; \
		actual=$$(docker info --format '{{.DockerRootDir}}' 2>/dev/null); \
		test "$$actual" = "$$expected" || { echo "Configure Docker data root first"; exit 1; }; \
		if [ ! -d "$$expected" ]; then \
			echo "Restoring Docker directories after evaluation cleanup"; \
			sudo systemctl restart docker || exit 1; \
		fi; \
	fi

build: setup check
	$(COMPOSE) build

up: setup check
	$(COMPOSE) up --build -d --wait

down: check
	$(COMPOSE) down

restart: check
	$(COMPOSE) restart
	$(COMPOSE) up -d --wait

logs: check
	$(COMPOSE) logs -f --tail=100

ps: check
	$(COMPOSE) ps

verify: check
	./srcs/requirements/tools/verify.sh
