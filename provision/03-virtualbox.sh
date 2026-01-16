#!/bin/sh -eux

# Get the latest VirtualBox version from LATEST.TXT
VBOX_VERSION=$(curl -s https://download.virtualbox.org/virtualbox/LATEST.TXT)

if [ -z "$VBOX_VERSION" ]; then
  echo "Failed to retrieve VirtualBox version" >&2
  exit 1
fi

echo "Virtualbox Tools Version: $VBOX_VERSION";

VBOX_ISO="VBoxGuestAdditions_${VBOX_VERSION}.iso";
if [ ! -e $VBOX_ISO ]; then
  wget http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso;
fi

mkdir -p /tmp/vbox;
mount -o loop $HOME/${VBOX_ISO} /tmp/vbox;

/tmp/vbox/VBoxLinuxAdditions.run;
umount /tmp/vbox;
rm -f $HOME/*.iso;

mkdir -p /vagrant;
