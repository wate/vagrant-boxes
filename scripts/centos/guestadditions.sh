#!/bin/bash

VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /home/vagrant/"$VBOX_ISO" /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt
rm "$VBOX_ISO"

# Fix Fail to mount a shared folder on VirtualBox 4.3.10
if [ ! -d "/usr/lib/VBoxGuestAdditions" ]; then
	ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi

mkdir /vagrant
