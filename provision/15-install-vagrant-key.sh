#!/bin/sh -eux

## Vagrant接続用の公開鍵を登録する。
## Vagrantはデフォルトでインセキュア鍵(秘密鍵)を使うため、対応する公開鍵を
## vagrant ユーザーの ~/.ssh/authorized_keys に配置する必要がある。
## 出典: bento の packer_templates/scripts/_common/vagrant.sh と同等の処理

HOME_DIR=/home/vagrant
PUBKEY_URL="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"

mkdir -p "${HOME_DIR}/.ssh"
if command -v curl > /dev/null 2>&1; then
  curl --insecure --location "${PUBKEY_URL}" > "${HOME_DIR}/.ssh/authorized_keys"
elif command -v wget > /dev/null 2>&1; then
  wget --no-check-certificate "${PUBKEY_URL}" -O "${HOME_DIR}/.ssh/authorized_keys"
else
  echo "Cannot download vagrant public key (no curl/wget)" >&2
  exit 1
fi

chown -R vagrant "${HOME_DIR}/.ssh"
chmod -R go-rwsx "${HOME_DIR}/.ssh"
chmod 600 "${HOME_DIR}/.ssh/authorized_keys"

# 登録できたことを確認する。
grep -q "vagrant" "${HOME_DIR}/.ssh/authorized_keys"
echo "15-install-vagrant-key.sh completed"