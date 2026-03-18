#!/bin/sh -eux

export DEBIAN_FRONTEND=noninteractive

log() {
  echo "[$(date '+%H:%M:%S')] $*"
}

# Get the latest VirtualBox version from LATEST.TXT
VBOX_VERSION=$(curl -fsSL https://download.virtualbox.org/virtualbox/LATEST.TXT)

if [ -z "$VBOX_VERSION" ]; then
  echo "Failed to retrieve VirtualBox version" >&2
  exit 1
fi

echo "Virtualbox Tools Version: $VBOX_VERSION";

VBOX_ISO_DIR="/tmp"
VBOX_ISO="VBoxGuestAdditions_${VBOX_VERSION}.iso"
VBOX_ISO_PATH="${VBOX_ISO_DIR}/${VBOX_ISO}"

if [ ! -e "${VBOX_ISO_PATH}" ]; then
  log "Downloading ${VBOX_ISO}"
  wget -O "${VBOX_ISO_PATH}" "http://download.virtualbox.org/virtualbox/${VBOX_VERSION}/${VBOX_ISO}"
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

# apt-daily/unattended-upgradesによるロック解放を待つ。
APT_LOCK_WAIT_SECS=300
elapsed=0
log "Waiting for apt locks to clear (timeout: ${APT_LOCK_WAIT_SECS}s)"
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 \
  || fuser /var/lib/apt/lists/lock >/dev/null 2>&1 \
  || fuser /var/cache/apt/archives/lock >/dev/null 2>&1 \
  || pgrep -x unattended-upgrade >/dev/null 2>&1; do
  if [ "$elapsed" -ge "$APT_LOCK_WAIT_SECS" ]; then
    echo "Timed out waiting for apt lock" >&2
    exit 1
  fi
  sleep 5
  elapsed=$((elapsed + 5))
done
log "apt locks cleared"

log "Running apt-get update"
apt-get update -qq
log "Installing kernel headers"
if ! apt-get install -y "linux-headers-$(uname -r)" 2>/dev/null; then
  echo "Exact kernel headers not found, falling back to ${KERNEL_HEADERS_PACKAGE}..."
  apt-get install -y "${KERNEL_HEADERS_PACKAGE}"
fi
# autoremoveで削除されないよう手動インストール済みとしてマークする。
apt-mark manual "linux-headers-$(uname -r)" || true
log "Installing build-essential"
apt-get install -y build-essential

mkdir -p /tmp/vbox
log "Mounting Guest Additions ISO"
mount -o loop "${VBOX_ISO_PATH}" /tmp/vbox

log "Installing VirtualBox Guest Additions"
if [ "$ARCH" = "aarch64" ]; then
  /tmp/vbox/VBoxLinuxAdditions-arm64.run 2>&1 | tee /var/log/vboxadd-install.log &
else
  /tmp/vbox/VBoxLinuxAdditions.run 2>&1 | tee /var/log/vboxadd-install.log &
fi
vbox_pid=$!
while kill -0 "$vbox_pid" >/dev/null 2>&1; do
  log "Guest Additions install still running..."
  sleep 20
done
wait "$vbox_pid"
log "Guest Additions install completed"

umount /tmp/vbox
rm -f "${VBOX_ISO_PATH}"

mkdir -p /vagrant

# Guest Additions ビルドに使った apt キャッシュ・リストを削除する。
apt-get -y clean
rm -rf /var/lib/apt/lists/*

log "40-install-virtualbox-guest-additions.sh completed"
