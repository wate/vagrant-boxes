#!/bin/sh

# Amazon Linux 2 LTSの綺麗なVagrant boxを作ってみた
# https://qiita.com/mitsubachi/items/4bb3c63862bc70ac92bc

set -e

IMAGE_VERSION="2.0.20181024"
DOWNLOAD_URL="https://cdn.amazonlinux.com/os-images/${IMAGE_VERSION}/virtualbox/amzn2-virtualbox-${IMAGE_VERSION}-x86_64.xfs.gpt.vdi"
SAVE_FILE="amzn2-virtualbox-x86_64.vdi"
VAGRANT_CLOUD_BOX="wate/amazon-linux"

if [ ! -e "${SAVE_FILE}" ]; then
    echo "# ------------------------"
    echo "# Download Amazon Linux 2 VirtualBox image"
    echo "# ------------------------"
    curl ${DOWNLOAD_URL} -o ${SAVE_FILE}
fi

if [ ! -e seed.iso ]; then
    echo "# ------------------------"
    echo "Create cloud-init ISO image"
    echo "# ------------------------"
    hdiutil makehybrid -iso -joliet -o seed.iso seed -joliet-volume-name cidata
fi

if [ ! -e vagrant.pem ]; then
    echo "# ------------------------"
    echo "# Download Vagrant insecure private key"
    echo "# ------------------------"
    curl -sL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant -o vagrant.pem
    chmod 600 vagrant.pem
fi

VM_NAME=amazon_linux

VBoxManage createvm --name "${VM_NAME}" --ostype "RedHat_64" --register
VBoxManage storagectl "${VM_NAME}" --name "SATA Controller" --add "sata" --controller "IntelAHCI"
VBoxManage storagectl "${VM_NAME}" --name "IDE Controller" --add "ide"
VBoxManage storageattach "${VM_NAME}" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium ${SAVE_FILE}
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium seed.iso
VBoxManage modifyvm "${VM_NAME}" --natpf1 "ssh,tcp,127.0.0.1,2222,,22" --memory 1024 --vram 8 --audio none --usb off
VBoxManage startvm "${VM_NAME}" --type headless

sleep 5

SSH_PARAM="-p 2222 -i vagrant.pem -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@127.0.0.1"

echo "# ------------------------"
echo "# Update all packagses"
echo "# ------------------------"
ssh ${SSH_PARAM} "sudo yum update -y"

echo "# ------------------------"
echo "# Install dependency packagse"
echo "# ------------------------"
ssh ${SSH_PARAM} "sudo yum install -y kernel-devel perl gcc"

echo "# ------------------------"
echo "# Reboot"
echo "# ------------------------"
ssh ${SSH_PARAM} "sudo shutdown -r +1 && exit"

echo "# ------------------------"
echo "# Wait for reboot"
echo "# ------------------------"
sleep 90

echo "# ------------------------"
echo "# Install VirtualBox Guest Additions"
echo "# ------------------------"
VGA_ISO=/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso
VBoxManage storageattach "${VM_NAME}" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ${VGA_ISO} --forceunmount
ssh ${SSH_PARAM} "sudo mount -r /dev/cdrom /media"
ssh ${SSH_PARAM} "sudo /media/VBoxLinuxAdditions.run --nox11"
ssh ${SSH_PARAM} "sudo umount /media"

echo "# ------------------------"
echo "# Cleanup"
echo "# ------------------------"
ssh ${SSH_PARAM} "sudo yum remove -y gcc cpp kernel-devel kernel-headers perl"
ssh ${SSH_PARAM} "sudo yum clean -y all"
ssh ${SSH_PARAM} "touch /tmp/empty"
ssh ${SSH_PARAM} "dd if=/dev/zero of=/tmp/empty bs=1M || echo \"dd exit code $? is suppressed\""
ssh ${SSH_PARAM} "rm -f /tmp/empty"
ssh ${SSH_PARAM} "rm -f ~/.bash_history"
ssh ${SSH_PARAM} "history -c"

if [ -e ${VM_NAME}.box ]; then
    rm ${VM_NAME}.box
fi
vagrant package --base "${VM_NAME}" --output ${VM_NAME}.box

VBoxManage unregistervm "${VM_NAME}" --delete

echo "# ------------------------"
echo "# Remove download files"
echo "# ------------------------"
rm -f seed.iso
rm -f vagrant.pem

echo "# ------------------------"
echo "# Upload Vagrant Cloud"
echo "# ------------------------"
# ------
# https://www.vagrantup.com/docs/vagrant-cloud/api.html#example-requests
# ------
echo "Create new version"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${VAGRANTCLOUD_TOKEN}" \
  https://app.vagrantup.com/api/v1/box/${VAGRANT_CLOUD_BOX}/versions \
  --data "{\"version\": {\"version\": \"${IMAGE_VERSION}\"}}" >/dev/null

echo "Create new provider"
curl \
  --header "Content-Type: application/json" \
  --header "Authorization: Bearer ${VAGRANTCLOUD_TOKEN}" \
  https://app.vagrantup.com/api/v1/box/${VAGRANT_CLOUD_BOX}/version/${IMAGE_VERSION}/providers \
  --data '{ "provider": { "name": "virtualbox" } }' >/dev/null

echo "Upload Vagrant image"
response=$(curl \
  --header "Authorization: Bearer $VAGRANTCLOUD_TOKEN" \
  https://app.vagrantup.com/api/v1/box/${VAGRANT_CLOUD_BOX}/version/${IMAGE_VERSION}/provider/virtualbox/upload)
upload_path=$(echo "$response" | jq -r .upload_path)
curl $upload_path --request PUT --upload-file ${VM_NAME}.box >/dev/null

echo "Release version"
curl \
  --header "Authorization: Bearer ${VAGRANTCLOUD_TOKEN}" \
  https://app.vagrantup.com/api/v1/box/${VAGRANT_CLOUD_BOX}/version/${IMAGE_VERSION}/release \
  --request PUT >/dev/null
