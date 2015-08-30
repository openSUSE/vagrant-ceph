# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'

### Not working within Vagrant ###
# require 'archive/tar/minitar'

require_relative 'lib/settings.rb'
require_relative 'lib/hosts.rb'
require_relative 'lib/provisions.rb'

config_file = 'config.yml'
config = YAML.load_file(config_file)

# Check that the user has an ssh key
Vagrant::Hosts::check_for_ssh_keys

# Set BOX to one of 'openSUSE-13.2', 'Tumbleweed', 'SLE-12'
BOX = 'SLE-12'

# Set INSTALLATION to one of 'ceph-deploy', 'vsm'
INSTALLATION = 'salt'

# Set CONFIGURATION to one of 'default', 'small', 'iscsi' or 'economical'
CONFIGURATION = 'iscsi'

raise "Box #{BOX} missing from config.yml" unless config[BOX]
raise "Installation #{INSTALLATION} missing for box #{BOX} from config.yml" unless config[BOX][INSTALLATION]
raise "Configuration #{CONFIGURATION} missing from config.yml" unless config[CONFIGURATION]

# Set PREFIX for additional sets of VMs in libvirt from a separate directory
# (e.g. vagrant-ceph is default, vsm is another git clone with PREFIX='v'
# hostnames will be 'vadmin', 'vmon1', etc.  Both sets use same address range
# and cannot run simultaneously.  Each set will consume disk space. )
PREFIX = ''

# Generates a hosts file
hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'])

#def common_settings(node, config, name)
#      # Disable default vagrant folder
#      # Note: comment out the following line to have a shared folder but you
#      # will be prompted for the root password of the host machine to configure
#      # your NFS server
#      node.vm.synced_folder ".", "/vagrant", disabled: true
#
#      node.vm.hostname = name
#
#      # Ceph has three networks
#      networks = config[CONFIGURATION]['nodes'][name]
#      node.vm.network :private_network, ip: networks['management']
#      node.vm.network :private_network, ip: networks['public']
#      node.vm.network :private_network, ip: networks['cluster']
#end
#
#def libvirt_settings(provider, config, name)
#        provider.host = 'localhost'
#        provider.username = 'root'
#
#
#        # Use DSA key if available, otherwise, defaults to RSA
#        provider.id_ssh_key_file = 'id_dsa' if File.exists?("#{ENV['HOME']}/.ssh/id_dsa")
#        provider.connect_via_ssh = true
#
#        # Libvirt pool and prefix value
#        provider.storage_pool_name = 'default'
#        #l.default_prefix = ''
#
#        # Memory defaults to 512M, allow specific configurations 
#        unless (config[CONFIGURATION]['memory'].nil?) then
#          unless (config[CONFIGURATION]['memory'][name].nil?) then
#            provider.memory = config[CONFIGURATION]['memory'][name]
#          end
#        end
#
#        # Set cpus to 2, allow specific configurations
#        unless (config[CONFIGURATION]['cpu'].nil?) then
#          provider.cpus = config[CONFIGURATION]['cpu'][name] || 2
#        end
#
#        # Raw disk images to simulate additional drives on data nodes
#        unless (config[CONFIGURATION]['disks'].nil?) then
#          unless (config[CONFIGURATION]['disks'][name].nil?) then
#            disks = config[CONFIGURATION]['disks'][name]
#            unless (disks['hds'].nil?) then
#              (1..disks['hds']).each do |d|
#                provider.storage :file, size: '2G', type: 'raw'
#              end
#            end
#            unless (disks['ssds'].nil?) then
#              (1..disks['ssds']).each do |d|
#                provider.storage :file, size: '1G', type: 'raw'
#              end
#            end
#          end
#        end
#
#end
#
#def virtbox_settings(provider, config, name)
#        unless (config[CONFIGURATION]['memory'].nil?) then
#          unless (config[CONFIGURATION]['memory'][name].nil?) then
#            provider.customize [ "modifyvm", :id, "--memory", 
#                           config[CONFIGURATION]['memory'][name] ]
#          end
#        end
#        unless (config[CONFIGURATION]['cpu'].nil?) then
#          provider.cpus = config[CONFIGURATION]['cpu'][name] || 2
#        end
#
#        # Default interfaces will be eth0, eth1, eth2 and eth3
#        provider.customize [ "modifyvm", :id, "--nictype1", "virtio" ]
#        provider.customize [ "modifyvm", :id, "--nictype2", "virtio" ]
#        provider.customize [ "modifyvm", :id, "--nictype3", "virtio" ]
#        provider.customize [ "modifyvm", :id, "--nictype4", "virtio" ]
#
#        unless (config[CONFIGURATION]['disks'].nil?) then
#          unless (config[CONFIGURATION]['disks'][name].nil?) then
#            disks = config[CONFIGURATION]['disks'][name]
#            FileUtils.mkdir_p("#{Dir.home}/disks")
#            unless (disks['hds'].nil?) then
#              (1..disks['hds']).each do |d|
#                file = "#{Dir.home}/disks/#{name}-#{d}"
#                provider.customize [ "createhd", "--filename", file, "--size", "1100" ]
#                provider.customize [ "storageattach", :id, "--storagectl", "SCSI Controller", 
#                               "--port", d, 
#                               "--device", 0, 
#                               "--type", "hdd", 
#                               "--medium", file + ".vdi" ]
#              end
#            end
#            unless (disks['ssds'].nil?) then
#              (1..disks['ssds']).each do |d|
#                file = "#{Dir.home}/disks/#{name}-#{d}"
#                provider.customize [ "createhd", "--filename", file, "--size", "1000" ]
#                provider.customize [ "storageattach", :id, "--storagectl", "SCSI Controller", 
#                               "--port", d, 
#                               "--device", 0, 
#                               "--type", "hdd", 
#                               "--medium", file + ".vdi" ]
#              end
#            end
#          end
#        end
#
#end
 
def provisioning(hosts, node, config, name)
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

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = BOX

  # Keep admin at the end for provisioning
  nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'} 

  nodes.each do |name|
    vm_name = PREFIX + name

    vconfig.vm.define vm_name do |node|
      common_settings(node, config, name)

      node.vm.provider :libvirt do |l|
        libvirt_settings(l, config, name)
      end

      node.vm.provider :virtualbox do |vb|
        virtbox_settings(vb, config, name)
      end

      provisioning(hosts, node, config, name)

    end
  end

  # Appending admin to the nodes array does *not* guarantee that admin
  # will provision last
  name = "admin"
  vm_name = PREFIX + "admin"

  vconfig.vm.define vm_name do |node|
    common_settings(node, config, name)

    node.vm.provider :libvirt do |l|
      libvirt_settings(l, config, name)
    end

    node.vm.provider :virtualbox do |vb|
      virtbox_settings(vb, config, name)
    end

    provisioning(hosts, node, config, name)

  end
   
end

