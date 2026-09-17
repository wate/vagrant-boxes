# Debian 13 (trixie) arm64 の Vagrant box を公式ISOから直接ビルドするテンプレート。
# 既存 debian-13.pkr.hcl (bentoイメージ取得ベース) は変更せず、こちらは ISO ビルド専用。
# bento プロジェクトの arm64 + VirtualBox 実績値(guest_os_type / boot_command / vboxmanage)を流用している。

packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source  = "github.com/hashicorp/vagrant"
    }
    virtualbox = {
      version = "~> 1"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

variable "version_codename" {
  type    = string
  default = "trixie"
}

variable "version_major" {
  type    = string
  default = "13"
}

variable "version_minor" {
  type    = string
  default = "7"
}

variable "version_patch" {
  type    = string
  default = "0"
}

variable "arch" {
  type    = string
  # default = "amd64"
  default = "arm64"
}

source "virtualbox-iso" "trixie" {
  vm_name              = "packer-iso-debian"
  guest_os_type        = "Debian13_arm64"
  iso_url              = "https://cdimage.debian.org/debian-cd/${var.version_major}.${var.version_minor}.${var.version_patch}/${var.arch}/iso-cd/debian-${var.version_major}.${var.version_minor}.${var.version_patch}-${var.arch}-netinst.iso"
  iso_checksum         = "file:https://cdimage.debian.org/debian-cd/${var.version_major}.${var.version_minor}.${var.version_patch}/${var.arch}/iso-cd/SHA256SUMS"
  communicator         = "ssh"
  ssh_username         = "vagrant"
  ssh_password         = "vagrant"
  ssh_timeout          = "15m"
  # https://github.com/chef/bento/blob/main/os_pkrvars/debian/debian-13-aarch64.pkrvars.hcl#L10
  boot_command         = ["<wait>e<wait><down><down><down><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><right><wait>install <wait> preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>debian-installer=en_US.UTF-8 <wait>auto <wait>locale=en_US.UTF-8 <wait>kbd-chooser/method=us <wait>keyboard-configuration/xkb-keymap=us <wait>netcfg/get_hostname={{ .Name }} <wait>netcfg/get_domain=vagrantup.com <wait>fb=false <wait>debconf/frontend=noninteractive <wait>console-setup/ask_detect=false <wait>console-keymaps-at/keymap=us <wait>grub-installer/bootdev=default <wait><f10><wait>"]
  http_directory       = "http/debian-13"
  nic_type             = "virtio"
  hard_drive_interface = "virtio"
  iso_interface        = "virtio"
  guest_additions_mode = "disable"
  cpus                 = 2
  memory               = 4096
  shutdown_command     = "echo 'vagrant' | sudo -S shutdown -P now"
  vboxmanage = [
    # ARMホスト向け最適化(bento の aarch64 Linux 実績値)
    # 出典: https://github.com/chef/bento/blob/main/packer_templates/pkr-sources.pkr.hcl#L151-L193
    # このうち「非Windows × aarch64」分岐(L174-L192)の設定を流用している。
    ["modifyvm", "{{.Name}}", "--chipset", "armv8virtual"],
    ["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
    ["modifyvm", "{{.Name}}", "--cableconnected1", "on"],
    ["modifyvm", "{{.Name}}", "--usb-xhci", "on"],
    ["modifyvm", "{{.Name}}", "--graphicscontroller", "qemuramfb"],
    ["modifyvm", "{{.Name}}", "--mouse", "usb"],
    ["modifyvm", "{{.Name}}", "--keyboard", "usb"],
    ["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
  ]
}

build {
  sources = ["source.virtualbox-iso.trixie"]

  # パッケージ最新化（カーネル更新が発生する可能性があるためexpect_disconnect: trueで切断を許容）
  provisioner "shell" {
    execute_command   = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/10-base-setup-and-upgrade.sh",
      "provision/15-install-vagrant-key.sh",
    ]
  }

  # クリーンアップ後にGuest Additionsを最終実行し、最終イメージに
  # vboxsfモジュールを確実に残す。
  provisioner "shell" {
    execute_command   = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/20-remove-vbox-isos.sh",
      "provision/30-package-prune.sh",
      "provision/40-install-virtualbox-guest-additions.sh",
      "provision/50-zero-free-space.sh"
    ]
  }

  # vagrant box 形式にパッケージングする。
  post-processor "vagrant" {
    output = "debian-${var.version_codename}/${var.version_major}.${var.version_minor}/package.box"
  }

  # ビルド後にローカルのvagrant boxとして登録する。
  # 同名のboxが既に存在する場合は上書きする。
  post-processor "shell-local" {
    inline = [
      "vagrant box add --force debian-${var.version_major} debian-${var.version_codename}/${var.version_major}.${var.version_minor}/package.box",
      "printf 'version_codename: \"%s\"\\nversion_major: \"%s\"\\nversion_minor: \"%s\"\\nversion_patch: \"%s\"\\narch: \"%s\"\\n' '${var.version_codename}' '${var.version_major}' '${var.version_minor}' '${var.version_patch}' '${var.arch}' > metadata.yml",
      "rm -rf debian-${var.version_codename}/${var.version_major}.${var.version_minor}"
    ]
  }
}
