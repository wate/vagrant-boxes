# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  # vagrant-cachier
  if Vagrant.has_plugin?('vagrant-cachier')
    config.cache.scope = :box
  end

  config.vm.define 'debian-9' do |stretch|
    stretch.vm.box = 'wate/debian-9'
    stretch.vm.provider 'virtualbox' do |v|
      v.name = 'stretch'
      v.customize ["modifyvm", :id, "--ostype", "Debian_64"]
    end
  end
end
