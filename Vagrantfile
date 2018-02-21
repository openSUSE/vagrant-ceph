# -*- mode: ruby -*- # vi: set ft=ruby :

require "yaml"
require "pp"


require_relative "lib/settings.rb"
require_relative "lib/provisions.rb"


# create config and default, merge both.
default_config_file =  "config/default.yml"
default_config = YAML.load_file(default_config_file)

# Set PREFIX for additional sets of VMs in libvirt from a separate directory
# (e.g. vagrant-ceph is default, vsm is another git clone with PREFIX='v'
# hostnames will be 'vadmin', 'vmon1', etc.  Both sets use same address range
# and cannot run simultaneously.  Each set will consume disk space. )
PREFIX = ''

# Generates a hosts file
# if (INSTALLATION == 'salt') then
#   hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'],
#                              selected = 'public', domain='ceph',
#                              aliases={ 'admin' => 'salt' })
# elsif (INSTALLATION == 'openattic') then
#   hosts = Vagrant::Hosts.new(config[CONFIGURATION]['nodes'],
#                              selected = 'public', domain='ceph')
if File.exists?("#{ENV['VC_CONFIG']}")
    config_file = "#{ENV['VC_CONFIG']}"
    user_config = YAML.load_file(config_file)
else
    user_config = {}
end

config = default_config.merge(user_config)

def provisioned?(vm_name='default', provider='libvirt')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def provisioning(node, config, name)

      # Allow passwordless root access between nodes
      # keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      # if (name == 'admin') then
         # puts "authorize dummy"
          # keys.authorize
      # end
      # Run prep-commands
      commands = Vagrant::Commands.new(node, name, config["prep-commands"])
      commands.run

      # Add missing repos
      repos = Vagrant::Repos.new(node, config['repos'])
      repos.add
      #
      # Add SUSEConnect repos
      # suseconnect = Vagrant::SUSEConnect.new(node, config[BOX][INSTALLATION]['register'])
      # suseconnect.add

      # Copy custom files
      # files = Vagrant::Files.new(node, INSTALLATION, name,
                                 # config[BOX][INSTALLATION]['files'], BOX, CONFIGURATION)
      # files.copy
      # Copy custom files
      # files = Vagrant::Files.new(node, name, config["files"])
      # files.copy

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, name, config["packages"])
      pkgs.install

      # Run commands
      commands = Vagrant::Commands.new(node, name, config["commands"])
      commands.run

end

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = config["box"]

  # workaround to skip key replacement, as it could hang with vagrant 1.8.7
  # vconfig.ssh.insert_key = false

  # Keep admin at the end for provisioning
  # nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'}
  nodes = config["nodes"]

  nodes.each_key do |name|
    vm_name = name

    vconfig.vm.define vm_name do |node|
      common_settings(node, config, name)

      node.vm.provider :libvirt do |l|
        libvirt_settings(l, config, name)
      end

      provisioning(node, config, name)

    end
  end

end
