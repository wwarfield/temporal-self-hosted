# Server Upgrade
When upgrading the temporal server you cannot skip server versions and incrementally upgrade up to the latest
version available. Additionally, you must ensure that any required database migrations are upgraded along with it.


## Local Instructions

1. Ensure all services are up and running locally first with the command `make init-temporal-services`
2. Update the `TEMPORAL_ADMINTOOLS_VERSION` in the `build.env` file to the next minor version
   schema migrations.
3. Reload the environment variables with the command `direnv reload`
4. Generate the new flyway migrations with the command `make generate-migrations`
5. Apply new migrations to the postgres database `make migrate-db`
6. Then update the `TEMPORAL_VERSION` in the `build.env` file to the next version minor version
7. Reload the environment variables with the command `direnv reload`
8. build the new server and run it with the command `make build-temporal-services init-temporal-services`
9. Give the server several minutes to stablize and be sure to review the logs for any new warnings from the upgrade.
10. Repeat the process until you reach the most up to date version.

