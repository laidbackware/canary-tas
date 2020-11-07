#!/bin/bash
# Script to set all pipelines

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BRANCH="$(git rev-parse --symbolic-full-name --abbrev-ref HEAD)"

# AWS
FOUNDATION=canary

fly -t ${FOUNDATION} sp -n -p fetch-dependancies -c ${SCRIPT_DIR}/pipeline/download-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -v branch=${BRANCH} \
    -v foundation=${FOUNDATION}

fly -t ${FOUNDATION} sp -n -p install-pas-${FOUNDATION} -c ${SCRIPT_DIR}/pipeline/install-product-pipeline.yml \
    -l ${SCRIPT_DIR}/vars/download-vars/download-vars.yml -l ${SCRIPT_DIR}/vars/${FOUNDATION}/install-tas-vars.yml \
    -v branch=${BRANCH}