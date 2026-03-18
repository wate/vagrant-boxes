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
# リポジトリのファイル形式をdeb822形式に変換する。
# 古いイメージでは/etc/apt/sources.listが残っているため変換が必要。
if [ -f /etc/apt/sources.list ]; then
  apt modernize-sources -y
fi
# リポジトリのミラーURLを標準のURLに更新する。
if [ -f /etc/apt/sources.list.d/debian.sources ]; then
  sed -i 's|http://[^ ]*\.debian\.org/debian/|http://deb.debian.org/debian/|g' \
    /etc/apt/sources.list.d/debian.sources
fi
apt-get -y update
apt-get -y upgrade
apt-get -y install openssh-server bzip2 cryptsetup zlib1g-dev wget curl dkms make nfs-common locales
# 必要なロケールのみ生成する（locales-all の代わり）。
sed -i 's/^# \(ja_JP.UTF-8\)/\1/' /etc/locale.gen
sed -i 's/^# \(en_US.UTF-8\)/\1/' /etc/locale.gen
locale-gen
localectl set-locale LANG=ja_JP.UTF-8 LANGUAGE=ja_JP.UTF-8

# 後続のプロビジョニング中にapt-daily系がロックを掴まないよう無効化する。
systemctl stop apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service || true
systemctl disable apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service || true
systemctl mask apt-daily.timer apt-daily-upgrade.timer apt-daily.service apt-daily-upgrade.service || true

# パッケージ更新でカーネルが更新された場合に備えてリブートする。
# 次のプロビジョナー（40-install-virtualbox-guest-additions.sh）で新カーネル向けに
# Guest Additionsをビルドするために必要。
reboot
