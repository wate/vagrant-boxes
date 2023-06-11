variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANTCLOUD_TOKEN")}"
}

variable "version_major" {
  type    = string
  default = "11"
}

variable "version_minor" {
  type    = string
  default = "7"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "virtualbox-iso" "bullseye" {
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
  guest_os_type        = "Debian11_64"
  http_directory       = "http"
  iso_checksum         = "file:https://cdimage.debian.org/mirror/cdimage/archive/${var.version_major}.${var.version_minor}.${var.version_patch}/amd64/iso-cd/SHA256SUMS"
  iso_url              = "https://cdimage.debian.org/mirror/cdimage/archive/${var.version_major}.${var.version_minor}.${var.version_patch}/amd64/iso-cd/debian-${var.version_major}.${var.version_minor}.${var.version_patch}-amd64-netinst.iso"
  shutdown_command     = "echo 'vagrant' | sudo -S /sbin/shutdown -hP now"
  ssh_password         = "vagrant"
  ssh_port             = 22
  ssh_timeout          = "20m"
  ssh_username         = "vagrant"
  vboxmanage = [
    ["modifyvm", "{{ .Name }}", "--cpus", "1"],
    ["modifyvm", "{{ .Name }}", "--memory", "1024"],
    // @see https://github.com/hashicorp/packer/issues/12118
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"]
  ]
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = ["source.virtualbox-iso.bullseye"]

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
      "provision/debian/pre-virtualbox.sh",
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
    post-processor "vagrant-cloud" {
      access_token        = "${var.vagrantcloud_token}"
      box_tag             = "wate/debian-${var.version_major}"
      version             = "${var.version_major}.${var.version_minor}.${var.version_patch}"
      version_description = "Debian ${var.version_major}.${var.version_minor} (64bit)日本語環境用"
    }
  }
}
