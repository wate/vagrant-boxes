Packer Template Debian Vagrant box
=========================================

Requiment
---------
- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

building Debian Vagrant box
----------------------------------

### Debian 9

```
packer build debian-9.json
```

### CentOS 7

```
packer build centos-7.json
```


Test
----------------------------------

```
ansible-galaxy install -p ./roles -r requirements.yml --force
vagrant up
```
