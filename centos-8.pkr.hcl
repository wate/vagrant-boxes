
variable "iso_checksum" {
  type    = string
  default = "0394ecfa994db75efc1413207d2e5ac67af4f6685b3b896e2837c682221fd6b2"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANTCLOUD_TOKEN")}"
}

variable "version_build" {
  type    = string
  default = "2105"
}

variable "version_major" {
  type    = string
  default = "8"
}

variable "version_minor" {
  type    = string
  default = "4"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "virtualbox-iso" "centos8" {
  boot_command            = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-8/ks.cfg<enter><wait>"]
  boot_wait               = "10s"
  disk_size               = 20480
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = "RedHat_64"
  hard_drive_interface    = "sata"
  http_directory          = "http"
  iso_checksum            = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                 = "http://ftp.jaist.ac.jp/pub/Linux/CentOS/${var.version_major}/isos/x86_64/CentOS-${var.version_major}.${var.version_minor}.${var.version_build}-x86_64-dvd1.iso"
  shutdown_command        = "echo 'vagrant'|sudo -S /sbin/halt -h -p"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "1024"], ["modifyvm", "{{ .Name }}", "--cpus", "1"]]
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = ["source.virtualbox-iso.centos8"]

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    inline            = ["yum update -y", "reboot"]
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    pause_before    = "10s"
    scripts = [
      "scripts/debian/pre-base.sh",
      "scripts/01-base.sh",
      "scripts/debian/post-base.sh",
      "scripts/02-vagrant.sh",
      "scripts/debian/pre-virtualbox.sh",
      "scripts/03-virtualbox.sh",
      "scripts/90-cleanup.sh",
      "scripts/debian/pre-minimize.sh",
      "scripts/99-minimize.sh"
    ]
  }

  post-processors {
    post-processor "vagrant" {
      output = "centos-${var.version_major}.box"
    }
    post-processor "vagrant-cloud" {
      access_token        = "${var.vagrantcloud_token}"
      box_tag             = "wate/centos-${var.version_major}"
      no_release          = false
      version             = "${var.version_major}.${var.version_minor}.${var.version_patch}"
      version_description = "CentOS ${var.version_major}.${var.version_minor} Build ${var.version_build} (64bit)日本語環境用"
    }
  }
}
