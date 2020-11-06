#!/bin/bash

set -euxo pipefail

OM_TARGET=$(om interpolate -c config/${ENV_FILE} -s --path /target) || exit 1

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Ops Man is up"
else
    echo "Skipping task as Ops Man is not contactable and assumed to be deleted"
    cp state/om-state-*.yml generated-state/
    exit 0
fi

if [[ $(om -e config/${ENV_FILE} deployed-products -f json ) != "[]" ]]; then
    echo "There are still products deployed, refusing to delete Ops Man!\n Existing!"
    exit 1
fi

platform-automation-tasks/tasks/delete-vm.sh
