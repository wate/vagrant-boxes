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

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/bento.sh",
      "provision/90-cleanup.sh",
      "provision/Debian/post-cleanup.sh",
      "provision/Debian/pre-minimize.sh",
      "provision/99-minimize.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      # provider_override   = "virtualbox"
      # output = "debian${var.version_major}.box"
    }
    # post-processor "vagrant-registry" {
    #   client_id           = "${var.hcp_client_id}"
    #   client_secret       = "${var.hcp_client_secret}"
    #   ## https://portal.cloud.hashicorp.com/vagrant/discover/wate/
    #   box_tag             = "wate/debian-${var.version_major}"
    #   version             = "${var.version_major}.${var.version_minor}.${var.version_patch}"
    #   version_description = "Debian ${var.version_major}.${var.version_minor} (64bit)日本語環境用"
    # }
  }
}
