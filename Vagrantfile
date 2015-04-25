# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'
require_relative 'lib/hosts.rb'
require_relative 'lib/provisions.rb'

config_file = 'config.yml'
config = YAML.load_file(config_file)

# Set INSTALLATION to one of 'ceph-deploy', 'vsm'
INSTALLATION = 'ceph-deploy'

# Set CONFIGURATION to one of 'default', 'small' or 'economical'
CONFIGURATION = 'default'

# Generates a hosts file
hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'])

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = "VagrantBox-openSUSE-13.2"

  # Keep admin at the end for provisioning
  nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'} + [ 'admin' ]

  nodes.each do |name|
    vconfig.vm.define name do |node|
      # Disable default vagrant folder
      # Note: comment out the following line to have a shared folder but you
      # will be prompted for the root password of the host machine to configure
      # your NFS server
      node.vm.synced_folder ".", "/vagrant", disabled: true

      node.vm.hostname = name

      # Ceph has three networks
      networks = config[CONFIGURATION]['nodes'][name]
      node.vm.network :private_network, ip: networks['management']
      node.vm.network :private_network, ip: networks['public']
      node.vm.network :private_network, ip: networks['cluster']

      node.vm.provider :libvirt do |l|
        l.host = 'localhost'
        l.username = 'root'

        # Use DSA key if available, otherwise, defaults to RSA
        l.id_ssh_key_file = 'id_dsa' if File.exists?("#{ENV['HOME']}/.ssh/id_dsa")
        #l.password = 'root_password'
        l.connect_via_ssh = true
        l.storage_pool_name = 'default'
        l.cpus = 2

        # Raw disk images to simulate additional drives on data nodes
        unless (config[CONFIGURATION]['disks'].nil?) then
          unless (config[CONFIGURATION]['disks'][name].nil?) then
            disks = config[CONFIGURATION]['disks'][name]
            unless (disks['hds'].nil?) then
              (1..disks['hds']).each do |d|
                l.storage :file, size: '1G', type: 'raw'
              end
            end
            unless (disks['ssds'].nil?) then
              (1..disks['ssds']).each do |d|
                l.storage :file, size: '1G', type: 'raw'
              end
            end
          end
        end

      end

      # Update /etc/hosts on each node
      hosts.update(node)

      # Add missing repos
      repos = Vagrant::Repos.new(node, config, vconfig.vm.box)
      repos.add

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, config[INSTALLATION][vconfig.vm.box]['packages'])
      pkgs.install

      # Allow passwordless root access between nodes
      keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      if (name == 'admin') then
        keys.authorize
      end
    end
  end

end

