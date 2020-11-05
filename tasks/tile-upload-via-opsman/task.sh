#!/bin/bash

set -euxo pipefail

OM_TARGET=$(bosh int ${ENV_FILE} --path /target | \
                            sed s"/((domain))/${OM_VAR_domain}/" | \
                            sed s"/((foundation))/${OM_VAR_foundation}/")

mkdir workdir

om interpolate -c ${ENV_FILE} > workdir/env.yml
om interpolate -c ${DOWNLOAD_CONFIG_FILE} > workdir/download-config.yml

# Remove and S3 references from  download config
sed '/s3-/d' workdir/download-config.yml

# Extract OM SSH key
bosh int ${TF_VARS_FILE} --path /ops_manager_ssh_private_key > workdir/om-ssh-key

cd workdir

cat > download-upload.sh << EOF
wget -O om https://github.com/pivotal-cf/om/releases/download/6.5.0/om-linux-6.5.0
chmod +x om
./om -e env.yml download-product -c download-config.yml -o .
./om upload-product -p cf*.pivotal
EOF

chmod +x download-upload.sh

# transfer files
scp -i om-ssh-key * ubuntu@${OM_TARGET}:/tmp/

scp -i om-ssh-key * ubuntu@${OM_TARGET} /tmp/download-upload.sh