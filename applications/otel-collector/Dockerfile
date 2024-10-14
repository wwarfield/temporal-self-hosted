FROM alpine:latest AS build

# Map Build Args to Environment Variables
ARG OTEL_GRAFANA_INSTANCE_ID=temp
ARG OTEL_GRAFANA_API_TOKEN=temp
ARG OTEL_EXPORTER_OTLP_ENDPOINT=temp
ENV OTEL_GRAFANA_INSTANCE_ID=${OTEL_GRAFANA_INSTANCE_ID}
ENV OTEL_GRAFANA_API_TOKEN=${OTEL_GRAFANA_API_TOKEN}
ENV OTEL_EXPORTER_OTLP_ENDPOINT=${OTEL_EXPORTER_OTLP_ENDPOINT}

RUN apk add envsubst

WORKDIR /config

COPY otel-template.yaml otel-template.yaml
COPY generate-otel-config.sh generate-otel-config.sh

# Generate all configuration files
RUN /bin/sh ./generate-otel-config.sh "/config"

# Start release stage and Copy all generated configuration files in
FROM otel/opentelemetry-collector-contrib:latest AS release

COPY --from=build /config/*.yaml .

# Run the collector
CMD ["--feature-gates=-component.UseLocalHostAsDefaultHost"]