# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box_check_update = true

  vm_name = 'packer_test_debian'

  # if Vagrant.has_plugin?('vagrant-vbguest')
  #   config.vbguest.auto_update = false
  # end
  config.vm.define 'debian' do |debian|
    debian.vm.box = 'debian-13'
    debian.vm.network :private_network, ip: "192.168.56.101"
    debian.vm.network "forwarded_port", guest: 22, host: 2101, id: "ssh"
    debian.vm.network "forwarded_port", guest: 80, host: 8081
    debian.vm.provider 'virtualbox' do |v|
      v.name = vm_name
    end
    # VirtualBox管理外の残骸ディレクトリだけを起動前に削除する。
    debian.trigger.before :up do |trigger|
      trigger.info = 'Checking stale VirtualBox VM directory...'
      trigger.run = { path: 'up_before_local.sh' }
    end
    ## テスト用にLEMPスタックを構築する。
    debian.vm.provision "ansible" do |ansible|
      ansible.playbook = "setup_lemp.yml"
      ansible.config_file = "ansible.cfg"
      ansible.compatibility_mode = "2.0"
      ansible.galaxy_role_file = "requirements.yml"
      ansible.galaxy_roles_path = ".vagrant/provisioners/ansible/roles"
    end
    ## 仮想マシンの構築後に、LEMPスタックが正しく構築されているかを確認するためのPlaybookを実行する。
    debian.vm.provision "ansible" do |ansible|
      ansible.playbook = "verify.yml"
      ansible.config_file = "ansible.cfg"
      ansible.compatibility_mode = "2.0"
    end
  end
end
