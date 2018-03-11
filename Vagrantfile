# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end
  config.vm.define 'centos-7' do |centos7|
    centos7.vm.box = 'wate/centos-7'
    centos7.vm.provision "shell", path: "notes/LAMP.sh"
    centos7.vm.provider 'virtualbox' do |v|
      v.name = 'packer_centos7'
      v.customize ["modifyvm", :id, "--ostype", "Redhat_64"]
    end
  end
  config.vm.define 'debian-9' do |stretch|
    stretch.vm.box = 'wate/debian-9'
    stretch.vm.provider 'virtualbox' do |v|
      v.name = 'packer_stretch'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "test.yml"
  end
end
