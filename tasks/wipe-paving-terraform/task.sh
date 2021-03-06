#!/bin/bash

set -euxo pipefail

ROOT_DIR="$(pwd)"

# Setup tools
cp ${ROOT_DIR}/terraform/terraform-* /usr/local/bin/terraform
chmod +x /usr/local/bin/terraform

ENV_FILE=vars/${OM_VAR_foundation}/env/env.yml
OM_TARGET=$(om interpolate -c config/${ENV_FILE} -s --path /target) || exit 1

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Aborting, Ops Man is still online"
    exit 1
fi

cd ${ROOT_DIR}/config/terraform/aws
export TF_VAR_access_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_id)"
export TF_VAR_secret_key="$(bosh int <(echo ${CLOUD_CREDS}) --path /client_secret)"

terraform init -backend-config="bucket=${STATE_BUCKET}" \
    -backend-config="key=${OM_VAR_foundation}/terraform.tfstate" \
    -backend-config="endpoint=${S3_ENDPOINT}"\
    -backend-config="access_key=${STATE_BUCKET_KEY_ID}"\
    -backend-config="secret_key=${STATE_BUCKET_SECRET_KEY}"

terraform destroy -auto-approve -var-file=${ROOT_DIR}/config/vars/${OM_VAR_foundation}/terraform.tfvars
