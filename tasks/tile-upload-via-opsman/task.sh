#!/bin/bash

set -euxo pipefail

OM_TARGET=$(bosh int ${ENV_FILE} --path /target | sed s"/((domain))/${OM_VAR_domain}/")

mkdir workdir
cp ${ENV_FILE} workdir/env.yml
cp ${DOWNLOAD_CONFIG_FILE} workdir/download-config.yml
cp ${PRODUCT_VARS_FILE} workdir/vars.yml

bosh int ${TF_VARS_FILE} --path /ops_manager_ssh_private_key > workdir/om-ssh-key

cd workdir

# Extract OM SSH key

# Remove and S3 references from  download config
sed '/s3-/d' workdir/download-config.yml

cat > download-upload.sh << EOF
wget -O om https://github.com/pivotal-cf/om/releases/download/6.5.0/om-linux-6.5.0
chmod +x om
./om -e env.yml download-product -c download-config.yml -l vars.yml -o .
./om upload-product -p cf*.pivotal
EOF

chmod +x download-upload.sh

# transfer files
scp -i om-ssh-key * ubuntu@${OM_TARGET}:/tmp/

scp -i om-ssh-key * ubuntu@${OM_TARGET} /tmp/download-upload.sh