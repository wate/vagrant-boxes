# GuestAdditions setup
apt-get -y purge virtualbox-guest-utils
apt-get -y autoremove

apt-get -y install dkms

VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /home/vagrant/$VBOX_ISO /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm $VBOX_ISO

