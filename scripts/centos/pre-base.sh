#!/bin/bash -eux

echo 'RES_OPTIONS="single-request-reopen"' >> /etc/sysconfig/network
service network restart
