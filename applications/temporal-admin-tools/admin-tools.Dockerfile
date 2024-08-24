ARG TEMPORAL_ADMINTOOLS_VERSION
ARG TARGETARCH

# Target image
FROM --platform=linux/${TARGETARCH} temporalio/admin-tools:${TEMPORAL_ADMINTOOLS_VERSION}

ARG DOCKERIZE_VERSION
ARG TARGETARCH

# Copy over config
# COPY config/config.yaml           /etc/temporal/config/config_template.yaml

# Copy over scripts
COPY pg-migrate-db.sh   /usr/local/bin/pg-migrate-db.sh