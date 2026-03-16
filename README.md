Packer Template Vagrant box
=========================================

Requiment
---------

- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Vagrant box
----------------------------------

### Debian 13(trixie)

```
packer build -force debian-13.pkr.hcl
```
