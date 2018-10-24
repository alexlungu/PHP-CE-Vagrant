# -*- mode: ruby -*-
# vi: set ft=ruby :
# (c) 2018 VesselsValue Ltd

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
Vagrant::DEFAULT_SERVER_URL.replace('https://vagrantcloud.com')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    # Every Vagrant virtual environment requires a box to build from.
    config.vm.box = "centos/7"
    config.vm.hostname = "local.vvdev"

    config.vm.provider "virtualbox" do |vb,override|
        vb.memory = 2048
        vb.cpus = 2

        override.vm.network "forwarded_port", :guest => 80, :host => 8080
        override.vm.network "forwarded_port", :guest => 443, :host => 8443
        override.vm.network "forwarded_port", :guest => 3306, :host => 3306
        override.vm.network "forwarded_port", :guest => 9200, :host => 9200

        vb.customize [
            "modifyvm", :id,
            "--cableconnected1", "on"
        ]
    end

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.synced_folder '.', '/opt'

  # Provisioning
  config.vm.provision :shell, path: "bootstrap.sh"
end