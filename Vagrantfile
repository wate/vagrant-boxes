# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box_check_update = true

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end
  # config.vm.provision "ansible" do |ansible|
  #   ansible.playbook = "overview.yml"
  #   ansible.compatibility_mode = "2.0"
  #   ansible.groups = {
  #     "debian_family" => [
  #       "debian",
  #       "ubuntu"
  #     ],
  #     "redhat_family"  => [
  #       "rocky",
  #       "alma",
  #       "amazon",
  #       "oracle"
  #       ]
  #   }
  # end
  config.vm.define 'debian' do |debian|
    debian.vm.box = 'wate/debian-12'
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
  # config.vm.define 'ubuntu' do |ubuntu|
  #   ubuntu.vm.box = 'bento/ubuntu-22.04'
  #   ubuntu.vm.network :private_network, ip: "192.168.56.102"
  #   ubuntu.vm.network "forwarded_port", guest: 22, host: 2102, id: "ssh"
  #   ubuntu.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_ubuntu'
  #   end
  # end
  # config.vm.define 'rocky' do |rocky|
  #   rocky.vm.box = 'bento/rockylinux-9'
  #   rocky.vm.network :private_network, ip: "192.168.56.103"
  #   rocky.vm.network "forwarded_port", guest: 22, host: 2103, id: "ssh"
  #   rocky.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_rocky'
  #   end
  # end
  # config.vm.define 'alma' do |alma|
  #   alma.vm.box = 'bento/almalinux-9'
  #   alma.vm.network :private_network, ip: "192.168.56.104"
  #   alma.vm.network "forwarded_port", guest: 22, host: 2104, id: "ssh"
  #   alma.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_alma'
  #   end
  # end
  # config.vm.define 'amazon' do |amazon|
  #   amazon.vm.box = 'bento/amazonlinux-2'
  #   amazon.vm.network :private_network, ip: "192.168.56.105"
  #   amazon.vm.network "forwarded_port", guest: 22, host: 2105, id: "ssh"
  #   amazon.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_amazon'
  #   end
  # end
  # config.vm.define 'oracle' do |oracle|
  #   oracle.vm.box = 'bento/oracle-9'
  #   oracle.vm.network :private_network, ip: "192.168.56.106"
  #   oracle.vm.network "forwarded_port", guest: 22, host: 2106, id: "ssh"
  #   oracle.vm.provider 'virtualbox' do |v|
  #     v.name = 'packer_test_oracle'
  #   end
  # end
  # config.trigger.after :provision do |trigger|
  #   trigger.name = "Generate overview"
  #   trigger.run = {
  #     inline: "bash -c 'ansible-cmdb --template overview.tpl .vagrant/facts/ >overview.md'"
  #   }
  # end
  # config.trigger.after :destroy do |trigger|
  #   trigger.name = "Cleanup"
  #   trigger.run = {
  #     inline: "bash -c 'rm -fr .vagrant/facts/'"
  #   }
  # end
end
