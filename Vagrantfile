# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'

### Not working within Vagrant ###
# require 'archive/tar/minitar'

require_relative 'lib/hosts.rb'
require_relative 'lib/provisions.rb'

config_file = 'config.yml'
config = YAML.load_file(config_file)

# Check that the user has an ssh key
Vagrant::Hosts::check_for_ssh_keys

# Set BOX to one of 'VagrantBox-openSUSE-13.2', 'VagrantBox-Tumbleweed', 'VagrantBox-SLE12'
BOX = 'VagrantBox-openSUSE-13.2'

# Set INSTALLATION to one of 'ceph-deploy', 'vsm'
INSTALLATION = 'vsm'

# Set CONFIGURATION to one of 'default', 'small' or 'economical'
CONFIGURATION = 'small'

# Set PREFIX for additional sets of VMs in libvirt from a separate directory
# (e.g. vagrant-ceph is default, vsm is another git clone with PREFIX='v'
# hostnames will be 'vadmin', 'vmon1', etc.  Both sets use same address range
# and cannot run simultaneously.  Each set will consume disk space. )
PREFIX = ''

# Generates a hosts file
hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'])

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = BOX

  # Keep admin at the end for provisioning
  nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'} + 
    [ 'admin' ]

  nodes.each do |name|
    vm_name = PREFIX + name
    vconfig.vm.define vm_name do |node|
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
        l.connect_via_ssh = true

        # Libvirt pool and prefix value
        l.storage_pool_name = 'default'
        #l.default_prefix = ''

        # Memory defaults to 512M, allow specific configurations 
        unless (config[CONFIGURATION]['memory'].nil?) then
          unless (config[CONFIGURATION]['memory'][name].nil?) then
            l.memory = config[CONFIGURATION]['memory'][name]
          end
        end

        # Set cpus to 2, allow specific configurations
        unless (config[CONFIGURATION]['cpu'].nil?) then
          if (config[CONFIGURATION]['cpu'][name].nil?) then
            l.cpus = 2
          else
            l.cpus = config[CONFIGURATION]['cpu'][name]
          end
        end

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

      # Allow passwordless root access between nodes
      keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      if (name == 'admin') then
        keys.authorize
      end

      # Add missing repos
      repos = Vagrant::Repos.new(node, config[BOX][INSTALLATION]['repos'])
      repos.add

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, name, 
                                   config[BOX][INSTALLATION]['packages'])
      pkgs.install

      # Copy custom files 
      files = Vagrant::Files.new(node, INSTALLATION, name, 
                                 config[BOX][INSTALLATION]['files'])
      files.copy

      # Run commands
      commands = Vagrant::Commands.new(node, name, 
                                       config[BOX][INSTALLATION]['commands'])
      commands.run
    end
  end
   
end

