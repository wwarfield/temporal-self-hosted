#!/bin/sh

# This Script parameterizes the OTEL configuration template by substituting the variables
# in the template and generating a new config dest_file that can be used

OTEL_APP_DIR=$1

write_header() {
    dest_file=$1
    echo "# !!!! DO NOT EDIT !!!!!!!!!!!!!!!" > ${dest_file}
    echo "# !!!! See Template File for Edits" >> ${dest_file}
    echo "# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >> ${dest_file}
}

write_substituted_content() {
    template_file=$1
    dest_file=$2

    export OTEL_SCRAPE_TARGET=$3

    envsubst < ${template_file} >> ${dest_file}
}

write_file() {
    template_file=$1
    dest_file=$2

    scrape_target=$3

    echo "Writing New Config File ${dest_file}"
    echo "scrape target: ${scrape_target}"

    write_header ${dest_file}
    write_substituted_content ${template_file} ${dest_file} ${scrape_target}

    echo "File Created"
    echo "-------------------------"
}

template_src=${OTEL_APP_DIR}/otel-template.yaml
docker_server_dest=${OTEL_APP_DIR}/otel-server-config-docker.yaml


write_file ${template_src} ${docker_server_dest} "temporal-server:4333"