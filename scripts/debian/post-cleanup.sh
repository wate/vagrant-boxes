#!/bin/bash -eux

rm -rf /dev/.udev/

# dhcp cleanup
rm /var/lib/dhcp/*
rm /etc/resolv.conf

# cleanup
apt-get -y autoremove
apt-get -y clean
for i in $(dpkg -l | grep ^rc | cut -d' ' -f3);do dpkg -P "$i";done

# zeroclear
dd if=/dev/zero of=/tmp/zeroclear bs=1M
rm -f /tmp/zeroclear
