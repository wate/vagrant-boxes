# Set up Vagrant.
LANG=C date > /etc/vagrant_box_build_time

# Install vagrant keys
mkdir -p -m 0700 /home/vagrant/.ssh
wget -O /home/vagrant/.ssh/authorized_keys https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Customize the message of the day
echo 'Welcome to your Vagrant-built virtual machine.' > /var/run/motd

