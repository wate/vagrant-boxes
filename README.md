Packer Template Debian Vagrant box
=========================================

Requiment
---------
- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Debian Vagrant box
----------------------------------

### Debian 7.9

```
packer build debian-7.json
```

### Debian 8.4

```
packer build debian-8.json
```

### CentOS 6.8

```
packer build centos-6.json
```

### CentOS 7.2

```
packer build centos-7.json
```
