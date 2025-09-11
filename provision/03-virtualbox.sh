#!/bin/sh -eux

VBOX_VERSION="7.2.2";

echo "Virtualbox Tools Version: $VBOX_VERSION";

VBOX_ISO="VBoxGuestAdditions_${VBOX_VERSION}.iso";
if [ ! -e $VBOX_ISO ]; then
  wget http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso;
fi

mkdir -p /tmp/vbox;
mount -o loop /home/vagrant/${VBOX_ISO} /tmp/vbox;
/tmp/vbox/VBoxLinuxAdditions.run;
umount /tmp/vbox;
rm -rf /tmp/vbox;
rm -f $HOME_DIR/*.iso;

mkdir -p /vagrant;
