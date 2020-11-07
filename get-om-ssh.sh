#!/bin/bash
# Requires bosh CLI and s5cmd

set -euxo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

FOUNDATION=$1

TF_OUTPUT_FILE=$(ls -td  ~/minio/terraform-state/${FOUNDATION}/*.yml | head -1)

bosh int ${TF_OUTPUT_FILE} --path /ops_manager_ssh_private_key > ${SCRIPT_DIR}/om-sshHey Matt. Do you have any time this afternoon to help troubleshoot some PAS configuration ? I ran into something quite strange that’s not obvious to resolve.
￼
