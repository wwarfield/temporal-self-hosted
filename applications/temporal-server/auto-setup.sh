#!/bin/bash


register_default_namespace() {
  temporal operator namespace create \
    "default" \
    --retention "3d" \
    --description "default namespace"
}

setup_server() {
    echo "Temporal CLI address: ${TEMPORAL_ADDRESS}."

    until temporal operator cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    register_default_namespace

    echo "Auto Server Setup complete"
}

echo "Auto Server Setup Started"

setup_server &