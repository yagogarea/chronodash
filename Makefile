.PHONY: all compile clean check format lint credo test-unit db-up db-down db-redeploy deploy undeploy redeploy logs attach

###-----------------------------------------------------------------------------
### VARIABLES
###-----------------------------------------------------------------------------
COMPOSE_FILE := docker/docker-compose.yml
as ?= dev 

APP_NAME := chronodash
CONTAINER_NAME := chronodash
APP_BIN_PATH := /app/bin/chronodash

###-----------------------------------------------------------------------------
### DEVELOPMENT TARGETS
###-----------------------------------------------------------------------------
all: compile

compile:
	mix compile

clean:
	mix clean

###-----------------------------------------------------------------------------
### CODE QUALITY TARGETS
###-----------------------------------------------------------------------------
check: lint credo

format:
	mix format

lint:
	mix format --check-formatted

credo:
	mix credo --strict

###-----------------------------------------------------------------------------
### TEST TARGETS
###-----------------------------------------------------------------------------
test-unit:
	mix test

###-----------------------------------------------------------------------------
### DEPLOYMENT TARGETS
###-----------------------------------------------------------------------------
db-up:
	@echo "Starting only the PostgresDB service locally with Docker..."
	docker compose -f docker/docker-compose.yml up -d --build --wait postgres
	@echo "PostgresDB service is up and running"

db-down:
	@echo "Stopping PostgresDB service..."
	docker compose -f docker/docker-compose.yml stop postgres
	docker compose -f docker/docker-compose.yml rm -f -v postgres
	@echo "PostgresDB service has been stopped"

db-redeploy: db-down db-up

deploy:
	@echo "Deploying $(as) environment locally with Docker..."
	MIX_ENV=$(as) docker compose -f $(COMPOSE_FILE) up -d --build --wait
	@echo "Local deployment completed for $(as) environment"

undeploy:
	docker compose -f $(COMPOSE_FILE) down -v --remove-orphans

redeploy: undeploy deploy

logs:
	@docker logs $(CONTAINER_NAME)

attach:
	@docker exec -it $(CONTAINER_NAME) $(APP_BIN_PATH) remote
