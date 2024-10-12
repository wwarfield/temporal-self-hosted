#!/bin/bash

register_namespace() {
    name=$1
    retention_period=$2
    description=$3

    if temporal operator namespace list | grep -q "${name}"; then
        echo "Namespace ${name} Already Registered, Updating Namespace"
        temporal operator namespace update \
            --namespace "${name}" \
            --retention "${retention_period}" \
            --description "${description}"
        echo "Namespace Updated"
    else
        echo "Creating Namespace ${name}"
        temporal operator namespace create \
            --namespace "${name}" \
            --retention "${retention_period}" \
            --description "${description}"
        echo "Namespace ${name} Created"
    fi
}

setup_server() {
    echo "Temporal CLI address: ${TEMPORAL_ADDRESS}."

    until temporal operator cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    # register_default_namespace
    register_namespace "default" "3d" "default namespace"

    echo "Auto Server Setup complete"
}

echo "Auto Server Setup Started"

setup_server &