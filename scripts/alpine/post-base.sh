#!/bin/sh -eux

apk update && apk upgrade

source /etc/os-release

cat << EOF >/etc/motd
Welcome to ${PRETTY_NAME}

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <http://wiki.alpinelinux.org>.
EOF

# sshd setting
sed -i '/^PermitRootLogin yes/d' /etc/ssh/sshd_config

# install packages
apk add curl bash sudo

adduser vagrant -D -s /bin/bash
echo "vagrant:vagrant" | chpasswd

# sudo setting
echo "includedir /etc/sudoers.d" >> /etc/sudoers
echo "vagrant ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/vagrant

# add apk community repo
VARSION=$(echo ${PRETTY_NAME} | tr -d "${NAME} ")
echo "http://mirror.leaseweb.com/alpine/${VARSION}/community" >>/etc/apk/repositories

# set keymap
/sbin/setup-keymap jp jp106

# set timezone
/sbin/setup-timezone -z Asia/Tokyo
