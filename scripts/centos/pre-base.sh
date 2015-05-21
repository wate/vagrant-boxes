#!/bin/bash -eux

echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
service network restart

sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=sudo' /etc/sudoers
sed -i -e 's/%sudo  ALL=(ALL:ALL) ALL/%sudo  ALL=NOPASSWD:ALL/g' /etc/sudoers
