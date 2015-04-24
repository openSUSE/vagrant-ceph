# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'
require_relative 'lib/hosts.rb'
require_relative 'lib/provisions.rb'

config_file = 'config.yml'

config = YAML.load_file(config_file)

INSTALLATION = 'ceph-deploy'
CONFIGURATION = 'small'

hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'])

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = "VagrantBox-openSUSE-13.2"

  # Keep admin at the end for provisioning
  nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'} + [ 'admin' ]

  nodes.each do |name|
    vconfig.vm.define name do |node|
      node.vm.synced_folder ".", "/vagrant", disabled: true

      node.vm.hostname = name
      networks = config[CONFIGURATION]['nodes'][name]
      node.vm.network :private_network, ip: networks['management']
      node.vm.network :private_network, ip: networks['public']
      node.vm.network :private_network, ip: networks['cluster']

      node.vm.provider :libvirt do |l|
        l.host = 'localhost'
        l.username = 'root'
        l.id_ssh_key_file = 'id_dsa'
        #l.password = 'root_password'
        l.connect_via_ssh = true
        l.storage_pool_name = 'default'
        l.cpus = 2

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

      hosts.update(node)

      repos = Vagrant::Repos.new(node, config, vconfig.vm.box)
      repos.add

      pkgs = Vagrant::Packages.new(node, config[INSTALLATION][vconfig.vm.box]['packages'])
      pkgs.install

      keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      if (name == 'admin') then
        keys.authorize
      end
    end
  end

end

