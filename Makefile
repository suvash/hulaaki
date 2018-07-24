.DEFAULT_GOAL:=help
SHELL:=/usr/bin/env bash

HULAAKI_SERVICE:=hulaaki
MQTT_SERVICE:=mqtt-server

DOCKER_COMPOSE:=docker-compose -f docker-compose.yml
DOCKER_COMPOSE_RUN_HULAAKI:=$(DOCKER_COMPOSE) run --rm $(HULAAKI_SERVICE)

.PHONY: help build start stop stop-clean tail-logs run-hulaaki bash test prune

help:  ## Display this help
	$(info)
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build:  ## (Force) Build the docker images (automatically run by `make start`)
	$(DOCKER_COMPOSE) build

start: build ## Start the MQTT service container daemonised
	$(DOCKER_COMPOSE) up -d $(MQTT_SERVICE)

stop: ## Stop all the service containers
	$(DOCKER_COMPOSE) down

stop-clean: ## Stop all the service containers, cleanup project images, dangling/orphaned volumes
	$(DOCKER_COMPOSE) down --rmi local --volumes --remove-orphans

tail-logs: ## Tail the logs for MQTT service container
	$(DOCKER_COMPOSE) logs -f $(MQTT_SERVICE)

run-hulaaki: ## Run a one-off command in a new hulaaki service container. Specify using CMD (eg. make run-web CMD=mix test)
	$(if $(CMD), $(DOCKER_COMPOSE_RUN_HULAAKI) $(CMD), $(error -- CMD must be set))

sh: CMD=/bin/sh
sh: run-hulaaki ## Spawn a bash shell for hulaaki service

test: CMD=mix test
test: run-hulaaki ## Run the test for hulaaki service

format: CMD=mix format
format: run-hulaaki ## Run mix format on the library

prune: ## Cleanup dangling/orphaned docker resources globally
	docker system prune --volumes -f
