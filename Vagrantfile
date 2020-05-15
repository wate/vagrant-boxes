# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end
  config.vm.define 'centos-7' do |centos7|
    centos7.vm.box = 'wate/centos-7'
    centos7.vm.network :private_network, ip: "192.168.33.101"
    centos7.vm.network "forwarded_port", guest: 22, host: 2220, id: "ssh"
    centos7.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_centos7'
      v.customize ["modifyvm", :id, "--ostype", "Redhat_64"]
    end
  end
  config.vm.define 'centos-8' do |centos8|
    centos8.vm.box = 'wate/centos-8'
    centos8.vm.network :private_network, ip: "192.168.33.102"
    centos8.vm.network "forwarded_port", guest: 22, host: 2221, id: "ssh"
    centos8.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_centos8'
      v.customize ["modifyvm", :id, "--ostype", "Redhat_64"]
    end
  end
  config.vm.define 'debian-9' do |debian9|
    debian9.vm.box = 'wate/debian-9'
    debian9.vm.network :private_network, ip: "192.168.33.103"
    debian9.vm.network "forwarded_port", guest: 22, host: 2222, id: "ssh"
    debian9.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_debian9'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.define 'debian-10' do |debian10|
    debian10.vm.box = 'wate/debian-10'
    debian10.vm.network :private_network, ip: "192.168.33.104"
    debian10.vm.network "forwarded_port", guest: 22, host: 2223, id: "ssh"
    debian10.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_debian10'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  # config.vm.define 'amazon-linux' do |amazonlinux|
  #   amazonlinux.vm.box = 'bento/amazonlinux-2'
  #   amazonlinux.vm.network :private_network, ip: "192.168.33.105"
  #   amazonlinux.vm.network "forwarded_port", guest: 22, host: 2224, id: "ssh"
  #   amazonlinux.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_amazon_linux'
  #   end
  # end
  # config.vm.define 'kusanagi' do |kusanagi|
  #   kusanagi.vm.box = 'primestrategy/kusanagi'
  #   kusanagi.vm.network :private_network, ip: "192.168.33.106"
  #   kusanagi.vm.network "forwarded_port", guest: 22, host: 2225, id: "ssh"
  #   kusanagi.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_kusanagi'
  #   end
  # end
end
