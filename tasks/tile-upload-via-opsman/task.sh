#!/bin/bash

set -euxo pipefail

OM_TARGET=$(bosh int ${ENV_FILE} --path /target | \
                            sed s"/((domain))/${OM_VAR_domain}/" | \
                            sed s"/((foundation))/${OM_VAR_foundation}/")

# Remove and S3 references from  download config
sed -i '/s3-/d' ${DOWNLOAD_CONFIG_FILE}
sed -i '/stemcell/d' ${DOWNLOAD_CONFIG_FILE}

mkdir -p workdir

om interpolate -c ${ENV_FILE} > workdir/env.yml
om interpolate -c ${DOWNLOAD_CONFIG_FILE} -l ${PRODUCT_VARS_FILE}> workdir/download-config.yml

# Extract OM SSH key
bosh int ${TF_VARS_FILE} --path /ops_manager_ssh_private_key > workdir/om-ssh-key

cd workdir

chmod 600 om-ssh-key

cat > download-upload.sh << EOF
#!/bin/bash
cd /tmp
wget -O om https://github.com/pivotal-cf/om/releases/download/6.5.0/om-linux-6.5.0
chmod +x om
./om -e env.yml download-product -c download-config.yml -o .
./om -e env.yml upload-product -p cf*.pivotal
EOF

chmod +x download-upload.sh

echo "Opsman target is: $OM_TARGET"

# Add key to trust store
mkdir -p ~/.ssh
ssh-keyscan -t rsa $OM_TARGET > ~/.ssh/known_hosts

# transfer files
scp -i om-ssh-key ./* ubuntu@${OM_TARGET}:/tmp/

ssh -i om-ssh-key ubuntu@${OM_TARGET} /tmp/download-upload.sh