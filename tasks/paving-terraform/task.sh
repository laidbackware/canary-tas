#!/bin/bash

set -euxo pipefail

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform 

cd ${ROOT_DIR}/config/terraform/${FOUNDATION}
export TF_VAR_access_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
export TF_VAR_secret_key="$(bosh int <(echo ${CLOUD_CREDS}) --path  /client_secret)"

terraform init -backend-config="bucket=$STATE_BUCKET" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

terraform plan -out=./tf.plan -var-file=${ROOT_DIR}/config/vars/${FOUNDATION}/terraform.tfvars -input=false

terraform apply -auto-approve ./tf.plan

mkdir -p ${ROOT_DIR}/generated-tf-output/
FILE_VERSION="$(date '+%Y%m%d.%H%M%S')"
OUTPUT_FILE=${ROOT_DIR}/generated-tf-output/tf-output-${FILE_VERSION}.yml

terraform output  stable_config_yaml > ${OUTPUT_FILE}