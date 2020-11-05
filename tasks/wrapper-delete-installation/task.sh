#!/bin/bash

set -euxo pipefail

OM_TARGET=$(bosh int config/${ENV_FILE} --path /target | \
                            sed s"/((domain))/${OM_VAR_domain}/" | \
                            sed s"/((foundation))/${OM_VAR_foundation}/")

if $(curl -k --output /dev/null --silent --head --fail -m 5 ${OM_TARGET})
then
    echo "Ops Man is up"
else
    echo "Skipping task as Ops Man is not contactable and assumed to be deleted"
    exit 0
fi

platform-automation-tasks/tasks/delete-installation.sh
