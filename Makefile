help: ## Print the help documentation
	@grep -E '^[/a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


OTEL_APP_DIR = "applications/otel-collector"

#######################################################
######## Project Build Operations #####################
#######################################################

tools-venv: ## Creates Python Virtual Env for tooling scripts
	(cd tools; python3 -m venv .env)

install-tool-dependencies: ## Installs tool dependencies
	(cd tools; . .env/bin/activate; pip install -r requirements.txt)

build-temporal-services: gen-otel-config ## Build all temporal services
	docker compose build

#######################################################
######## Database Migration Management#################
#######################################################

generate-migrations: ## Generates flyway migrations from temporal admin
	( \
		. tools/.env/bin/activate; \
		python3 ./tools/migrations/generate_migration.py \
	)

migrate-db: ## Runs flyway db migrations against Postgres
	docker compose up flyway-migrations

#######################################################
######## Service Initialization Commands ##############
#######################################################

init-postgres-db:  ## Starts Postgres Database & runs database migrations
	docker compose up -d --wait postgresql

init-temporal-services: init-postgres-db migrate-db ## Start all temporal services
	docker compose up server-otel-collector temporal-server temporal-ui

start-native-worker: ## Starts Native Temporal worker
	cd applications/worker; poetry run temporal-worker


#######################################################
######## Project Clean-Up Commands ####################
#######################################################

wipe-generated-migrations: ## Delete all generated migrations
	rm applications/flyway/sql-migrations/*.sql

wipe-docker: ## Tears down services and wipes volumes
	docker compose down --volumes --remove-orphans

