# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box_check_update = true

  # if Vagrant.has_plugin?('vagrant-vbguest')
  #   config.vbguest.auto_update = false
  # end
  config.vm.define 'debian' do |debian|
    debian.vm.box = 'bento/debian-13'
    debian.vm.network :private_network, ip: "192.168.56.101"
    debian.vm.network "forwarded_port", guest: 22, host: 2101, id: "ssh"
    debian.vm.network "forwarded_port", guest: 80, host: 8081
    debian.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_debian'
    end
    debian.vm.provision "ansible" do |ansible|
      ansible.playbook = "test_setup.yml"
      ansible.config_file = "ansible.cfg"
      ansible.compatibility_mode = "2.0"
      ansible.galaxy_role_file = "requirements.yml"
      ansible.galaxy_roles_path = ".vagrant/provisioners/ansible/roles"
    end
  end
end
