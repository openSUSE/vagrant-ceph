# -*- mode: ruby -*-
# vi: set ft=ruby :

require "yaml"
require "pp"


require_relative "lib/settings.rb"
require_relative "lib/provisions.rb"


# create config and default, merge both.
config_file =  File.exists?("#{ENV['VC_CONFIG']}") : "#{ENV['VC_CONFIG']}"? "config/default.yml"
config = YAML.load_file(config_file)

def provisioned?(vm_name='default', provider='libvirt')
  File.exist?(".vagrant/machines/#{vm_name}/#{provider}/action_provision")
end

def provisioning(node, config, name)

      # Allow passwordless root access between nodes
      # keys = Vagrant::Keys.new(node, config[CONFIGURATION]['nodes'].keys)
      # keys.authorize

      # Add missing repos
      repos = Vagrant::Repos.new(node, config['repos'])
      if ENV.has_key?("CLEAN_ZYPPER_REPOS") or !provisioned?(name)
        repos.clean
      end
      repos.add

      # Copy custom files
      files = Vagrant::Files.new(node, name,
                                 config["files"])
      files.copy

      # Install additional/unique packages
      pkgs = Vagrant::Packages.new(node, name,
                                   config["packages"])
      pkgs.install

      # Run commands
      commands = Vagrant::Commands.new(node, name,
                                       config["commands"])
      commands.run

end

Vagrant.configure("2") do |vconfig|
  vconfig.vm.box = config["box"]

  nodes = config["nodes"]

  nodes.each do |name|
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

