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
variable "hcp_client_id" {
  type    = string
  default = "${env("HCP_CLIENT_ID")}"
}

variable "hcp_client_secret" {
  type    = string
  default = "${env("HCP_CLIENT_SECRET")}"
}
variable "arch" {
  type    = string
  default = "arm64"
}

variable "version_major" {
  type    = string
  default = "13"
}

variable "version_minor" {
  type    = string
  default = "3"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "vagrant" "trixie" {
  communicator = "ssh"
  ## https://portal.cloud.hashicorp.com/vagrant/discover/bento/
  source_path = "bento/debian-13"
  provider = "virtualbox"
  add_force = true
}
build {
  sources = ["source.vagrant.trixie"]

  # パッケージ最新化（カーネル更新が発生する可能性があるためexpect_disconnect: trueで切断を許容）
  provisioner "shell" {
    execute_command   = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/bento.sh",
    ]
  }

  # リブート後に新カーネルでGuest Additionsをインストールしてからクリーンアップを実行
  provisioner "shell" {
    execute_command   = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/03-virtualbox.sh",
      "provision/90-cleanup.sh",
      "provision/Debian/post-cleanup.sh",
      "provision/Debian/pre-minimize.sh",
      "provision/99-minimize.sh"
    ]
  }

  # vagrant-registryへの公開時のみ以下を有効化する。
  # macOSのgtarが生成する拡張属性（LIBARCHIVE.xattr）により
  # artificeがmetadata.jsonを認識できない問題があり未解決。
  # post-processors {
  #   post-processor "artifice" {
  #     files = ["output-trixie/package.box"]
  #   }
  #   post-processor "vagrant-registry" {
  #     client_id           = "${var.hcp_client_id}"
  #     client_secret       = "${var.hcp_client_secret}"
  #     ## https://portal.cloud.hashicorp.com/vagrant/discover/wate/
  #     box_tag             = "wate/debian-${var.version_major}"
  #     version             = "${var.version_major}.${var.version_minor}.${var.version_patch}"
  #     version_description = "Debian ${var.version_major}.${var.version_minor} (64bit)日本語環境用"
  #   }
  # }
}
