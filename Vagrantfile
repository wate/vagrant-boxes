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

  config.vm.define 'debian-8' do |jessie|
    jessie.vm.box = 'wate/debian-8'
    jessie.vm.provider 'virtualbox' do |v|
      v.name = 'jessie'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.define 'debian-7' do |wheezy|
    wheezy.vm.box = 'wate/debian-7'
    wheezy.vm.provider 'virtualbox' do |v|
      v.name = 'wheezy'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.define 'centos-6' do |centos6|
    centos6.vm.box = 'wate/centos-6'
    centos6.vm.provider 'virtualbox' do |v|
      v.name = 'centos-6'
      v.customize ["modifyvm", :id, "--ostype", "RedHat_64"]
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
