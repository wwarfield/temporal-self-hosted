# Temporal Self Hosted
This project is one example to self host the temporal workflow engine platform.

Self hosting temporal is very involved and challenging.
This repository provides documentation and specific examples on how some self hosting challenges can be solved.

[Self Host Temporal Guide](https://docs.temporal.io/self-hosted-guide)

# About This Self Hosting Approach

## Stack
- Temporal Server
- PostgreSQL
- Flyway Migrations
- Temporal UI
- Python Worker
- OTEL Collector & Grafana

## Current Examples

- Configuring Temporal Server Metrics
- Integrating Migrations with Flyway
- Upgrading Temporal Server

## Example TODO list

- [ ] configure worker metrics
- [ ] configure multiple virtual workers
- [ ] create test workflows
- [ ] Create context logging interceptor
- [ ] configure service scaling
- [ ] load test

# Local Development Setup

For local development this project relies on several tools. Be sure to review the pre-requistes section
and install the software tools before going much further.

The project also heavily relies on a makefile that
provides easy commands to perform different tasks,
but also serves as a form of documentation for the
project as well. So be sure to familiarize yourself
with it.

## Pre-requistes

- Docker
- Docker Compose
- Direnv
- Python 3
- Python Virtual Environment
- Poetry

## Instructions

1. Configure environment variables by adding the build.env to your .envrc
    ```
    dotenv_if_exists ./build.env
    ```
    Then Allow the .envrc file by running
    ```
    direnv allow .
    ```
    This will automatically load most of the environment variables that you need
    into your shell.

2. Install Python Tooling Dependencies
    ```
    make tools-venv install-tool-dependencies
    ```

3. Build & Start the docker containers
    ```
    make build-temporal-services init-temporal-services
    ```

4. In another Shell run the temporal worker
    ```
    make start-native-worker
    ```