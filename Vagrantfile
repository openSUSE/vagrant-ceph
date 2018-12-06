# -*- mode: ruby -*- # vi: set ft=ruby :

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

### take BOX from the enviroment ###
BOX = ENV.has_key?('BOX') ? ENV['BOX'] : 'opensuse/openSUSE-42.3-x86_64'

# Set BOX to one of 'openSUSE-13.2', 'Tumbleweed', 'SLE-12'
#BOX = 'opensuse/openSUSE-42.2-x86_64'
#BOX = 'SLE12-SP2-migration'
#BOX = 'SLE12-SP3-qa'
#BOX = 'SUSE/SLE-12-SP3'
#BOX = 'SUSE/SLE-15-SP1'
#BOX = 'opensuse/openSUSE-Tumbleweed-x86_64'
#BOX = 'opensuse/openSUSE-42.3-x86_64'
#BOX = 'opensuse/openSUSE-15.0-x86_64'


# Set INSTALLATION to one of 'ceph-deploy', 'salt'
INSTALLATION = 'salt'

# Set CONFIGURATION to one of 'default', 'small', 'iscsi' or 'economical'
#CONFIGURATION = 'default'
CONFIGURATION = 'tiny'
#CONFIGURATION = 'dataonmon'

raise "Box #{BOX} missing from config.yml" unless config[BOX]
raise "Installation #{INSTALLATION} missing for box #{BOX} from config.yml" unless config[BOX][INSTALLATION]
raise "Configuration #{CONFIGURATION} missing from config.yml" unless config[CONFIGURATION]

# Set PREFIX for additional sets of VMs in libvirt from a separate directory
# (e.g. vagrant-ceph is default, vsm is another git clone with PREFIX='v'
# hostnames will be 'vadmin', 'vmon1', etc.  Both sets use same address range
# and cannot run simultaneously.  Each set will consume disk space. )
PREFIX = ''

# Generates a hosts file
if (INSTALLATION == 'salt') then
  hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'], 
                             selected = 'public', domain='ceph', 
                             aliases={ 'admin' => 'salt' })
elsif (INSTALLATION == 'openattic') then
  hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'], 
                             selected = 'public', domain='ceph')
else
  hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'])
end

def provisioned?(vm_name='default', provider='libvirt')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def provisioning(hosts, node, config, name)
      # Update /etc/hosts on each node
      hosts.update(node)

      # Allow passwordless root access between nodes
      keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      if (name == 'admin') then
         # puts "authorize dummy"
          keys.authorize 
      end

      # Add missing repos
      repos = Vagrant::Repos.new(node, config[BOX][INSTALLATION]['repos'])
      if ENV.has_key?("CLEAN_ZYPPER_REPOS") or !provisioned?(name)
        repos.clean
      end
      repos.add
      #
      # Add SUSEConnect repos
      suseconnect = Vagrant::SUSEConnect.new(node, config[BOX][INSTALLATION]['register'])
      suseconnect.add

      # Copy custom files 
      files = Vagrant::Files.new(node, INSTALLATION, name, 
                                 config[BOX][INSTALLATION]['files'], BOX, CONFIGURATION)
      files.copy

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, name, 
                                   config[BOX][INSTALLATION]['packages'])
      pkgs.install

      # Run commands
      commands = Vagrant::Commands.new(node, name, 
                                       config[BOX][INSTALLATION]['commands'])
      commands.run

end

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = BOX

  # workaround to skip key replacement, as it could hang with vagrant 1.8.7
  vconfig.ssh.insert_key = false

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

