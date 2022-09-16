# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = false
  end
  config.vm.provision "ansible" do |ansible|
    ansible.playbook = "playbook.yml"
    ansible.groups = {
      "debian_family" => [
        "debian",
        "ubuntu"
      ],
      "redhat_family"  => [
        "rockylinux",
        "almalinux",
        "amazonlinux",
        "oracle"
        ]
    }
  end
  config.vm.define 'debian' do |debian|
    debian.vm.box = 'wate/debian-11'
    debian.vm.network :private_network, ip: "192.168.56.101"
    debian.vm.network "forwarded_port", guest: 22, host: 2101, id: "ssh"
    debian.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_debian'
    end
  end
  config.vm.define 'ubuntu' do |ubuntu|
    ubuntu.vm.box = 'bento/ubuntu-22.04'
    ubuntu.vm.network :private_network, ip: "192.168.56.102"
    ubuntu.vm.network "forwarded_port", guest: 22, host: 2102, id: "ssh"
    ubuntu.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_ubuntu'
    end
  end
  config.vm.define 'rockylinux' do |rockylinux|
    rockylinux.vm.box = 'bento/rockylinux-9'
    rockylinux.vm.network :private_network, ip: "192.168.56.103"
    rockylinux.vm.network "forwarded_port", guest: 22, host: 2103, id: "ssh"
    rockylinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_rockylinux'
    end
  end
  config.vm.define 'almalinux' do |almalinux|
    almalinux.vm.box = 'bento/almalinux-9'
    almalinux.vm.network :private_network, ip: "192.168.56.104"
    almalinux.vm.network "forwarded_port", guest: 22, host: 2104, id: "ssh"
    almalinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_almalinux'
    end
  end
  config.vm.define 'amazonlinux' do |amazonlinux|
    amazonlinux.vm.box = 'bento/amazonlinux-2'
    amazonlinux.vm.network :private_network, ip: "192.168.56.105"
    amazonlinux.vm.network "forwarded_port", guest: 22, host: 2105, id: "ssh"
    amazonlinux.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_amazonlinux'
    end
  end
  config.vm.define 'oracle' do |oracle|
    oracle.vm.box = 'bento/oracle-9'
    oracle.vm.network :private_network, ip: "192.168.56.106"
    oracle.vm.network "forwarded_port", guest: 22, host: 2106, id: "ssh"
    oracle.vm.provider 'virtualbox' do |v|
      v.name = 'packer_test_oracle'
    end
  end
end
