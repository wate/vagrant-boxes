#!/bin/bash -eux

apt-get update
apt-get -y upgrade

# set GRUB_TIMEOUT is none
sed -i '/^GRUB_TIMEOUT/s/[0-9]$/0/g' /etc/default/grub
sed -i 's/frontend=noninteractive//g' /etc/default/grub
# If use in systemd # sed -i 's/quiet/quiet\ init=\/bin\/systemd/g' /etc/default/grub
/usr/sbin/update-grub
