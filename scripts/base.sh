#!/bin/bash -eux

apt-get update
apt-get -y upgrade

# add ssh confguration
echo "UseDNS no" >> /etc/ssh/sshd_config
echo "GSSAPIAuthentication no" >> /etc/ssh/sshd_config

# Install vagrant keys
mkdir -p -m 0700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# set GRUB_TIMEOUT is none
sed -i '/^GRUB_TIMEOUT/s/[0-9]$/0/g' /etc/default/grub
sed -i 's/frontend=noninteractive//g' /etc/default/grub
# If use in systemd # sed -i 's/quiet/quiet\ init=\/bin\/systemd/g' /etc/default/grub
/usr/sbin/update-grub
