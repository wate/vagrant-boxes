#!/bin/sh -eux

## キーボード設定、日本語ロケール設定、基本パッケージインストール
## ------------

debconf-set-selections <<< "keyboard-configuration keyboard-configuration/model select Generic 105-key (Intl) PC"
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/modelcode string pc105"
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/variant select Japanese"
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/variantcode string "
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/xkb-keymap select jp"
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/altgr select The default for the keyboard layout"
debconf-set-selections <<< "keyboard-configuration keyboard-configuration/compose select No compose key"
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure keyboard-configuration
apt-get -y update
apt-get -y upgrade
apt-get -y install openssh-server bzip2 cryptsetup zlib1g-dev wget curl dkms make nfs-common locales-all linux-headers-$(uname -r)
localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP.UTF-8

## Guest Additionsのインストール/更新
## ------------

# Get the latest VirtualBox version from LATEST.TXT
VBOX_VERSION=$(curl -s https://download.virtualbox.org/virtualbox/LATEST.TXT)

if [ -z "$VBOX_VERSION" ]; then
  echo "Failed to retrieve VirtualBox version" >&2
  exit 1
fi

echo "Virtualbox Tools Version: $VBOX_VERSION";

VBOX_ISO="VBoxGuestAdditions_${VBOX_VERSION}.iso";
if [ ! -e $VBOX_ISO ]; then
  wget http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso;
fi

mkdir -p /tmp/vbox;
mount -o loop /home/vagrant/${VBOX_ISO} /tmp/vbox;

/tmp/vbox/VBoxLinuxAdditions.run;
umount /tmp/vbox;
rm -f /home/vagrant/*.iso;

mkdir -p /vagrant;

