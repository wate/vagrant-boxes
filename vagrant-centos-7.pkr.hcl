
variable "iso_checksum" {
  type    = string
  default = "b79079ad71cc3c5ceb3561fff348a1b67ee37f71f4cddfec09480d4589c191d6"
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
  default = "2009"
}

variable "version_major" {
  type    = string
  default = "7"
}

variable "version_minor" {
  type    = string
  default = "9"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "virtualbox-iso" "centos7" {
  boot_command            = ["<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/centos-7/ks.cfg<enter><wait>"]
  boot_wait               = "10s"
  disk_size               = 20480
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = "RedHat_64"
  hard_drive_interface    = "sata"
  http_directory          = "http"
  iso_checksum            = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                 = "http://ftp.jaist.ac.jp/pub/Linux/CentOS/${var.version_major}/isos/x86_64/CentOS-${var.version_major}-x86_64-NetInstall-${var.version_build}.iso"
  shutdown_command        = "echo 'vagrant'|sudo -S /sbin/halt -h -p"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "10000s"
  ssh_username            = "vagrant"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "1024"], ["modifyvm", "{{ .Name }}", "--cpus", "1"]]
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = ["source.virtualbox-iso.centos7"]

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    expect_disconnect = true
    inline            = ["yum update -y", "reboot"]
  }

  provisioner "shell" {
    execute_command = "echo 'vagrant' | {{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    pause_before    = "10s"
    scripts = [
      "scripts/centos/pre-base.sh",
      "scripts/01-base.sh",
      "scripts/centos/post-base.sh",
      "scripts/02-vagrant.sh",
      "scripts/03-virtualbox.sh",
      "scripts/90-cleanup.sh",
      "scripts/centos/post-cleanup.sh",
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
