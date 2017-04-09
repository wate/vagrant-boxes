# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
  config.vm.define 'debian-8' do |jessie|
    jessie.vm.box = 'wate/debian-8'
    jessie.vm.provider 'virtualbox' do |v|
      v.name = 'jessie'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.define 'centos-7' do |centos7|
    centos7.vm.box = 'wate/centos-7'
    centos7.vm.provider 'virtualbox' do |v|
      v.name = 'centos-7'
      v.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
    end
  end
end
