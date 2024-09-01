Packer Template Vagrant box
=========================================

Requiment
---------

- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Vagrant box
----------------------------------

### Debian 12(bookworm)

```
packer build debian-12.pkr.hcl
```

### Debian 11(bullseye)

```
packer build debian-11.pkr.hcl
```
