# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-vbguest
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_reboot  = true
    config.vbguest.auto_update  = true
  end
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end

  config.vm.define 'jessie' do |jessie|
    jessie.vm.box = 'debian-8.0'
    jessie.vm.box_url = 'file://debian-8.0.box'
    jessie.vm.provider 'virtualbox' do |v|
      v.name = 'jessie'
    end
    jessie.vm.provision 'shell', inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive
      export DEBIAN_FRONTEND
      sudo apt-get update
      sudo apt-get -y upgrade
    SHELL
  end
  config.vm.define 'wheezy' do |wheezy|
    wheezy.vm.box = 'debian-7.8'
    wheezy.vm.box_url = 'file://debian-7.8.box'
    wheezy.vm.provider 'virtualbox' do |v|
      v.name = 'wheezy'
    end
    wheezy.vm.provision 'shell', inline: <<-SHELL
      DEBIAN_FRONTEND=noninteractive
      export DEBIAN_FRONTEND
      sudo apt-get update
      sudo apt-get -y upgrade
    SHELL
  end
  config.vm.define 'centos-6.6' do |centos66|
    centos66.vm.box = 'centos-6.6'
    centos66.vm.box_url = 'file://centos-6.6.box'
    centos66.vm.provider 'virtualbox' do |v|
      v.name = 'centos-6.6'
    end
    centos66.vm.provision 'shell', inline: <<-SHELL
      sudo yum update -y
    SHELL
  end
end
