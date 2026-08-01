Packer Template Vagrant box
=========================================

Requirements
---------

- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

Building Vagrant box
-------------------------

### Debian 13(Trixie)

```
packer build -force debian-13.pkr.hcl
```
