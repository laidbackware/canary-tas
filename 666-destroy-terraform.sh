#!/bin/bash

set -euxo pipefail

[ -z "${FOUNDATION:-}" ] && echo '$FOUNDATION must be set' && exit 2

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

plane_dir=${PLANE_DIR:="${script_dir}/../k9-bootstrapping"}

export state_bucket=`terraform output -state="$plane_dir/state/terraform.tfstate" stable_config_concourse | jq -r .state_bucket`
echo $state_bucket

pushd ${script_dir}/terraform/aws

terraform init -backend-config="bucket=$state_bucket" \
    -backend-config="key=${FOUNDATION}/terraform.tfstate"

terraform destroy -var-file=${script_dir}/vars/${FOUNDATION}/terraform.tfvars -input=false