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

test-contract: undeploy
	@$(MAKE) deploy as=dev
	@echo "Running OpenAPI contract tests with Schemathesis..."
	@docker run --rm --network host \
		-v "$(shell pwd)/priv/specs/chronodash:/specs" \
		-v "$(shell pwd)/schemathesis.toml:/schemathesis.toml" \
		schemathesis/schemathesis:stable \
		run /specs/openapi.json --url http://localhost:4000/api/1
	@$(MAKE) undeploy

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

deploy_with_tel: deploy
	@echo "Deploying extra service tel..."
	docker compose -f docker/docker-compose.tel.yml up -d --build --wait
	@echo "All requested services deployed for $(as)"

undeploy_with_tel: undeploy
	@echo "Undeploying extra service tel..."
	docker compose -f docker/docker-compose.tel.yml down -v --remove-orphans
	@echo "All requested services undeployed for $(as)"

redeploy_with_tel: undeploy_with_tel deploy_with_tel

logs:
	@docker logs $(CONTAINER_NAME)

attach:
	@docker exec -it $(CONTAINER_NAME) $(APP_BIN_PATH) remote
