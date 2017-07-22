#!/bin/bash -eux

yum -y install gcc kernel-devel kernel-headers perl
case "$PACKER_BUILDER_TYPE" in
virtualbox-iso|virtualbox-ovf)
    # Fix slow DNS:
    # Add 'single-request-reopen' so it is included when /etc/resolv.conf is generated
    # https://access.redhat.com/site/solutions/58625 (subscription required)
    echo 'RES_OPTIONS="single-request-reopen"' >>/etc/sysconfig/network;
    service network restart;
    ;;
esac
