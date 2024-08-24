
ARG TEMPORAL_VERSION
ARG TARGETARCH

FROM --platform=linux/${TARGETARCH} temporalio/server:${TEMPORAL_VERSION}

ARG TARGETARCH

USER temporal

WORKDIR /etc/temporal

COPY config.yaml         /etc/temporal/config/config_template.yaml
COPY dynamic-config.yaml /etc/temporal/config/dynamic-config.yaml

COPY auto-setup.sh /etc/temporal/auto-setup.sh

CMD autosetup