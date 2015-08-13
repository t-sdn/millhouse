# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/vivid64"
  config.vm.network "forwarded_port", guest: 10080, host: 10080
  config.vm.network "forwarded_port", guest: 18181, host: 18181
  config.vm.network "forwarded_port", guest: 22, host: 10022

  config.vm.provider "virtualbox" do |vbox|
    vbox.memory = 8192
    vbox.cpus = 4
  end

  config.vm.provision "shell", path: "./install.sh"
end
