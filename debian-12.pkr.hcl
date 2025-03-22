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
variable "version_major" {
  type    = string
  default = "12"
}

variable "version_minor" {
  type    = string
  default = "10"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "virtualbox-iso" "bookworm" {
  boot_command = [
    "<esc><wait>",
    "auto <wait>",
    "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-${var.version_major}/preseed.cfg <wait>",
    "console-setup/ask_detect=false <wait>",
    "frontend=noninteractive <wait>",
    "<enter><wait>"
  ]
  boot_wait            = "5s"
  disk_size            = 20480
  guest_additions_path = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type        = "Debian_64"
  http_directory       = "http"
  iso_checksum         = "file:http://cdimage.debian.org/debian-cd/${var.version_major}.${var.version_minor}.${var.version_patch}/amd64/iso-cd/SHA512SUMS"
  iso_url              = "http://cdimage.debian.org/debian-cd/${var.version_major}.${var.version_minor}.${var.version_patch}/amd64/iso-cd/debian-${var.version_major}.${var.version_minor}.${var.version_patch}-amd64-netinst.iso"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/shutdown -hP now"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "20m"
  ssh_username         = "vagrant"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--cpus", "2"],
    ["modifyvm", "{{ .Name }}", "--memory", "2048"],
    // @see https://github.com/hashicorp/packer/issues/12118
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
  ]
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = ["source.virtualbox-iso.bookworm"]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "echo 'vagrant'|sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "provision/Debian/pre-base.sh",
      "provision/01-base.sh",
      "provision/Debian/post-base.sh",
      "provision/02-vagrant.sh",
      "provision/Debian/pre-virtualbox.sh",
      "provision/03-virtualbox.sh",
      "provision/90-cleanup.sh",
      "provision/Debian/post-cleanup.sh",
      "provision/99-minimize.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      output = "debian${var.version_major}.box"
    }
    post-processor "vagrant-registry" {
      client_id           = "${var.hcp_client_id}"
      client_secret       = "${var.hcp_client_secret}"
      ## https://portal.cloud.hashicorp.com/vagrant/discover/wate/
      box_tag             = "wate/debian-${var.version_major}"
      version             = "${var.version_major}.${var.version_minor}.${var.version_patch}"
      version_description = "Debian ${var.version_major}.${var.version_minor} (64bit)日本語環境用"
    }
  }
}
