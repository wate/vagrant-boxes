# setup sudo
echo "vagrant ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

# add ssh confguration
echo "UseDNS no" >> /etc/ssh/sshd_config

# set GRUB_TIMEOUT is none
sed -i '/^GRUB_TIMEOUT/s/[0-9]$/0/g' /etc/default/grub
/usr/sbin/update-grub

# set hostname
#echo "vagrant-wheezy" > /etc/hostname
#sed -e '2d' -e '3i 127.0.1.1\tvagrant-wheezy\tvagrant-wheezy.vagrantup.com' -i /etc/hosts

# dhcp cleanup
rm /var/lib/dhcp/*
