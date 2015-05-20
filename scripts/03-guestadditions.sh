#!/bin/bash -eux

VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
if [ ! -e $VBOX_ISO ]; then
  wget http://dlc-cdn.sun.com/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
fi
mount -o loop /home/vagrant/"$VBOX_ISO" /mnt
yes|sh /mnt/VBoxLinuxAdditions.run --nox11
umount /mnt

# Fix Fail to mount a shared folder on VirtualBox 4.3.10
if [ ! -d "/usr/lib/VBoxGuestAdditions" ]; then
	ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi

mkdir /vagrant
