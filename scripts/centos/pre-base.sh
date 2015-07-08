#!/bin/bash -eux
yum update -y
echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
service network restart
