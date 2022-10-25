#!/bin/bash

UID = $(shell id -u)
DOCKER_BE = php-base-repository-be

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

start: ## Start the containers
	docker network create php-base-repository-network || true
	cp -n docker-compose.yml.dist docker-compose.yml || true
	U_ID=${UID} docker-compose up -d

stop: ## Stop the containers
	U_ID=${UID} docker-compose stop

restart: ## Restart the containers
	$(MAKE) stop && $(MAKE) start

build: ## Rebuilds all the containers
	docker network create php-base-repository-network || true
	cp -n docker-compose.yml.dist docker-compose.yml || true
	U_ID=${UID} docker-compose build

prepare: ## Runs backend commands
	$(MAKE) composer-install

# Backend commands
composer-install: ## Installs composer dependencies
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_BE} composer install --no-interaction
# End backend commands

ssh-be: ## bash into the be container
	U_ID=${UID} docker exec -it --user ${UID} ${DOCKER_BE} bash
