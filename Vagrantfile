# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'yaml'
require 'pp'


require_relative 'lib/settings.rb'
require_relative 'lib/provisions.rb'

config_file = 'config.yml'
config = YAML.load_file(config_file)

# Set BOX to one of 'openSUSE-13.2', 'Tumbleweed', 'SLE-12'
BOX = 'SLE12SP2'

# Set INSTALLATION to one of 'ceph-deploy', 'vsm', 'salt'
INSTALLATION = 'salt'

# Set CONFIGURATION to one of 'default', 'small', 'iscsi' or 'economical'
CONFIGURATION = 'default'

raise "Box #{BOX} missing from config.yml" unless config[BOX]
raise "Installation #{INSTALLATION} missing for box #{BOX} from config.yml" unless config[BOX][INSTALLATION]
raise "Configuration #{CONFIGURATION} missing from config.yml" unless config[CONFIGURATION]

def provisioned?(vm_name='default', provider='libvirt')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def provisioning(node, config, name)

      # Allow passwordless root access between nodes
      # keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      # keys.authorize

      # Add missing repos
      repos = Vagrant::Repos.new(node, config[BOX][INSTALLATION]['repos'])
      if ENV.has_key?("CLEAN_ZYPPER_REPOS") or !provisioned?(name)
        repos.clean
      end
      repos.add

      # Copy custom files
      files = Vagrant::Files.new(node, INSTALLATION, name,
                                 config[BOX][INSTALLATION]['files'])
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

  # Keep admin at the end for provisioning
  nodes = config[CONFIGURATION]['nodes'].keys.reject{|i| i == 'admin'}

  nodes.each do |name|
    vm_name = name

    vconfig.vm.define vm_name do |node|
      common_settings(node, config, name)

      node.vm.provider :libvirt do |l|
        libvirt_settings(l, config, name)
      end

      node.vm.provider :virtualbox do |vb|
        virtbox_settings(vb, config, name)
      end

      provisioning(node, config, name)

    end
  end

  # Appending admin to the nodes array does *not* guarantee that admin
  # will provision last
  name = "admin"
  vm_name = "admin"

  vconfig.vm.define vm_name do |node|
    common_settings(node, config, name)

    node.vm.provider :libvirt do |l|
      libvirt_settings(l, config, name)
    end

    node.vm.provider :virtualbox do |vb|
      virtbox_settings(vb, config, name)
    end

    provisioning(node, config, name)

  end

end

