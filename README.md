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

Builds the Vagrant box directly from the official Debian ISO (preseed based).

```
packer build -force debian-13.pkr.hcl
```

The built box is registered locally as `debian-13`.
