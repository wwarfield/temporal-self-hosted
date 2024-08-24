#!/bin/bash

set -eu -o pipefail


# Extract variables from config file
PG_DEFAULT_DB_NAME="temporal"
PG_DEFAULT_DB_PORT=5432
PG_DEFAULT_DB_HOST="postgresql"

PG_DEFAULT_DB_SCHEMA="temporal_default"
PG_VISIBILITY_DB_SCHEMA="temporal_visibility"
SQL_PASSWORD="temporal"
POSTGRES_USER="temporal"


# Create schemas if they don't exist
PGPASSWORD=$SQL_PASSWORD psql \
  --echo-all \
  --no-password \
  --host            "${PG_DEFAULT_DB_HOST}" \
  --port            "${PG_DEFAULT_DB_PORT}" \
  --dbname          "${PG_DEFAULT_DB_NAME}" \
  --username        "${POSTGRES_USER}" \
  -c                "CREATE SCHEMA IF NOT EXISTS ${PG_DEFAULT_DB_SCHEMA}; CREATE SCHEMA IF NOT EXISTS ${PG_VISIBILITY_DB_SCHEMA}"

# Migrate postgres-default tables
temporal-sql-tool \
  --plugin  "postgres12" \
  --ep      "${PG_DEFAULT_DB_HOST}" \
  -u        "${POSTGRES_USER}" \
  -p        "${PG_DEFAULT_DB_PORT}" \
  --db      "${PG_DEFAULT_DB_NAME}" \
  --ca      "search_path=${PG_DEFAULT_DB_SCHEMA}" \
  --password "${SQL_PASSWORD}" \
  setup-schema \
  -v 0.0

temporal-sql-tool \
  --plugin  "postgres12" \
  --ep      "${PG_DEFAULT_DB_HOST}" \
  -u        "${POSTGRES_USER}" \
  -p        "${PG_DEFAULT_DB_PORT}" \
  --db      "${PG_DEFAULT_DB_NAME}" \
  --ca      "search_path=${PG_DEFAULT_DB_SCHEMA}" \
  --password "${SQL_PASSWORD}" \
  update-schema \
  -d        "/etc/temporal/schema/postgresql/v12/temporal/versioned"

# Migrate postgres-default tables
temporal-sql-tool \
  --plugin  "postgres12" \
  --ep      "${PG_DEFAULT_DB_HOST}" \
  -u        "${POSTGRES_USER}" \
  -p        "${PG_DEFAULT_DB_PORT}" \
  --db      "${PG_DEFAULT_DB_NAME}" \
  --ca      "search_path=${PG_VISIBILITY_DB_SCHEMA}" \
  --password "${SQL_PASSWORD}" \
  setup-schema \
  -v 0.0

temporal-sql-tool \
  --plugin  "postgres12" \
  --ep      "${PG_DEFAULT_DB_HOST}" \
  -u        "${POSTGRES_USER}" \
  -p        "${PG_DEFAULT_DB_PORT}" \
  --db      "${PG_DEFAULT_DB_NAME}" \
  --ca      "search_path=${PG_VISIBILITY_DB_SCHEMA}" \
  --password "${SQL_PASSWORD}" \
  update-schema \
  -d        "/etc/temporal/schema/postgresql/v12/visibility/versioned"