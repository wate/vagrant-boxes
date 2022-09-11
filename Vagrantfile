# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
  end
  config.vm.define 'bullseye' do |bullseye|
    bullseye.vm.box = 'wate/debian-11'
    bullseye.vm.network :private_network, ip: "192.168.56.101"
    bullseye.vm.network "forwarded_port", guest: 22, host: 2101, id: "ssh"
    bullseye.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_bullseye'
    end
  end
  config.vm.define 'buster' do |buster|
    buster.vm.box = 'wate/debian-10'
    buster.vm.network :private_network, ip: "192.168.56.102"
    buster.vm.network "forwarded_port", guest: 22, host: 2102, id: "ssh"
    buster.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_buster'
    end
  end
  config.vm.define 'jammy' do |jammy|
    jammy.vm.box = 'bento/ubuntu-22.04'
    jammy.vm.network :private_network, ip: "192.168.56.103"
    jammy.vm.network "forwarded_port", guest: 22, host: 2103, id: "ssh"
    jammy.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_jammy'
    end
  end
  config.vm.define 'focal' do |focal|
    focal.vm.box = 'bento/ubuntu-20.04'
    focal.vm.network :private_network, ip: "192.168.56.104"
    focal.vm.network "forwarded_port", guest: 22, host: 2104, id: "ssh"
    focal.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_focal'
    end
  end
  config.vm.define 'rockylinux' do |rockylinux|
    rockylinux.vm.box = 'bento/rockylinux-9'
    rockylinux.vm.network :private_network, ip: "192.168.56.105"
    rockylinux.vm.network "forwarded_port", guest: 22, host: 2105, id: "ssh"
    rockylinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_rockylinux'
    end
  end
  config.vm.define 'almalinux' do |almalinux|
    almalinux.vm.box = 'bento/almalinux-9'
    almalinux.vm.network :private_network, ip: "192.168.56.106"
    almalinux.vm.network "forwarded_port", guest: 22, host: 2106, id: "ssh"
    almalinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_almalinux'
    end
  end
  config.vm.define 'amazonlinux' do |amazonlinux|
    amazonlinux.vm.box = 'bento/amazonlinux-2'
    amazonlinux.vm.network :private_network, ip: "192.168.56.107"
    amazonlinux.vm.network "forwarded_port", guest: 22, host: 2107, id: "ssh"
    amazonlinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_amazonlinux'
    end
  end
  config.vm.define 'oracle' do |oracle|
    oracle.vm.box = 'bento/oracle-9'
    oracle.vm.network :private_network, ip: "192.168.56.108"
    oracle.vm.network "forwarded_port", guest: 22, host: 2108, id: "ssh"
    oracle.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_oracle'
    end
  end
end
