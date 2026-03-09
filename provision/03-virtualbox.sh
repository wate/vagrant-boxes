#!/bin/sh -eux

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

# カーネルヘッダーをインストールする。
# bento.shでのパッケージ更新後にリブートが発生した場合、uname -rが新カーネルのバージョンを
# 返すため、正確なバージョンのヘッダーを優先してインストールする。
# 見つからない場合はアーキテクチャのメタパッケージにフォールバックする。
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
  KERNEL_HEADERS_PACKAGE="linux-headers-arm64"
else
  KERNEL_HEADERS_PACKAGE="linux-headers-amd64"
fi
apt-get update -qq
if ! apt-get install -y "linux-headers-$(uname -r)" 2>/dev/null; then
  echo "Exact kernel headers not found, falling back to ${KERNEL_HEADERS_PACKAGE}..."
  apt-get install -y "${KERNEL_HEADERS_PACKAGE}"
fi
apt-get install -y build-essential

mkdir -p /tmp/vbox;
mount -o loop $HOME/${VBOX_ISO} /tmp/vbox;

if [ "$ARCH" = "aarch64" ]; then
  /tmp/vbox/VBoxLinuxAdditions-arm64.run;
else
  /tmp/vbox/VBoxLinuxAdditions.run;
fi

umount /tmp/vbox;
rm -f $HOME/*.iso;

mkdir -p /vagrant;
