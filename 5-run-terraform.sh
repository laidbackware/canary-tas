#!/bin/bash

set -euxo pipefail

[ -z "${FOUNDATION:-}" ] && echo '$FOUNDATION must be set' && exit 2

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

plane_dir=${PLANE_DIR:="${script_dir}/../k9-bootstrapping"}

export state_bucket=`terraform output -state="$plane_dir/state/terraform.tfstate" stable_config_concourse | jq -r .state_bucket`
echo "State bucket is: ${state_bucket}"

pushd ${script_dir}/terraform/aws

terraform init -backend-config="bucket=$state_bucket" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate"

terraform plan -out=./tf.plan -var-file=${script_dir}/vars/${FOUNDATION}/terraform.tfvars -input=false

terraform apply -auto-approve ./tf.plan

trap 'rm -rf "${tmp_dir}"' EXIT
tmp_dir=$(mktemp -d) || exit 1
echo "Temp dir is ${tmp_dir}"

file_version="$(date '+%Y%m%d.%H%M%S')"
output_file=${tmp_dir}/tf-output-${file_version}.yml

terraform output  stable_config_yaml > ${output_file}

s3 cp ${output_file} s3://${state_bucket}/${FOUNDATION}/