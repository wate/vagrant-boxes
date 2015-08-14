#!/bin/bash -eux

yum -y install gcc kernel-devel kernel-headers perl
echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
service network restart
