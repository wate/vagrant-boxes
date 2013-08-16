# add ssh confguration
echo "UseDNS no" >> /etc/ssh/sshd_config

# Install vagrant keys
mkdir -p -m 0700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# set GRUB_TIMEOUT is none
sed -i '/^GRUB_TIMEOUT/s/[0-9]$/0/g' /etc/default/grub
/usr/sbin/update-grub
