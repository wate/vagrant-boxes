#!/bin/bash -eux

apt-get -y install gcc make;
apt-get -y purge virtualbox-guest-utils xauth;
apt-get -y autoremove;
