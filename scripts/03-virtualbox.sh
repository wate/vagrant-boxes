#!/bin/sh -eux

case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
  VBOX_VERSION="`cat .vbox_version`";

  echo "Virtualbox Tools Version: $VBOX_VERSION";

  VBOX_ISO="VBoxGuestAdditions_${VBOX_VERSION}.iso"
  if [ ! -e $VBOX_ISO ]; then
    wget http://dlc-cdn.sun.com/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso
  fi

  mkdir -p /tmp/vbox;
  mount -o loop /home/vagrant/${VBOX_ISO} /tmp/vbox;
  sh /tmp/vbox/VBoxLinuxAdditions.run
  umount /tmp/vbox;
  rm -rf /tmp/vbox;
  rm -f $HOME_DIR/*.iso;

  mkdir /vagrant
  ;;
esac
