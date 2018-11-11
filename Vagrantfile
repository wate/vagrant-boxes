# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
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
  config.vm.define 'debian-9' do |debian9|
    debian9.vm.box = 'wate/debian-9'
    debian9.vm.network :private_network, ip: "192.168.33.102"
    debian9.vm.network "forwarded_port", guest: 22, host: 2221, id: "ssh"
    debian9.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_debian9'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
  config.vm.provision "ansible" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.config_file = "ansible.cfg"
    ansible.galaxy_roles_path = './roles'
    ansible.playbook = "playbook.yml"
    ansible.become = false
  end
end
