#!/bin/bash -eux

rm -rf /dev/.udev/

export DEBIAN_FRONTEND=noninteractive
APT_OPTS="-o DPkg::Lock::Timeout=300 -o Acquire::Retries=3"

# apt/dpkg lock を待機し、長時間ハングを防ぐ。
APT_LOCK_WAIT_SECS=300
elapsed=0
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

# dhcp cleanup
rm -f /var/lib/dhcp/* || true;
# /etc/resolv.conf is kept so later provisioning steps can still resolve hosts.

# Delete Linux headers for kernels other than the running one.
# Current kernel headers are retained so that VirtualBox Guest Additions
# (vboxsf) can be rebuilt on next boot if needed.
dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-headers' \
    | grep -v '^linux-headers-arm64$' \
    | grep -v '^linux-headers-amd64$' \
    | grep -v "$(uname -r | sed 's/-[^-]*$//')" \
    | xargs --no-run-if-empty apt-get ${APT_OPTS} -y purge;

# Remove specific Linux kernels, such as linux-image-3.11.0-15 but
# keeps the current kernel and does not touch the virtual packages,
# e.g. 'linux-image-amd64', etc.
dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-[234].*' \
    | grep -v $(uname -r) \
    | xargs --no-run-if-empty apt-get ${APT_OPTS} -y purge;

# Delete Linux source
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs --no-run-if-empty apt-get ${APT_OPTS} -y purge;

# Delete development packages
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-dev$' \
    | xargs --no-run-if-empty apt-get ${APT_OPTS} -y purge;

# Delete X11 libraries
apt-get ${APT_OPTS} -y purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6 || true;

# Delete obsolete networking
apt-get ${APT_OPTS} -y purge ppp pppconfig pppoeconf || true;

# Delete oddities
apt-get ${APT_OPTS} -y purge popularity-contest || true;
apt-get ${APT_OPTS} -y purge installation-report || true;

apt-get ${APT_OPTS} -y autoremove;
apt-get ${APT_OPTS} -y clean;

# delete any logs that have built up during the install
find /var/log/ -name '*.log' -exec rm -f {} \;
