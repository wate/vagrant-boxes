variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANTCLOUD_TOKEN")}"
}

variable "version_major" {
  type    = string
  default = "12"
}

variable "version_minor" {
  type    = string
  default = "0"
}

variable "version_patch" {
  type    = string
  default = "0.rc.3"
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
  iso_checksum         = "file:https://cdimage.debian.org/cdimage/bookworm_di_rc3/amd64/iso-cd/SHA512SUMS"
  iso_url              = "https://cdimage.debian.org/cdimage/bookworm_di_rc3/amd64/iso-cd/debian-bookworm-DI-rc3-amd64-netinst.iso"
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
  sources = ["source.virtualbox-iso.bookworm"]

  provisioner "shell" {
    environment_vars = [
      "HOME_DIR=/home/vagrant"
    ]
    execute_command   = "echo 'vagrant'|sudo -S bash '{{ .Path }}'"
    expect_disconnect = true
    scripts = [
      "scripts/debian/pre-base.sh",
      "scripts/01-base.sh",
      "scripts/debian/post-base.sh",
      "scripts/02-vagrant.sh",
      "scripts/debian/pre-virtualbox.sh",
      "scripts/03-virtualbox.sh",
      "scripts/90-cleanup.sh",
      "scripts/debian/post-cleanup.sh",
      "scripts/99-minimize.sh"
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