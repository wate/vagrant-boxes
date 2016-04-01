#!/bin/sh -eux

apk update && apk upgrade

source /etc/os-release

cat << EOF
$NAME $VERSION_ID

See the Alpine Wiki for how-to guides and
general information about administrating
Alpine systems and development.
See <http://wiki.alpinelinux.org>
EOF

# sshd setting
sed -i '/^PermitRootLogin yes/d' /etc/ssh/sshd_config

# install packages
apk add curl bash sudo

adduser -D vagrant
echo "vagrant:vagrant" | chpasswd

# sudo
echo "%vagrant ALL=NOPASSWD:ALL" >> /etc/sudoers
