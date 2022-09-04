#!/bin/bash -eux

apt-get -y install gcc make;
apt-get -y purge xauth;
apt-get -y autoremove;
