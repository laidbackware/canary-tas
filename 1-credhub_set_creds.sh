#!/bin/bash
# Script to set credhub secrets for pipelines.
# Secrets will be pulled from lastpass.
# Secrets will print to the screen when run.

set -euxo pipefail

if [ $# -eq 0 ]; then
    echo "You must add your lastpass username as a parameter"
fi

source ../ducc/1-vars.sh

ATTEMPT_COUNTER=0
MAX_ATTEMPTS=12

until $(curl -k --output /dev/null --silent --head --fail https://${DUCC_HOSTNAME}:9000/info); do
    if [ ${ATTEMPT_COUNTER} -eq ${MAX_ATTEMPTS} ];then
      echo "Max attempts reached"
      exit 1
    fi
    ATTEMPT_COUNTER=$(expr ${ATTEMPT_COUNTER} + 1)
    CURRENT_TRY=$(expr ${MAX_ATTEMPTS} - ${ATTEMPT_COUNTER})
    echo "https://${DUCC_HOSTNAME}:9000/info not online yet, ${CURRENT_TRY} more retries left"
    sleep 5
done

credhub login --client-name credhub_client --client-secret ${DUCC_CREDHUB_CLIENT_SECRET} -s https://${DUCC_HOSTNAME}:9000 --skip-tls-validation

PIVNET_TOKEN="$(lpass show pivnet_token --password)"
AWS_ACCESS_KEY="$(lpass show aws-paving-user --username)"
AWS_SECRET_KEY="$(lpass show aws-paving-user --password)"
OM_PASSWORD="$(lpass show opsman --password)"
FOUNDATION=canary
DOMAIN="$(lpass show aws_domain --notes)"
GOROUTER_CA="$(lpass show aws-pas-gorouter --field=ca)"
GOROUTER_PUBLIC_KEY="$(lpass show aws-pas-gorouter --field=public_key)"
GOROUTER_PRIVATE_KEY="$(lpass show aws-pas-gorouter --field=private_key)"

# S3_JSON are keys used for bucket access from Concourse
S3_JSON="{\"client_id\": \"minio\", \"client_secret\": \"minio123\"}"
# Cloud creds are the AWS tokens used by BOSH and Opsman.
CLOUD_CREDS_JSON="{\"client_id\": \"${AWS_ACCESS_KEY}\", \"client_secret\": \"${AWS_SECRET_KEY}\"}"

credhub set -n /concourse/${FOUNDATION}/decryption_passphrase -t password -w "${OM_PASSWORD}${OM_PASSWORD}"
credhub set -n /concourse/${FOUNDATION}/pivnet_token -t password -w "$PIVNET_TOKEN"
credhub set -n /concourse/${FOUNDATION}/s3_access -t json -v "${S3_JSON}"
credhub set -n /concourse/${FOUNDATION}/om_login -t user -z admin -w "$OM_PASSWORD"
credhub set -n /concourse/${FOUNDATION}/aws_client -t user -z "$AWS_ACCESS_KEY" -w "$AWS_SECRET_KEY"
credhub set -n /concourse/${FOUNDATION}/cloud_creds -t json -v "${CLOUD_CREDS_JSON}"
credhub set -n /concourse/${FOUNDATION}/domain -t value -v "${DOMAIN}"
credhub set -n /concourse/${FOUNDATION}/pas_cert -t rsa  -p "${GOROUTER_PRIVATE_KEY}" -u "${GOROUTER_PUBLIC_KEY}"  -m "${GOROUTER_CA}"
