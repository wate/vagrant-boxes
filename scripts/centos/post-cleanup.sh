#!/bin/bash -eux

# Remove development and kernel source packages
yum -y remove gcc cpp kernel-devel kernel-headers perl
yum -y clean all

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules;
mkdir -p /etc/udev/rules.d/70-persistent-net.rules;
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules;
rm -rf /dev/.udev/;

for ndev in `ls -1 /etc/sysconfig/network-scripts/ifcfg-*`; do
    if [ "`basename $ndev`" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev";
        sed -i '/^UUID/d' "$ndev";
    fi
done

# radio off & remove all interface configration
nmcli radio all off
/bin/systemctl stop NetworkManager.service

for ifcfg in `ls -1 /etc/sysconfig/network-scripts/ifcfg-* | grep -v ifcfg-lo`; do
  rm -f $ifcfg
done
rm -rf /var/lib/NetworkManager/*

echo "==> Setup /etc/rc.d/rc.local for CentOS7"
cat <<_EOF_ | cat >> /etc/rc.d/rc.local
#PACKER-BEGIN
LANG=C
# delete all connection
for con in \`nmcli -t -f uuid con\`; do
  if [ "\$con" != "" ]; then
    nmcli con del \$con
  fi
done
# add gateway interface connection.
gwdev=\`nmcli dev | grep ethernet | egrep -v 'unmanaged' | head -n 1 | awk '{print \$1}'\`
if [ "\$gwdev" != "" ]; then
  nmcli c add type eth ifname \$gwdev con-name \$gwdev
fi
sed -i "/^#PACKER-BEGIN/,/^#PACKER-END/d" /etc/rc.d/rc.local
chmod -x /etc/rc.d/rc.local
#PACKER-END
_EOF_
chmod +x /etc/rc.d/rc.local
