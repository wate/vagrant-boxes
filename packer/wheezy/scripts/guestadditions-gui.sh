# GuestAdditions setup
apt-get -y purge virtualbox-guest-utils
apt-get -y install dkms
apt-get -y autoremove

VBOX_VERSION=$(cat .vbox_version)
VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop /home/vagrant/$VBOX_ISO /mnt
yes|bash /mnt/VBoxLinuxAdditions.run
umount /mnt
rm $VBOX_ISO

# Fix Fail to mount a shared folder on VirtualBox 4.3.10
if [ ! -d "/usr/lib/VBoxGuestAdditions" ]; then
	ln -s /opt/VBoxGuestAdditions-*/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
fi

# gdm3 Enable AutoLogin
GDMCONF=/etc/gdm3/daemon.conf
if [ -f "${GDMCONF}" ]; then
  sed '7,8s/^#\ \ //g ' ${GDMCONF}
  sed '8s/user1/vagrant/g' ${GDMCONF}
fi


mkdir /vagrant

