Packer Template Vagrant box
=========================================

Requirements
---------

- [Vagrant](http://www.vagrantup.com/ "Vagrant")
- [Packer](http://www.packer.io/ "Packer")
- [Oracle VM VirtualBox](https://www.virtualbox.org/ "Oracle VM VirtualBox")

Building Vagrant box
-------------------------

### Debian 13(Trixie)— ISO build (default)

Builds the Vagrant box directly from the official Debian ISO (preseed based).

```
packer build -force debian-13-iso.pkr.hcl
```

The built box is registered locally as `debian-13-iso`.

### Debian 13(Trixie)— bento base (legacy)

Alternative template that fetches the `bento/debian-13` base image and upgrades it.
Kept for reference only; the ISO build above is the default.

```
packer build -force debian-13-bento.pkr.hcl
```
