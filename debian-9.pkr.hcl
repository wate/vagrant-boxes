
variable "iso_checksum" {
  type    = string
  default = "71c7e9eb292acc880f84605b1ca2b997f25737fe0a43fc9586f61d35cd2eb43b"
}

variable "iso_checksum_type" {
  type    = string
  default = "sha256"
}

variable "vagrantcloud_token" {
  type    = string
  default = "${env("VAGRANTCLOUD_TOKEN")}"
}

variable "version_major" {
  type    = string
  default = "9"
}

variable "version_minor" {
  type    = string
  default = "13"
}

variable "version_patch" {
  type    = string
  default = "0"
}

source "virtualbox-iso" "stretch" {
  boot_command            = ["<esc><wait>", "auto <wait>", "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/debian-9/preseed.cfg <wait>", "frontend=noninteractive <wait>", "<enter><wait>"]
  boot_wait               = "5s"
  disk_size               = 20480
  guest_additions_path    = "VBoxGuestAdditions_{{ .Version }}.iso"
  guest_os_type           = "Debian_64"
  http_directory          = "http"
  iso_checksum            = "${var.iso_checksum_type}:${var.iso_checksum}"
  iso_url                 = "https://cdimage.debian.org/mirror/cdimage/archive/${var.version_major}.${var.version_minor}.${var.version_patch}/amd64/iso-cd/debian-${var.version_major}.${var.version_minor}.${var.version_patch}-amd64-netinst.iso"
  shutdown_command        = "echo 'vagrant' | sudo -S /sbin/shutdown -hP now"
  ssh_password            = "vagrant"
  ssh_port                = 22
  ssh_timeout             = "20m"
  ssh_username            = "vagrant"
  vboxmanage              = [["modifyvm", "{{ .Name }}", "--memory", "1024"], ["modifyvm", "{{ .Name }}", "--cpus", "1"]]
  virtualbox_version_file = ".vbox_version"
}

build {
  sources = ["source.virtualbox-iso.stretch"]

  provisioner "shell" {
    execute_command = "echo 'vagrant'|sudo -S bash '{{ .Path }}'"
    scripts         = ["scripts/debian/pre-base.sh", "scripts/01-base.sh", "scripts/debian/post-base.sh", "scripts/02-vagrant.sh", "scripts/debian/pre-virtualbox.sh", "scripts/03-virtualbox.sh", "scripts/90-cleanup.sh", "scripts/debian/post-cleanup.sh", "scripts/99-minimize.sh"]
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
