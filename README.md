Packer Template Debian Wheezy Vagrant box 
=========================================

Requiment
---------
- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Debian Wheezy Vagrant box
----------------------------------
1. git clone https://github.com/nogajun/vagrant-boxes.git
2. cd packer/wheezy/
3. packer build wheezy-i386.json (or wheezy-amd64.json)

