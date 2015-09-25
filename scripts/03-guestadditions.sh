#!/bin/bash -eux

VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
if [ ! -e $VBOX_ISO ]; then
  wget http://dlc-cdn.sun.com/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
fi
mount -o loop /home/vagrant/${VBOX_ISO} /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

mkdir /vagrant
