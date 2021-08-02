Packer Template Vagrant box
=========================================

Requiment
---------
- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Vagrant box
----------------------------------

### Debian 10(buster)

```
packer build debian-10.pkr.hcl
```

### CentOS 7

```
packer build centos-7.pkr.hcl
```

